-- GitHub Dark bubbles lualine theme
local colors = {
  blue   = '#58a6ff',
  green  = '#3fb950',
  purple = '#bc8cff',
  red    = '#f85149',
  fg     = '#c9d1d9',
  bg     = '#0d1117',
  grey   = '#30363d',
}

local bubbles_theme = {
  normal = {
    a = { fg = colors.bg, bg = colors.blue },
    b = { fg = colors.fg, bg = colors.grey },
    c = { fg = colors.fg, bg = colors.bg },
  },

  insert  = { a = { fg = colors.bg, bg = colors.green } },
  visual  = { a = { fg = colors.bg, bg = colors.purple } },
  replace = { a = { fg = colors.bg, bg = colors.red } },

  inactive = {
    a = { fg = colors.fg, bg = colors.bg },
    b = { fg = colors.fg, bg = colors.bg },
    c = { fg = colors.fg, bg = colors.bg },
  },
}

require('lualine').setup {
  options = {
    theme = bubbles_theme,
    component_separators = '',
    section_separators = { left = '', right = '' },
  },
  sections = {
    -- removed left edge separator
    lualine_a = { { 'mode', right_padding = 2 } },

    lualine_b = { 'filename', 'branch' },
    lualine_c = { '%=' },

    lualine_x = {},
    lualine_y = { 'filetype', 'progress' },

    -- removed right edge separator
    lualine_z = { { 'location', left_padding = 2 } },
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

