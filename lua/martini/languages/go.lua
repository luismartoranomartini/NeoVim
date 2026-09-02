-- =========================================================
-- lua/martini/languages/go.lua
-- Tudo que é específico de Go, consolidado num único lugar durante
-- a reestruturação (ago/2026). Antes estava espalhado por:
--   plugins/ui.lua     → filetype .tmpl/.gohtml, highlight de verbos
--                         de printf e de ações de template
--   plugins/format.lua → golangci-lint, organize imports
--   plugins/runner.lua → entrada "go" da tabela de filetypes + os
--                         atalhos <leader>gt/<leader>ga/<leader>gr
--   plugins/debug.lua  → setup do dap-go
--
-- Interface deste módulo, consumida por outros arquivos:
--   M.runner_filetypes  → lido por plugins/runner.lua (tbl_extend)
--   M.setup_debug()     → chamado por plugins/debug.lua dentro do
--                          setup() lazy do debugger
-- Tudo o resto (filetype.add, highlights, lint, keymaps de teste) roda
-- direto ao dar require() neste módulo — não precisa de chamada
-- explícita.
-- =========================================================

local terminal = require("martini.utils.terminal")

local M = {}

-- Todos os autocmds deste arquivo ficam neste augroup, com clear=true —
-- evita listeners duplicados se o módulo for recarregado via :luafile
-- durante desenvolvimento da própria config (set/2026, auditoria externa).
local go_group = vim.api.nvim_create_augroup("MartiniGo", { clear = true })

-- =========================================================
-- Filetype: reconhece arquivos .tmpl/.gohtml (Go HTML templates).
-- Tratados como "html" para ativar auto-fechamento de tags,
-- Emmet e o LSP de HTML sem depender de parser extra.
-- =========================================================
vim.filetype.add({
  extension = {
    tmpl   = "html",
    gohtml = "html",
  },
  pattern = {
    -- pega nomes compostos como home.page.tmpl, layout.base.tmpl, etc.
    [".*%.tmpl"] = "html",
  },
})

-- Garante o filetype mesmo em casos que escapem das regras acima
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group    = go_group,
  pattern  = "*.tmpl",
  callback = function()
    vim.bo.filetype = "html"
  end,
})

-- =========================================================
-- Highlight: verbos de formatação do Go (%s, %d, %v, %+v, %-10.2f,
-- etc.), via matchadd — o Treesitter do Go não trata verbos de
-- printf/Sprintf como nó separado dentro da string; fica tudo
-- achatado em @string. O grupo GoFormatVerb é definido em
-- config/colors.lua; aqui só aplicamos onde o cursor está.
--
-- IMPORTANTE #1: usa long-bracket [=[ ... ]=] em vez de [[ ... ]] — o
-- padrão termina em "]" (fim da classe de caracteres do regex) seguido
-- do "]]" de fechamento da string, e o Lua fecha a string cedo na
-- primeira ocorrência de "]]" que encontrar, quebrando o parse (erro
-- "')' expected near ']'"). O nível [=[...]=] só fecha em "]=]".
--
-- IMPORTANTE #2: o padrão começa com UM único "%", não "%%" — verbos
-- de printf no Go usam um só (%s, %d, %v), então "%%" no início do
-- regex nunca dava match em nada (exigia dois "%" seguidos no texto).
--
-- IMPORTANTE #3: matchadd() é POR JANELA, não por buffer. Só disparar
-- no autocmd FileType não é suficiente — FileType só dispara quando o
-- filetype do buffer é definido pela primeira vez. Se o mesmo arquivo
-- é aberto numa aba/split nova (via gd, :tabedit, etc.), essa janela
-- nova nunca recebe o matchadd, mesmo com o highlight já ativo em
-- outra janela do mesmo buffer. Por isso também dispara em BufWinEnter
-- e WinEnter, com uma flag por janela (vim.w) pra não empilhar
-- matches repetidos toda vez que você troca de janela.
--
-- IMPORTANTE #4: a classe de caracteres precisa incluir "t" minúsculo
-- (verbo de %t, usado pra valores booleanos) além do "T" maiúsculo
-- (verbo de %T, tipo de dado) — os dois são verbos distintos em Go, e
-- faltar o "t" minúsculo faz %t nunca receber highlight.
local function destacar_verbos_go()
  if vim.bo.filetype ~= "go" then return end
  if vim.w.martini_go_verb_hl then return end
  vim.fn.matchadd("GoFormatVerb", [=[%[-+ #0]*[0-9]*\.\?[0-9]*[sdvTtqxXobeEfFgGpc]]=])
  vim.w.martini_go_verb_hl = true
end

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
  group    = go_group,
  callback = destacar_verbos_go,
})

-- =========================================================
-- Highlight: destaque aproximado dos blocos {{ ... }} de template Go
-- dentro de arquivos HTML — via matchadd, pois não existe parser
-- Treesitter mantido e funcional pra essa sintaxe hoje (o parser de
-- terceiros exige setup frágil e mesmo assim não recupera highlight
-- de HTML dentro do bloco). Não dá autocomplete — só contraste visual.
-- \_. casa qualquer caractere incluindo quebra de linha, .\{-} é
-- non-greedy — cobre blocos multi-linha como {{if eq len(x) 0}}...{{end}}.
-- Mesmo caveat do bloco acima: matchadd() é por janela.
-- =========================================================
local function destacar_template_go()
  if vim.bo.filetype ~= "html" then return end
  if vim.w.martini_go_tmpl_hl then return end
  vim.fn.matchadd("GoTemplateAction", [=[{{-\?\_.\{-}-\?}}]=])
  vim.w.martini_go_tmpl_hl = true
end

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
  group    = go_group,
  callback = destacar_template_go,
})

