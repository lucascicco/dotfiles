-- --------------
-- GENERAL ---
--
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.reload_config_on_save = true
lvim.colorscheme = "onedarker"
lvim.leader = "space"

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true

-- --------------
-- KEYMAPPINGS ---
--
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<C-Up>"] = "10kzz"
lvim.keys.normal_mode["<C-Down>"] = "10jzz"
lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"
lvim.keys.normal_mode["<F2>"] = ":set spell!<CR>" -- toggle spell check
lvim.keys.normal_mode["<F3>"] = ":set spelllang=pt_br<CR>"
lvim.keys.normal_mode["<F4>"] = ":set spelllang=en<CR>"

-- --------------
-- NVIM TREE ---
--
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true

-- --------------
-- TELESCOPE ---
--
lvim.builtin.telescope.pickers = {
  find_files = { find_command = { "fd", "--type=file", "--hidden", "--exclude", ".git" } },
}

-- --------------
-- TREESITTER ---
--
lvim.builtin.treesitter.ensure_installed = {
  "c",
  "lua",
  "go",
  "python",
  "java",
  "rust",
  "elixir",
  -- Web
  "javascript",
  "typescript",
  "tsx",
  "css",
  -- DevOps
  "dockerfile",
  "bash",
  "yaml",
  "hcl",
  -- Others
  "graphql",
  "json",
  "json5",
}
lvim.builtin.treesitter.autotag.enable = true
lvim.builtin.treesitter.highlight.enable = true
lvim.parser_configs.hcl = {
  filetype = "hcl", "terraform",
}

-- -------
-- LSP ---
--
lvim.lsp.installer.setup.automatic_installation = true

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "black", filetypes = { "python" } },
  { command = "prettier", extra_args = { "--print-with", "100" }, filetypes = { "typescript", "typescriptreact" }, },
  { command = "lua-format", filetypes = { "lua" } },
}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { exe = "flake8" },
  { exe = "eslint_d" },
}
-- -------
-- PLUGINS
--
lvim.plugins = {
  { "vim-syntastic/syntastic" },
  -- Themes
  { "sainnhe/sonokai" },
  { "folke/tokyonight.nvim" },
  -- Extras
  { "ggandor/lightspeed.nvim" },
  { "wakatime/vim-wakatime" },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
  { "windwp/nvim-ts-autotag" },
  {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    ft = "markdown",
    config = function()
      vim.g.mkdp_auto_start = 0
    end,
  },
  {
    "ray-x/lsp_signature.nvim",
    config = function() require "lsp_signature".on_attach() end,
    event = "BufRead"
  },
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
}
