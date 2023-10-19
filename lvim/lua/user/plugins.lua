lvim.plugins = {
  -- Themes
  "nyoom-engineering/oxocarbon.nvim",

  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPost",
    dependencies = {
      "nvimtools/none-ls.nvim",
      "b0o/schemastore.nvim",
      "SmiteshP/nvim-navic",
      {
        "ray-x/lsp_signature.nvim",
        opts = {
          hint_enable = false,
          toggle_key = "<C-K>",
        },
      },
    },
    config = function()
      require("user.lsp")
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "TroubleToggle", "Trouble" },
    opts = {
      close = "<C-q>",
      padding = false,
      auto_preview = false,
      use_diagnostic_signs = true,
    },
  },

  -- Completion
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      disable_in_macro = true,
      check_ts = true,
    },
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
        "L3MON4D3/LuaSnip",
        dependencies = {
          "saadparwaiz1/cmp_luasnip",
          "rafamadriz/friendly-snippets",
        },
        build = "make install_jsregexp",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      {
        "onsails/lspkind-nvim",
        dependencies = {
          "nvim-treesitter/nvim-treesitter",
        },
        config = function()
          require("lspkind").init({
            symbol_map = {
              Copilot = "",
              Codeium = "",
            },
          })
          vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#69ae6a" })
          vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = "#69ae6a" })
        end,
      },
    },
    event = "InsertEnter",
    config = function()
      require("user.completion")
    end,
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      keymaps = {
        submit = { "<C-Enter>", "<C-Space>" },
      },
    },
  },
  {
    "jcdickinson/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    event = "VeryLazy",
    config = function()
      require("codeium").setup({})
    end,
  },

  -- Testing
  {
    "mfussenegger/nvim-dap",
    event = "BufReadPost",
    config = function()
      require("user.dap")
    end,
    dependencies = {
      {
        "mfussenegger/nvim-dap-python",
        config = false,
      },
      {
        "rcarriga/nvim-dap-ui",
        config = true,
      },
    },
  },
  {
    "nvim-neotest/neotest",
    event = "BufReadPost",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            args = { "-vvv", "--no-cov", "--disable-warnings" },
          }),
        },
        quickfix = {
          enabled = false,
          open = false,
        },
        output = {
          enabled = true,
          open_on_run = false,
        },
        status = {
          enabled = true,
          signs = true,
          virtual_text = true,
        },
      })
    end,
  },

  -- UI
  "petertriho/nvim-scrollbar",
  {
    "Bekaboo/dropbar.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "neovim/nvim-lspconfig",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      menu = {
        keymaps = {
          ["<Esc>"] = "<C-w>q",
          ["<Left>"] = "<C-w>c",
          ["<Right>"] = function()
            local menu = require("dropbar.api").get_current_dropbar_menu()
            if not menu then
              return
            end
            local cursor = vim.api.nvim_win_get_cursor(menu.win)
            local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
            if component then
              menu:click_on(component, nil, 1, "l")
            end
          end,
        },
      },
    },
  },
  {
    "stevearc/dressing.nvim",
    opts = {
      input = {
        insert_only = true,
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        background_colour = "#000000",
        timeout = 2000,
      })
      vim.notify = notify
    end,
  },
  {
    "sindrets/winshift.nvim",
    event = "BufReadPost",
  },
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    init = function()
      vim.g.navic_silence = 1
    end,
    opts = {
      separator = " ⇒ ",
    },
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
  "folke/todo-comments.nvim",
  "folke/zen-mode.nvim",
  "ghillb/cybu.nvim",

  -- Git
  "ruifm/gitlinker.nvim",
  "f-person/git-blame.nvim",
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
  },

  -- Typing
  "kylechui/nvim-surround",
  {
    "ggandor/lightspeed.nvim",
    event = "BufRead",
  },

  -- Utils
  {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    ft = "markdown",
  },
  "windwp/nvim-spectre",
  "wakatime/vim-wakatime",
}