-- =========================================================
-- Lint: golangci-lint via nvim-lint
-- =========================================================
pcall(function()
  local lint = require("lint")

  -- Localiza o executável correto no Windows
  local golangci = vim.fn.exepath("golangci-lint")
  if golangci == "" then
    vim.notify("golangci-lint não encontrado no PATH", vim.log.levels.WARN)
    return
  end

  -- Sobrescreve o comando para usar o caminho completo
  lint.linters.golangcilint = {
    cmd             = golangci,
    stdin           = false,
    args            = { "run", "--out-format", "json", "--issues-exit-code=1" },
    stream          = "stdout",
    ignore_exitcode = true,
    parser          = require("lint.linters.golangcilint").parser,
  }

  lint.linters_by_ft = lint.linters_by_ft or {}
  lint.linters_by_ft.go = { "golangcilint" }

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group    = go_group,
    pattern  = "*.go",
    callback = function() lint.try_lint() end,
  })
end)

-- =========================================================
-- Format: organiza imports do Go automaticamente ao salvar.
--
-- MUDANÇA (set/2026, auditoria externa): antes isso rodava via
-- vim.lsp.buf_request_sync(..., 1000) num autocmd BufWritePre — uma
-- requisição SÍNCRONA ao gopls, bloqueando a digitação por até 1s
-- sempre que o gopls estivesse ocupado reindexando (projetos grandes).
-- Trocado pelo binário `goimports` como formatter do conform.nvim (ver
-- plugins/format.lua), que roda em processo externo, assíncrono, sem
-- travar o :w. Único requisito: `goimports` no PATH — já vem junto do
-- toolchain padrão do Go (go install golang.org/x/tools/cmd/goimports@latest,
-- ou já presente se você usou `go install` genérico antes).
--
-- Trade-off consciente: goimports NÃO é 100% idêntico à code action
-- "source.organizeImports" do gopls — ambos removem imports não usados
-- e adicionam os que faltam, mas o gopls pode aplicar regras extras
-- específicas de projeto (raro no dia a dia). Se notar diferença de
-- comportamento, o code action síncrono antigo ainda existe no
-- histórico do git caso queira reverter.
-- =========================================================

-- =========================================================
-- Runner: contribuição pra tabela de filetypes do code_runner.nvim.
-- Lido por plugins/runner.lua via vim.tbl_extend.
-- =========================================================
M.runner_filetypes = {
  -- Go: roda o pacote inteiro da pasta
  go = "cd $dir && go run .",
}

-- =========================================================
-- Testes: atalhos sob o prefixo <leader>g (reservado pra Go nesta
-- reestruturação — ver comentário em config/keymaps.lua).
--
-- MUDANÇA (set/2026): antes cada chamada abria um split novo
-- (vim.cmd("botright split | resize 15 | terminal ...")), empilhando
-- splits/buffers de terminal órfãos a cada execução — perceptível em
-- TDD, quando o teste roda dezenas de vezes seguidas. Agora usa
-- terminal.run_test(cmd) (utils/terminal.lua), que reaproveita a MESMA
-- janela a cada chamada em vez de criar uma nova.
-- =========================================================

-- <leader>gt : testa o pacote do arquivo atual (verbose)
vim.keymap.set("n", "<leader>gt", function()
  local dir = vim.fn.expand("%:p:h")
  terminal.run_test("cd " .. vim.fn.fnameescape(dir) .. " && go test -v")
end, { desc = "Go: testar pacote atual" })

-- <leader>ga : testa o projeto inteiro ("a" de "all")
vim.keymap.set("n", "<leader>ga", function()
  terminal.run_test("go test ./...")
end, { desc = "Go: testar projeto inteiro" })

-- <leader>gr : testa APENAS a função de teste onde o cursor está
-- posicionado (ou a função de teste mais próxima acima do cursor).
-- Usa go test -run ^NomeDaFuncao$ para escopar a um único teste.
--
-- IMPORTANTE: o padrão de Lua %w NÃO inclui sublinhado. Nomes de teste em Go
-- costumam usar underscore (ex.: Test_Create_Campaign), então o padrão de
-- casamento precisa ser [%w_]* — nunca %w* sozinho, ou o nome é cortado
-- no primeiro underscore.
vim.keymap.set("n", "<leader>gr", function()
  local bufnr       = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local func_name   = nil

  -- Varre da linha do cursor para cima até achar "func TestAlgo(t *testing.T)"
  for lnum = cursor_line, 1, -1 do
    local linha = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
    local nome = linha:match("^func%s+(Test[%w_]*)%s*%(")
    if nome then
      func_name = nome
      break
    end
  end

  if not func_name then
    vim.notify("Nenhuma função de teste encontrada acima do cursor", vim.log.levels.WARN)
    return
  end

  local dir = vim.fn.expand("%:p:h")
  local cmd = string.format(
    "cd %s && go test -v -run ^%s$",
    vim.fn.fnameescape(dir),
    func_name
  )
  terminal.run_test(cmd)
end, { desc = "Go: testar apenas a função de teste sob o cursor" })

-- =========================================================
-- Debug: dap-go. Chamado por plugins/debug.lua dentro do setup()
-- lazy do debugger (não roda sozinho ao dar require neste módulo).
-- =========================================================
function M.setup_debug()
  require("dap-go").setup({
    delve = {
      path = vim.fn.exepath("dlv"),
    },
  })
end

return M
