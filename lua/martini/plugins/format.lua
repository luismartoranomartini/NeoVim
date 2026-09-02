-- =========================================================
-- lua/martini/plugins/format.lua
-- Formatação automática via conform.nvim (genérico, multi-linguagem).
--
-- O linting de Go (golangci-lint) fica em languages/go.lua — é
-- comportamento específico de uma linguagem, não deste plugin.
--
-- MUDANÇA (set/2026): "go" adicionado aqui usando o binário `goimports`,
-- substituindo o organize-imports síncrono via gopls que antes rodava
-- em BufWritePre dentro de languages/go.lua (vim.lsp.buf_request_sync
-- com timeout de 1s, bloqueando a digitação enquanto o gopls estivesse
-- ocupado). goimports roda assíncrono como qualquer outro formatter do
-- conform, sem esse travamento. Requer `goimports` no PATH:
--   go install golang.org/x/tools/cmd/goimports@latest
-- =========================================================

pcall(function()
  require("conform").setup({
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      python     = { "black" },
      html       = { "prettier" },
      css        = { "prettier" },
      go         = { "goimports" },
    },
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback",
    },
  })
end)
