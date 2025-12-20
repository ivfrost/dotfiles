require("onedark").setup {
  -- options: dark, darker, cool, deep, warm, warmer
  style = "dark",
  transparent = true, 
  code_style = {
    comments = "italic",
    keywords = "none",
    functions = "none",
    strings = "none",
    variables = "none",
  },
  diagnostics = {
    darker = true,
    undercurl = true,
    background = false,
  },
}
require("onedark").load()

