#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(realpath "$script_dir/..")"
templates_dir="$skill_dir/templates"
timestamp="$(date +%Y%m%dT%H%M%S)"
backup_dir="$HOME/.local/state/sustainable-home-system/backups/$timestamp"
installed_skill_dir="$(realpath "$HOME/.agents/skills/sustainable-home-system" 2>/dev/null || printf '%s' "$HOME/.agents/skills/sustainable-home-system")"

log() {
  printf '%s\n' "$*"
}

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "Missing required command: $1"
    return 1
  fi
}

require_installed_skill() {
  if [ "$skill_dir" != "$installed_skill_dir" ]; then
    printf '%s\n' "Refusing to run from: $skill_dir" >&2
    printf '%s\n' "Install the skill first, then run: $installed_skill_dir/scripts/apply-fedora-kde-home-restore.sh" >&2
    exit 2
  fi
}

backup_file() {
  local path="$1"
  if [ -e "$path" ] || [ -L "$path" ]; then
    local relative="${path#$HOME/}"
    local target="$backup_dir/${relative//\//__}"
    mkdir -p "$backup_dir"
    cp -a "$path" "$target"
    log "Backed up $path -> $target"
  fi
}

install_template() {
  local source="$1"
  local target="$2"
  mkdir -p "$(dirname -- "$target")"
  backup_file "$target"
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line//__HOME__/$HOME}"
    line="${line//__SKILL_DIR__/$skill_dir}"
    printf '%s\n' "$line"
  done < "$source" > "$target"
  log "Installed $target"
}

configure_kde_session_restore() {
  mkdir -p "$HOME/.config"
  if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file ksmserverrc --group General --key loginMode restorePreviousLogout
  else
    backup_file "$HOME/.config/ksmserverrc"
    if [ ! -f "$HOME/.config/ksmserverrc" ]; then
      printf '[General]\nloginMode=restorePreviousLogout\n' > "$HOME/.config/ksmserverrc"
    else
      log "kwriteconfig6 unavailable; verify ~/.config/ksmserverrc manually."
    fi
  fi
  log "Configured KDE previous-session restore"
}

configure_konsole() {
  install_template "$templates_dir/RestorableTmux.profile" "$HOME/.local/share/konsole/RestorableTmux.profile"
  mkdir -p "$HOME/.config"
  if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile RestorableTmux.profile
  else
    backup_file "$HOME/.config/konsolerc"
    printf '\n[Desktop Entry]\nDefaultProfile=RestorableTmux.profile\n' >> "$HOME/.config/konsolerc"
  fi
  log "Configured Konsole default profile"
}

configure_tmux() {
  require tmux
  require git
  mkdir -p "$HOME/.tmux/plugins" "$HOME/.local/state/tmux/logs"
  install_template "$templates_dir/tmux.conf" "$HOME/.tmux.conf"

  if [ ! -d "$HOME/.tmux/plugins/tpm/.git" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi

  "$HOME/.tmux/plugins/tpm/bin/install_plugins" || true
  if tmux new-session -Ad -s main; then
    tmux source-file "$HOME/.tmux.conf" || log "tmux config will finish loading from the next interactive tmux client."
    if [ -x "$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh" ]; then
      "$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh" || log "tmux snapshot save skipped in this non-interactive shell; use Ctrl+b Ctrl+s inside tmux."
    fi
  else
    log "tmux session creation failed in this non-interactive shell; open a terminal and run: tmux new-session -A -s main"
  fi
  log "Configured tmux durable session"
}

configure_tmux_service() {
  install_template "$templates_dir/tmux-main-session" "$HOME/.local/bin/tmux-main-session"
  chmod +x "$HOME/.local/bin/tmux-main-session"
  install_template "$templates_dir/tmux-main.service" "$HOME/.config/systemd/user/tmux-main.service"
  systemctl --user daemon-reload
  systemctl --user enable --now tmux-main.service
  log "Configured tmux login service"
}

configure_browser_restore() {
  if ! command -v jq >/dev/null 2>&1; then
    log "jq unavailable; skipping browser JSON preference updates. Set browser startup restore manually."
    return 0
  fi

  local found=0
  local prefs=(
    "$HOME/.var/app/com.google.Chrome/config/google-chrome/Default/Preferences"
    "$HOME/.config/google-chrome/Default/Preferences"
    "$HOME/.var/app/org.chromium.Chromium/config/chromium/Default/Preferences"
    "$HOME/.config/chromium/Default/Preferences"
    "$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser/Default/Preferences"
    "$HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences"
    "$HOME/.var/app/com.vivaldi.Vivaldi/config/vivaldi/Default/Preferences"
    "$HOME/.config/vivaldi/Default/Preferences"
    "$HOME/.var/app/com.microsoft.Edge/config/microsoft-edge/Default/Preferences"
    "$HOME/.config/microsoft-edge/Default/Preferences"
  )

  for pref in "${prefs[@]}"; do
    if [ -f "$pref" ]; then
      found=1
      backup_file "$pref"
      local tmp="$pref.sustainable-home-system.tmp"
      jq '.session.restore_on_startup = 1' "$pref" > "$tmp"
      mv "$tmp" "$pref"
      log "Configured Chromium-family restore-on-startup in $pref"
    fi
  done

  if [ "$found" = 0 ]; then
    log "No supported browser Preferences file found. Ask which browser the user wants restored and configure that app explicitly."
  fi

  install_template "$templates_dir/sustainable-home-system-browser-restore.desktop" "$HOME/.config/autostart/sustainable-home-system-browser-restore.desktop"

  if pgrep -x chrome >/dev/null 2>&1 || pgrep -x chromium >/dev/null 2>&1; then
    log "A Chromium-family browser is running; it may overwrite Preferences until it exits cleanly. The login autostart enforcer will reapply restore-on-startup before normal browser use."
  fi
}

verify_setup() {
  log ""
  log "Verification:"
  if command -v kreadconfig6 >/dev/null 2>&1; then
    log "KDE loginMode=$(kreadconfig6 --file ksmserverrc --group General --key loginMode 2>/dev/null || true)"
  fi
  if command -v konsole >/dev/null 2>&1; then
    log "Konsole profiles:"
    konsole --list-profiles || true
  fi
  log "tmux sessions:"
  tmux list-sessions || true
  log "tmux continuum interval=$(tmux show-options -gqv @continuum-save-interval 2>/dev/null || true)"
  log "tmux capture pane contents=$(tmux show-options -gqv @resurrect-capture-pane-contents 2>/dev/null || true)"
  log "tmux capture pane area=$(tmux show-options -gqv @resurrect-pane-contents-area 2>/dev/null || true)"
  log "tmux service enabled=$(systemctl --user is-enabled tmux-main.service 2>/dev/null || true)"
  log "tmux service failed=$(systemctl --user is-failed tmux-main.service 2>/dev/null || true)"
  log "Browser restore enforcer=$([ -x "$skill_dir/scripts/browser-restore-enforcer.sh" ] && printf installed || printf missing)"
}

main() {
  require_installed_skill
  log "Applying Sustainable Home System restore setup for Fedora KDE/Bazzite/Kinoite"
  configure_kde_session_restore
  configure_browser_restore
  configure_tmux
  configure_konsole
  configure_tmux_service
  verify_setup
  log "Done"
}

main "$@"
