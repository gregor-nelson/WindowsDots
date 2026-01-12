-- Unified theme colors for Neovim config
-- Used by init.lua (highlights) and plugins.lua (lualine, etc.)

local M = {}

M.colors = {
  black    = "#1e222a",
  white    = "#abb2bf",
  grey     = "#282c34",  -- statusbar background
  gray2    = "#2e323a",  -- unfocused window border (dwm)
  gray3    = "#545862",
  gray4    = "#6d8dad",
  blue     = "#61afef",  -- focused window border (dwm)
  darkblue = "#4d8ac0",  -- derived from blue
  green    = "#7EC7A2",  -- matches dwm
  red      = "#e06c75",  -- matches dwm
  orange   = "#caaa6a",
  yellow   = "#EBCB8B",
  pink     = "#c678dd",
  border   = "#1e222a",  -- inner border (dwm col_borderbar)
}

-- Lualine theme (derived from colors)
-- Varied colors per mode for visual distinction
M.lualine_theme = {
  normal = {
    a = { fg = M.colors.black, bg = M.colors.blue, gui = "bold" },
    b = { fg = M.colors.blue, bg = M.colors.gray2 },
    c = { fg = M.colors.gray4, bg = M.colors.black },
    x = { fg = M.colors.gray4, bg = M.colors.black },
    y = { fg = M.colors.green, bg = M.colors.gray2 },
    z = { fg = M.colors.black, bg = M.colors.green, gui = "bold" },
  },
  insert = {
    a = { fg = M.colors.black, bg = M.colors.green, gui = "bold" },
    b = { fg = M.colors.green, bg = M.colors.gray2 },
    c = { fg = M.colors.gray4, bg = M.colors.black },
  },
  visual = {
    a = { fg = M.colors.black, bg = M.colors.pink, gui = "bold" },
    b = { fg = M.colors.pink, bg = M.colors.gray2 },
    c = { fg = M.colors.gray4, bg = M.colors.black },
  },
  replace = {
    a = { fg = M.colors.black, bg = M.colors.red, gui = "bold" },
    b = { fg = M.colors.red, bg = M.colors.gray2 },
    c = { fg = M.colors.gray4, bg = M.colors.black },
  },
  command = {
    a = { fg = M.colors.black, bg = M.colors.orange, gui = "bold" },
    b = { fg = M.colors.orange, bg = M.colors.gray2 },
    c = { fg = M.colors.gray4, bg = M.colors.black },
  },
  inactive = {
    a = { fg = M.colors.gray4, bg = M.colors.black },
    b = { fg = M.colors.gray4, bg = M.colors.black },
    c = { fg = M.colors.gray4, bg = M.colors.black },
  },
}

return M
