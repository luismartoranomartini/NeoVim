-- =========================================================
-- lua/martini/config/colors.lua
-- Colorscheme, highlights de sintaxe e semantic tokens
-- =========================================================

-- Função central de highlights — chamada após qualquer troca de tema
local function aplicar_highlights()
  local hl = vim.api.nvim_set_hl

  -- LSP semantic tokens (gopls)
  hl(0, "@lsp.type.namespace",    { fg = "#7aa2f7" })
  hl(0, "@lsp.type.namespace.go", { fg = "#7aa2f7" })
  hl(0, "@lsp.type.function",     { fg = "#7dcfff" })
  hl(0, "@lsp.type.function.go",  { fg = "#7dcfff" })
  hl(0, "@lsp.type.method",       { fg = "#7dcfff" })
  hl(0, "@lsp.type.method.go",    { fg = "#7dcfff" })
  hl(0, "@lsp.type.type",         { fg = "#e0af68" })
  hl(0, "@lsp.type.type.go",      { fg = "#e0af68" })
  hl(0, "@lsp.type.parameter",    { fg = "#ff9e64" })
  hl(0, "@lsp.type.parameter.go", { fg = "#ff9e64" })
  hl(0, "@lsp.type.variable",     { fg = "#c0caf5" })
  hl(0, "@lsp.type.variable.go",  { fg = "#c0caf5" })

  -- Treesitter (funciona sem LSP)
  hl(0, "@function.call",  { fg = "#7dcfff" })
  hl(0, "@method.call",    { fg = "#7dcfff" })
  hl(0, "@namespace",      { fg = "#7aa2f7" })
  hl(0, "@type",           { fg = "#e0af68" })
  hl(0, "@type.builtin",   { fg = "#e0af68" })
  hl(0, "@variable",       { fg = "#c0caf5" })
  hl(0, "@parameter",      { fg = "#ff9e64" })
end

-- Colorscheme
pcall(function()
  require("ondedark").setup({
    style = "deep",
    styles = {
      comments  = { italic = true },
      keywords  = { bold   = false },
      functions = { bold   = false },
    },
  })
  vim.cmd.colorscheme("onedark")
end)

-- Aplica imediatamente após carregar o tema
aplicar_highlights()

-- Reaaplica ao trocar de colorscheme
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = aplicar_highlights,
})

-- Reaaplica quando o LSP conecta (semantic tokens chegam com delay)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    vim.defer_fn(aplicar_highlights, 300)
  end,
})
