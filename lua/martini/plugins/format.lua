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
