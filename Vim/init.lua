-- Load unified theme colors
local this_file = debug.getinfo(1, "S").source:sub(2)
local config_path = vim.fn.fnamemodify(vim.fn.resolve(this_file), ":h")
local theme = dofile(config_path .. "/theme.lua")
local colors = theme.colors

-- ------------------------
-- Basic Neovim UI settings
-- ------------------------
vim.opt.termguicolors   = true    -- 24-bit RGB colors in the TUI
vim.opt.background      = "dark"  -- dark theme base
vim.opt.number          = true    -- absolute line numbers
vim.opt.relativenumber  = true    -- relative line numbers for motions
vim.opt.cursorline      = true    -- highlight the current line
vim.opt.signcolumn      = "yes"   -- always show sign column to avoid jitter

-- ---------------------------------
-- Additional visual polish 
-- ---------------------------------
vim.opt.scrolloff       = 8       -- keep 8 lines visible above/below cursor
vim.opt.sidescrolloff   = 8       -- keep 8 columns visible left/right of cursor
vim.opt.wrap            = true    -- soft wrap long lines
vim.opt.showmode        = false   -- hide "-- INSERT --" (statusline/UIs show it)
vim.opt.showcmd         = true    -- (legacy) show partial commands in statusline
vim.opt.showmatch       = true    -- flash matching bracket
vim.opt.matchtime       = 3       -- tenths of a second to show match for
vim.opt.laststatus      = 2       -- always show statusline (will be upgraded below)
vim.opt.shortmess:append("c")     -- fewer completion messages (augmented below)
vim.opt.wildmenu        = true    -- legacy CLI completion menu (will be upgraded below)
vim.opt.cmdheight       = 1       -- height of command line
vim.opt.conceallevel    = 0       -- show concealed text normally
vim.opt.pumheight       = 10      -- max items in popup menu

-- ----------------------------
-- Indent settings 
-- ----------------------------
vim.opt.smartindent     = true    -- smart autoindent on new lines
vim.opt.expandtab       = true    -- insert spaces instead of tabs
vim.opt.shiftwidth      = 2       -- spaces per indent
vim.opt.tabstop         = 2       -- visual width of <Tab>
vim.opt.softtabstop     = 2       -- editing feels like <Tab> = 2 spaces

-- --------------------------------
-- Remove visual distraction (bars)
-- --------------------------------
vim.opt.fillchars = {
  eob       = " ",   -- no "~" at end of buffer
  vert      = "│",   -- window separator
  fold      = "·",   -- fold filler
  foldopen  = "▾",   -- fold open icon
  foldsep   = "│",   -- fold separator
  foldclose = "▸",   -- fold closed icon
}

-- =========================================================
-- Built-in Quality-of-Life improvements 
-- =========================================================

-- Search UX: smart, highlighted, with live :substitute preview
vim.opt.ignorecase = true                  -- case-insensitive by default…
vim.opt.smartcase = true                   -- …but becomes sensitive if pattern has uppercase
vim.opt.hlsearch  = true                   -- highlight matches of last search
vim.opt.incsearch = true                   -- incremental search while typing
vim.opt.inccommand = "split"               -- live preview of :s in a split (requires Neovim)

-- Clipboard & mouse
vim.opt.clipboard = "unnamedplus"          -- use system clipboard for all yanks/pastes
vim.opt.mouse = "a"                        -- enable mouse (click, drag, resize) in all modes

-- Completion & popup feel
vim.opt.completeopt = { "menuone", "noselect" } -- better completion menu behavior
vim.opt.pumblend = 10                      -- subtle transparency for completion menu (0..100)
vim.opt.winblend = 10                      -- subtle transparency for floating windows

-- Command-line completion (modernizes wildmenu)
vim.opt.wildmode = "longest:full,full"     -- first longest match, then cycle full matches
vim.opt.wildoptions = "pum"                -- show cmdline completions in a popup menu
vim.opt.wildmenu = false                   -- disable legacy wildmenu (replaced by popup)
-- Tidy messages & noise
vim.opt.showcmd = false                    -- hide last typed command (UIs/statusline are enough)
vim.opt.title = true                       -- set terminal title to current file

