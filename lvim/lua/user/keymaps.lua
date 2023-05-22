M = {}
lvim.leader = "space"

local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set

-- Normal --
keymap("n", "<C-s>", ":w<cr>", opts)
keymap("n", "<C-Up>", "10kzz", opts)
keymap("n", "<C-Down>", "10jzz", opts)

-- word navigation
keymap("n", "n", "nzz", opts)
keymap("n", "N", "Nzz", opts)
keymap("n", "*", "*zz", opts)
keymap("n", "#", "#zz", opts)
keymap("n", "g*", "g*zz", opts)
keymap("n", "g#", "g#zz", opts)
-- tab navigation
keymap("n", "<S-Right>", ":BufferLineCycleNext<CR>", opts)
keymap("n", "<S-Left>", ":BufferLineCyclePrev<CR>", opts)
-- telescope
keymap("n", "<F2>", "<cmd>Telescope find_files<CR>", opts)
keymap("n", "<C-b>", "<cmd>Telescope buffers<CR>", opts)
keymap("n", "<C-f>", "<cmd>Telescope live_grep<CR>", opts)
-- spell check
keymap("n", "<F5>", ":set spell!<CR>", opts)
keymap("n", "<F6>", ":set spelllang=pt_br<CR>", opts)
keymap("n", "<F7>", ":set spelllang=en<CR>", opts)
-- lsp
keymap("n", "K", vim.lsp.buf.hover, opts)
keymap("n", "<C-K>", vim.lsp.buf.signature_help, opts)
keymap("n", "gD", vim.lsp.buf.declaration, opts)
keymap("n", "<C-LeftMouse>", vim.lsp.buf.definition, opts)
keymap("n", "gd", vim.lsp.buf.definition, opts)
keymap("n", "gI", vim.lsp.buf.implementation, opts)
keymap("n", "gci", vim.lsp.buf.incoming_calls, opts)
keymap("n", "gco", vim.lsp.buf.outgoing_calls, opts)
keymap("n", "gr", vim.lsp.buf.references, opts)
keymap("n", "gs", vim.lsp.buf.document_symbol, opts)
keymap("n", "gS", vim.lsp.buf.workspace_symbol, opts)
keymap("n", "gt", vim.lsp.buf.type_definition, opts)
keymap("n", ",rn", vim.lsp.buf.rename, opts)
-- trouble
keymap("n", "<F3>", "<cmd>TroubleToggle<cr>", opts)
-- diagnostic
keymap("n", "[d", vim.diagnostic.goto_prev, opts)
keymap("n", "]d", vim.diagnostic.goto_next, opts)
keymap("n", "<F4>", "<cmd>Telescope diagnostics<cr>", opts)
-- git
keymap("n", "<F8>", "<cmd>GitBlameToggle<cr>", opts)
keymap("n", "<F9>", "<cmd>lua require 'lvim.core.terminal'.lazygit_toggle()<cr>", opts)
-- lunarvim
keymap("n", "<C-Space>", "<cmd>WhichKey \\<space><cr>", opts)
-- zenmode
keymap("n", "<C-z>", "<cmd>ZenMode<cr>", opts)
-- diffview
keymap("n", ",d", ":DiffviewOpen<cr>", opts)
keymap("n", ",dq", ":DiffviewClose<cr>", opts)

return M
