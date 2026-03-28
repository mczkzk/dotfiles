#!/bin/bash
#
# JIRA チケット情報を取得して .claude/tasks/{ISSUE_KEY}/jira.md に保存
#
# Usage: jira-fetch.sh PROJ-100 [PROJ-101 PROJ-102 ...]
#

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# プロジェクトルートを git から取得
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [[ -z "$PROJECT_ROOT" ]]; then
    echo "Error: Not inside a git repository"
    exit 1
fi

# 環境変数読み込み (~/.claude/.jira.env を共通で使用)
ENV_FILE="$HOME/.claude/.jira.env"
if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: $ENV_FILE not found"
    echo "Create it with:"
    echo "  JIRA_DOMAIN=your-domain.atlassian.net"
    echo "  JIRA_EMAIL=your-email@example.com"
    echo "  JIRA_API_TOKEN=your-api-token"
    exit 1
fi

source "$ENV_FILE"

# 必須環境変数チェック
: "${JIRA_DOMAIN:?JIRA_DOMAIN is required}"
: "${JIRA_EMAIL:?JIRA_EMAIL is required}"
: "${JIRA_API_TOKEN:?JIRA_API_TOKEN is required}"

# 引数チェック
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <ISSUE_KEY> [ISSUE_KEY ...]"
    echo "Example: $0 PROJ-826"
    echo "Example: $0 PROJ-826 PROJ-827 PROJ-828"
    exit 1
fi

BASE_URL="https://${JIRA_DOMAIN}/rest/api/3"
AUTH=$(echo -n "${JIRA_EMAIL}:${JIRA_API_TOKEN}" | base64)

