-- =========================================================
-- lua/martini/plugins/format.lua
-- Formatação automática via conform.nvim e linting via nvim-lint
-- =========================================================

-- Linting com golangci-lint para Go
pcall(function()
  local lint = require("lint")

  -- Resolve o caminho completo do executável (funciona em qualquer SO)
  local golangci = vim.fn.exepath("golangci-lint")
  if golangci == "" then
    vim.notify("golangci-lint não encontrado no PATH", vim.log.levels.WARN)
    return
  end

  -- Sobrescreve o comando para usar o caminho completo.
  -- IMPORTANTE: "--out-format" foi removida no golangci-lint v2 (confirmado
  -- no guia oficial de migração, golangci-lint.run/docs/product/migration-guide
  -- e na discussão golangci/golangci-lint#5612). O equivalente atual para
  -- saída em JSON no stdout é "--output.json.path stdout".
  lint.linters.golangcilint = {
    cmd        = golangci,
    stdin      = false,
    args       = { "run", "--output.json.path", "stdout", "--issues-exit-code=1" },
    stream     = "stdout",
    ignore_exitcode = true,
    parser     = require("lint.linters.golangcilint").parser,
  }

  lint.linters_by_ft = {
    go = { "golangcilint" },
  }

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern  = "*.go",
    callback = function() lint.try_lint() end,
  })
end)

-- =========================================================
-- Organizar imports ao salvar (source.organizeImports e afins)
--
-- Função genérica: pede ao LSP ativo no buffer para executar um ou mais
-- "source code actions" (organizar imports, adicionar os que faltam
-- etc.) e aplica o resultado ANTES da gravação em disco. Baseado na
-- receita oficial do time do gopls, generalizada aqui para reaproveitar
-- em qualquer LSP que suporte esses kinds:
-- https://go.dev/gopls/editor/vim#neovim-imports
-- =========================================================
local function aplicar_source_actions(kinds, wait_ms)
  local params = vim.lsp.util.make_range_params()
  params.context = { only = kinds }
  -- buf_request_sync tem timeout padrão de 1000ms. Em projetos grandes,
  -- se notar que precisa salvar duas vezes para a mudança "pegar",
  -- aumente esse valor.
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms or 1000)
  for cid, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
        vim.lsp.util.apply_workspace_edit(r.edit, enc)
      end
    end
  end
end

-- Go: remove imports não usados e adiciona os que faltam (goimports),
-- depois formata. gopls é o único formatador de Go aqui (não há
-- entrada "go" no conform abaixo), por isso o vim.lsp.buf.format()
-- roda direto nesse bloco.
pcall(function()
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern  = "*.go",
    callback = function()
      aplicar_source_actions({ "source.organizeImports" })
      vim.lsp.buf.format({ async = false })
    end,
  })
end)

-- TypeScript/JavaScript: o typescript-language-server trata "organizar"
-- e "adicionar os que faltam" como DUAS ações separadas — diferente do
-- Go, onde uma ação só já faz as duas coisas. Confirmado no README
-- oficial do typescript-language-server (kinds: source.organizeImports.ts
-- e source.addMissingImports.ts). Sem vim.lsp.buf.format() aqui: o
-- conform.nvim (prettier) já formata esses filetypes logo abaixo — rodar
-- os dois formatadores em sequência causaria conflito de estilo.
pcall(function()
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern  = { "*.ts", "*.tsx", "*.js", "*.jsx" },
    callback = function()
      aplicar_source_actions({ "source.addMissingImports.ts", "source.organizeImports.ts" })
    end,
  })
end)

-- Python (pyright): só remove/organiza imports não usados. Ao contrário
-- do Go e do TS, o pyright NÃO tem uma ação equivalente para adicionar
-- imports faltantes automaticamente — confirmado como pedido em aberto
-- nos repositórios oficiais (microsoft/pyright#251 e
-- microsoft/pylance-release#2222). O fork basedpyright adiciona isso,
-- mas trocar o LSP configurado é uma decisão à parte, não incluída aqui.
pcall(function()
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern  = "*.py",
    callback = function()
      aplicar_source_actions({ "source.organizeImports" })
    end,
  })
end)

pcall(function()
  require("conform").setup({
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      python     = { "black" },
      html       = { "prettier" },
      css        = { "prettier" },
    },
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback",
    },
  })
end)
