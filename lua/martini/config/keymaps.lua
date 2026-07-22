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

-- Abrir/criar arquivo sob o cursor em nova aba.
-- Ordem de resolução do caminho:
--   1) URL (https?://)          -> abre no navegador via xdg-open
--   2) caminho absoluto         -> usado como está
--   3) relativo à pasta do arquivo atual (ex.: href="style.css")
--   4) relativo à raiz do projeto (.git ou go.mod) (ex.: import Go/Lua)
-- Só cria um arquivo novo se NENHUM candidato já existir no disco.
-- Se o arquivo já está aberto em outro buffer, reaproveita esse buffer.
vim.keymap.set("n", "gf", function()
  local alvo = vim.fn.expand("<cfile>")
  if alvo == "" then
    vim.notify("Nenhum nome de arquivo sob o cursor", vim.log.levels.WARN)
    return
  end

  -- URL: abre no navegador, não trata como caminho de arquivo
  if alvo:match("^https?://") then
    vim.fn.jobstart({ "xdg-open", alvo }, { detach = true })
    return
  end

  local pasta_atual = vim.fn.expand("%:p:h")
  local candidatos   = {}

  if alvo:match("^/") then
    table.insert(candidatos, alvo)
  else
    -- Candidato 1: relativo à pasta do arquivo atual
    table.insert(candidatos, vim.fs.normalize(pasta_atual .. "/" .. alvo))

    -- Candidato 2: relativo à raiz do projeto (git ou módulo Go)
    local raiz_encontrada = vim.fs.find({ ".git", "go.mod" }, { path = pasta_atual, upward = true })[1]
    if raiz_encontrada then
      local raiz = vim.fn.fnamemodify(raiz_encontrada, ":h")
      table.insert(candidatos, vim.fs.normalize(raiz .. "/" .. alvo))
    end
  end

  -- Usa o primeiro candidato que já existe no disco
  local encontrado = nil
  for _, caminho in ipairs(candidatos) do
    if vim.uv.fs_stat(caminho) then
      encontrado = caminho
      break
    end
  end

  local final = encontrado or candidatos[1]

  -- Se já existe um buffer carregado para esse arquivo, reaproveita em vez de recriar
  local bufnr = vim.fn.bufnr(final)
  if bufnr ~= -1 and vim.fn.bufloaded(bufnr) == 1 then
    vim.cmd("tabedit")
    vim.api.nvim_win_set_buf(0, bufnr)
    return
  end

  vim.cmd("tabedit " .. vim.fn.fnameescape(final))

  -- Só grava (criando o arquivo) se realmente não existir em nenhum candidato
  if not encontrado then
    vim.fn.mkdir(vim.fn.fnamemodify(final, ":h"), "p")
    vim.cmd("write")
  end
end, { desc = "Abrir/criar arquivo sob o cursor (pasta atual, raiz do projeto ou buffer já aberto)" })

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
vim.keymap.set("n", "<F5>",       function() require("dap").continue() end,          { desc = "Debug: continuar / iniciar" })
vim.keymap.set("n", "<F10>",      function() require("dap").step_over() end,         { desc = "Debug: passo sobre (step over)" })
vim.keymap.set("n", "<F11>",      function() require("dap").step_into() end,         { desc = "Debug: passo para dentro (step into)" })
vim.keymap.set("n", "<F12>",      function() require("dap").step_out() end,          { desc = "Debug: passo para fora (step out)" })
vim.keymap.set("n", "<leader>b",  function() require("dap").toggle_breakpoint() end, { desc = "Debug: breakpoint" })
vim.keymap.set("n", "<leader>dr", function() require("dap").repl.open() end,         { desc = "Debug: abrir REPL" })
vim.keymap.set("n", "<leader>dt", function() require("dap").terminate() end,         { desc = "Debug: encerrar sessão" })
vim.keymap.set("n", "<leader>du", function() require("dapui").toggle() end,          { desc = "Debug: interface visual" })

-- Code runner
vim.keymap.set("n", "<leader>r",  ":RunCode<CR>",    { desc = "Executar arquivo atual" })
vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { desc = "Executar projeto" })