-- Statusline & command-line height
if vim.fn.has("nvim-0.9") == 1 then
  vim.opt.laststatus = 3                   -- global statusline across all windows
  vim.opt.cmdheight  = 0                   -- auto-hide cmdline when unused (frees a line)
else
  vim.opt.laststatus = 2                   -- fallback: per-window statusline
  vim.opt.cmdheight  = 1
end

-- Windows & splits
vim.opt.splitright = true                  -- vertical splits open to the right
vim.opt.splitbelow = true                  -- horizontal splits open below
vim.opt.equalalways = false                -- avoid auto-resizing survivors when a split closes
vim.opt.winminwidth = 5                    -- minimum width a window can shrink to
vim.opt.winminheight = 1                   -- minimum height a window can shrink to

-- Gutters & columns
vim.opt.signcolumn = "auto:1-2"            -- sign column widens automatically if needed
vim.opt.numberwidth = 3                    -- min width for line number column
vim.opt.colorcolumn = "99999"              -- prevents colorcolumn jitter from plugins
vim.opt.cursorlineopt = "number"           -- highlight only the line number

-- Files, undo & writes
vim.opt.undofile = true                    -- persistent undo across sessions
vim.opt.swapfile = false                   -- disable swapfiles (less clutter; tradeoff: crash recovery)
vim.opt.backup = false                     -- no backup file before overwriting
vim.opt.writebackup = false                -- no backup during write
vim.opt.autowrite = true                   -- write when leaving buffer or running cmds
vim.opt.confirm = true                     -- confirm dialogs instead of failing on unsaved changes

-- Performance
vim.opt.updatetime = 200                   -- faster CursorHold updates (affects diagnostics, etc.)
vim.opt.timeoutlen = 400                   -- snappier mapped-sequence timeout (default 1000ms)

-- Folds: enabled but start fully open (your fillchars already styled)
vim.opt.foldmethod = "indent"              -- indent-based folds (built-in)
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "0"                   -- hide fold column (minimal UI)



-- Whitespace visualization (toggle with :set list)
vim.opt.list = false                       -- keep off by default; toggle when needed
vim.opt.listchars = {
  tab = "» ", trail = "·", extends = "⟩", precedes = "⟨", nbsp = "␣",
}

-- Optional (built-in) niceties — uncomment if you want them:
-- vim.opt.spell = true                    -- enable spelling
-- vim.opt.spelllang = { "en" }            -- set languages for spell
-- vim.opt.diffopt:append({ "linematch:60", "vertical" }) -- improved, vertical diffs
-- If ripgrep is installed, make :grep fast & modern:
-- vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
-- vim.opt.grepformat = "%f:%l:%c:%m"

