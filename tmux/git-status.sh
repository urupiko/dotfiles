#!/bin/sh
# tmuxステータスバー用: カレントペインのディレクトリのgit情報を表示する
# 使い方: git-status.sh <path>  (tmuxからは #{pane_current_path} を渡す)

cd "${1:-.}" 2>/dev/null || exit 0

# porcelain v2 のヘッダ(ブランチ・ahead/behind)とファイル状態をまとめて取得
status=$(git status --porcelain=v2 --branch 2>/dev/null) || exit 0

printf '%s\n' "$status" | awk '
  /^# branch.oid / { oid = substr($3, 1, 7) }
  /^# branch.head / { head = $3 }
  /^# branch.ab /   { ahead = substr($3, 2) + 0; behind = substr($4, 2) + 0 }
  /^[12u] / {
    xy = $2
    if (substr(xy, 1, 1) != ".") staged++
    if (substr(xy, 2, 1) != ".") modified++
  }
  /^\? / { untracked++ }
  END {
    if (head == "(detached)") head = oid
    out = "#[fg=colour141]\356\202\240 " head
    if (ahead)     out = out " #[fg=colour114]↑" ahead
    if (behind)    out = out " #[fg=colour203]↓" behind
    if (staged)    out = out " #[fg=colour114]+" staged
    if (modified)  out = out " #[fg=colour214]~" modified
    if (untracked) out = out " #[fg=colour245]?" untracked
    print out "#[default]"
  }
'
