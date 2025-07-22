# Foolatro 🚀

Foolatro is a tiny experimental game prototype written in **Lua** for the **LÖVE** (Love2D) engine.

---

## Table of Contents
- [Foolatro 🚀](#foolatro-)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Running the Game](#running-the-game)
    - [1. From the project folder (recommended)](#1-from-the-project-folder-recommended)
    - [2. Using a standalone *.love* file](#2-using-a-standalone-love-file)
  - [Building Distributable Packages](#building-distributable-packages)
    - [Quick \& dirty (manual)](#quick--dirty-manual)
    - [Automated (with `love-release`)](#automated-with-love-release)
  - [Customising Assets](#customising-assets)

---

## Prerequisites

| Tool   | Version | Notes |
|--------|---------|-------|
| [LÖVE](https://love2d.org/) | **11.4** (or newer 11.x) | Required to run or package the game |
| `zip`  | any     | For creating a standalone *.love* file (optional) |
| `love-release` | latest | *Optional.*  Automates multi-platform packaging |

> 💡 **Linux users:** many distros ship `love` via their package manager:<br/>`sudo pacman -S love` (Arch/Manjaro) • `sudo apt install love` (Ubuntu) • `sudo dnf install love` (Fedora).

> 💡 **Windows & macOS:** grab the official binaries from the Love2D website or use [WinGet](https://learn.microsoft.com/windows/package-manager/winget/).

---

## Running the Game

### 1. From the project folder (recommended)
```bash
# In the repo root
love .
```

### 2. Using a standalone *.love* file
```bash
zip -9 -r foolatro.love . -x "*.git*" "*README.md"
love foolatro.love
```

Both methods launch a window displaying a single spaceship sprite at (100, 100).

---

## Building Distributable Packages

### Quick & dirty (manual)
1. Create a `.love` archive as shown above.
2. Distribute the file *or* append/rename it to platform-specific executables (see LÖVE wiki for details).

### Automated (with `love-release`)
```bash
# Install love-release once (requires LuaRocks)
luarocks install love-release

# In project root; generates Windows, macOS & Linux packages inside ./dist
love-release -v 1.0.0
```
> Customise the metadata by editing the generated `.luarocks` spec or via CLI flags (`-t`, `-m`, etc.).

---

## Customising Assets

1. **Add a new spritesheet:**
   * Drop a PNG inside `assets/`.
   * Register it in `foolatro/utils/asset_server.lua` under `spritesheet_assets`.
2. **Standalone images:** add to `image_assets` the same way (`name = "image.png"`).
