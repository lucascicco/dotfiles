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
lvim.keys.normal_mode["<C-Up>"] = "10kzz"
lvim.keys.normal_mode["<C-Down>"] = "10jzz"
lvim.keys.normal_mode["n"] = "nzz"
lvim.keys.normal_mode["N"] = "Nzz"
-- tab navigation
lvim.keys.normal_mode["<S-Right>"] = ":BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<S-Left>"] = ":BufferLineCyclePrev<CR>"
-- telescope
lvim.keys.normal_mode["<F2>"] = "<cmd>Telescope find_files<CR>"
lvim.keys.normal_mode["<C-b>"] = "<cmd>Telescope buffers<CR>"
lvim.keys.normal_mode["<C-f>"] = "<cmd>Telescope live_grep<CR>"
-- spell check
lvim.keys.normal_mode["<F5>"] = ":set spell!<CR>"
lvim.keys.normal_mode["<F6>"] = ":set spelllang=pt_br<CR>"
lvim.keys.normal_mode["<F7>"] = ":set spelllang=en<CR>"
-- lsp
lvim.keys.normal_mode["K"] = vim.lsp.buf.hover
lvim.keys.normal_mode["gd"] = vim.lsp.buf.definition
lvim.keys.normal_mode["gD"] = vim.lsp.buf.declaration
lvim.keys.normal_mode["gI"] = vim.lsp.buf.implementation
lvim.keys.normal_mode["gci"] = vim.lsp.buf.incoming_calls
lvim.keys.normal_mode["gco"] = vim.lsp.buf.outgoing_calls
lvim.keys.normal_mode["grn"] = vim.lsp.buf.rename
lvim.keys.normal_mode["gr"] = vim.lsp.buf.references
-- trouble
lvim.keys.normal_mode["<F3>"] = "<cmd>TroubleToggle<cr>"
-- diagnostic
lvim.keys.normal_mode["[d"] = vim.diagnostic.goto_prev
lvim.keys.normal_mode["]d"] = vim.diagnostic.goto_next
lvim.keys.normal_mode["<F4>"] = "<cmd>Telescope diagnostics<cr>"
-- git
lvim.keys.normal_mode["<F8>"] = "<cmd>lua require 'gitsigns'.blame_line()<cr>"
lvim.keys.normal_mode["<F9>"] = "<cmd>lua require 'lvim.core.terminal'.lazygit_toggle()<cr>"

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

-- -------
-- LSP ---
--
lvim.lsp.installer.setup.automatic_installation = true
lvim.lsp.installer.setup.ensure_installed = {
  "sumneko_lua",
  "bashls",
  "yamlls"
}

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
  -- Extras
  {
    "ggandor/lightspeed.nvim",
    event = "BufRead",
  },
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
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "TroubleToggle", "trouble" },
  },
}
