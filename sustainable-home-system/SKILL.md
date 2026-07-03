---
name: sustainable-home-system
description: Configure a resilient KDE Plasma home workstation so terminal sessions, desktop windows, browser tabs, and selected app workspaces recover after accidental closes, logout/login, reboot, or crash as much as Linux realistically allows. Use this skill whenever the user wants a sustainable desktop/home system, worries about losing workflow after reboot, wants KDE session restore, browser tab restore, tmux terminal persistence, or wants to reproduce this setup on another KDE Plasma machine.
---

# Sustainable Home System

Make a Linux desktop safe to reboot by layering restore mechanisms. This is intended to be useful as a public, portable skill for KDE Plasma users who want less fragile workstation state.

- KDE restores the desktop session and reopens windows where apps support it.
- The user's selected browser restores tabs where the browser supports "continue where you left off".
- Konsole opens into tmux instead of disposable Bash tabs.
- Each Konsole tab auto-creates or reattaches to its own tmux session named by working directory. This keeps tabs independent — each tab has its own history and process.
- tmux persists terminal layout, working directories, processes, and captured scrollback per session.
- tmux-resurrect restores sessions after reboot; tmux-continuum autosaves every 5 minutes. Restore fires once at login via the systemd service — not on arbitrary server starts — so intentionally closing a session mid-day gives a clean new tab.
- A user systemd service starts the tmux server at login and triggers the resurrect restore, so sessions are ready before any Konsole tab opens.
- Terminal recovery must preserve the user's visual profile. Do not replace a dark/translucent terminal with a light default profile.

This skill targets KDE Plasma. Treat other Linux desktops as adaptations of the same model. Keep instructions public-safe: avoid private usernames, machine-specific paths, account details, and personal workflow assumptions unless the current user explicitly asks for them.

## Reality Check

Be explicit about limits:

- A reboot or power loss kills running processes.
- KDE can reopen many windows and Konsole tabs with saved working directories, but process state depends on tmux.
- Browsers can restore tabs, but unsaved form/app state may still depend on each website.
- tmux-resurrect can restore layout, working directories, scrollback, and specific safe processes (e.g. opencode, vim). It cannot restore arbitrary live process memory. For opencode, use `"opencode->opencode --continue"` in `@resurrect-processes` so the restored process resumes the previous conversation instead of starting a new session.
- Per-tab tmux session naming is based on working directory basename. If multiple tabs share the same directory, they get indexed names (e.g. `foo`, `foo-2`). After reboot these tabs may reconnect in shuffled order, but all processes and history still restore.

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

If the user already uses a dark or translucent profile, copy its `ColorScheme` into the restorable tmux profile. The bundled `RestorableTmux.profile` uses `ColorScheme=Linux` which is a built-in dark scheme available in every Konsole install. Some distributions also ship `Vapor` (a dark translucent profile) — use it where present, otherwise stick with `Linux`.

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

For KDE Plasma, prefer the installed skill script:

```bash
~/.agents/skills/sustainable-home-system/scripts/apply-kde-home-restore.sh
```

The script intentionally refuses to run from a Git checkout. Install the skill first, then run the installed copy. This prevents accidental execution of mutable repo working-tree scripts. The installed script applies user-level configuration only. It does not use `sudo`, does not install system packages, and does not overwrite files without backups. That keeps it suitable for public reuse on any KDE Plasma desktop, including immutable distributions.

Bundled resources:

- `scripts/apply-kde-home-restore.sh` - applies KDE, selected Chromium-family browser, Konsole, tmux, and user systemd settings.
- `scripts/browser-restore-enforcer.sh` - login-time Chromium-family browser startup restore enforcer with common-path discovery and an explicit override variable for non-standard preference files.
- `scripts/tmux-auto-attach` - per-tab tmux session manager: auto-creates or reattaches to a tmux session named by working directory. Used as the Konsole profile command.
- `scripts/opencode-tmux-resume` - per-pane opencode session restore wrapper used by `@resurrect-processes`. Reads the saved pane title from the tmux-resurrect file and resumes the matching opencode session by ID. See "Per-pane opencode resume" below for the mechanism.
- `templates/tmux.conf` - tmux persistence config.
- `templates/RestorableTmux.profile` - Konsole profile that runs `tmux-auto-attach`.
- `templates/tmux-main-session` - login helper script that starts the tmux server.
- `templates/tmux-main.service` - user systemd service.
- `templates/sustainable-home-system-browser-restore.desktop` - KDE autostart entry for the browser restore enforcer.

