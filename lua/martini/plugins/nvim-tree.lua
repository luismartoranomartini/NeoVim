-- =========================================================
-- lua/martini/plugins/nvim-tree.lua
-- Extraído de plugins/ui.lua durante a reestruturação (ago/2026).
-- =========================================================

-- Decorator customizado: ícone + cor por NOME de pasta, estilo Material
-- Icon Theme do VSCode. API oficial do nvim-tree (nvim_tree.api.decorator.
-- UserDecorator), documentada em :help nvim-tree-decorators — estrutura
-- copiada do exemplo de referência da wiki oficial do plugin. Edite a
-- tabela "pasta_icones" abaixo pra adicionar mais nomes de pasta.
local pasta_icones = {
  cmd       = { str = "", hl = "NvimTreeFolderCmd" },       -- entrypoints
  internal  = { str = "", hl = "NvimTreeFolderInternal" },  -- código privado do módulo
  db        = { str = "", hl = "NvimTreeFolderDb" },        -- banco de dados
  views     = { str = "", hl = "NvimTreeFolderViews" },     -- views/templates
  models    = { str = "", hl = "NvimTreeFolderModels" },    -- modelos/entidades
  static    = { str = "", hl = "NvimTreeFolderStatic" },    -- assets estáticos
  templates = { str = "", hl = "NvimTreeFolderTemplates" }, -- templates HTML
  config    = { str = "", hl = "NvimTreeFolderConfig" },    -- configuração
  handlers  = { str = "", hl = "NvimTreeFolderHandlers" },  -- handlers HTTP
}

---@class (exact) MartiniFolderDecorator: nvim_tree.api.decorator.UserDecorator
local MartiniFolderDecorator = require("nvim-tree.api").decorator.UserDecorator:extend()

function MartiniFolderDecorator:new()
  self.enabled         = true
  self.highlight_range = "all"
  self.icon_placement  = "before"
end

---@param node nvim_tree.api.Node
---@return nvim_tree.api.HighlightedString? icon_node
function MartiniFolderDecorator:icon_node(node)
  if node.type ~= "directory" then return nil end
  local item = pasta_icones[node.name]
  if not item then return nil end
  return { str = item.str, hl = { item.hl } }
end

---@param node nvim_tree.api.Node
---@return string? highlight_group
function MartiniFolderDecorator:highlight_group(node)
  if node.type ~= "directory" then return nil end
  local item = pasta_icones[node.name]
  if not item then return nil end
  return item.hl
end

pcall(function()
  require("nvim-web-devicons").setup()
  require("nvim-tree").setup({
    view = {
      width = 30,
      side  = "left",
    },
    renderer = {
      group_empty   = false,
      highlight_git = true,
      indent_markers = {
        enable = true,
      },
      decorators = {
        "Git", "Open", "Hidden", "Modified", "Bookmark", "Diagnostics",
        "Copied", MartiniFolderDecorator, "Cut",
      },
      icons = {
        show = {
          file         = true,
          folder       = true,
          folder_arrow = true,
          git          = true,
          diagnostics  = true,
          modified     = true,
        },
      },
    },
    diagnostics = {
      enable            = true,
      show_on_dirs      = true,
      show_on_open_dirs = true,
    },
    filters = { dotfiles = false },
    git     = { enable = true, ignore = false },
    actions = {
      open_file = { quit_on_open = true },
    },
    on_attach = function(bufnr)
      local api = require("nvim-tree.api")
      api.config.mappings.default_on_attach(bufnr)
      vim.keymap.set("n", "<Tab>", api.node.open.tab, { buffer = bufnr, desc = "Abrir em nova aba" })
    end,
  })
end)
