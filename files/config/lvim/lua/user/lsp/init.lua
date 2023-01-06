require "lsp.languages.go"
require "lsp.languages.python"
require "lsp.languages.js-ts"
require "lsp.languages.sh"

lvim.lsp.diagnostics.virtual_text = false
lvim.lsp.diagnostics.float.focusable = true

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "jdtls" })

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "google_java_format", filetypes = { "java" } },
  { command = "stylua", filetypes = { "lua" } },
}
