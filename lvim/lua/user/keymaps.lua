local utils = require("user.utils")

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
keymap("n", "<F2>", utils.find_files, opts)
keymap("n", "<C-b>", "<cmd>Telescope buffers<CR>", opts)
keymap("n", "<C-f>", utils.grep, opts)
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
			g = {
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

return M
