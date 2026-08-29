-- =========================================================
-- lua/martini/utils/path.lua
-- Resolução e criação de arquivos usadas por config/keymaps.lua.
-- Extraído para cá durante a reestruturação (ago/2026) — antes vivia
-- inline em config/keymaps.lua, dentro do próprio mapeamento gf.
-- =========================================================

local M = {}

-- Resolve `alvo` relativo à PASTA DO ARQUIVO ATUAL (não ao diretório de
-- trabalho do Neovim) quando não for um caminho absoluto — assim um
-- href="style.css" resolve para o CSS ao lado do HTML atual, não do cwd.
function M.resolve_relative(alvo)
  if alvo:match("^/") then return alvo end
  local pasta_atual = vim.fn.expand("%:p:h")
  return pasta_atual .. "/" .. alvo
end

-- gf — cria/abre em nova aba o arquivo sob o cursor.
-- Comportamento INALTERADO em relação à versão anterior (a reestruturação
-- só moveu o código de lugar, não a lógica): continua criando o arquivo e
-- os diretórios intermediários automaticamente se ainda não existirem,
-- porque essa é a conveniência real usada no dia a dia (ex.: seguir um
-- href="css/style.css" que ainda não existe já cria o arquivo e a pasta).
function M.goto_or_create()
  local alvo = vim.fn.expand("<cfile>")
  if alvo == "" then
    vim.notify("Nenhum nome de arquivo sob o cursor", vim.log.levels.WARN)
    return
  end

  alvo = M.resolve_relative(alvo)

  vim.cmd("tabedit " .. vim.fn.fnameescape(alvo))

  -- Se o arquivo ainda não existe no disco, grava para criá-lo
  if not vim.uv.fs_stat(alvo) then
    -- Cria a(s) pasta(s) intermediária(s) que faltarem (ex.: "css/" em
    -- "css/style.css") ANTES de escrever — sem isso, :write falha com
    -- "E212: Can't open file for writing: no such file or directory"
    -- sempre que o caminho apontar pra uma subpasta ainda não criada.
    local pasta_alvo = vim.fn.fnamemodify(alvo, ":h")
    vim.fn.mkdir(pasta_alvo, "p")
    vim.cmd("write")
  end
end

-- NOVO (ago/2026) — <leader>fn: cria um arquivo novo explicitamente via
-- prompt, sem depender de haver um nome de arquivo sob o cursor. Peça da
-- reestruturação (item 7 da proposta): "gf" continua semanticamente
-- "go to file"; criação avulsa de arquivo ganha seu próprio comando.
-- Resolve caminhos relativos à pasta do arquivo atual, igual ao gf, e
-- também cria diretórios intermediários automaticamente.
function M.new_file()
  vim.ui.input({ prompt = "Novo arquivo: ", completion = "file" }, function(nome)
    if not nome or nome == "" then return end

    local alvo = M.resolve_relative(nome)

    if vim.uv.fs_stat(alvo) then
      vim.notify("Arquivo já existe: " .. alvo, vim.log.levels.WARN)
      return
    end

    local pasta_alvo = vim.fn.fnamemodify(alvo, ":h")
    vim.fn.mkdir(pasta_alvo, "p")

    vim.cmd("tabedit " .. vim.fn.fnameescape(alvo))
    vim.cmd("write")
  end)
end

return M
