vim.cmd [[command Format :lua require("user.utils").lsp_format({force = true})]]
vim.cmd [[command TSReload :write | edit | TSBufEnable highlight]]
vim.cmd [[command PeekOpen :lua require("peek").open()]]
vim.cmd [[command LineDiff :lua require("gitsigns").blame_line({full=true})]]
