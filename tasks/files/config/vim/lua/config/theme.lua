local M = {}

local function setup_themer()
  local themer = require("themer")
  local utils = require("themer.utils.colors")
  local colors = require("themer.modules.themes.sakura")

  themer.setup({
    colorscheme = "sakura",
    remaps = {
      highlights = {
        globals = {
          base = {
            Visual = {
              bg = utils.lighten(colors.bg.selected, 0.8),
            },
            LspReferenceText = {
              bg = utils.lighten(colors.bg.alt, 0.7),
            },
            LspReferenceRead = {
              bg = utils.lighten(colors.bg.alt, 0.7),
            },
            LspReferenceWrite = {
              bg = utils.lighten(colors.bg.alt, 0.7),
            },
          },
        },
      },
    },
  })
end

local function setup_lualine()
  local utils = require("themer.utils.colors")
  local colors = require("themer.modules.core.api").get_cp("jellybeans")
  local theme = require("lualine.themes.jellybeans")
  local bgs = {
    normal = colors.blue,
    insert = colors.yellow,
    command = colors.syntax.constant,
    visual = colors.magenta,
    replace = colors.syntax.constant,
    inactive = colors.bg.alt,
  }
  for kind, bg in pairs(bgs) do
    vim.tbl_deep_extend("force", theme, {
      [kind] = {
        a = { bg = bg, fg = colors.bg.alt, gui = "NONE" },
        b = { bg = utils.lighten(colors.bg.alt, 0.95), fg = colors.accent },
        c = { bg = colors.bg.alt, fg = colors.cursorlinenr },
      },
    })
  end
  require("lualine").setup({
    options = {
      -- theme = theme,
      component_separators = { left = "｜", right = "｜" },
    },
    sections = {
      lualine_b = { "branch", "diagnostics" },
      lualine_c = {
        { "filename", path = 1 },
      },
      lualine_x = {
        {
          "lsp_progress",
          spinner_symbols = { "◴", "◷", "◶", "◵" },
        },
        "encoding",
        "fileformat",
        "filetype",
      },
    },
    extensions = {
      "nvim-tree",
    },
  })
end

local function setup_tabline()
  local themes = require("tabline.themes")
  local theme = require("tabline.themes.default").theme()
  theme = vim.tbl_extend("force", theme, {
    name = "jellybeans",
    TFill = "link %s ThemerNormalFloat",
    TNumSel = "link %s ThemerAccentFloat",
    TNum = "link %s ThemerAccentFloat",
    TCorner = "link %s ThemerAccentFloat",
  })
  for _, hl_name in ipairs({ "TSelect", "TSpecial" }) do
    theme = vim.tbl_extend("force", theme, {
      [hl_name] = "link %s ThemerNormal",
      [hl_name .. "Dim"] = "link %s ThemerDimmed",
      [hl_name .. "Sep"] = "link %s ThemerSubtle",
      [hl_name .. "Mod"] = "link %s ThemerAccent",
    })
  end
  for _, hl_name in ipairs({ "TVisible", "THidden", "TExtra" }) do
    theme = vim.tbl_extend("force", theme, {
      [hl_name] = "link %s ThemerFloat",
      [hl_name .. "Dim"] = "link %s ThemerDimmedFloat",
      [hl_name .. "Sep"] = "link %s ThemerSubtleFloat",
      [hl_name .. "Mod"] = "link %s ThemerAccentFloat",
    })
  end
  themes.add(theme)
  require("tabline.setup").setup({
    modes = { "tabs" },
    theme = "themer",
  })
end

M.setup = function()
  setup_themer()
  setup_lualine()
  setup_tabline()
end

return M
