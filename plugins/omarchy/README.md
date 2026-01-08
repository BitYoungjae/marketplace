# omarchy

**Skills for creating and managing themes in Omarchy desktop environment.**

Omarchy is a Hyprland-based Linux desktop environment with a template-based theming system.

## Installation

```bash
/plugin marketplace add bityoungjae/marketplace
/plugin install omarchy@bityoungjae-marketplace
```

## Skills

### omarchy-theming

Create custom themes for Omarchy using the `colors.toml` template system.

**Features:**
- Define 22 color variables once, apply everywhere
- Automatic config generation for 13+ applications
- Support for dark and light themes
- HEX, stripped HEX, and RGB color formats

**Supported applications:**
- Terminals: Alacritty, Kitty, Ghostty
- Window Manager: Hyprland, Hyprlock
- Status Bar: Waybar
- Launcher: Walker
- Notifications: Mako, SwayOSD
- System Monitor: btop
- Apps: Obsidian, Chromium, VS Code, Neovim

**Quick start:**

```toml
# ~/.config/omarchy/themes/my-theme/colors.toml
accent = "#7aa2f7"
cursor = "#c0caf5"
foreground = "#a9b1d6"
background = "#1a1b26"
selection_foreground = "#c0caf5"
selection_background = "#7aa2f7"

color0 = "#32344a"
color1 = "#f7768e"
color2 = "#9ece6a"
color3 = "#e0af68"
color4 = "#7aa2f7"
color5 = "#ad8ee6"
color6 = "#449dab"
color7 = "#787c99"
color8 = "#444b6a"
color9 = "#ff7a93"
color10 = "#b9f27c"
color11 = "#ff9e64"
color12 = "#7da6ff"
color13 = "#bb9af7"
color14 = "#0db9d7"
color15 = "#acb0d0"
```

Apply the theme:

```bash
omarchy-theme-set my-theme
```

## License

MIT
