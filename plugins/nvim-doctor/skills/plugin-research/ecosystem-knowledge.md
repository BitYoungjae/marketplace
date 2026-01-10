# Neovim Plugin Ecosystem Knowledge

Reference guide for the Neovim plugin ecosystem, including major authors, plugin categories, known conflicts, and migration paths.

## Major Plugin Authors

### Tier 1: Core Ecosystem

| Author | GitHub | Specialty | Notable Plugins |
|--------|--------|-----------|-----------------|
| **folke** | github.com/folke | UI, UX, Plugin Management | lazy.nvim, which-key.nvim, noice.nvim, snacks.nvim, trouble.nvim, todo-comments.nvim |
| **hrsh7th** | github.com/hrsh7th | Completion | nvim-cmp, cmp-nvim-lsp, cmp-buffer, cmp-path, cmp-cmdline |
| **nvim-telescope** | github.com/nvim-telescope | Fuzzy Finding | telescope.nvim, telescope-fzf-native.nvim |
| **neovim** | github.com/neovim | Core/Official | nvim-lspconfig, nvim-treesitter |
| **nvim-lua** | github.com/nvim-lua | Utilities | plenary.nvim (dependency for many plugins) |

### Tier 2: Specialized Ecosystems

| Author | GitHub | Specialty | Notable Plugins |
|--------|--------|-----------|-----------------|
| **echasnovski** | github.com/echasnovski | Modular Utilities | mini.nvim (mini.ai, mini.surround, mini.comment, etc.) |
| **nvim-neo-tree** | github.com/nvim-neo-tree | File Explorer | neo-tree.nvim |
| **nvim-tree** | github.com/nvim-tree | File Explorer | nvim-tree.lua |
| **williamboman** | github.com/williamboman | LSP Management | mason.nvim, mason-lspconfig.nvim |
| **L3MON4D3** | github.com/L3MON4D3 | Snippets | LuaSnip |
| **lewis6991** | github.com/lewis6991 | Git | gitsigns.nvim |
| **numToStr** | github.com/numToStr | Comments | Comment.nvim |

### Tier 3: Distributions

| Distribution | Author | Base |
|--------------|--------|------|
| **LazyVim** | folke | lazy.nvim + curated plugins |
| **NvChad** | NvChad | Custom UI layer |
| **AstroNvim** | AstroNvim | Comprehensive IDE setup |
| **LunarVim** | LunarVim | Opinionated IDE |

## Plugin Categories

### Plugin Management

| Plugin | Status | Notes |
|--------|--------|-------|
| lazy.nvim | **Standard** | Modern, fast, feature-rich |
| packer.nvim | Deprecated | No longer maintained, migrate to lazy.nvim |
| vim-plug | Legacy | Works but not Lua-native |

### Completion

| Plugin | Ecosystem | Notes |
|--------|-----------|-------|
| nvim-cmp | hrsh7th | Most popular, modular |
| coq_nvim | ms-jpq | Fast, Python-based |
| mini.completion | echasnovski | Minimal, part of mini.nvim |

### File Navigation

| Plugin | Style | Notes |
|--------|-------|-------|
| telescope.nvim | Fuzzy finder | Extensible, many pickers |
| fzf-lua | Fuzzy finder | Fast, fzf-based |
| neo-tree.nvim | Tree explorer | Feature-rich |
| nvim-tree.lua | Tree explorer | Lighter weight |
| oil.nvim | Buffer-based | Edit filesystem like buffer |
| mini.files | Buffer-based | Part of mini.nvim |

### LSP & Diagnostics

| Plugin | Purpose | Notes |
|--------|---------|-------|
| nvim-lspconfig | LSP setup | Official configurations |
| mason.nvim | LSP installer | Package manager for LSP servers |
| mason-lspconfig.nvim | Bridge | Connects mason to lspconfig |
| trouble.nvim | Diagnostics UI | Pretty diagnostics list |
| lspsaga.nvim | LSP UI | Enhanced LSP features |

### Syntax & Highlighting

| Plugin | Purpose | Notes |
|--------|---------|-------|
| nvim-treesitter | Parsing | Required for modern highlighting |
| nvim-treesitter-textobjects | Text objects | Treesitter-aware movements |
| nvim-ts-autotag | Auto tags | HTML/JSX tag completion |

### Git Integration

