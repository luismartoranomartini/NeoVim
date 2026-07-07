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

-- Salvar todos os buffers modificados de uma vez (:wa nativo do Neovim)
vim.keymap.set("n", "<leader>W",  ":wa<CR>",  { desc = "Salvar todos os buffers" })
-- Salvar todos os buffers e sair do Neovim (:xa nativo do Neovim)
vim.keymap.set("n", "<leader>WQ", ":xa<CR>",  { desc = "Salvar todos os buffers e sair" })

-- Criar/abrir arquivo sob o cursor em nova aba.
-- Resolve o caminho relativo à PASTA DO ARQUIVO ATUAL (não ao diretório
-- de trabalho do Neovim), então um href="style.css" cria o CSS ao lado do HTML.
vim.keymap.set("n", "gf", function()
  local alvo = vim.fn.expand("<cfile>")
  if alvo == "" then
    vim.notify("Nenhum nome de arquivo sob o cursor", vim.log.levels.WARN)
    return
  end

  -- Resolve o caminho ABSOLUTO real do arquivo atual PRIMEIRO.
  -- Isso evita o bug de "salva na pasta errada" quando o arquivo foi
  -- aberto com um caminho relativo (ex.: `n projetos/site/index.html`
  -- a partir de outra pasta): sem essa conversão explícita, contas de
  -- pasta feitas a partir de "%:p:h" podem herdar o caminho relativo
  -- torto em vez da pasta real do arquivo no disco.
  local arquivo_atual = vim.fn.expand("%")
  if arquivo_atual == "" then
    vim.notify("Buffer atual não está associado a um arquivo", vim.log.levels.WARN)
    return
  end

  local arquivo_absoluto = vim.fn.fnamemodify(arquivo_atual, ":p")
  local pasta_arquivo    = vim.fn.fnamemodify(arquivo_absoluto, ":h")

  -- Se o alvo já for uma URL completa (http/https), não faz sentido
  -- juntar com a pasta local nem normalizar como caminho de arquivo —
  -- isso corromperia o endereço (ex.: viraria "/pasta/https://site.com").
  -- Abre direto no navegador do sistema via xdg-open, sem consumir uma
  -- aba do Neovim. jobstart({...}, {detach=true}) é o método confiável
  -- no Linux; vim.system() combinado com xdg-open tem falha silenciosa
  -- conhecida e documentada no repositório oficial do Neovim (issue
  -- #24567 em github.com/neovim/neovim).
  if alvo:match("^https?://") then
    vim.fn.jobstart({ "xdg-open", alvo }, { detach = true })
    return
  end

  -- Se o alvo não for absoluto, junta com a pasta do arquivo atual
  if not alvo:match("^/") then
    alvo = pasta_arquivo .. "/" .. alvo
  end

  -- Normaliza o caminho (resolve "..", "." etc.)
  alvo = vim.fn.fnamemodify(alvo, ":p")

  -- Se o alvo for um arquivo HTML (ex.: <a href="sobre.html">), abre
  -- no navegador em vez de como texto no Neovim, pelo mesmo motivo:
  -- manter o buffer de código disponível enquanto a página renderizada
  -- aparece em outra janela.
  if alvo:match("%.html?$") then
    vim.fn.jobstart({ "xdg-open", alvo }, { detach = true })
    return
  end

  local existe = vim.uv.fs_stat(alvo) ~= nil

  -- Garante que a subpasta de destino exista antes de abrir/gravar
  if not existe then
    local pasta_destino = vim.fn.fnamemodify(alvo, ":h")
    if vim.fn.isdirectory(pasta_destino) == 0 then
      local ok_mkdir = vim.fn.mkdir(pasta_destino, "p")
      if ok_mkdir == 0 then
        vim.notify("Falha ao criar pasta: " .. pasta_destino, vim.log.levels.ERROR)
        return
      end
    end
  end

  local ok_open, erro_open = pcall(vim.cmd, "tabedit " .. vim.fn.fnameescape(alvo))
  if not ok_open then
    vim.notify("Falha ao abrir: " .. erro_open, vim.log.levels.ERROR)
    return
  end

  if not existe then
    local ok_write, erro_write = pcall(vim.cmd, "write")
    if not ok_write then
      vim.notify("Falha ao criar arquivo: " .. erro_write, vim.log.levels.ERROR)
    end
  end
end, { desc = "Criar/Abrir arquivo sob o cursor (relativo à pasta do arquivo atual, cria subpastas se necessário)" })

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
