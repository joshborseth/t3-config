# t3-config

Personal [T3 Code](https://github.com/joshborseth/t3code) settings, kept here so a new machine can start from the same configuration.

## On a new machine

```bash
git clone https://github.com/joshborseth/t3-config.git
cd t3-config
./install.sh
```

That copies `settings.json` and `keybindings.json` into `~/.t3/userdata`, backing up anything already there. Restart T3 Code afterward.

## After you change settings

```bash
./export.sh
git add -A
git commit -m "Update T3 settings"
git push
```

## What is stored

- `userdata/settings.json` — provider setup and UI preferences
- `userdata/keybindings.json` — keyboard shortcuts

Secrets, the session database, logs, caches, themes, and the T3 runtime stay on the machine. Sign in to providers again on each new machine.
