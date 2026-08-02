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
    turquesa = "#2dd4bf",  -- parâmetros de função (distinto de tipos/variáveis)
    amarelo_pastel = "#f1fa8c",  -- escapes dentro de strings (\n, \t, \\, ...)
    ciano_claro    = "#8be9fd",  -- verbos de formatação (%d, %s, %v, ...)
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

  -- Tipos e structs → AMARELO
  hl(0, "@lsp.type.type",    { fg = cor.amarelo })
  hl(0, "@lsp.type.type.go", { fg = cor.amarelo })
  hl(0, "@type",            { fg = cor.amarelo })
  hl(0, "@type.builtin",    { fg = cor.amarelo })
  hl(0, "@type.definition", { fg = cor.amarelo })
  hl(0, "Type",             { fg = cor.amarelo })

  -- Keywords → VERMELHO
  hl(0, "@keyword",          { fg = cor.vermelho })
  hl(0, "@keyword.function", { fg = cor.vermelho, italic = true })
  hl(0, "@keyword.return",   { fg = cor.vermelho })
  hl(0, "@keyword.import",   { fg = cor.vermelho })
  hl(0, "@conditional",      { fg = cor.vermelho })
  hl(0, "@repeat",           { fg = cor.vermelho })
  hl(0, "Keyword",           { fg = cor.vermelho })
  hl(0, "Statement",         { fg = cor.vermelho })

  -- Strings → VERDE, escapes → AMARELO PASTEL
  -- IMPORTANTE: o gopls manda semantic token "string" cobrindo a string
  -- inteira (inclusive escapes). Como esse token tem prioridade maior que
  -- o Treesitter, ele pintava tudo com uma única cor plana. Zerando
  -- @lsp.type.string, o token do LSP não pinta nada e o Treesitter
  -- (que já diferencia string normal de escape) volta a aparecer por baixo.
  hl(0, "@lsp.type.string",    {})
  hl(0, "@lsp.type.string.go", {})
  hl(0, "@string",         { fg = cor.verde })
  hl(0, "@string.escape",  { fg = cor.amarelo_pastel, bold = true })
  hl(0, "String",          { fg = cor.verde })

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

  -- Variáveis (não-parâmetro) → BRANCO
  hl(0, "@lsp.type.variable",     { fg = cor.branco })
  hl(0, "@lsp.type.variable.go",  { fg = cor.branco })
  hl(0, "@variable",        { fg = cor.branco })
  hl(0, "@variable.member", { fg = cor.branco })
  hl(0, "Identifier",       { fg = cor.branco })

  -- Parâmetros de função → TURQUESA + itálico
  hl(0, "@lsp.type.parameter",     { fg = cor.turquesa, italic = true })
  hl(0, "@lsp.type.parameter.go",  { fg = cor.turquesa, italic = true })
  hl(0, "@variable.parameter",     { fg = cor.turquesa, italic = true })
  hl(0, "@parameter",              { fg = cor.turquesa, italic = true })

  -- Verbos de formatação (%d, %s, %v, %+v, ...) dentro de strings de Go
  -- Não existe nó de sintaxe para isso no Treesitter, então o grupo é
  -- preenchido via extmarks (ver destacar_verbos_formato mais abaixo).
  hl(0, "MartiniVerboFormato", { fg = cor.ciano_claro, bold = true })

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

-- =========================================================
-- Destaque de verbos de formatação (%d, %s, %v, %+v, ...)
-- Escaneia apenas o TEXTO DENTRO de literais de string do Go via
-- Treesitter (nunca o código fora delas), evitando falso-positivo
-- com o operador módulo (%) usado fora de strings.
-- =========================================================
local ns_verbo = vim.api.nvim_create_namespace("martini_verbos_formato")

-- Padrão de um verbo printf: % [flags] [largura] [.precisão] verbo
-- flags: - + espaço # 0   |   verbo: v T t b c d o O q x X U e E f F g G s p %
local PADRAO_VERBO = "%%[%-+ #0]*[%d%*]*%.?[%d%*]*[vTtbcdoOqxXUeEfFgGsp%%]"

-- Converte um índice de byte dentro do texto do nó para (linha, coluna)
-- absolutas do buffer, considerando que raw strings (`...`) podem ter
-- múltiplas linhas.
local function posicao_absoluta(srow, scol, texto, byte_idx)
  local antes = texto:sub(1, byte_idx - 1)
  local _, quebras = antes:gsub("\n", "")
  if quebras == 0 then
    return srow, scol + byte_idx - 1
  end
  local ultima_quebra = 0
  for pos in antes:gmatch("()\n") do ultima_quebra = pos end
  return srow + quebras, byte_idx - ultima_quebra - 1
end

local function destacar_verbos_formato(bufnr)
  bufnr = bufnr or 0
  vim.api.nvim_buf_clear_namespace(bufnr, ns_verbo, 0, -1)

  local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr, "go")
  if not ok_parser or not parser then return end

  local ok_tree, tree = pcall(function() return parser:parse()[1] end)
  if not ok_tree or not tree then return end

  local ok_query, query = pcall(vim.treesitter.query.parse, "go", [[
    [
      (interpreted_string_literal)
      (raw_string_literal)
    ] @str
  ]])
  if not ok_query then return end

  for _, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
    local texto      = vim.treesitter.get_node_text(node, bufnr)
    local srow, scol = node:start()

    local pos = 1
    while true do
      local i, j = texto:find(PADRAO_VERBO, pos)
      if not i then break end

      local lin_i, col_i = posicao_absoluta(srow, scol, texto, i)
      local lin_j, col_j = posicao_absoluta(srow, scol, texto, j + 1)

      -- só marca verbos dentro de uma única linha (caso comum);
      -- verbos "quebrados" por uma quebra de linha não ocorrem na prática
      if lin_i == lin_j then
        pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_verbo, lin_i, col_i, {
          end_col  = col_j,
          hl_group = "MartiniVerboFormato",
        })
      end

      pos = j + 1
    end
  end
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern  = "go",
  callback = function(args) destacar_verbos_formato(args.buf) end,
})

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave", "BufEnter" }, {
  pattern  = "*.go",
  callback = function(args)
    vim.defer_fn(function() destacar_verbos_formato(args.buf) end, 30)
  end,
})
