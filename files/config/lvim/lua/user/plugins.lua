lvim.plugins = {
  "kylechui/nvim-surround",
  "vim-syntastic/syntastic",
  "ruifm/gitlinker.nvim",
  "windwp/nvim-ts-autotag",
  "wakatime/vim-wakatime",
  "f-person/git-blame.nvim",
  "mfussenegger/nvim-jdtls",
  "lunarvim/darkplus.nvim",
  "folke/todo-comments.nvim",
  "folke/zen-mode.nvim",
  "nacro90/numb.nvim",
  "ghillb/cybu.nvim",
  "lvimuser/lsp-inlayhints.nvim",
  "petertriho/nvim-scrollbar",
  "jose-elias-alvarez/typescript.nvim",
  "windwp/nvim-spectre",
  {
    "sindrets/diffview.nvim",
    requires = 'nvim-lua/plenary.nvim'
  },
  {
    "ggandor/lightspeed.nvim",
    event = "BufRead",
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
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
  {
    "saecki/crates.nvim",
    tag = "v0.3.0",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup {
        null_ls = {
          enabled = true,
          name = "crates.nvim",
        },
      }
    end,
  },
}
