-- =========================================================
-- lua/martini/plugins/multicursor.lua
-- Multiplos cursores (jake-stewart/multicursor.nvim, branch 1.0)
-- =========================================================
local ok, erro = pcall(function()
  local mc = require("multicursor-nvim")
  mc.setup()
  local map = vim.keymap.set
  -- Adiciona cursor na linha de cima/baixo (funciona em normal e visual)
  map({ "n", "x" }, "<C-Up>",   function() mc.lineAddCursor(-1) end, { desc = "Multicursor: cursor acima" })
  map({ "n", "x" }, "<C-Down>", function() mc.lineAddCursor(1)  end, { desc = "Multicursor: cursor abaixo" })
  -- Pula uma linha sem adicionar cursor (util pra saltar blocos)
  map({ "n", "x" }, "<leader>mj", function() mc.lineSkipCursor(1)  end, { desc = "Multicursor: pular linha abaixo" })
  map({ "n", "x" }, "<leader>mk", function() mc.lineSkipCursor(-1) end, { desc = "Multicursor: pular linha acima" })
  -- Adiciona cursor na proxima/anterior ocorrencia da palavra sob o cursor
  -- (ou da selecao, em modo visual)
  map({ "n", "x" }, "<leader>mn", function() mc.matchAddCursor(1)  end, { desc = "Multicursor: proxima ocorrencia" })
  map({ "n", "x" }, "<leader>mN", function() mc.matchAddCursor(-1) end, { desc = "Multicursor: ocorrencia anterior" })
  map({ "n", "x" }, "<leader>ms", function() mc.matchSkipCursor(1)  end, { desc = "Multicursor: pular proxima ocorrencia" })
  map({ "n", "x" }, "<leader>mS", function() mc.matchSkipCursor(-1) end, { desc = "Multicursor: pular ocorrencia anterior" })
  -- Adiciona cursor em TODAS as ocorrencias do documento de uma vez
  map({ "n", "x" }, "<leader>mA", mc.matchAllAddCursors, { desc = "Multicursor: selecionar todas ocorrencias" })
  -- Alterna qual cursor e o "principal" (util pra revisar edicoes)
  map({ "n", "x" }, "<leader>mh", mc.prevCursor, { desc = "Multicursor: cursor principal anterior" })
  map({ "n", "x" }, "<leader>ml", mc.nextCursor, { desc = "Multicursor: proximo cursor principal" })
  -- Remove o cursor principal atual
  map({ "n", "x" }, "<leader>mx", mc.deleteCursor, { desc = "Multicursor: remover cursor" })
  -- Ctrl + clique esquerdo adiciona/remove cursor com o mouse
  map("n", "<C-LeftMouse>",    mc.handleMouse,       { desc = "Multicursor: adicionar cursor (mouse)" })
  map("n", "<C-LeftDrag>",     mc.handleMouseDrag,   { desc = "Multicursor: arrastar selecao (mouse)" })
  map("n", "<C-LeftRelease>",  mc.handleMouseRelease,{ desc = "Multicursor: soltar selecao (mouse)" })
  -- Ativa/desativa os cursores extras sem apaga-los
  map({ "n", "x" }, "<leader>mq", mc.toggleCursor, { desc = "Multicursor: ativar/desativar cursores" })
  -- Camada de atalhos que so vale enquanto ha multiplos cursores ativos.
  -- <Esc> aqui fecha o modo multicursor (ou desativa, se ja estiver desativado).
  mc.addKeymapLayer(function(layerSet)
    layerSet({ "n", "x" }, "<Esc>", function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      else
        mc.clearCursors()
      end
    end)
    layerSet({ "n", "x" }, "<leader>mh", mc.prevCursor)
    layerSet({ "n", "x" }, "<leader>ml", mc.nextCursor)
    layerSet({ "n", "x" }, "<leader>mx", mc.deleteCursor)
  end)
  -- Aparencia dos cursores extras — ajustada pra combinar com o tema
  -- preto/Tokyo Night definido em colors.lua
  local hl = vim.api.nvim_set_hl
  hl(0, "MultiCursorCursor",         { reverse = true })
  hl(0, "MultiCursorVisual",         { link = "Visual" })
  hl(0, "MultiCursorSign",           { link = "SignColumn" })
  hl(0, "MultiCursorMatchPreview",   { link = "Search" })
  hl(0, "MultiCursorDisabledCursor", { reverse = true })
  hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
  hl(0, "MultiCursorDisabledSign",   { link = "SignColumn" })
end)

-- DIAGNÓSTICO TEMPORÁRIO: antes, o pcall acima engolia qualquer erro
-- em silêncio (era só "pcall(function() ... end)", sem capturar o
-- resultado). Se algo dentro do bloco falhar — setup, algum map(),
-- addKeymapLayer, etc. — este aviso mostra exatamente o quê e onde.
if not ok then
  vim.notify("multicursor.lua ERRO: " .. tostring(erro), vim.log.levels.ERROR)
end
