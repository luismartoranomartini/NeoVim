-- =========================================================
-- lua/martini/config/colors.lua
-- Fundo preto · paleta forte com muitas categorias distintas
-- =========================================================

local function aplicar_highlights()
  local hl = vim.api.nvim_set_hl

  -- Paleta de cores fortes e saturadas
  local cor = {
    azul     = "#4fc1ff",  -- funções, métodos
    ciano    = "#00e5ff",  -- pacotes / namespaces
    amarelo  = "#ffd700",  -- tipos e structs
    vermelho = "#ff3b5c",  -- keywords (func, return, if, for)
    verde    = "#39ff14",  -- strings
    laranja  = "#ff8c00",  -- números e constantes
    rosa     = "#ff4fd8",  -- operadores
    roxo     = "#bd93f9",  -- booleanos, nil, builtins
    cinza    = "#7a8290",  -- comentários
    branco   = "#ffffff",  -- variáveis e texto
    escape   = "#ffee58",  -- sequências de escape dentro de strings (\n, \t, \", etc.)
  }

  -- Funções e métodos → AZUL
  hl(0, "@lsp.type.function",     { fg = cor.azul })
  hl(0, "@lsp.type.function.go",  { fg = cor.azul })
  hl(0, "@lsp.type.method",       { fg = cor.azul })
  hl(0, "@lsp.type.method.go",    { fg = cor.azul })
  hl(0, "@function.call",   { fg = cor.azul })
  hl(0, "@method.call",     { fg = cor.azul })
  hl(0, "@function",        { fg = cor.azul })
  hl(0, "@function.method", { fg = cor.azul })

  -- Pacotes / namespaces → CIANO
  hl(0, "@lsp.type.namespace",    { fg = cor.ciano })
  hl(0, "@lsp.type.namespace.go", { fg = cor.ciano })
  hl(0, "@namespace",  { fg = cor.ciano })
  hl(0, "@module",     { fg = cor.ciano })

  -- Tipos e structs → AMARELO
  hl(0, "@lsp.type.type",    { fg = cor.amarelo })
  hl(0, "@lsp.type.type.go", { fg = cor.amarelo })
  hl(0, "@type",            { fg = cor.amarelo })
  hl(0, "@type.builtin",    { fg = cor.amarelo })
  hl(0, "@type.definition", { fg = cor.amarelo })
  hl(0, "Type",             { fg = cor.amarelo })

  -- Keywords → VERMELHO
  hl(0, "@keyword",          { fg = cor.vermelho })
  hl(0, "@keyword.function", { fg = cor.vermelho })
  hl(0, "@keyword.return",   { fg = cor.vermelho })
  hl(0, "@keyword.import",   { fg = cor.vermelho })
  hl(0, "@conditional",      { fg = cor.vermelho })
  hl(0, "@repeat",           { fg = cor.vermelho })
  hl(0, "Keyword",           { fg = cor.vermelho })
  hl(0, "Statement",         { fg = cor.vermelho })

  -- Strings → VERDE
  hl(0, "@string",         { fg = cor.verde })
  hl(0, "String",          { fg = cor.verde })

  -- IMPORTANTE: o semantic token do gopls (@lsp.type.string.go) marca a
  -- string inteira como um único token "string", sem distinguir a parte
  -- de escape (\n, \t, etc.). Por padrão o Neovim faz esse grupo linkar
  -- para @string (prioridade 125, mais alta que a sintaxe legada), o que
  -- pinta tudo de verde e esconde a distinção. Limpando o link aqui, a
  -- cor cai para a sintaxe legada (goString/goEscapeC), que já distingue
  -- corretamente string normal (String) de escape (Special).
  hl(0, "@lsp.type.string",    {})
  hl(0, "@lsp.type.string.go", {})

  -- Sequências de escape dentro de strings (\n, \t, \", \\, etc.) → AMARELO VIVO
  -- Precisa vir DEPOIS do highlight de @string para não ser sobrescrito,
  -- e cobre tanto o grupo do Treesitter quanto o legado (syntax/regex).
  hl(0, "@string.escape",     { fg = cor.escape })
  hl(0, "@string.escape.go",  { fg = cor.escape })
  hl(0, "@string.special",    { fg = cor.escape })
  hl(0, "@escape",            { fg = cor.escape })
  hl(0, "@punctuation.special", { fg = cor.escape })
  hl(0, "Special",            { fg = cor.escape })
  hl(0, "SpecialChar",        { fg = cor.escape })

  -- Números e constantes → LARANJA
  hl(0, "@number",   { fg = cor.laranja })
  hl(0, "@float",    { fg = cor.laranja })
  hl(0, "@constant", { fg = cor.laranja })
  hl(0, "Number",    { fg = cor.laranja })
  hl(0, "Constant",  { fg = cor.laranja })

  -- Operadores → ROSA
  hl(0, "@operator", { fg = cor.rosa })
  hl(0, "Operator",  { fg = cor.rosa })

  -- Booleanos, nil, builtins → ROXO
  hl(0, "@boolean",          { fg = cor.roxo })
  hl(0, "@constant.builtin", { fg = cor.roxo })
  hl(0, "@function.builtin", { fg = cor.roxo })
  hl(0, "Boolean",           { fg = cor.roxo })

  -- Comentários → CINZA (itálico)
  hl(0, "@comment", { fg = cor.cinza, italic = true })
  hl(0, "Comment",  { fg = cor.cinza, italic = true })

  -- Variáveis e parâmetros → BRANCO
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
end

pcall(function()
  require("tokyonight").setup({
    style = "night",
    styles = {
      comments  = { italic = true },
      keywords  = { bold = false },
      functions = { bold = false },
    },
  })
  vim.cmd.colorscheme("tokyonight-night")
end)

aplicar_highlights()

vim.api.nvim_create_autocmd("ColorScheme", { callback = aplicar_highlights })
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function() vim.defer_fn(aplicar_highlights, 300) end,
})