-- ===========================================
local function create_custom_theme()
  -- Clear any existing highlights (resets to base so we fully control colors)
  vim.cmd("highlight clear")
  -- Register scheme name
  vim.g.colors_name = "custom_theme"

  -- Base highlight groups (original)
  local highlights = {
    -- UI elements
    Normal       = { fg = colors.white, bg = colors.black },
    NormalFloat  = { fg = colors.white, bg = colors.black }, -- floating windows
    LineNr       = { fg = colors.gray3 },
    CursorLine   = { bg = colors.gray2 },
    CursorLineNr = { fg = colors.blue, bold = true },

    -- Window borders (matches dwm: gray2 = unfocused, blue = focused)
    VertSplit    = { fg = colors.gray2, bg = colors.black }, -- legacy split
    -- (Neovim's modern split is WinSeparator; added below)

    -- Status line
    StatusLine   = { fg = colors.white, bg = colors.gray2 },
    StatusLineNC = { fg = colors.gray4, bg = colors.black },

    -- Search
    Search       = { fg = colors.black, bg = colors.yellow },
    IncSearch    = { fg = colors.black, bg = colors.orange },

    -- Syntax
    Comment      = { fg = colors.gray4, italic = true },
    String       = { fg = colors.green },
    Number       = { fg = colors.orange },
    Function     = { fg = colors.blue },
    Keyword      = { fg = colors.pink },
    Identifier   = { fg = colors.white },
    Statement    = { fg = colors.pink },
    Type         = { fg = colors.yellow },
    Special      = { fg = colors.orange },
    Constant     = { fg = colors.orange },
    Operator     = { fg = colors.blue },
    PreProc      = { fg = colors.pink },

    -- Diagnostics (text color)
    DiagnosticError = { fg = colors.red },
    DiagnosticWarn  = { fg = colors.yellow },
    DiagnosticInfo  = { fg = colors.blue },
    DiagnosticHint  = { fg = colors.green },

    -- Diff (original)
    DiffAdd      = { fg = colors.green },
    DiffChange   = { fg = colors.blue },
    DiffDelete   = { fg = colors.red },
    DiffText     = { fg = colors.white, bg = colors.blue },

    -- Completion menu
    Pmenu        = { fg = colors.white, bg = colors.black },
    PmenuSel     = { fg = colors.black, bg = colors.blue },
    PmenuSbar    = { bg = colors.gray2 },
    PmenuThumb   = { bg = colors.gray3 },
  }

  -- Extended groups for consistency across modern UI elements
  -- All backgrounds use colors.black (#1e222a) for unified dark theme
  local more = {
    -- Unfocused windows & separators (matches dwm border colors)
    NormalNC      = { fg = colors.white, bg = colors.black },         -- non-current window
    WinSeparator  = { fg = colors.gray2, bg = colors.black },         -- unfocused border (dwm gray2)
    FloatBorder   = { fg = colors.blue,  bg = colors.black },         -- focused border (dwm blue)
    FloatTitle    = { fg = colors.black, bg = colors.blue, bold = true }, -- pill style title

    -- Columns & selection
    ColorColumn   = { bg = colors.gray2 },                            -- 'colorcolumn'
    CursorColumn  = { bg = colors.gray2 },
    Visual        = { bg = colors.gray3 },                            -- selection
    NonText       = { fg = colors.gray3 },                            -- ~ and other non-text
    Whitespace    = { fg = colors.gray3 },                            -- :set list chars

    -- Tabs
    TabLine       = { fg = colors.gray4, bg = colors.black },
    TabLineSel    = { fg = colors.white, bg = colors.gray2, bold = true },
    TabLineFill   = { fg = colors.gray3, bg = colors.black },

    -- Sign/gutter background (so signs blend with main bg)
    SignColumn    = { bg = colors.black },

    -- Diagnostics: undercurls (colored squiggles)
    DiagnosticUnderlineError = { undercurl = true, sp = colors.red },
    DiagnosticUnderlineWarn  = { undercurl = true, sp = colors.yellow },
    DiagnosticUnderlineInfo  = { undercurl = true, sp = colors.blue },
    DiagnosticUnderlineHint  = { undercurl = true, sp = colors.green },

    -- Diffs with subtle backgrounds (nice in side-by-side)
    DiffAdd       = { fg = colors.green, bg = "#1f2a1f" },
    DiffChange    = { fg = colors.blue,  bg = "#1d2430" },
    DiffDelete    = { fg = colors.red,   bg = "#2a1f1f" },
    DiffText      = { fg = colors.black, bg = colors.blue },

    -- Current search match accent (pairs with Search/IncSearch)
    CurSearch     = { fg = colors.black, bg = colors.yellow, bold = true },

    -- NvimTree: structure
    NvimTreeNormal          = { fg = colors.white, bg = colors.black },
    NvimTreeNormalNC        = { fg = colors.white, bg = colors.black },
    NvimTreeWinSeparator    = { fg = colors.gray2, bg = colors.black },
    NvimTreeIndentMarker    = { fg = colors.gray3 },
    NvimTreeRootFolder      = { fg = colors.blue, bold = true },
    NvimTreeCursorLine      = { bg = colors.gray2 },

    -- NvimTree: folders
    NvimTreeFolderIcon      = { fg = colors.blue },
    NvimTreeFolderName      = { fg = colors.blue },
    NvimTreeOpenedFolderName = { fg = colors.blue, bold = true },
    NvimTreeEmptyFolderName = { fg = colors.gray4 },

    -- NvimTree: files
    NvimTreeSpecialFile     = { fg = colors.orange, bold = true },
    NvimTreeExecFile        = { fg = colors.green },
    NvimTreeImageFile       = { fg = colors.pink },
    NvimTreeSymlink         = { fg = colors.pink },

    -- NvimTree: git status
    NvimTreeGitDirty        = { fg = colors.yellow },
    NvimTreeGitStaged       = { fg = colors.green },
    NvimTreeGitNew          = { fg = colors.green },
    NvimTreeGitDeleted      = { fg = colors.red },
    NvimTreeGitMerge        = { fg = colors.red },
    NvimTreeGitRenamed      = { fg = colors.blue },
    NvimTreeGitIgnored      = { fg = colors.gray3 },

    -- NvimTree: file states
    NvimTreeModifiedFile    = { fg = colors.orange },
    NvimTreeOpenedFile      = { fg = colors.white, bold = true },
    NvimTreeOpenedFolderIcon = { fg = colors.blue },
    NvimTreeBookmarkIcon    = { fg = colors.pink },
    NvimTreeBookmarkHL      = { fg = colors.pink },

    -- NvimTree: clipboard
    NvimTreeCutHL           = { fg = colors.red, italic = true },
    NvimTreeCopiedHL        = { fg = colors.green, italic = true },

    -- Telescope: layout
    TelescopeNormal         = { fg = colors.white, bg = colors.black },
    TelescopeBorder         = { fg = colors.blue, bg = colors.black },
    TelescopeTitle          = { fg = colors.blue, bold = true },

    -- Telescope: prompt (input area)
    TelescopePromptNormal   = { fg = colors.white, bg = colors.black },
    TelescopePromptBorder   = { fg = colors.blue, bg = colors.black },
    TelescopePromptTitle    = { fg = colors.blue, bold = true },
    TelescopePromptPrefix   = { fg = colors.blue, bg = colors.black },
    TelescopePromptCounter  = { fg = colors.gray4, bg = colors.black },

    -- Telescope: results (file list)
    TelescopeResultsNormal  = { fg = colors.white, bg = colors.black },
    TelescopeResultsBorder  = { fg = colors.gray2, bg = colors.black },
    TelescopeResultsTitle   = { fg = colors.darkblue, bold = true },

    -- Telescope: preview
    TelescopePreviewNormal  = { fg = colors.white, bg = colors.black },
    TelescopePreviewBorder  = { fg = colors.gray2, bg = colors.black },
    TelescopePreviewTitle   = { fg = colors.green, bold = true },

    -- Telescope: selection & matching
    TelescopeSelection      = { fg = colors.white, bg = colors.gray2, bold = true },
    TelescopeSelectionCaret = { fg = colors.blue, bg = colors.gray2 },
    TelescopeMatching       = { fg = colors.yellow, bold = true },
    TelescopeMultiSelection = { fg = colors.pink, bg = colors.gray2 },
  }

  -- Apply highlights
  for group, settings in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, settings)
  end
  for group, settings in pairs(more) do
    vim.api.nvim_set_hl(0, group, settings)
  end
end

-- Apply the custom theme at startup
create_custom_theme()

-- Convenience command to rebuild theme (useful if you tweak palette live)
vim.api.nvim_create_user_command('RefreshTheme', function()
  create_custom_theme()
  vim.notify('Theme refreshed!')
end, {})

-- Leader key (must be set before lazy.nvim loads plugins)
vim.g.mapleader = " "

-- =========================================================
-- Plugin Manager: lazy.nvim
-- =========================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from plugins.lua (same directory, follows symlinks)
-- (config_path already defined at top for theme loading)
require("lazy").setup(dofile(config_path .. "/plugins.lua"), {
  ui = { border = "single" },
})

-- =========================================================
-- Keymaps (non-plugin keymaps go here)
-- =========================================================

