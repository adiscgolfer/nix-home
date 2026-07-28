#!/usr/bin/env bash
# Claude Code statusLine command
# Mirrors key elements from the user's Starship prompt config
#
# Managed by nix-home (home.file in home-configuration/claude.nix). The
# deployed copy at ~/.claude/statusline-command.sh is a read-only symlink
# into /nix/store — edit this file and run `home-manager switch` instead.

input=$(cat)

# Directory: fish-style abbreviated path (up to 3 components)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
home="$HOME"
# Replace home prefix with ~
display_dir="${cwd/#$home/~}"
# Fish-style: abbreviate all but last 3 path components to first letter
IFS='/' read -ra parts <<< "$display_dir"
total=${#parts[@]}
if [ "$total" -le 4 ]; then
  short_dir="$display_dir"
else
  abbreviated=""
  for ((i=0; i<total-3; i++)); do
    part="${parts[$i]}"
    if [ -n "$part" ]; then
      abbreviated="$abbreviated/${part:0:1}"
    fi
  done
  last_three="${parts[*]: -3}"
  last_three_slashed="${last_three// //}"
  short_dir="$abbreviated/$last_three_slashed"
fi

# Git branch from worktree or repo info
git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

# Dirty working tree indicator
git_dirty=""
if [ -n "$git_branch" ]; then
  if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    git_dirty="*"
  fi
fi

# Worktree name if present
worktree=$(echo "$input" | jq -r '.worktree.name // empty')

# Model display name
model=$(echo "$input" | jq -r '.model.display_name // empty')

# Context used percentage
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Rate limits (Claude.ai subscription usage)
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_hour_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_resets_at=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Convert a resets_at value (unix epoch seconds, or ISO8601 UTC string) to local time
fmt_reset_time() {
  local raw="$1" fmt="$2"
  [ -z "$raw" ] && return
  local clean epoch
  if [[ "$raw" =~ ^[0-9]+$ ]]; then
    epoch="$raw"
  else
    clean=$(echo "$raw" | sed -E 's/\.[0-9]+//; s/\+00:00$//; s/Z$//')
    epoch=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$clean" "+%s" 2>/dev/null) || return
  fi
  date -r "$epoch" "$fmt" 2>/dev/null
}

five_hour_reset_local=$(fmt_reset_time "$five_hour_resets_at" "+%H:%M")
seven_day_reset_local=$(fmt_reset_time "$seven_day_resets_at" "+%a %H:%M")

# Time
now=$(date +%H:%M:%S)

# Build output
parts_out=()

# Directory (bold blue via ANSI)
parts_out+=("$(printf '\033[1;34m%s\033[0m' "$short_dir")")

# Git branch
if [ -n "$git_branch" ]; then
  branch_str="$git_branch$git_dirty"
  if [ -n "$worktree" ]; then
    branch_str="$branch_str ($worktree)"
  fi
  parts_out+=("$(printf '\033[1;36m%s\033[0m' "$branch_str")")
fi

# Model
if [ -n "$model" ]; then
  parts_out+=("$(printf '\033[0;90m%s\033[0m' "$model")")
fi

# Context remaining
if [ -n "$remaining" ]; then
  used_int=$(printf '%.0f' "$(echo "100 - $remaining" | bc)")
  if [ "$used_int" -gt 80 ]; then
    ctx_color='\033[0;31m'  # red when high
  else
    ctx_color='\033[0;90m'  # dim otherwise
  fi
  parts_out+=("$(printf "${ctx_color}ctx:%s%%\033[0m" "$used_int")")
fi

# Rate limits
if [ -n "$five_hour" ] || [ -n "$seven_day" ]; then
  rl_str=""
  if [ -n "$five_hour" ]; then
    rl_str="5h:$(printf '%.0f' "$five_hour")%"
    [ -n "$five_hour_reset_local" ] && rl_str="$rl_str @$five_hour_reset_local"
  fi
  if [ -n "$seven_day" ]; then
    [ -n "$rl_str" ] && rl_str="$rl_str "
    rl_str="${rl_str}7d:$(printf '%.0f' "$seven_day")%"
    [ -n "$seven_day_reset_local" ] && rl_str="$rl_str @$seven_day_reset_local"
  fi
  parts_out+=("$(printf '\033[0;90m%s\033[0m' "$rl_str")")
fi

# Time
parts_out+=("$(printf '\033[1;90mat %s\033[0m' "$now")")

# Join with separators
sep="$(printf '\033[0;90m | \033[0m')"
out=""
for part in "${parts_out[@]}"; do
  if [ -z "$out" ]; then
    out="$part"
  else
    out="$out$sep$part"
  fi
done
printf '%s\n' "$out"