fetch_issue() {
    local ISSUE_KEY="$1"

    echo "Fetching ${ISSUE_KEY}..."

    RESPONSE=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Basic ${AUTH}" \
        -H "Accept: application/json" \
        "${BASE_URL}/issue/${ISSUE_KEY}?fields=summary,status,assignee,description,created,updated,attachment,comment,issuelinks,subtasks,parent")

    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')

    if [[ "$HTTP_CODE" != "200" ]]; then
        echo "Error: HTTP ${HTTP_CODE} for ${ISSUE_KEY}"
        echo "$BODY" | jq -r '.errorMessages[]?' 2>/dev/null || echo "$BODY"
        return 1
    fi

    # JSONからデータ抽出
    KEY=$(echo "$BODY" | jq -r '.key')
    SUMMARY=$(echo "$BODY" | jq -r '.fields.summary // "N/A"')
    STATUS=$(echo "$BODY" | jq -r '.fields.status.name // "N/A"')
    ASSIGNEE=$(echo "$BODY" | jq -r '.fields.assignee.displayName // "未割当"')
    CREATED=$(echo "$BODY" | jq -r '.fields.created // "N/A"' | cut -d'T' -f1)
    UPDATED=$(echo "$BODY" | jq -r '.fields.updated // "N/A"' | cut -d'T' -f1)

    # Description (ADF形式からテキスト抽出 - 再帰的にパース)
    DESCRIPTION=$(echo "$BODY" | jq -r '
def repeat_char(c; n): if n <= 0 then "" else (c + repeat_char(c; n-1)) end;

def extract_text:
    if type == "array" then
        map(extract_text) | join("")
    elif type == "object" then
        if .type == "text" then
            .text // ""
        elif .type == "hardBreak" then
            "\n"
        elif .type == "mention" then
            "@" + (.attrs.text // "user")
        elif .type == "inlineCard" then
            "[link](" + (.attrs.url // "") + ")"
        elif .type == "emoji" then
            .attrs.shortName // ""
        elif .content then
            (.content | extract_text)
        else
            ""
        end
    else
        ""
    end;

def convert_node($indent):
    if .type == "paragraph" then
        (.content | extract_text) + "\n"
    elif .type == "heading" then
        repeat_char("#"; .attrs.level // 1) + " " + (.content | extract_text) + "\n"
    elif .type == "bulletList" then
        ([.content[]? | $indent + "- " + (. | convert_node($indent + "    ") | rtrimstr("\n"))] | join("\n")) + "\n"
    elif .type == "orderedList" then
        ([.content[]? | $indent + "1. " + (. | convert_node($indent + "    ") | rtrimstr("\n"))] | join("\n")) + "\n"
    elif .type == "listItem" then
        ([.content[]? | convert_node($indent)] | join("") | rtrimstr("\n"))
    elif .type == "codeBlock" then
        "```\n" + (.content | extract_text) + "```\n"
    elif .type == "blockquote" then
        ([.content[]? | "> " + (. | convert_node($indent) | rtrimstr("\n"))] | join("\n")) + "\n"
    elif .type == "rule" then
        "---\n"
    elif .type == "mediaSingle" or .type == "mediaGroup" then
        "![MEDIA:" + (.content[0]?.attrs.id // "unknown") + ":" + (.content[0]?.attrs.alt // "") + "]\n"
    elif .type == "table" then
        "[テーブル]\n"
    elif .type == "expand" then
        "<details>\n<summary>" + (.attrs.title // "詳細") + "</summary>\n\n" + ([.content[]? | convert_node($indent)] | join("")) + "</details>\n"
    elif .type == "panel" then
        "> **" + (.attrs.panelType // "info") + "**\n" + ([.content[]? | "> " + (convert_node($indent) | rtrimstr("\n"))] | join("\n")) + "\n"
    else
        ""
    end;

if .fields.description then
    [.fields.description.content[]? | convert_node("")] | join("\n") | gsub("\n\n\n+"; "\n\n") | rtrimstr("\n")
else
    "説明なし"
end
' || echo "説明なし")

    # メディア参照を実際のファイル名に置換
    ID_FILENAME_MAP=$(echo "$BODY" | jq -r '
        [.fields.description | .. | objects | select(.type == "media" and .attrs.alt) | {id: .attrs.id, filename: .attrs.alt}] |
        unique_by(.id) | .[] | "\(.id)\t\(.filename)"
    ')

    while IFS=$'\t' read -r media_id alt_name; do
        if [[ -n "$media_id" ]]; then
            if [[ -n "$alt_name" ]]; then
                filename="$alt_name"
            else
                filename=$(echo "$ID_FILENAME_MAP" | grep "^${media_id}" | cut -f2)
            fi
            if [[ -n "$filename" ]]; then
                escaped_id=$(echo "$media_id" | sed 's/[[\.*^$()+?{|]/\\&/g')
                escaped_alt=$(echo "$alt_name" | sed 's/[[\.*^$()+?{|]/\\&/g')
                DESCRIPTION=$(echo "$DESCRIPTION" | sed "s|\!\[MEDIA:${escaped_id}:${escaped_alt}\]|![$filename](./images/$filename)|g")
            fi
        fi
    done < <(echo "$BODY" | jq -r '
        [.fields.description | .. | objects | select(.type == "media") | {id: .attrs.id, alt: (.attrs.alt // "")}] | .[] | "\(.id)\t\(.alt)"
    ')

    # 出力ディレクトリ作成
    OUTPUT_DIR="$PROJECT_ROOT/.claude/tasks/${KEY}"
    mkdir -p "$OUTPUT_DIR"

    # 画像ダウンロード
    IMAGE_DIR="$OUTPUT_DIR/images"
    ATTACHMENT_COUNT=$(echo "$BODY" | jq '[.fields.attachment[]? | select(.mimeType | startswith("image/"))] | length')

    if [[ "$ATTACHMENT_COUNT" -gt 0 ]]; then
        mkdir -p "$IMAGE_DIR"
        echo "Downloading ${ATTACHMENT_COUNT} images..."

        echo "$BODY" | jq -r '.fields.attachment[]? | select(.mimeType | startswith("image/")) | "\(.content)\t\(.filename)"' | while IFS=$'\t' read -r url filename; do
            if [[ -n "$url" && -n "$filename" ]]; then
                echo "  - ${filename}"
                curl -s -L \
                    -H "Authorization: Basic ${AUTH}" \
                    -o "${IMAGE_DIR}/${filename}" \
                    "$url"
            fi
        done
    fi

    # コメント取得 (ADF形式からテキスト抽出)
    COMMENTS=$(echo "$BODY" | jq -r '
def repeat_char(c; n): if n <= 0 then "" else (c + repeat_char(c; n-1)) end;

def extract_text:
    if type == "array" then
        map(extract_text) | join("")
    elif type == "object" then
        if .type == "text" then
            .text // ""
        elif .type == "hardBreak" then
            "\n"
        elif .type == "mention" then
            "@" + (.attrs.text // "user")
        elif .type == "inlineCard" then
            "[link](" + (.attrs.url // "") + ")"
        elif .type == "emoji" then
            .attrs.shortName // ""
        elif .content then
            (.content | extract_text)
        else
            ""
        end
    else
        ""
    end;

def convert_node($indent):
    if .type == "paragraph" then
        (.content | extract_text) + "\n"
    elif .type == "heading" then
        repeat_char("#"; .attrs.level // 1) + " " + (.content | extract_text) + "\n"
    elif .type == "bulletList" then
        ([.content[]? | $indent + "- " + (. | convert_node($indent + "    ") | rtrimstr("\n"))] | join("\n")) + "\n"
    elif .type == "orderedList" then
        ([.content[]? | $indent + "1. " + (. | convert_node($indent + "    ") | rtrimstr("\n"))] | join("\n")) + "\n"
    elif .type == "listItem" then
        ([.content[]? | convert_node($indent)] | join("") | rtrimstr("\n"))
    elif .type == "codeBlock" then
        "```\n" + (.content | extract_text) + "```\n"
    elif .type == "blockquote" then
        ([.content[]? | "> " + (. | convert_node($indent) | rtrimstr("\n"))] | join("\n")) + "\n"
    elif .type == "rule" then
        "---\n"
    elif .type == "mediaSingle" or .type == "mediaGroup" then
        "![MEDIA:" + (.content[0]?.attrs.id // "unknown") + ":" + (.content[0]?.attrs.alt // "") + "]\n"
    elif .type == "table" then
        "[テーブル]\n"
    elif .type == "expand" then
        "<details>\n<summary>" + (.attrs.title // "詳細") + "</summary>\n\n" + ([.content[]? | convert_node($indent)] | join("")) + "</details>\n"
    elif .type == "panel" then
        "> **" + (.attrs.panelType // "info") + "**\n" + ([.content[]? | "> " + (convert_node($indent) | rtrimstr("\n"))] | join("\n")) + "\n"
    else
        ""
    end;

if .fields.comment.comments and (.fields.comment.comments | length) > 0 then
    [.fields.comment.comments[] |
        "### " + .author.displayName + " (" + (.created | split("T")[0]) + ")\n\n" +
        ([.body.content[]? | convert_node("")] | join("\n") | gsub("\n\n\n+"; "\n\n") | rtrimstr("\n"))
    ] | join("\n\n---\n\n")
else
    "コメントなし"
end
')

    # コメント内のメディア参照を実際のファイル名に置換
    while IFS=$'\t' read -r media_id alt_name; do
        if [[ -n "$media_id" ]]; then
            if [[ -n "$alt_name" ]]; then
                filename="$alt_name"
            else
                filename=$(echo "$ID_FILENAME_MAP" | grep "^${media_id}" | cut -f2)
            fi
            if [[ -n "$filename" ]]; then
                escaped_id=$(echo "$media_id" | sed 's/[[\.*^$()+?{|]/\\&/g')
                escaped_alt=$(echo "$alt_name" | sed 's/[[\.*^$()+?{|]/\\&/g')
                COMMENTS=$(echo "$COMMENTS" | sed "s|\!\[MEDIA:${escaped_id}:${escaped_alt}\]|![$filename](./images/$filename)|g")
            fi
        fi
    done < <(echo "$BODY" | jq -r '
        [.fields.comment.comments[]?.body | .. | objects | select(.type == "media") | {id: .attrs.id, alt: (.attrs.alt // "")}] | .[] | "\(.id)\t\(.alt)"
    ')

    # 親チケット
    PARENT=$(echo "$BODY" | jq -r '
        if .fields.parent then
            "- **親チケット**: [" + .fields.parent.key + "] " + (.fields.parent.fields.summary // "N/A") + " (" + (.fields.parent.fields.status.name // "N/A") + ")"
        else
            ""
        end
    ')

    # サブタスク
    SUBTASKS=$(echo "$BODY" | jq -r '
        if .fields.subtasks and (.fields.subtasks | length) > 0 then
            [.fields.subtasks[] |
                "- [" + .key + "] " + (.fields.summary // "N/A") + " (" + (.fields.status.name // "N/A") + ")"
            ] | join("\n")
        else
            ""
        end
    ')

    # 関連チケット (issuelinks)
    ISSUELINKS=$(echo "$BODY" | jq -r '
        if .fields.issuelinks and (.fields.issuelinks | length) > 0 then
            [.fields.issuelinks[] |
                if .outwardIssue then
                    "- **" + .type.outward + "**: [" + .outwardIssue.key + "] " + (.outwardIssue.fields.summary // "N/A") + " (" + (.outwardIssue.fields.status.name // "N/A") + ")"
                elif .inwardIssue then
                    "- **" + .type.inward + "**: [" + .inwardIssue.key + "] " + (.inwardIssue.fields.summary // "N/A") + " (" + (.inwardIssue.fields.status.name // "N/A") + ")"
                else
                    empty
                end
            ] | join("\n")
        else
            ""
        end
    ')

    # 関連情報セクション構築
    RELATIONS=""
    if [[ -n "$PARENT" ]]; then
        RELATIONS="${PARENT}"$'\n'
    fi
    if [[ -n "$SUBTASKS" ]]; then
        RELATIONS="${RELATIONS}"$'\n'"### サブタスク"$'\n'"${SUBTASKS}"$'\n'
    fi
    if [[ -n "$ISSUELINKS" ]]; then
        RELATIONS="${RELATIONS}"$'\n'"### リンク"$'\n'"${ISSUELINKS}"$'\n'
    fi

    # Markdown出力
    OUTPUT_FILE="$OUTPUT_DIR/jira.md"
    cat > "$OUTPUT_FILE" << EOF
# ${KEY}

## 基本情報
- **ステータス**: ${STATUS}
- **担当者**: ${ASSIGNEE}
- **作成日**: ${CREATED}
- **更新日**: ${UPDATED}

## タイトル
${SUMMARY}

## 関連チケット
${RELATIONS:-関連チケットなし}

## 説明
${DESCRIPTION}

## コメント
${COMMENTS}
EOF

    echo "Saved to: ${OUTPUT_FILE}"
}

# 全引数を処理
SUCCESS_COUNT=0
FAIL_COUNT=0

for ISSUE_KEY in "$@"; do
    if fetch_issue "$ISSUE_KEY"; then
        ((SUCCESS_COUNT++))
    else
        ((FAIL_COUNT++))
    fi
    echo ""
done

echo "Done: ${SUCCESS_COUNT} succeeded, ${FAIL_COUNT} failed"