| Plugin | Purpose | Notes |
|--------|---------|-------|
| gitsigns.nvim | Signs + hunk actions | Most popular |
| fugitive.vim | Git commands | Vim classic, still works |
| neogit | Git UI | Magit-like interface |
| lazygit.nvim | Terminal UI | Wrapper for lazygit |
| diffview.nvim | Diff viewer | Side-by-side diffs |

### UI Enhancement

| Plugin | Purpose | Notes |
|--------|---------|-------|
| noice.nvim | Messages/cmdline | Replaces native UI |
| dressing.nvim | Input/select | Better vim.ui |
| nvim-notify | Notifications | Pretty notifications |
| lualine.nvim | Statusline | Most popular |
| bufferline.nvim | Tabline | Buffer tabs |

## Known Plugin Conflicts

### Critical Conflicts

| Plugin A | Plugin B | Conflict | Resolution |
|----------|----------|----------|------------|
| nvim-tree.lua | neo-tree.nvim | Both are file explorers | Use only one |
| packer.nvim | lazy.nvim | Both are plugin managers | Migrate to lazy.nvim |
| coc.nvim | nvim-cmp | Both handle completion | Use only one |
| coc.nvim | nvim-lspconfig | Both configure LSP | Use only one |

### Load Order Conflicts

| Plugin | Must Load Before | Reason |
|--------|------------------|--------|
| plenary.nvim | telescope.nvim | Dependency |
| nvim-web-devicons | Most UI plugins | Icon provider |
| nvim-lspconfig | mason-lspconfig | Config before bridge |
| LuaSnip | cmp-luasnip | Snippet engine first |

### Keymap Conflicts

| Default Key | Plugins Using It | Resolution |
|-------------|------------------|------------|
| `<leader>e` | neo-tree, nvim-tree, oil | Choose one, remap others |
| `<leader>f` | telescope, fzf-lua | Choose one, remap others |
| `<C-n>` | nvim-cmp, copilot | Remap in cmp config |
| `<Tab>` | nvim-cmp, copilot, luasnip | Use cmp's tab mapping config |

## Migration Paths

### packer.nvim → lazy.nvim

```lua
-- packer.nvim
use { 'plugin/name', config = function() ... end }

-- lazy.nvim
{ 'plugin/name', config = function() ... end }
-- Or with opts:
{ 'plugin/name', opts = { ... } }
```

Key differences:
- No `use()` wrapper
- `config` now receives plugin object, use `opts` for simple config
- `requires` → `dependencies`
- `run` → `build`
- `ft`, `cmd`, `keys`, `event` work similarly

### nvim-lsp-installer → mason.nvim

```lua
-- Old: nvim-lsp-installer
require("nvim-lsp-installer").setup()

-- New: mason.nvim + mason-lspconfig.nvim
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "pyright" }
})
```

### null-ls.nvim → none-ls.nvim

null-ls is archived. Use none-ls (community fork):
```lua
-- Change import
-- Old: require("null-ls")
-- New: require("none-ls")
```

## Version Compatibility Matrix

### Neovim Version Requirements (Common Plugins)

| Plugin | Min Neovim | Notes |
|--------|------------|-------|
| lazy.nvim | 0.8.0 | Uses newer APIs |
| nvim-cmp | 0.7.0 | Stable |
| telescope.nvim | 0.9.0 | Recent versions |
| nvim-treesitter | 0.9.0 | Parser updates |
| noice.nvim | 0.9.0 | Uses nui.nvim |
| snacks.nvim | 0.9.4 | Latest folke plugin |

### Breaking Changes Timeline

| Date | Plugin | Change |
|------|--------|--------|
| 2024 | lazy.nvim | `require("lazy").setup()` opts restructured |
| 2024 | nvim-cmp | Some source configs changed |
| 2024 | telescope.nvim | Some picker APIs updated |
| 2023 | null-ls.nvim | Archived, use none-ls |
| 2023 | nvim-lsp-installer | Deprecated, use mason.nvim |
| 2023 | packer.nvim | No longer maintained |

## Distribution-Specific Notes

### LazyVim

- Uses `lazyvim.json` for enabled extras
- Plugin configs in `lua/plugins/*.lua`
- Override defaults with `opts` function
- Check `~/.config/nvim/lazyvim.json` for active extras

### NvChad

- Uses `chadrc.lua` for customization
- Plugin overrides in `lua/custom/plugins/`
- Theme configs separate from plugin configs

### AstroNvim

- Uses `user/` directory for customization
- Community plugins via AstroCommunity
- Version-locked dependencies
