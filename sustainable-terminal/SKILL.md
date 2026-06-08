---
name: sustainable-terminal
description: Set up a resilient Linux terminal workspace that survives terminal crashes, desktop session restarts, logout/login, and reboots as well as Linux realistically allows. Use this skill whenever the user wants terminal tabs/windows/shell context/output restored after reboot, asks about tmux/Konsole/Bash/shell/session persistence, wants to reproduce a durable terminal setup on another computer, or reports losing work when terminal windows close unexpectedly.
---

# Sustainable Terminal

Build a practical, durable terminal setup for Linux desktops.

The goal is not impossible process resurrection. After a full reboot or power loss, Linux cannot preserve live process memory for arbitrary Bash commands, dev servers, editors, or AI agents. The practical goal is to restore:

- Terminal workspace entry point.
- tmux sessions, windows, panes, and working directories.
- Large scrollback and captured pane output.
- Shell history and enough context to resume quickly.
- Optional, explicit restart commands for selected safe workloads.

## Mental Model

Explain the stack when the user asks what these pieces are:

```text
Terminal emulator, for example Konsole
  -> tmux session manager
      -> shell, for example Bash
          -> commands/apps, for example make dev, vim, opencode
```

- A terminal emulator is the GUI window that displays a text interface.
- Konsole is KDE's terminal emulator.
- A console is an older/looser term; on Linux it can also mean a real text TTY.
- A shell is the command interpreter.
- Bash is one shell implementation.
- tmux is a terminal session manager that sits between the terminal window and shells.

Important behavior:

- If only the terminal window closes, tmux can keep the session alive and reattach later.
- If the whole machine reboots, live processes die, but tmux-resurrect/continuum can restore layout, directories, and captured output snapshots.

## First Questions

Ask only what is needed. Prefer inspecting the system first when tool access is available.

Key facts to identify:

- Desktop environment: KDE Plasma, GNOME, etc.
- Terminal emulator: Konsole, GNOME Terminal, Kitty, WezTerm, Alacritty, Ptyxis, etc.
- Shell: Bash, Zsh, Fish.
- Existing session tools: tmux, zellij, screen.
- Whether the user wants practical restore or risky command auto-restart.

Recommended target:

- Practical robust restore.
- Restore layouts/directories/output snapshots.
- Do not auto-rerun long-lived or side-effecting commands by default.

## Evidence Chain

Before changing configuration, collect concrete evidence:

1. Desktop/session path.
2. Terminal emulator process/config.
3. Shell and tmux availability.
4. Existing config files, if any.
5. Current save/restore support.

Useful commands:

```bash
printenv SHELL TERM DESKTOP_SESSION XDG_CURRENT_DESKTOP XDG_SESSION_TYPE COLORTERM
command -v tmux zellij screen systemctl loginctl konsole gnome-terminal kitty wezterm alacritty
tmux -V
ps -eo pid,ppid,comm,args
```

For KDE/Konsole:

```bash
konsole --list-profiles
konsole --list-profile-properties
```

## Standard KDE Konsole + Bash + tmux Setup

Use this path when the user is on KDE Plasma with Konsole and Bash. Adapt paths for other usernames and home directories. Prefer `$HOME` in explanations, but concrete config files can use the resolved home path when writing files.

### 1. Install or confirm tmux

Check:

```bash
tmux -V
```

If tmux is missing, install using the distro package manager. Examples:

```bash
sudo dnf install tmux
sudo apt install tmux
sudo pacman -S tmux
```

On immutable Fedora/Bazzite/Kinoite systems, prefer already-installed tmux, a toolbox/distrobox, or the user's preferred package layering workflow. Do not casually layer packages without confirming.

### 2. Create directories

```bash
mkdir -p ~/.tmux/plugins ~/.local/state/tmux/logs
```

### 3. Add tmux config

Create `~/.tmux.conf`:

```tmux
# Durable terminal sessions.
# Start daily work with: tmux new-session -A -s main

set -g default-terminal "tmux-256color"
set -g history-limit 200000
set -g mouse on
set -g renumber-windows on
set -g base-index 1
setw -g pane-base-index 1

# Keep tmux state in XDG state, not in the home directory root.
set -g @resurrect-dir '~/.local/state/tmux/resurrect'

# Restore layout, panes, working directories, and safe editor/shell sessions.
# Long-running project commands are intentionally not auto-restarted.
set -g @resurrect-processes 'vi vim nvim emacs man less more tail top htop btop ssh bash zsh fish'
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-pane-contents-area 'full'

# Autosave tmux sessions every 5 minutes.
set -g @continuum-save-interval '5'
set -g @continuum-restore 'on'
set -g @continuum-boot 'off'

# tmux plugin manager.
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

run '~/.tmux/plugins/tpm/tpm'
```

Rationale:

- `history-limit` gives a large in-tmux scrollback.
- `tmux-resurrect` saves layouts, panes, directories, and selected commands.
- `tmux-continuum` saves automatically.
- Full pane capture preserves visible terminal content snapshots.
- Risky auto-restart is intentionally disabled for dev servers and AI agents.

