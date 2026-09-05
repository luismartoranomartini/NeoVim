-- =========================================================
-- lua/martini/utils/terminal.lua
-- Funções de terminal usadas por config/keymaps.lua.
-- =========================================================

local M = {}

-- <leader>t — terminal horizontal embaixo, altura fixa 15, entra em insert.
function M.open_horizontal()
  vim.cmd("botright split | resize 15 | terminal")
  vim.cmd("startinsert")
end

-- <leader>vs — terminal vertical (lado a lado), sempre com um NOVO
-- processo de shell (não reaproveita buffer existente).
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

return M