## Workstation Bootstrap Scope

This skill is broader than desktop session restore: it should also capture the repeatable workstation bootstrap story for a fresh machine. The target is that a new Fedora Kinoite/KDE workstation can be rebuilt from the user's home repository, documented runtime choices, and explicit verification checks without rediscovering local setup decisions.

Use "sustainable workstation" as the conceptual scope when the user asks about fresh-machine setup, durable runtime install choices, or whether the home/workstation guide is enough to reproduce the system. Keep the installed skill name `sustainable-home-system` until references are deliberately migrated; do not rename it opportunistically.

### Hermes Agent Runtime Baseline

The preferred Hermes runtime for this workstation is a user-space package-style `uv tool` install, not the official shell installer's writable git checkout. This avoids treating `~/.hermes/hermes-agent` as both an installed product and a mutable source tree.

Current baseline pattern:

```bash
uv tool install --force \
  --with sounddevice \
  --with numpy \
  --with faster-whisper \
  hermes-agent
```

Expected layout:

- Launcher: `~/.local/bin/hermes`.
- Runtime: `~/.local/share/uv/tools/hermes-agent/`.
- Code path reported by `hermes --version`: `~/.local/share/uv/tools/hermes-agent/lib/python*/site-packages`.
- Config/state remains under `~/.hermes/`: `config.yaml`, `.env`, `auth.json`, `state.db`, `sessions/`, `skills/`, `cron/`, `logs/`, and optional profile directories.
- Update command: `uv tool upgrade hermes-agent`.
- Do not use `~/.hermes/hermes-agent` as the active runtime on this workstation unless the user explicitly chooses a development/source install.

Voice/STT baseline:

- `sounddevice` + `numpy` provide local audio capture support.
- `faster-whisper` provides local STT without a cloud key.
- Expected config: `stt.enabled: true`, `stt.provider: local`, and `stt.local.model: medium` unless the user chooses another model.

Approval timeout baseline for package installs:

- Because package releases may not treat `approvals.timeout: 0` as unlimited, use a very large timeout as a config-only workaround instead of patching Hermes source:
  - `approvals.timeout: 315360000`
  - `approvals.gateway_timeout: 315360000`

Fresh-machine bootstrap expectation:

1. Restore or clone the home/workstation configuration repository so `~/.hermes/config.yaml`, cross-agent instructions, and documented environment registry are available.
2. Install the generic runtime tools needed by the guide, especially `uv`, Git, Node.js, ripgrep, and desktop/audio prerequisites appropriate for Fedora Kinoite.
3. Install Hermes with the `uv tool install --force --with ... hermes-agent` command above.
4. Do not copy secrets into documentation. Restore secret-bearing files (`~/.hermes/.env`, provider auth files, OAuth caches) through the user's chosen secret/backup mechanism, or re-authenticate with `hermes auth` / `hermes model` / provider-specific setup.
5. Run verification before declaring the workstation reproducible.

Hermes verification checklist:

```bash
command -v hermes
readlink -f "$(command -v hermes)"
hermes --version
hermes config path
uv tool list
~/.local/share/uv/tools/hermes-agent/bin/python - <<'PY'
import importlib.util
from hermes_cli.config import load_config, detect_install_method, recommended_update_command
print('detect_install_method =', detect_install_method())
print('recommended_update_command =', recommended_update_command())
for name in ['sounddevice', 'numpy', 'faster_whisper']:
    print(f'{name} =', 'installed' if importlib.util.find_spec(name) else 'missing')
cfg = load_config()
print('stt.enabled =', cfg.get('stt', {}).get('enabled'))
print('stt.provider =', cfg.get('stt', {}).get('provider'))
print('stt.local.model =', cfg.get('stt', {}).get('local', {}).get('model'))
print('approvals.timeout =', cfg.get('approvals', {}).get('timeout'))
print('approvals.gateway_timeout =', cfg.get('approvals', {}).get('gateway_timeout'))
PY
hermes doctor
```

Expected verification:

- `readlink -f $(command -v hermes)` points into `~/.local/share/uv/tools/hermes-agent/bin/hermes`.
- `hermes --version` reports the project under uv tool `site-packages`, not `~/.hermes/hermes-agent`.
- `recommended_update_command` is `uv tool upgrade hermes-agent`.
- `sounddevice`, `numpy`, and `faster_whisper` are installed in Hermes' uv-tool Python.
- STT config is local + medium when voice mode is expected.
- `hermes doctor` may still warn about optional messaging/API integrations that are intentionally unconfigured; do not run `hermes doctor --fix` blindly if it proposes editable/source installs.

