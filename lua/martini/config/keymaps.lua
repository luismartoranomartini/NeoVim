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

-- Criar/abrir arquivo sob o cursor em nova aba.
-- Resolve o caminho relativo à PASTA DO ARQUIVO ATUAL (não ao diretório
-- de trabalho do Neovim), então um href="style.css" cria o CSS ao lado do HTML.
vim.keymap.set("n", "gf", function()
  local alvo = vim.fn.expand("<cfile>")
  if alvo == "" then
    vim.notify("Nenhum nome de arquivo sob o cursor", vim.log.levels.WARN)
    return
  end

  -- Se o caminho não for absoluto, junta com a pasta do arquivo atual
  if not alvo:match("^/") then
    local pasta_atual = vim.fn.expand("%:p:h")
    alvo = pasta_atual .. "/" .. alvo
  end

  vim.cmd("tabedit " .. vim.fn.fnameescape(alvo))
  -- Se o arquivo ainda não existe no disco, grava para criá-lo
  if not vim.uv.fs_stat(alvo) then
    vim.cmd("write")
  end
end, { desc = "Criar/Abrir arquivo sob o cursor (relativo à pasta atual)" })

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

-- Debugger (carregado sob demanda: martini.plugins.debug.setup()
-- só roda dapui/dap-go/dap-python na PRIMEIRA ação de debug,
-- não no boot — ver comentário em plugins/debug.lua)
local function dbg()
  require("martini.plugins.debug").setup()
  return require("dap")
end

vim.keymap.set("n", "<F5>",       function() dbg().continue() end,          { desc = "Debug: continuar / iniciar" })
vim.keymap.set("n", "<F10>",      function() dbg().step_over() end,         { desc = "Debug: passo sobre (step over)" })
vim.keymap.set("n", "<F11>",      function() dbg().step_into() end,         { desc = "Debug: passo para dentro (step into)" })
vim.keymap.set("n", "<F12>",      function() dbg().step_out() end,          { desc = "Debug: passo para fora (step out)" })
vim.keymap.set("n", "<leader>b",  function() dbg().toggle_breakpoint() end, { desc = "Debug: breakpoint" })
vim.keymap.set("n", "<leader>dr", function() dbg().repl.open() end,         { desc = "Debug: abrir REPL" })
vim.keymap.set("n", "<leader>dt", function() dbg().terminate() end,         { desc = "Debug: encerrar sessão" })
vim.keymap.set("n", "<leader>du", function()
  require("martini.plugins.debug").setup()
  require("dapui").toggle()
end, { desc = "Debug: interface visual" })

-- Code runner
vim.keymap.set("n", "<leader>r",  ":RunCode<CR>",    { desc = "Executar arquivo atual" })
vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { desc = "Executar projeto" })
