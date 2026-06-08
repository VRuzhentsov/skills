---
name: sustainable-home-system
description: Configure a resilient Fedora Kinoite/Bazzite/KDE home workstation so terminal sessions, desktop windows, browser tabs, and selected app workspaces recover after accidental closes, logout/login, reboot, or crash as much as Linux realistically allows. Use this skill whenever the user wants a sustainable desktop/home system, worries about losing workflow after reboot, wants KDE session restore, browser tab restore, tmux terminal persistence, or wants to reproduce this setup on another Fedora Atomic machine.
---

# Sustainable Home System

Make a Linux desktop safe to reboot by layering restore mechanisms. This is intended to be useful as a public, portable skill for Fedora KDE users who want less fragile workstation state.

- KDE restores the desktop session and reopens windows where apps support it.
- The user's selected browser restores tabs where the browser supports "continue where you left off".
- Konsole opens into tmux instead of disposable Bash tabs.
- tmux persists terminal windows, panes, directories, and captured output snapshots.
- A user systemd service starts the durable tmux session at login.
- Terminal recovery must preserve the user's visual profile. Do not replace a dark/translucent terminal with a light default profile.

This skill targets Fedora Atomic desktops first: Bazzite and Kinoite on KDE Plasma. Treat other Linux desktops as adaptations of the same model. Keep instructions public-safe: avoid private usernames, machine-specific paths, account details, and personal workflow assumptions unless the current user explicitly asks for them.

## Reality Check

Be explicit about limits:

- A reboot or power loss kills running processes.
- KDE can reopen many windows, but app state depends on each app.
- Browsers can restore tabs, but unsaved form/app state may still depend on each website.
- tmux can restore terminal layout, directories, safe shell/editor processes, and captured output, but not arbitrary live process memory.

The success target is "resume quickly without losing the map of work," not impossible process immortality.

## Evidence First

Before changing a machine, inspect the platform and ask which apps matter to the user. Do not assume Chrome, Discord, Steam, or any specific app install method is the desired recovery target.

```bash
printenv SHELL TERM DESKTOP_SESSION XDG_CURRENT_DESKTOP XDG_SESSION_TYPE COLORTERM
command -v tmux git jq systemctl kreadconfig6 kwriteconfig6 konsole flatpak
tmux -V
konsole --list-profiles
kreadconfig6 --file ksmserverrc --group General --key loginMode
```

For Konsole appearance, inspect the current/default profile before creating the tmux profile:

```bash
konsole --list-profiles
grep -R "ColorScheme" ~/.local/share/konsole /usr/share/konsole 2>/dev/null
```

If the user already uses a dark or translucent profile, copy its `ColorScheme` into the restorable tmux profile. On Bazzite/KDE, `Vapor` is a common dark translucent profile. The bundled `RestorableTmux.profile` uses `ColorScheme=Vapor` as the default public-safe choice, but prefer the user's existing profile when clear.

For browsers, first identify what is installed and what the user wants restored. Then check only relevant profile locations. Common Chromium-family preference files include:

```bash
~/.var/app/com.google.Chrome/config/google-chrome/Default/Preferences
~/.config/google-chrome/Default/Preferences
~/.var/app/org.chromium.Chromium/config/chromium/Default/Preferences
~/.config/chromium/Default/Preferences
~/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser/Default/Preferences
~/.config/BraveSoftware/Brave-Browser/Default/Preferences
~/.var/app/com.vivaldi.Vivaldi/config/vivaldi/Default/Preferences
~/.config/vivaldi/Default/Preferences
~/.var/app/com.microsoft.Edge/config/microsoft-edge/Default/Preferences
~/.config/microsoft-edge/Default/Preferences
```

Avoid reading or exposing unrelated account/profile details from browser preference files. When a browser uses non-Chromium preferences, prefer that browser's UI or documented policy/config mechanism instead of guessing.

## Use The Bundled Installer

For Fedora Kinoite/Bazzite/KDE, prefer the installed skill script:

```bash
~/.agents/skills/sustainable-home-system/scripts/apply-fedora-kde-home-restore.sh
```

The script intentionally refuses to run from a Git checkout. Install the skill first, then run the installed copy. This prevents accidental execution of mutable repo working-tree scripts. The installed script applies user-level configuration only. It does not use `sudo`, does not layer packages with `rpm-ostree`, and does not overwrite files without backups. That keeps it suitable for public reuse on immutable Fedora-style systems.

Bundled resources:

- `scripts/apply-fedora-kde-home-restore.sh` - applies KDE, selected Chromium-family browser, Konsole, tmux, and user systemd settings.
- `scripts/browser-restore-enforcer.sh` - login-time Chromium-family browser startup restore enforcer with common-path discovery and an explicit override variable for non-standard preference files.
- `templates/tmux.conf` - tmux persistence config.
- `templates/RestorableTmux.profile` - Konsole profile that attaches to `tmux main`.
- `templates/tmux-main-session` - login helper script.
- `templates/tmux-main.service` - user systemd service.
- `templates/sustainable-home-system-browser-restore.desktop` - KDE autostart entry for the browser restore enforcer.

## Manual Workflow

If not using the script, apply the same layers manually:

1. Configure KDE session restore: `ksmserverrc` `loginMode=restorePreviousLogout`.
2. Configure only desired browser profiles. For Chromium-family browsers, set `session.restore_on_startup=1`, plus a user autostart enforcer because browsers can overwrite Preferences while running. For Firefox and other browsers, use their own documented restore settings instead of Chromium JSON.
3. Install tmux plugins: `tpm`, `tmux-resurrect`, `tmux-continuum`.
4. Configure Konsole default profile to run `tmux new-session -A -s main` while preserving the user's existing color scheme/transparency.
5. Add a user systemd oneshot service that starts `tmux main` at login.
6. Save a tmux-resurrect snapshot and verify restore files exist.

## Verification

After setup, verify:

```bash
kreadconfig6 --file ksmserverrc --group General --key loginMode
konsole --list-profiles
systemctl --user is-enabled tmux-main.service
systemctl --user is-failed tmux-main.service
tmux list-sessions
tmux show-options -gqv @continuum-save-interval
tmux show-options -gqv @resurrect-capture-pane-contents
tmux show-options -gqv @resurrect-pane-contents-area
```

Expected:

- KDE mode is `restorePreviousLogout`.
- Desired browser startup restore is enabled using that browser's supported mechanism.
- Browser restore enforcer exists in the installed skill `scripts/` directory and KDE autostart points at it when Chromium-family browser restore is configured.
- Konsole lists `RestorableTmux`.
- `RestorableTmux.profile` has a non-empty dark/translucent `ColorScheme`, usually copied from the user's previous profile or `Vapor` on Bazzite/KDE.
- `tmux-main.service` is enabled and not failed.
- tmux session `main` exists.
- tmux autosave interval is `5`.
- pane content capture is `on` and area is `full`.

## Response Style

Explain the layered system in plain language. Do not promise every app will restore perfectly. When the user asks to broaden the scope from terminal to all apps, distinguish "desktop session restore" from "per-app state restore" and configure both where possible.
