#!/bin/sh
# tmuxステータスバー用: Claudeの使用率(5時間/7日)を表示する
# Claude Codeのログイン情報(キーチェーン)のOAuthトークンを使う

CACHE="${HOME}/.cache/claude-usage.txt"
NEXT="${HOME}/.cache/claude-usage.next"  # 次にAPIを叩いてよい時刻(epoch)
TTL=300
STALE=900  # これより古いキャッシュは「?」を付けて表示

now=$(date +%s)

show_cache() {
  if [ -f "$CACHE" ]; then
    age=$(( now - $(stat -f %m "$CACHE") ))
    if [ "$age" -ge "$STALE" ]; then
      printf '%s#[fg=colour245]?#[default]\n' "$(cat "$CACHE")"
    else
      cat "$CACHE"
    fi
  else
    echo "#[fg=colour245]CC -#[default]"
  fi
}

# 待機中ならキャッシュを返す (APIを叩きすぎないように)
if [ -f "$NEXT" ] && [ "$now" -lt "$(cat "$NEXT")" ]; then
  show_cache
  exit 0
fi

mkdir -p "$(dirname "$CACHE")"
# 成功・失敗に関わらず、次の取得はTTL後 (失敗時に毎回叩いてレート制限が続くのを防ぐ)
echo $(( now + TTL )) > "$NEXT"

token=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
  | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)

json=""
if [ -n "$token" ]; then
  hdr=$(mktemp)
  json=$(curl -s --max-time 5 -D "$hdr" https://api.anthropic.com/api/oauth/usage \
    -H "Authorization: Bearer ${token}" \
    -H "anthropic-beta: oauth-2025-04-20")
  # 429ならretry-afterの間は待つ
  retry=$(tr -d '\r' < "$hdr" | awk 'tolower($1)=="retry-after:" {print $2}')
  rm -f "$hdr"
  case "$retry" in
    ''|*[!0-9]*) ;;
    *) [ "$retry" -gt "$TTL" ] && echo $(( now + retry )) > "$NEXT" ;;
  esac
fi

out=$(printf '%s' "$json" | jq -r '
  def color: if . >= 90 then "colour196" elif . >= 70 then "colour214" else "colour114" end;
  def reset: .resets_at | sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601 | strflocaltime("%H:%M");
  def item($label): "#[fg=\(.utilization | color)]\($label):\(.utilization | floor)%#[fg=colour245](\(reset))";
  if .five_hour and .seven_day then
    "#[fg=colour245]CC \(.five_hour | item("5h")) \(.seven_day | item("7d"))#[default]"
  else empty end
' 2>/dev/null)

if [ -n "$out" ]; then
  printf '%s\n' "$out" > "$CACHE"
  printf '%s\n' "$out"
else
  # 取得失敗時は前回の値を表示
  show_cache
fi
