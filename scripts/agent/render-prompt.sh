#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/agent/render-prompt.sh <mode> <prompt-file>

Modes:
  operating-loop
  diff-review
  session-postmortem
  knowledge-compile

Environment:
  AGENT_OUT=<file>  Write rendered prompt bundle to a file instead of stdout.
  TASK=<text>       Optional user task/request to include in the bundle.
EOF
}

mode="${1:-}"
prompt_file="${2:-}"

if [[ -z "$mode" || -z "$prompt_file" ]]; then
  usage >&2
  exit 2
fi

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  echo "render-prompt: run inside a git repository" >&2
  exit 1
fi

cd "$repo_root"

if [[ ! -f "$prompt_file" ]]; then
  echo "render-prompt: missing prompt file: $prompt_file" >&2
  exit 1
fi

section_file() {
  local title="$1"
  local path="$2"

  printf '\n## %s\n\n' "$title"
  if [[ -f "$path" ]]; then
    printf '```text\n'
    sed -n '1,220p' "$path"
    printf '\n```\n'
  else
    printf '_Missing: `%s`_\n' "$path"
  fi
}

section_cmd() {
  local title="$1"
  shift

  printf '\n## %s\n\n' "$title"
  printf 'Command: `%s`\n\n' "$*"
  printf '```text\n'
  "$@" 2>&1 || true
  printf '\n```\n'
}

render_common() {
  printf '# Agent Workflow Bundle\n'
  printf '\nGenerated from `%s` using `%s` mode.\n' "$prompt_file" "$mode"
  if [[ -n "${TASK:-}" ]]; then
    printf '\n## User Task\n\n'
    printf '```text\n%s\n```\n' "$TASK"
  fi
  section_file "Prompt" "$prompt_file"
  section_file "Root Instructions" "AGENTS.md"
}

render_operating_loop() {
  render_common
  section_file "Current Session Notes" ".codex/session-notes/current.md"
  section_file "Roadmap" "docs/roadmap.md"
  section_file "Codex Workflow" "docs/codex-workflow.md"
  section_file "AI Native Workflow" "docs/ai-native-workflow.md"
  section_file "Task History Index" "docs/task-history/index.md"
  section_file "Troubleshooting Index" "docs/troubleshooting/index.md"
  section_file "Learning Inbox" "docs/learning/inbox.md"
  section_cmd "Git Status" git status --short
  section_cmd "Git Diff Stat" git diff --stat
  section_cmd "Git Diff" git diff
}

render_diff_review() {
  render_common
  section_file "Current Session Notes" ".codex/session-notes/current.md"
  section_cmd "Git Status" git status --short
  section_cmd "Git Diff Stat" git diff --stat
  section_cmd "Git Diff" git diff
}

render_session_postmortem() {
  render_common
  section_file "Current Session Notes" ".codex/session-notes/current.md"
  section_cmd "Git Status" git status --short
  section_cmd "Git Diff Stat" git diff --stat
  section_cmd "Git Diff" git diff
  section_file "Runbook" "docs/runbook.md"
  section_file "Troubleshooting Index" "docs/troubleshooting/index.md"
  section_file "Task History Index" "docs/task-history/index.md"
}

render_knowledge_compile() {
  render_common
  section_cmd "Git Diff Stat" git diff --stat
  section_cmd "Recent Git Log" git log --oneline -5
  section_file "Current Session Notes" ".codex/session-notes/current.md"
  section_file "Roadmap" "docs/roadmap.md"
  section_file "Runbook" "docs/runbook.md"
  section_file "Troubleshooting Index" "docs/troubleshooting/index.md"
  section_file "Learning Inbox" "docs/learning/inbox.md"
  section_file "Task History Index" "docs/task-history/index.md"
}

render() {
  case "$mode" in
    operating-loop)
      render_operating_loop
      ;;
    diff-review)
      render_diff_review
      ;;
    session-postmortem)
      render_session_postmortem
      ;;
    knowledge-compile)
      render_knowledge_compile
      ;;
    *)
      echo "render-prompt: unknown mode: $mode" >&2
      usage >&2
      exit 2
      ;;
  esac
}

if [[ -n "${AGENT_OUT:-}" ]]; then
  mkdir -p "$(dirname "$AGENT_OUT")"
  render >"$AGENT_OUT"
  echo "Wrote agent workflow bundle: $AGENT_OUT"
else
  render
fi
