---
name: video-debug
description: "Extract screenshots from a screen recording video for visual debugging. Use when the user shares a .mov/.mp4 video file path and wants to analyze UI behavior frame by frame."
argument-hint: "<video-path> [fps] (default fps=2, i.e. every 0.5s)"
allowed-tools:
  - Bash
  - Read
  - Glob
---

# Video Debug

Extract frames from a screen recording and display them for visual debugging.

## Process

### 1. Parse Arguments

- `$ARGUMENTS` format: `<video-path> [fps]`
- `fps` defaults to `2` (one frame every 0.5 seconds)
- If `$ARGUMENTS` is empty, ask for the video file path

### 2. Prepare Output Directory

Derive a folder name from the video filename (without extension, spaces replaced with `_`):

```
.claude/debug-frames/<video-name>/
```

Example: `Screen Recording 2026-03-27 at 10.57.03.mov` → `.claude/debug-frames/Screen_Recording_2026-03-27_at_10.57.03/`

- **Delete old frames** in that subdirectory before extracting (use `find ... -name "*.jpg" -delete`, not `rm -rf`)
- `.claude/debug-frames/` is globally gitignored via `~/.config/git/ignore` (chezmoi managed), no per-repo exclude needed

### 3. Extract Frames

```bash
DIR=".claude/debug-frames/<video-name>"
mkdir -p "$DIR"
find "$DIR" -name "*.jpg" -delete
ffmpeg -i "<video-path>" -vf "fps=<fps>" -q:v 2 "$DIR/frame_%03d.jpg" 2>&1 | tail -3
```

Report: total frames extracted, video duration, time per frame.

### 4. Display Frames

- Read **all frames** using the Read tool (they are images, Read can display them)
- For each frame, note the timestamp: `frame N → {(N-1) / fps} seconds`
- If there are more than 20 frames, read every Nth frame to stay under 20, and mention which frames were skipped

### 5. Analyze

After displaying, provide a brief summary of what's visible across the frames:
- What UI state changes are observed
- Any anomalies or bugs visible
- Timeline of events

Do NOT clean up the frames directory after analysis. The user may want to reference them again.
