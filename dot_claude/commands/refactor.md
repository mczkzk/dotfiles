---
description: Perform refactoring on <target>
argument-hint: <target: what to refactor like "files changed since main" or "xxx.ts too long">
allowed-tools:
  - Read
  - Edit
  - MultiEdit
  - Glob
  - Grep
  - Bash(test:*, lint:*, build:*)
  - mcp__ide__getDiagnostics
---

# Refactor Command

Apply refactoring techniques through natural language requests.

## Safety Requirements

⚠️ **MANDATORY before refactoring:**
- Tests exist and pass (`npm test`, `pytest`, etc.)
- Clean git status (committed changes)
- Can rollback easily

## Process

### 1. Pre-Check
- Read target files
- Run tests (must be green)
- Check git status (must be clean)

### 2. Refactoring Techniques

Select appropriate technique(s) based on the description:

**Extraction & Splitting**
- Extract Method - 長いメソッドを分割
- Extract Class - 責務が多いクラスを分割
- Extract + Move Method - 重複コードを統合

**Naming & Clarity**
- Rename Variable/Method/Class - 不明瞭な命名を改善
- Replace Magic Number with Constant - マジックナンバーに名前をつける

**Conditionals & Control Flow**
- Guard Clauses - 早期リターンで条件をフラット化
- Decompose Conditional - 複雑な条件式を分解
- Replace Conditional with Polymorphism - 型による分岐をOOPに
- Remove Flag Argument - フラグ引数を別メソッドに

**Parameters & Data**
- Introduce Parameter Object - 多すぎる引数をオブジェクトに
- Replace Primitive with Object - プリミティブを値オブジェクトに
- Extract Class (Data Clump) - 一緒に使うデータをまとめる

**Encapsulation & Moving**
- Move Method/Field - 責務が違う場所に移動
- Encapsulate Field - 直接アクセスをgetter/setterに
- Move Method (Feature Envy) - 他クラスを多用するメソッドを移動

**Visibility & Scope**
- Remove Unused Public - 外部から使われていないpublic APIを削除
- Minimize Public Surface - 内部実装の公開を最小化
- Consolidate Exports - バラバラのexport/publicをまとめる

**Inheritance & Abstraction**
- Extract Superclass/Interface - サブクラス間の共通コードを抽出
- Replace Inheritance with Delegation - 不適切な継承を委譲に

**Simplification & Cleanup**
- Inline Method/Class - 過剰な抽象化を戻す
- Remove Dead Code - 未使用コードを削除
- Replace Temp with Query - 一時変数をメソッド呼び出しに
- Separate Query from Modifier - 副作用と参照を分離
- Avoid Unnecessary Complexity - 冗長な間接参照や不要なステップを避ける
- Consolidate Duplicate Definitions - 既存の定義と重複するものを統合

**Performance Optimization**
- Replace Loop Lookup with Map/Set - ループ内の線形探索をO(1)アクセスに
- Cache Repeated Queries - 繰り返し計算される値をキャッシュ

**Type Safety**
- Add Type Definitions - 型定義が可能なら追加（JS→TS、any→具体型、JSDoc型注釈など）

**Comments & Documentation**
- Remove Unnecessary Comments - What説明・自明なコメント・コメントアウトは削除、Whyのみ残す
- Verify Doc Accuracy - ドキュメントと実装の整合性を検証

**Git-Based**
- Analyze git diff - ブランチ間の差分を分析してリファクタ

### 3. Micro-Cycle (Repeat)
1. **Small change** (one technique, one location)
2. **Test** (must stay green)
3. **Commit** (enable rollback)

### 4. Complete
- Run full test suite
- Run linting/type check
- Verify improved readability

## Key Principles

- **Small steps** - One change at a time
- **Always green** - Tests pass after each step  
- **Reversible** - Easy rollback at any point
- **Behavior preservation** - External behavior unchanged

