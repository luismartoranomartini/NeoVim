-- =========================================================
-- lua/martini/plugins/textobjects.lua
-- Text objects via Treesitter (nvim-treesitter-textobjects, branch main)
-- Aplicável a qualquer filetype com parser instalado — por isso vive
-- em plugins/, não em languages/go.lua.
-- API nova (pós-reescrita): sem require("nvim-treesitter.configs").
-- Keymaps setados manualmente via os módulos .select e .move.
-- =========================================================

-- Desativa mapeamentos automáticos de ftplugins nativos que colidiriam
-- com os keymaps abaixo (ex.: [[/]] em alguns filetypes)
vim.g.no_plugin_maps = true

pcall(function()
  require("nvim-treesitter-textobjects").setup({
    select = {
      lookahead = true, -- pula pro próximo objeto se não estiver dentro de um
      selection_modes = {
        ["@parameter.outer"] = "v",
        ["@function.outer"] = "V",
        ["@class.outer"] = "V",
      },
    },
    move = {
      set_jumps = true, -- registra posição na jumplist (Ctrl-o/Ctrl-i funcionam)
    },
  })
end)

-- ── Select: if/af (function), ic/ac (class/struct), ia/aa (parameter) ──
local ok_select, select = pcall(require, "nvim-treesitter-textobjects.select")
if ok_select then
  local function sel(query) return function() select.select_textobject(query, "textobjects") end end

  vim.keymap.set({ "x", "o" }, "af", sel("@function.outer"), { desc = "Selecionar função (outer)" })
  vim.keymap.set({ "x", "o" }, "if", sel("@function.inner"), { desc = "Selecionar função (inner)" })
  vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer"), { desc = "Selecionar struct/class (outer)" })
  vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner"), { desc = "Selecionar struct/class (inner)" })
  vim.keymap.set({ "x", "o" }, "aa", sel("@parameter.outer"), { desc = "Selecionar parâmetro (outer)" })
  vim.keymap.set({ "x", "o" }, "ia", sel("@parameter.inner"), { desc = "Selecionar parâmetro (inner)" })
end

-- ── Move: ]f / [f pula entre funções, ]c / [c entre structs/classes ──
local ok_move, move = pcall(require, "nvim-treesitter-textobjects.move")
if ok_move then
  local function goto_next(query) return function() move.goto_next_start(query, "textobjects") end end
  local function goto_prev(query) return function() move.goto_previous_start(query, "textobjects") end end

  vim.keymap.set({ "n", "x", "o" }, "]f", goto_next("@function.outer"), { desc = "Próxima função" })
  vim.keymap.set({ "n", "x", "o" }, "]c", goto_next("@class.outer"), { desc = "Próxima struct/class" })
  vim.keymap.set({ "n", "x", "o" }, "[f", goto_prev("@function.outer"), { desc = "Função anterior" })
  vim.keymap.set({ "n", "x", "o" }, "[c", goto_prev("@class.outer"), { desc = "Struct/class anterior" })
end
