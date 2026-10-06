# t3-config

Personal T3 Code settings, kept here so a new machine can start from the same configuration.

## On a new machine

```bash
git clone https://github.com/joshborseth/t3-config.git
cd t3-config
./install.sh
```

That copies the files below into place and backs up anything already there. Restart T3 Code afterward. Sign in to Cursor and the model providers on that machine; this repo does not store login tokens.

## After you change settings

```bash
./export.sh
git add -A
git commit -m "Update T3 settings"
git push
```

## What is stored

- `userdata/settings.json` — T3 provider setup and UI preferences, installed to `~/.t3/userdata/`
- `userdata/keybindings.json` — T3 keyboard shortcuts, installed to `~/.t3/userdata/`
- `userdata/client-settings.json` — T3 appearance, fonts, diff view, notifications, and hidden models, installed to `~/.t3/userdata/`
- `cursor/cli-config.json` — Cursor agent model, permissions, display, and sandbox settings, installed to `~/.cursor/cli-config.json`
- `cursor/mcp.json` — MCP servers the agent can use, installed to `~/.cursor/mcp.json`

`install.sh` keeps an existing Cursor login in `cli-config.json` instead of replacing it. `export.sh` leaves login details out of the repo.

Secrets, the session database, logs, caches, and the T3 runtime stay on the machine.
