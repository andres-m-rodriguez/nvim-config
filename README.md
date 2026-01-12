# Neovim Configuration

My personal Neovim configuration focused on Zig development.

## Features

- **Package Manager**: lazy.nvim
- **Colorscheme**: rose-pine (transparent background)
- **Fuzzy Finder**: Telescope
- **Quick Navigation**: Harpoon
- **Autocompletion**: nvim-cmp with LSP support
- **LSP**: Zig Language Server (zls)

## Keybindings

| Key | Action |
|-----|--------|
| `<Space>` | Leader key |
| `<C-p>` | Find files |
| `<C-f>` | Search in files |
| `<C-s>` | Save file |
| `<C-z>` | Undo |
| `<C-e>` | Harpoon menu |
| `<A-1-4>` | Jump to Harpoon file 1-4 |
| `<leader>a` | Add file to Harpoon |
| `gd` | Go to definition |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>f` | Format file |

## Installation

1. Backup your existing config (if any):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/andres-m-rodriguez/nvim-config ~/.config/nvim
   ```

3. Open Neovim and let lazy.nvim install plugins:
   ```bash
   nvim
   ```

## Requirements

- Neovim >= 0.9.0
- Git
- [Zig Language Server (zls)](https://github.com/zigtools/zls) for Zig support
- A [Nerd Font](https://www.nerdfonts.com/) (optional, for icons)
