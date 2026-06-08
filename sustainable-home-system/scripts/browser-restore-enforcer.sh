#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(realpath "$script_dir/..")"
installed_skill_dir="$(realpath "$HOME/.agents/skills/sustainable-home-system" 2>/dev/null || printf '%s' "$HOME/.agents/skills/sustainable-home-system")"

if [ "$skill_dir" != "$installed_skill_dir" ]; then
  printf '%s\n' "Refusing to run from: $skill_dir" >&2
  printf '%s\n' "Use installed skill script: $installed_skill_dir/scripts/browser-restore-enforcer.sh" >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

candidate_prefs=()

add_pref() {
  if [ -f "$1" ]; then
    candidate_prefs+=("$1")
  fi
}

# Explicit override for non-standard Chromium-family installs. Colon-separated list.
if [ -n "${SUSTAINABLE_HOME_BROWSER_PREFS:-}" ]; then
  old_ifs="$IFS"
  IFS=:
  for pref in $SUSTAINABLE_HOME_BROWSER_PREFS; do
    add_pref "$pref"
  done
  IFS="$old_ifs"
fi

# Discover common Chromium-family preference files without assuming one install method.
add_pref "$HOME/.var/app/com.google.Chrome/config/google-chrome/Default/Preferences"
add_pref "$HOME/.config/google-chrome/Default/Preferences"
add_pref "$HOME/.var/app/org.chromium.Chromium/config/chromium/Default/Preferences"
add_pref "$HOME/.config/chromium/Default/Preferences"
add_pref "$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser/Default/Preferences"
add_pref "$HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences"
add_pref "$HOME/.var/app/com.vivaldi.Vivaldi/config/vivaldi/Default/Preferences"
add_pref "$HOME/.config/vivaldi/Default/Preferences"
add_pref "$HOME/.var/app/com.microsoft.Edge/config/microsoft-edge/Default/Preferences"
add_pref "$HOME/.config/microsoft-edge/Default/Preferences"

seen=""
for pref in "${candidate_prefs[@]}"; do
  case ":$seen:" in
    *":$pref:"*) continue ;;
  esac
  seen="$seen:$pref"
  tmp="$pref.sustainable-home-system.tmp"
  jq '.session.restore_on_startup = 1' "$pref" > "$tmp" && mv "$tmp" "$pref"
done
