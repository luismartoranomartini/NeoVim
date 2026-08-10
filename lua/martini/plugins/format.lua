-- =========================================================
-- lua/martini/plugins/format.lua
-- Formatação automática via conform.nvim, linting via nvim-lint
-- e organização automática de imports para Go
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

-- =========================================================
-- Organização automática de imports para Go (gopls)
-- Executa source.organizeImports via LSP ANTES de salvar,
-- para que o import (ex.: "errors") seja adicionado ao buffer
-- e já vá para o disco na mesma escrita.
--
-- position_encoding é passado explicitamente para evitar o
-- warning de depreciação do Neovim 0.11+ em make_range_params
-- e apply_workspace_edit.
-- =========================================================
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local clients = vim.lsp.get_clients({ bufnr = 0, name = "gopls" })
    if #clients == 0 then return end

    local client = clients[1]
    local encoding = client.offset_encoding or "utf-16"

    local params = vim.lsp.util.make_range_params(0, encoding)
    params.context = { only = { "source.organizeImports" } }

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
    if not result then return end

    for _, res in pairs(result) do
      for _, action in pairs(res.result or {}) do
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, encoding)
        elseif action.command then
          vim.lsp.buf.execute_command(action.command)
        end
      end
    end
  end,
})
