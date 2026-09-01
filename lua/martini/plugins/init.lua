-- =========================================================
-- lua/martini/plugins/init.lua
-- Regra desta pasta: "plugins/ configura plugins, não o Neovim."
-- Cada arquivo aqui é responsável por UM plugin (ou um grupo bem
-- pequeno e coeso, como completion = cmp+luasnip).
-- =========================================================
require("martini.plugins.treesitter")
require("martini.plugins.textobjects") -- depende dos parsers registrados acima
require("martini.plugins.editing")
require("martini.plugins.nvim-tree")
require("martini.plugins.bufferline")
require("martini.plugins.completion")
require("martini.plugins.lsp")
require("martini.plugins.format")
require("martini.plugins.debug")
require("martini.plugins.runner")
require("martini.plugins.http")
require("martini.plugins.multicursor")
require("martini.plugins.finder")
