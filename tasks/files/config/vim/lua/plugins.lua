local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  BOOTSTRAPED = vim.fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
end

local packer = require("packer")

packer.init({
  luarocks = {
    python_cmd = "python3",
  },
  display = {
    open_cmd = "topleft 65vnew \\[packer\\]",
  },
})

return packer.startup(function(use, use_rocks)
  -- Packer manage itself
  use({ "wbthomason/packer.nvim" })

  -- Treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("config.treesitter")
    end,
    requires = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "windwp/nvim-ts-autotag",
      {
        "nvim-treesitter/playground",
        cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
      },
      {
        "norcalli/nvim-colorizer.lua",
        config = function()
          require("colorizer").setup({
            "*",
            python = { names = false },
          })
        end,
      },
    },
  })

  -- LSP
  use({
    "neovim/nvim-lspconfig",
    config = function()
      require("config.lsp")
    end,
    requires = {
      "jose-elias-alvarez/null-ls.nvim",
      "b0o/schemastore.nvim",
      use({
        "ray-x/lsp_signature.nvim",
        config = function()
          require("lsp_signature").setup({
            hint_enable = false,
            toggle_key = "<C-K>",
          })
        end,
      }),
    },
  })
  use({
    "ThePrimeagen/refactoring.nvim",
    config = function()
      require("refactoring").setup({})
    end,
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  })
  use({
    -- FIXME: Go back to the original repo once my PRs are merged
    -- "folke/trouble.nvim",
    "bellini666/trouble.nvim",
    config = function()
      require("trouble").setup({
        close = "<C-q>",
        padding = false,
        auto_preview = false,
        use_diagnostic_signs = true,
        track_cursor = true,
      })
    end,
    requires = "kyazdani42/nvim-web-devicons",
  })

  -- Completion
  use({
    "hrsh7th/nvim-cmp",
    config = function()
      require("config.completion")
    end,
    requires = {
      "windwp/nvim-autopairs",
      "lukas-reineke/cmp-under-comparator",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      {
        "L3MON4D3/LuaSnip",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
        requires = {
          "saadparwaiz1/cmp_luasnip",
          "rafamadriz/friendly-snippets",
        },
      },
      {
        "onsails/lspkind-nvim",
        config = function()
          require("lspkind").init({
            preset = "codicons",
          })
        end,
        requires = {
          "nvim-treesitter/nvim-treesitter",
        },
      },
    },
  })
  use({
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({
        disable_in_macro = true,
      })
    end,
  })

  -- DAP
  use({
    "mfussenegger/nvim-dap",
    config = function()
      require("config.dap")
    end,
    requires = {
      {
        "rcarriga/nvim-dap-ui",
        config = function()
          require("dapui").setup()
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        config = function()
          require("nvim-dap-virtual-text").setup()
        end,
        requires = {
          "nvim-treesitter/nvim-treesitter",
        },
      },
    },
  })

  -- UI
  use({
    "themercorp/themer.lua",
    config = function()
      require("config.theme").setup()
    end,
    requires = {
      {
        "mg979/tabline.nvim",
        requires = { "kyazdani42/nvim-web-devicons" },
      },
      {
        "nvim-lualine/lualine.nvim",
        requires = {
          "kyazdani42/nvim-web-devicons",
          "arkav/lualine-lsp-progress",
        },
      },
    },
  })
  use({
    "stevearc/dressing.nvim",
    config = function()
      require("dressing").setup({
        input = {
          insert_only = true,
        },
      })
    end,
  })
  use({
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        timeout = 750,
      })
      vim.notify = notify
    end,
  })
  use({ "sindrets/winshift.nvim" })

  -- File browsing
  use({
    "nvim-telescope/telescope.nvim",
    config = function()
      require("telescope").load_extension("fzf")
      local trouble = require("trouble.providers.telescope")
      require("telescope").setup({
        defaults = {
          prompt_prefix = "???? ",
          selection_caret = "??? ",
          dynamic_preview_title = true,
          mappings = {
            i = {
              ["<Esc>"] = require("telescope.actions").close,
              ["<c-q>"] = trouble.open_with_trouble,
            },
            n = {
              ["<C-q>"] = trouble.open_with_trouble,
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })
    end,
    requires = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        run = "make",
      },
    },
  })
  use({
    "kyazdani42/nvim-tree.lua",
    cmd = "NvimTreeToggle",
    config = function()
      vim.g.nvim_tree_quit_on_open = 1
      require("nvim-tree").setup({
        auto_close = true,
      })
    end,
    requires = { "kyazdani42/nvim-web-devicons" },
  })

  -- Terminal integration
  use({
    "numToStr/FTerm.nvim",
    config = function()
      require("FTerm").setup({
        border = "double",
        dimensions = {
          height = 0.9,
          width = 0.9,
        },
      })
    end,
  })

  -- Language specifics
  use({
    "Vimjas/vim-python-pep8-indent",
    ft = "python",
  })
  use({
    "danymat/neogen",
    config = function()
      require("neogen").setup({
        enabled = true,
      })
    end,
    requires = "nvim-treesitter/nvim-treesitter",
  })

  -- Text editing
  use({ "ggandor/lightspeed.nvim" })
  use({ "tpope/vim-repeat" })
  use({ "tpope/vim-surround" })
  use({ "tpope/vim-unimpaired" })
  use({ "tpope/vim-speeddating" })
  use({ "wakatime/vim-wakatime" })
  use({
    "mbbill/undotree",
    cmd = "UndotreeToggle",
  })
  use({
    "mg979/vim-visual-multi",
    config = function()
      -- Use colors from themer
      vim.g.VM_Mono_hl = "ThemerSearchResult"
      vim.g.VM_Extend_hl = "ThemerSearchResult"
      vim.g.VM_Cursor_hl = "ThemerSearchResult"
      vim.g.VM_Insert_hl = "Cursor"
    end,
    branch = "master",
    requires = "themercorp/themer.lua",
    keys = "<C-n>",
  })
  use({
    "ethanholz/nvim-lastplace",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help", "Trouble" },
        lastplace_ignore_filetype = { "gitcommit", "gitrebase" },
      })
    end,
  })
  use({
    "lewis6991/spellsitter.nvim",
    config = function()
      require("spellsitter").setup()
    end,
  })
  use({
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
    keys = { { "n", "gcc" }, { "v", "gc" } },
  })

  if BOOTSTRAPED then
    packer.sync()
  end
end)
