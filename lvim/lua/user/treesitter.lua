if lvim.colorscheme == "darkplus" then
  lvim.builtin.treesitter.rainbow = {
    enable = true,
    extended_mode = false,
    colors = {
      "DodgerBlue",
      "Orchid",
      "Gold",
    },
    disable = { "html" },
  }
end

lvim.builtin.treesitter.ensure_installed = "all"
lvim.builtin.treesitter.autotag.enable = true
lvim.builtin.treesitter.highlight = {
  enable = true,
  use_languagetree = true,
}
lvim.builtin.treesitter.indent.enable = true
lvim.builtin.treesitter.match.enable = true

lvim.builtin.treesitter.textobjects = {
  select = {
    enable = true,
    lookahead = true,
    keymaps = {
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["at"] = "@class.outer",
      ["it"] = "@class.inner",
      ["ac"] = "@call.outer",
      ["ic"] = "@call.inner",
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",
      ["al"] = "@loop.outer",
      ["il"] = "@loop.inner",
      ["ai"] = "@conditional.outer",
      ["ii"] = "@conditional.inner",
      ["a/"] = "@comment.outer",
      ["i/"] = "@comment.inner",
      ["ab"] = "@block.outer",
      ["ib"] = "@block.inner",
      ["as"] = "@statement.outer",
      ["is"] = "@scopename.inner",
      ["aA"] = "@attribute.outer",
      ["iA"] = "@attribute.inner",
      ["aF"] = "@frame.outer",
      ["iF"] = "@frame.inner",
    },
  },
}
