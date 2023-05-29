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
  "nyoom-engineering/oxocarbon.nvim",
  {
    "sindrets/diffview.nvim",
    dependencies = 'nvim-lua/plenary.nvim'
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
    build = "cd app && npm install",
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
    "zbirenbaum/copilot.lua",
    opts = {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = false,
      },
      filetypes = {
        ["*"] = true,
      },
    },
    event = "VeryLazy",
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      "FelipeLema/cmp-async-path",
      "lukas-reineke/cmp-under-comparator",
      {
        "zbirenbaum/copilot-cmp",
        dependencies = {
          "copilot.lua",
        },
        config = true,
      },
      {
        "onsails/lspkind-nvim",
        dependencies = {
          "nvim-treesitter/nvim-treesitter",
        },
        config = function()
          require("lspkind").init({
            preset = "codicons",
            symbol_map = {
              Copilot = "",
            },
          })
          vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#69ae6a" })
        end,
      },
    },
    event = "InsertEnter",
    config = function()
      require("user.completion")
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "TroubleToggle", "Trouble" },
  },
  {
    "saecki/crates.nvim",
    version = "v0.3.0",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup {
        null_ls = {
          enabled = true,
          name = "crates.nvim",
        },
      }
    end,
  }
}
