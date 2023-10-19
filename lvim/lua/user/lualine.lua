lvim.builtin.lualine.options.globalstatus = true
lvim.builtin.lualine.options.component_separators = { left = "|", right = "|" }
lvim.builtin.lualine.sections = {
  lualine_a = { "mode" },
  lualine_b = { "branch", "diff", "diagnostics" },
  lualine_c = {
    { "filename", path = 1 },
  },
  lualine_x = {
    {
      require("lazy.status").updates,
      cond = require("lazy.status").has_updates,
      color = { fg = "#ff9e64" },
    },
    {
      "lsp_progress",
      spinner_symbols = {
        "⠋",
        "⠙",
        "⠹",
        "⠸",
        "⠼",
        "⠴",
        "⠦",
        "⠧",
        "⠇",
        "⠏",
      },
    },
  },
  lualine_y = {
    "encoding",
    "fileformat",
    "filetype",
    "progress",
  },
}
lvim.builtin.lualine.extensions = {
  "neo-tree",
  "fugitive",
  "toggleterm",
  "nvim-dap-ui",
  "mundo",
  "trouble",
  "lazy",
}
