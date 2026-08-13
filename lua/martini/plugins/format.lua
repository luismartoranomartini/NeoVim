-- =========================================================
-- lua/martini/plugins/format.lua
-- Formatação automática via conform.nvim e linting via nvim-lint
-- =========================================================

-- Linting com golangci-lint para Go
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
    cmd        = golangci,
    stdin      = false,
    args       = { "run", "--out-format", "json", "--issues-exit-code=1" },
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

-- Organiza imports do Go automaticamente ao salvar (remove imports não
-- usados e adiciona os que faltam), via code action do gopls.
-- Isso NÃO é feito pelo lsp_format do conform.nvim nem por um gofmt
-- comum — "organizar imports" é uma code action LSP separada
-- (source.organizeImports) que precisa ser pedida explicitamente.
-- Roda em BufWritePre, síncrono, ANTES do conform formatar/salvar,
-- para que o resultado já saia formatado corretamente.
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern  = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
    for _, res in pairs(result or {}) do
      for _, action in pairs(res.result or {}) do
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
        elseif action.command then
          vim.lsp.buf.execute_command(action.command)
        end
      end
    end
  end,
})

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
