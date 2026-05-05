---@type vim.lsp.Config
return {
  -- Monorepo layout: each directory containing .terraform or .git is its own root.
  -- This prevents terraform-ls from treating the entire repo as one workspace.
  root_dir = function(fname)
    return require("lspconfig.util").root_pattern(".terraform", ".terragrunt-cache", ".git")(fname)
  end,
  settings = {
    terraform = {
      validation = {
        enableEnhancedValidation = true,
      },
    },
  },
}
