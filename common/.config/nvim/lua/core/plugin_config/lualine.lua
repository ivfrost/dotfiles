-- Solarized Dark bubbles lualine theme
local colors = {
  base03  = "#002b36",
  base02  = "#073642",
  base01  = "#586e75",
  base00  = "#657b83",
  base0   = "#839496",
  base1   = "#93a1a1",
  base2   = "#eee8d5",
  base3   = "#fdf6e3",

  yellow  = "#b58900",
  orange  = "#cb4b16",
  red     = "#dc322f",
  magenta = "#d33682",
  violet  = "#6c71c4",
  blue    = "#268bd2",
  cyan    = "#2aa198",
  green   = "#859900",
}

local bubbles_theme = {
  normal = {
    a = { fg = colors.base03, bg = colors.blue },
    b = { fg = colors.base1,  bg = colors.base02 },
    c = { fg = colors.base1,  bg = colors.base03 },
  },

  insert  = { a = { fg = colors.base03, bg = colors.cyan } },
  visual  = { a = { fg = colors.base03, bg = colors.violet } },
  replace = { a = { fg = colors.base03, bg = colors.red } },

  inactive = {
    a = { fg = colors.base01, bg = colors.base02 },
    b = { fg = colors.base01, bg = colors.base02 },
    c = { fg = colors.base01, bg = colors.base03 },
  },
}

require('lualine').setup {
  options = {
    theme = bubbles_theme,
    component_separators = '',
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
    lualine_b = { 'filename', 'branch' },
    lualine_c = { '%=' },
    lualine_x = {},
    lualine_y = { 'filetype', 'progress' },
    lualine_z = {
      { 'location', separator = { right = '' }, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = { 'filename' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'location' },
  },
  tabline = {},
  extensions = {},
}

