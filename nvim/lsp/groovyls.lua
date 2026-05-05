---@type vim.lsp.Config
-- groovy-language-server must be built first.
-- Bootstrap does this automatically via _groovyls; see scripts/bootstrapping/common.sh.
-- JAR location: ~/.local/share/groovyls/groovy-language-server-all.jar
local jar = vim.fn.expand("~/.local/share/groovyls/groovy-language-server-all.jar")

if vim.fn.filereadable(jar) == 0 then
  return {}
end

return {
  cmd = { "java", "-jar", jar },
  filetypes = { "groovy" },
  root_dir = function(fname)
    return require("lspconfig.util").root_pattern(
      "Jenkinsfile",
      "build.gradle",
      "build.gradle.kts",
      ".git"
    )(fname)
  end,
  settings = {
    groovy = {
      classpath = {},
    },
  },
}