### 4. Install tmux plugins

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins
```

If `~/.tmux/plugins/tpm` already exists, do not overwrite it. Inspect first and only install missing plugins.

### 5. Start durable main session

```bash
tmux new-session -Ad -s main
tmux source-file ~/.tmux.conf
~/.tmux/plugins/tmux-resurrect/scripts/save.sh
```

Manual key bindings after plugins are loaded:

- Save: `Ctrl+b`, then `Ctrl+s`.
- Restore: `Ctrl+b`, then `Ctrl+r`.

### 6. Configure Konsole default profile

Create `~/.local/share/konsole/RestorableTmux.profile`:

```ini
[General]
Name=Restorable Tmux
Command=/usr/bin/tmux
Arguments=new-session,-A,-s,main
Directory=%d
LocalTabTitleFormat=%d: %n
HistoryMode=2
HistorySize=200000

[Appearance]
ColorScheme=
```

If `Directory=%d` is not accepted on a target system, use the user's home directory as a fallback.

Set it as default in `~/.config/konsolerc`:

```ini
[Desktop Entry]
DefaultProfile=RestorableTmux.profile
```

Preserve existing sections in `konsolerc`; add or update only the default profile key.

### 7. Enable KDE previous-session restore

Create or update `~/.config/ksmserverrc`:

```ini
[General]
loginMode=restorePreviousLogout
```

This lets KDE reopen GUI windows where possible. tmux handles terminal state underneath.

### 8. Add user service for tmux session at login

Create `~/.local/bin/tmux-main-session`:

```bash
#!/usr/bin/env bash
set -euo pipefail

if /usr/bin/tmux has-session -t main 2>/dev/null; then
  exit 0
fi

exec /usr/bin/tmux new-session -d -s main
```

Make it executable:

```bash
chmod +x ~/.local/bin/tmux-main-session
```

Create `~/.config/systemd/user/tmux-main.service`:

```ini
[Unit]
Description=Start durable tmux main session

[Service]
Type=oneshot
ExecStart=%h/.local/bin/tmux-main-session

[Install]
WantedBy=default.target
```

Enable it:

```bash
systemctl --user daemon-reload
systemctl --user enable --now tmux-main.service
```

Expected `is-active` result may be `inactive` because this is a successful `oneshot` service. Verify failure separately:

```bash
systemctl --user is-enabled tmux-main.service
systemctl --user is-failed tmux-main.service
tmux list-sessions
```

## Verification Checklist

Run these checks:

```bash
tmux list-sessions
tmux show-options -gqv @continuum-save-interval
tmux show-options -gqv @resurrect-capture-pane-contents
tmux show-options -gqv @resurrect-pane-contents-area
konsole --list-profiles
systemctl --user is-enabled tmux-main.service
systemctl --user is-failed tmux-main.service
```

Expected evidence:

- `main` tmux session exists.
- Continuum interval is `5`.
- Pane capture is `on`.
- Pane capture area is `full`.
- Konsole lists `RestorableTmux`.
- Service is `enabled` and not failed.
- Restore files exist under `~/.local/state/tmux/resurrect` after a manual save.

Manual test:

1. Open Konsole.
2. Confirm it attaches to tmux `main`.
3. Create a tmux window and pane.
4. Change into different directories.
5. Run commands that print recognizable output.
6. Press `Ctrl+b`, then `Ctrl+s`.
7. Close Konsole.
8. Reopen Konsole and confirm the tmux session is back.
9. Reboot when convenient and confirm KDE/Konsole/tmux restoration.

## Optional Auto-Restart Policy

Do not enable broad command resurrection by default. Auto-restarting commands can duplicate dev servers, agents, database migrations, SSH sessions, or side-effecting jobs.

If the user explicitly wants maximum automation, design per-project scripts instead:

- `~/projects/<repo>/scripts/dev-session`
- `~/projects/<repo>/scripts/restore-terminal-workspace`

Then add only those scripts to tmux-resurrect process restoration after reviewing side effects.

## Other Terminal Emulators

The tmux layer is portable. Terminal-specific setup changes by app:

- Kitty: configure startup command/session to run `tmux new-session -A -s main`.
- WezTerm: set default program or launch menu entry for tmux.
- GNOME Terminal/Ptyxis: create a profile or launcher that runs tmux.
- Alacritty: set shell/program args to tmux.

Keep the same core verification: new terminal windows attach to `tmux main`, tmux autosaves, restore snapshots exist.

## Troubleshooting

If new terminal opens plain Bash:

- Check the terminal's default profile.
- Check whether the profile command is executable.
- Launch manually: `tmux new-session -A -s main`.

If tmux plugin commands do not work:

- Check `~/.tmux/plugins/tpm` exists.
- Run `~/.tmux/plugins/tpm/bin/install_plugins`.
- Reload config: `tmux source-file ~/.tmux.conf`.

If no restore snapshot appears:

- Run `~/.tmux/plugins/tmux-resurrect/scripts/save.sh`.
- Check `~/.local/state/tmux/resurrect`.
- Check `tmux show-options -gqv @resurrect-dir`.

If user expects exact live process restoration after reboot:

- Explain the limit clearly.
- Full reboot kills processes.
- This setup restores workspace state and captured output, then helps the user restart work quickly.

## Response Style

Be direct and practical. Present evidence first, then changes. Avoid implying that reboot can preserve arbitrary running processes. Use terms like "durable workspace", "restore snapshot", and "reattach" precisely.
