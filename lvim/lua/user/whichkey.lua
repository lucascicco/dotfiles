local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

local new_maps = {
  R = {
    name = "Spectre Replace",
    r = { "<cmd>lua require('spectre').open()<cr>", "Replace" },
    w = { "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", "Replace Word" },
    f = { "<cmd>lua require('spectre').open_file_search()<cr>", "Replace Buffer" },
  },
  g = {
    d = {
      "<cmd>:DiffviewOpen<CR>",
      "Diffview",
    },
    D = {
      "<cmd>:DiffviewClose<CR>",
      "Diffview Close",
    },
    l = {
      "<cmd>GitBlameToggle<CR>",
      "Blame",
    },
  },
  t = {
    name = "Trouble",
    r = { "<cmd>Trouble lsp_references<cr>", "References" },
    f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
    q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
    l = { "<cmd>Trouble loclist<cr>", "LocationList" },
    d = { "<cmd>Trouble document_diagnostics<cr>", "Document Diagnostics" },
    D = { "<cmd>Trouble workspace_diagnostics<cr>", "Workspace Diagnostics" },
  },
  ["["] = {
    name = "Previous trouble result",
    d = {
      vim.diagnostic.goto_prev,
      "Go to previous diagnostic",
      silent = true,
    },
    q = {
      function()
        require("trouble").previous({ skip_groups = true, jump = true })
      end,
      "Previous trouble result",
    },
    Q = {
      function()
        require("trouble").first({ skip_groups = true, jump = true })
      end,
      "First trouble result",
    },
  },
  ["]"] = {
    name = "Next trouble result",
    d = {
      vim.diagnostic.goto_next,
      "Go to next diagnostic",
      silent = true,
    },
    q = {
      function()
        require("trouble").next({ skip_groups = true, jump = true })
      end,
      "Next trouble result",
    },
    Q = {
      function()
        require("trouble").last({ skip_groups = true, jump = true })
      end,
      "Last trouble result",
    },
  },
  ["<C-w>"] = {
    r = {
      function()
        require("smart-splits").start_resize_mode()
      end,
      "Smart resize",
    },
  },
}

for k, v in pairs(new_maps) do
  if lvim.builtin.which_key.mappings[k] ~= nil and type(v) == "table" then
    -- Let's merge then (subcommands), but for now we handle
    -- only the second nested table
    -- if it's needed, we should try a recursive merge function
    for k_v, v_v in pairs(v) do
      lvim.builtin.which_key.mappings[k][k_v] = v_v
    end
  else
    lvim.builtin.which_key.mappings[k] = v
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    which_key.register({
      K = { vim.lsp.buf.hover, "LSP hover", buffer = ev.buf, silent = true },
      ["<C-K>"] = {
        vim.lsp.buf.signature_help,
        "LSP signature help",
        buffer = ev.buf,
        silent = true,
      },
      ["<C-LeftMouse>"] = {
        function()
          require("telescope.builtin").lsp_definitions()
        end,
        "LSP hover",
        buffer = ev.buf,
        silent = true,
      },
      ["<C-P>"] = {
        d = {
          function()
            require("telescope.builtin").lsp_definitions()
          end,
          "LSP go to definition",
          buffer = ev.buf,
          silent = true,
        },
        D = { vim.lsp.buf.declaration, "LSP go to declaration", buffer = ev.buf, silent = true },
        I = {
          function()
            require("telescope.builtin").lsp_implementations()
          end,
          "LSP go to implementation",
          buffer = ev.buf,
          silent = true,
        },
        c = {
          name = "callhierarchy",
          i = {
            function()
              require("telescope.builtin").lsp_incoming_calls()
            end,
            "LSP incoming calls",
            buffer = ev.buf,
            silent = true,
          },
          o = {
            function()
              require("telescope.builtin").lsp_outgoing_calls()
            end,
            "LSP outgoing calls",
            buffer = ev.buf,
            silent = true,
          },
        },
        r = {
          function()
            require("telescope.builtin").lsp_references({ jump_type = "never" })
          end,
          "LSP references",
          buffer = ev.buf,
          silent = true,
        },
        s = {
          function()
            require("telescope.builtin").lsp_document_symbols()
          end,
          "LSP document symbols",
          buffer = ev.buf,
          silent = true,
        },
        S = {
          function()
            require("telescope.builtin").lsp_workspace_symbols()
          end,
          "LSP workspace symbols",
          buffer = ev.buf,
          silent = true,
        },
      },
      ["<leader>"] = {
        D = {
          function()
            require("telescope.builtin").lsp_type_definitions()
          end,
          "LSP type definition",
          buffer = ev.buf,
          silent = true,
        },
        ca = {
          vim.lsp.buf.code_action,
          "LSP code action",
          buffer = ev.buf,
          silent = true,
          mode = { "n", "v" },
        },
        rn = { vim.lsp.buf.rename, "LSP rename", buffer = ev.buf, silent = true },
        w = {
          name = "workspace",
          l = {
            function()
              vim.print(vim.lsp.buf.list_workspace_folders())
            end,
            "LSP list workspace",
            buffer = ev.buf,
            silent = true,
          },
          a = {
            vim.lsp.buf.add_workspace_folder,
            "LSP add workspace folder",
            buffer = ev.buf,
            silent = true,
          },
          r = {
            vim.lsp.buf.add_workspace_folder,
            "LSP remove workspace folder",
            buffer = ev.buf,
            silent = true,
          },
        },
      },
    })
  end,
})
