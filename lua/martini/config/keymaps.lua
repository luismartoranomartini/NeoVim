-- =========================================================
-- lua/martini/config/keymaps.lua
-- Atalhos globais de teclado
-- =========================================================

-- Arquivos e navegação
vim.keymap.set("n", "<leader>n",  ":tabnew<CR>")
vim.keymap.set("n", "<leader>e",  ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>t",  ":botright split | resize 15 | terminal<CR>i")

-- Buffers e abas
vim.keymap.set("n", "<leader>bd", ":bd<CR>",       { desc = "Fechar buffer" })
vim.keymap.set("n", "<leader>bD", ":bd!<CR>",      { desc = "Fechar buffer (forçado)" })
vim.keymap.set("n", "<leader>w",  ":tabclose<CR>", { desc = "Fechar aba atual" })

-- Criar/abrir arquivo sob o cursor em nova aba
vim.keymap.set("n", "gf", function()
  local arquivo = vim.fn.expand("<cfile>")
  vim.cmd("tabedit " .. vim.fn.fnameescape(arquivo))
  if not vim.uv.fs_stat(arquivo) then vim.cmd("write") end
end, { desc = "Criar/Abrir arquivo sob o cursor (nova aba)" })

-- Terminal
vim.keymap.set("t", "<Esc>",  "<C-\\><C-n>",       { desc = "Sair do modo terminal" })
vim.keymap.set("t", "<C-w>",  "<C-\\><C-n><C-w>",  { desc = "Navegar splits de dentro do terminal" })
vim.keymap.set("t", "<C-q>",  "<C-\\><C-n><C-w>q", { desc = "Fechar terminal" })

local function toggle_terminal()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      vim.api.nvim_win_close(win, false)
      return
    end
  end
  vim.cmd("botright split | resize 15 | terminal")
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<C-t>", toggle_terminal,         { desc = "Toggle terminal" })
vim.keymap.set("t", "<C-t>", "<C-\\><C-n><C-w>q",    { desc = "Fechar terminal com Ctrl+t" })

-- Debugger
vim.keymap.set("n", "<F5>",       function() require("dap").continue() end)
vim.keymap.set("n", "<leader>b",  function() require("dap").toggle_breakpoint() end)
vim.keymap.set("n", "<leader>du", function() require("dapui").toggle() end)

-- Code runner
vim.keymap.set("n", "<leader>r",  ":RunCode<CR>",    { desc = "Executar arquivo atual" })
vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { desc = "Executar projeto" })