## Manual Workflow

If not using the script, apply the same layers manually:

1. Configure KDE session restore: `ksmserverrc` `loginMode=restorePreviousLogout`.
2. Configure only desired browser profiles. For Chromium-family browsers, set `session.restore_on_startup=1`, plus a user autostart enforcer because browsers can overwrite Preferences while running. For Firefox and other browsers, use their own documented restore settings instead of Chromium JSON.
3. Install tmux plugins: `tpm`, `tmux-resurrect`, `tmux-continuum`.
4. Install `scripts/tmux-auto-attach` to `~/.local/bin/tmux-auto-attach` and make it executable.
5. Configure Konsole default profile to run `~/.local/bin/tmux-auto-attach` while preserving the user's existing color scheme/transparency.
6. Add a user systemd oneshot service that starts the tmux server at login and explicitly calls `~/.tmux/plugins/tmux-resurrect/scripts/restore.sh`. Set `@continuum-restore 'off'` so restore only fires at login, not on arbitrary server starts.
7. Save a tmux-resurrect snapshot and verify restore files exist.

## Per-Pane Opencode Resume

When a Konsole tab is running opencode, tmux-resurrect alone would only restart `opencode` after a reboot — a blank new session, not the previous conversation. The bundled `opencode-tmux-resume` wrapper closes that gap so each pane resumes its exact previous session, even when several Konsole tabs were open in the same git repo.

How it works:

- opencode writes its session title to the terminal title as `OC | <session title>`.
- tmux-resurrect's save format stores that pane title (`pane_title` is column 7 of every `pane` row in the resurrect save file).
- After reboot, `opencode-tmux-resume` looks up its own tmux address (session + window + pane indices), pulls the saved title from the resurrect file, and finds the matching opencode session JSON under `~/.local/share/opencode/storage/session/<project-hash>/`. opencode's project hash is the git initial commit hash for the current directory, so the lookup is scoped to the right project automatically.
- If a match is found the wrapper execs `opencode --session <id>`. Otherwise it falls back to `opencode --continue`, so the worst case is "last session for this project" — never a crash and never a worse-than-default behaviour.

To wire it in, `templates/tmux.conf` uses the custom restore-command syntax in `@resurrect-processes`:

```
set -g @resurrect-processes '... "opencode->opencode-tmux-resume"'
```

This is generic enough to extend to other TUIs that publish a stable terminal title (Aider, AIChat, etc.) by adding their own resume wrappers and matching entries.

## Verification

This checklist doubles as a `skill-ops` grader contract: each check below is objectively true or false, so `skill-ops` can run it as a binary checklist to empirically tune this skill or its installer.

After setup, verify:

```bash
kreadconfig6 --file ksmserverrc --group General --key loginMode
konsole --list-profiles
systemctl --user is-enabled tmux-main.service
systemctl --user is-failed tmux-main.service
tmux list-sessions
tmux show-options -gqv @continuum-save-interval
tmux show-options -gqv @continuum-restore
tmux show-options -gqv @resurrect-processes
tmux show-options -gqv @resurrect-capture-pane-contents
tmux show-options -gqv @resurrect-pane-contents-area
```

Expected:

- KDE mode is `restorePreviousLogout`.
- Desired browser startup restore is enabled using that browser's supported mechanism.
- Browser restore enforcer exists in the installed skill `scripts/` directory and KDE autostart points at it when Chromium-family browser restore is configured.
- Konsole lists `RestorableTmux`.
- `RestorableTmux.profile` has a non-empty dark/translucent `ColorScheme` (default: `Linux`).
- `RestorableTmux.profile` command is `~/.local/bin/tmux-auto-attach`.
- `~/.local/bin/tmux-auto-attach` exists and is executable.
- `tmux-main.service` is enabled and not failed.
- tmux server is running (`tmux list-sessions` returns sessions or "no server" only on first boot).
- tmux autosave interval is `5`.
- `@continuum-restore` is `off` (restore is triggered explicitly at login by the systemd service, not on every server start).
- `@resurrect-processes` includes `"opencode->opencode --continue"` so opencode resumes its previous conversation after reboot.
- pane content capture is `on` and area is `full`.

## Response Style

Explain the layered system in plain language. Do not promise every app will restore perfectly. When the user asks to broaden the scope from terminal to all apps, distinguish "desktop session restore" from "per-app state restore" and configure both where possible.
