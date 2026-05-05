---@type vim.lsp.Config
return {
  cmd = { "helm_ls", "serve" },
  filetypes = { "helm" },
  settings = {
    ["helm-ls"] = {
      logLevel = "info",
      valuesFiles = {
        mainValuesFile = "values.yaml",
        lintOverlayValuesFile = "values.lint.yaml",
        additionalValuesFilesGlobPattern = "values*.yaml",
      },
      helmLint = {
        -- Run `helm lint` on save. Catches missing values, invalid YAML
        -- structure, schema violations and malformed template expressions.
        enabled = true,
        ignoredMessages = {},
      },
      yamlls = {
        -- helm-ls delegates YAML-within-helm to yamlls internally for schema
        -- validation on values files. Requires yaml-language-server on PATH.
        enabled = true,
        enabledForFilesGlob = "*.{yaml,yml}",
        diagnosticsLimit = 50,
        showDiagnosticsDirectly = false,
        path = "yaml-language-server",
        initTimeoutSeconds = 3,
        config = {
          schemas = {
            -- Apply Kubernetes API schema to all template files so yamlls
            -- validates apiVersion/kind/spec structure within helm-ls.
            kubernetes = "templates/**",
          },
          completion = true,
          hover = true,
        },
      },
    },
  },
}
