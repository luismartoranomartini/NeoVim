-- =========================================================
-- lua/martini/plugins/format.lua
-- Formatação automática via conform.nvim (genérico, multi-linguagem).
--
-- O linting de Go (golangci-lint) e a organização automática de
-- imports do Go (BufWritePre + source.organizeImports) foram movidos
-- para languages/go.lua durante a reestruturação (ago/2026) — são
-- comportamento específico de uma linguagem, não deste plugin.
-- =========================================================

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
