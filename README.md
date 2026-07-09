<p align="center">
  <img src="docs/logo.png" alt="Darkmoon Faire Buff" width="200">
</p>

<h1 align="center">Darkmoon Faire Buff</h1>

<p align="center">World of Warcraft Classic Era addon that automates Sayge's Darkmoon Faire buff dialogue.</p>

## Features

- Automatically follows Sayge's dialogue path for the selected buff.
- Keeps localized in-game strings for supported clients.
- Recommends buffs from the player's class, level, and detected talents.
- Optional final click to request the written Darkmoon Faire Fortune.
- Per-character cooldown timer based on an absolute expiration timestamp.
- Options panel in the in-game Add-ons settings.
- Slash commands: `/dfb`, `/dfb status`, `/dfb debug`, and `/dfb reset`.

## Project Layout

- `addon/DarkmoonFaireBuff/` contains the files loaded by WoW.
- `scripts/dev.ps1` syncs the addon into the local WoW Classic Era AddOns folder.
- `scripts/build.ps1` creates `dist/DarkmoonFaireBuff.zip`.
- `dev.cmd` runs the development deploy script by double-click.

## Development Deploy

From this project directory:

```powershell
.\scripts\dev.ps1
```

The script auto-detects a standard Battle.net install. For a non-standard install location, pass
`-WowAddOnsPath`, set the `DFB_WOW_ADDONS_PATH` environment variable, or create a local
`scripts\dev.local.ps1` (gitignored) that sets `$WowAddOnsPath`.

After deployment, run `/reload` in game.

## Package

```powershell
.\scripts\build.ps1
```

The zip package is generated at `dist/DarkmoonFaireBuff.zip`.