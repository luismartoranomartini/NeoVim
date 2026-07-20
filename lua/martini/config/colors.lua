-- =========================================================
-- lua/martini/config/colors.lua
-- Fundo preto · paleta harmônica baseada em Tokyo Night
-- =========================================================
local function aplicar_highlights()
  local hl = vim.api.nvim_set_hl
  -- Paleta com saturação equilibrada, tons frios predominantes
  local cor = {
    azul     = "#7aa2f7",  -- funções, métodos
    ciano    = "#b3e3ff",  -- pacotes / namespaces
    dourado  = "#DCC218",  -- tipos e structs
    coral    = "#f7768e",  -- keywords (func, return, if, for)
    verde    = "#9ece6a",  -- strings
    laranja  = "#FFD700",  -- números e constantes
    lavanda  = "#D1A1D6",  -- operadores
    roxo     = "#bb9af7",  -- booleanos, nil, builtins
    cinza    = "#565f89",  -- comentários
    branco   = "#c0caf5",  -- variáveis e texto
  }

  -- Funções e métodos → AZUL (itálico)
  hl(0, "@lsp.type.function",     { fg = cor.azul, italic = true })
  hl(0, "@lsp.type.function.go",  { fg = cor.azul, italic = true })
  hl(0, "@lsp.type.method",       { fg = cor.azul, italic = true })
  hl(0, "@lsp.type.method.go",    { fg = cor.azul, italic = true })
  hl(0, "@function.call",   { fg = cor.azul, italic = true })
  hl(0, "@method.call",     { fg = cor.azul, italic = true })
  hl(0, "@function",        { fg = cor.azul, italic = true })
  hl(0, "@function.method", { fg = cor.azul, italic = true })

  -- Pacotes / namespaces → CIANO
  hl(0, "@lsp.type.namespace",    { fg = cor.ciano })
  hl(0, "@lsp.type.namespace.go", { fg = cor.ciano })
  hl(0, "@namespace",  { fg = cor.ciano })
  hl(0, "@module",     { fg = cor.ciano })

  -- Tipos e structs → DOURADO
  hl(0, "@lsp.type.type",    { fg = cor.dourado })
  hl(0, "@lsp.type.type.go", { fg = cor.dourado })
  hl(0, "@type",            { fg = cor.dourado })
  hl(0, "@type.builtin",    { fg = cor.dourado })
  hl(0, "@type.definition", { fg = cor.dourado })
  hl(0, "Type",             { fg = cor.dourado })
  hl(0, "@type.go",         { fg = cor.dourado })  -- força direto, sem depender de link
  hl(0, "@type.builtin.go", { fg = cor.dourado })  -- força direto, sem depender de link

  -- Keywords → CORAL (itálico)
  hl(0, "@keyword",          { fg = cor.coral, italic = true })
  hl(0, "@keyword.function", { fg = cor.coral, italic = true })
  hl(0, "@keyword.return",   { fg = cor.coral, italic = true })
  hl(0, "@keyword.import",   { fg = cor.coral, italic = true })
  hl(0, "@conditional",      { fg = cor.coral, italic = true })
  hl(0, "@repeat",           { fg = cor.coral, italic = true })
  hl(0, "Keyword",           { fg = cor.coral, italic = true })
  hl(0, "Statement",         { fg = cor.coral, italic = true })

  -- Strings → VERDE
  hl(0, "@string",         { fg = cor.verde })
  hl(0, "@string.escape",  { fg = cor.verde })
  hl(0, "String",          { fg = cor.verde })

  -- Números e constantes → LARANJA
  hl(0, "@number",   { fg = cor.laranja })
  hl(0, "@float",    { fg = cor.laranja })
  hl(0, "@constant", { fg = cor.laranja })
  hl(0, "Number",    { fg = cor.laranja })
  hl(0, "Constant",  { fg = cor.laranja })

  -- Operadores → LAVANDA
  hl(0, "@operator", { fg = cor.lavanda })
  hl(0, "Operator",  { fg = cor.lavanda })

  -- Booleanos, nil, builtins → ROXO
  hl(0, "@boolean",          { fg = cor.roxo })
  hl(0, "@constant.builtin", { fg = cor.roxo })
  hl(0, "@function.builtin", { fg = cor.roxo, italic = true })
  hl(0, "Boolean",           { fg = cor.roxo })

  -- Comentários → CINZA (itálico)
  hl(0, "@comment", { fg = cor.cinza, italic = true })
  hl(0, "Comment",  { fg = cor.cinza, italic = true })

  -- Variáveis e parâmetros → BRANCO (levemente azulado)
  hl(0, "@lsp.type.variable",     { fg = cor.branco })
  hl(0, "@lsp.type.variable.go",  { fg = cor.branco })
  hl(0, "@lsp.type.parameter",    { fg = cor.branco })
  hl(0, "@lsp.type.parameter.go", { fg = cor.branco })
  hl(0, "@variable",        { fg = cor.branco })
  hl(0, "@variable.member", { fg = cor.branco })
  hl(0, "@parameter",       { fg = cor.branco })
  hl(0, "Identifier",       { fg = cor.branco })

  -- Fundo preto puro
  hl(0, "Normal",      { fg = cor.branco, bg = "#000000" })
  hl(0, "NormalNC",    { bg = "#000000" })
  hl(0, "NormalFloat", { bg = "#000000" })
  hl(0, "SignColumn",  { bg = "#000000" })
  hl(0, "LineNr",      { bg = "#000000", fg = "#5c6370" })
  hl(0, "EndOfBuffer", { bg = "#000000" })
  hl(0, "CursorLine",  { bg = "#1a1a1a" })

  -- Dashboard (arte ASCII e menu)
  hl(0, "Function",       { fg = cor.azul, italic = true })
  hl(0, "DiagnosticOk",   { fg = cor.verde })
  hl(0, "DiagnosticWarn", { fg = cor.dourado })
end

pcall(function()
  require("tokyonight").setup({
    style = "night",
    styles = {
      comments  = { italic = true },
      keywords  = { italic = true },
      functions = { italic = true },
    },
  })
  vim.cmd.colorscheme("tokyonight-night")
end)

aplicar_highlights()

vim.api.nvim_create_autocmd("ColorScheme", { callback = aplicar_highlights })
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function() vim.defer_fn(aplicar_highlights, 300) end,
})
