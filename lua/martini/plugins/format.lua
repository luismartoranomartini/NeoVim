-- =========================================================
-- lua/martini/plugins/format.lua
-- Formatação automática via conform.nvim e linting via nvim-lint
-- =========================================================

-- Linting com golangci-lint para Go.
-- Carregado sob demanda (FileType go) em vez de no boot, porque
-- require('lint.linters.golangcilint') sozinho custa ~45ms —
-- quase metade do startup total quando carregado incondicionalmente.
local golangci_configurado = false

local function configurar_golangci()
  if golangci_configurado then return end
  golangci_configurado = true

  local ok, lint = pcall(require, "lint")
  if not ok then return end

  local golangci = vim.fn.exepath("golangci-lint")
  if golangci == "" then
    vim.notify("golangci-lint não encontrado no PATH", vim.log.levels.WARN)
    return
  end

  lint.linters.golangcilint = {
    cmd             = golangci,
    stdin           = false,
    args            = { "run", "--out-format", "json", "--issues-exit-code=1" },
    stream          = "stdout",
    ignore_exitcode = true,
    parser          = require("lint.linters.golangcilint").parser,
  }

  lint.linters_by_ft = {
    go = { "golangcilint" },
  }
end

vim.api.nvim_create_autocmd("FileType", {
  pattern  = "go",
  once     = false,
  callback = configurar_golangci,
})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern  = "*.go",
  callback = function()
    local ok, lint = pcall(require, "lint")
    if ok then lint.try_lint() end
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
