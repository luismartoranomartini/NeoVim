-- =========================================================
-- lua/martini/utils/terminal.lua
-- Funções de terminal usadas por config/keymaps.lua e languages/go.lua.
-- Extraído para cá durante a reestruturação (ago/2026) — antes vivia
-- inline em config/keymaps.lua.
-- =========================================================

local M = {}

-- <leader>t — terminal horizontal embaixo, altura fixa 15, entra em insert.
-- Equivalente ao antigo mapeamento por string
-- ":botright split | resize 15 | terminal<CR>i".
function M.open_horizontal()
  vim.cmd("botright split | resize 15 | terminal")
  vim.cmd("startinsert")
end

-- <leader>vs — terminal vertical (lado a lado), sempre com um NOVO
-- processo de shell (não reaproveita buffer existente).
--
-- IMPORTANTE: usa <leader>vs, não <leader>tv — ver comentário em
-- config/keymaps.lua sobre a colisão com o prefixo de <leader>t.
function M.open_vertical()
  vim.cmd("vsplit")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

-- Ctrl-t — alterna: fecha o terminal se algum estiver visível em
-- qualquer janela, senão abre um novo horizontal.
function M.toggle()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      vim.api.nvim_win_close(win, false)
      return
    end
  end
  M.open_horizontal()
end

-- NOVO (set/2026) — run_test(cmd): usado por languages/go.lua nos
-- atalhos <leader>gt/<leader>ga/<leader>gr. Antes, cada execução de
-- teste abria um split NOVO (botright split | resize 15 | terminal),
-- empilhando splits e buffers de terminal órfãos a cada chamada —
-- perceptível em TDD, quando o teste roda dezenas de vezes seguidas
-- na mesma sessão.
--
-- Esta versão reaproveita a MESMA janela entre execuções: se a janela
-- de teste anterior ainda está aberta, foca nela e roda o comando novo
-- ali dentro, em vez de criar outro split. Ainda cria um buffer de
-- terminal novo a cada chamada (:terminal sempre gera um buffer — não
-- dá pra reescrever o conteúdo de um terminal já encerrado), mas o
-- número de SPLITS na tela não cresce mais, que era o problema
-- perceptível de verdade (tela lotada de divisões após várias rodadas).
local test_win = nil

function M.run_test(cmd)
  if test_win and vim.api.nvim_win_is_valid(test_win) then
    vim.api.nvim_set_current_win(test_win)
    vim.cmd("enew")
  else
    vim.cmd("botright split")
    vim.cmd("resize 15")
    test_win = vim.api.nvim_get_current_win()
  end
  vim.cmd("terminal " .. cmd)
  vim.cmd("startinsert")
end

return M
