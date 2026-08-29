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
    teal     = "#5ccfe6",  -- parâmetros de função
  }

  -- Funções e métodos → AZUL
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
  hl(0, "@keyword.return",   { fg = cor.vermelho })
  hl(0, "@keyword.import",   { fg = cor.vermelho })
  hl(0, "@conditional",      { fg = cor.vermelho })
  hl(0, "@repeat",           { fg = cor.vermelho })
  hl(0, "Keyword",           { fg = cor.vermelho })
  hl(0, "Statement",         { fg = cor.vermelho })

  -- Keywords de DECLARAÇÃO (func, e — via highlights.scm customizado
  -- em after/queries/go/ — chan/map/interface/struct) → DOURADO +
  -- ITÁLICO, separadas do resto dos keywords (if/for/return continuam
  -- vermelho reto). @keyword.type é um grupo próprio criado no
  -- highlights.scm justamente pra isso; sem essa definição aqui, ele
  -- cai no fallback de @keyword (vermelho, sem itálico).
  hl(0, "@keyword.function", { fg = cor.vermelho, italic = true })
  hl(0, "@keyword.type",     { fg = cor.vermelho, italic = true })

  -- Strings → VERDE
  hl(0, "@string",         { fg = cor.verde })
  hl(0, "String",          { fg = cor.verde })

  -- Escape sequences (\n, \t, \", etc.) e verbos de formatação
  -- (%s, %d, %v — ver matchadd em languages/go.lua, pois o Treesitter
  -- do Go não marca verbos de printf como nó separado) → LARANJA,
  -- pra se destacar do verde da string normal.
  hl(0, "@string.escape",  { fg = cor.laranja })

  -- Verbos de formatação do Go (%s, %d, %v, etc. — ver matchadd em
  -- languages/go.lua, pois o Treesitter do Go não marca verbos de
  -- printf como nó separado) → AMARELO, pra diferenciar dos escapes.
  hl(0, "GoFormatVerb",    { fg = cor.amarelo })

  -- Ações de template Go ({{ }}) dentro de arquivos .html/.tmpl → ROSA,
  -- via matchadd em languages/go.lua (não existe parser Treesitter
  -- mantido/funcional pra Go template hoje — nvim-treesitter foi
  -- arquivado em abr/2026 — então isso é highlight aproximado, não
  -- semântico; não confundir com autocomplete, que não existe pra isso).
  hl(0, "GoTemplateAction", { fg = cor.rosa, bold = true })

  -- IMPORTANTE: limpa o override do gopls (semantic tokens), que
  -- achata a string inteira numa cor só e esconde o highlight de
  -- escape sequences do Treesitter. Sem isso, as duas linhas acima
  -- não têm efeito nenhum em arquivos .go.
  hl(0, "@lsp.type.string",    {})
  hl(0, "@lsp.type.string.go", {})

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

  -- Variáveis → BRANCO
  hl(0, "@lsp.type.variable",     { fg = cor.branco })
  hl(0, "@lsp.type.variable.go",  { fg = cor.branco })
  hl(0, "@variable",        { fg = cor.branco })
  hl(0, "@variable.member", { fg = cor.branco })
  hl(0, "Identifier",       { fg = cor.branco })

  -- Parâmetros de função → CORAL + ITÁLICO, separados das variáveis
  -- comuns (antes estavam juntos em branco, sem diferenciação).
  hl(0, "@lsp.type.parameter",    { fg = cor.teal, italic = true })
  hl(0, "@lsp.type.parameter.go", { fg = cor.teal, italic = true })
  hl(0, "@parameter",             { fg = cor.teal, italic = true })
  hl(0, "@variable.parameter",    { fg = cor.teal, italic = true })

  -- nvim-tree: cores por nome de pasta (decorator customizado em
  -- plugins/nvim-tree.lua, que mapeia cada pasta a um destes grupos — API
  -- oficial nvim_tree.api.decorator.UserDecorator, ver
  -- :help nvim-tree-decorators). Edite a tabela "pasta_icones" em
  -- plugins/nvim-tree.lua pra adicionar mais nomes de pasta além destes.
  hl(0, "NvimTreeFolderCmd",       { fg = cor.vermelho, bold = true }) -- entrypoints (cmd/)
  hl(0, "NvimTreeFolderViews",     { fg = cor.azul,      bold = true }) -- views/
  hl(0, "NvimTreeFolderStatic",    { fg = cor.laranja })                -- static/
  hl(0, "NvimTreeFolderTemplates", { fg = cor.ciano })                  -- templates/
  hl(0, "NvimTreeFolderModels",    { fg = cor.roxo,      bold = true }) -- models/
  hl(0, "NvimTreeFolderDb",        { fg = cor.verde })                  -- db/
  hl(0, "NvimTreeFolderInternal",  { fg = cor.teal })                   -- internal/
  hl(0, "NvimTreeFolderConfig",    { fg = cor.amarelo })                -- config/
  hl(0, "NvimTreeFolderHandlers",  { fg = cor.rosa })                   -- handlers/

  -- nvim-tree: cores dos ícones de diagnóstico (erro/aviso/info/hint)
  -- na árvore, usando a mesma paleta customizada em vez das cores
  -- padrão do TokyoNight — mantém consistência visual com o resto
  -- do editor. show_on_dirs (em plugins/nvim-tree.lua) propaga essas cores
  -- pra pasta fechada quando há diagnóstico escondido dentro.
  hl(0, "NvimTreeLspDiagnosticsError",       { fg = cor.vermelho })
  hl(0, "NvimTreeLspDiagnosticsWarning",     { fg = cor.laranja })
  hl(0, "NvimTreeLspDiagnosticsInformation", { fg = cor.ciano })
  hl(0, "NvimTreeLspDiagnosticsHint",        { fg = cor.roxo })

  -- nvim-dap: cores dos signs de breakpoint (ver plugins/debug.lua e languages/go.lua).
  -- Usa highlight group + caractere Unicode simples em vez de emoji,
  -- que renderiza grande e sem controle de tamanho no terminal.
  hl(0, "DapBreakpointHl",          { fg = cor.vermelho })
  hl(0, "DapBreakpointConditionHl", { fg = cor.laranja })
  hl(0, "DapLogPointHl",            { fg = cor.azul })
  hl(0, "DapStoppedHl",             { fg = cor.verde })
  hl(0, "DapBreakpointRejectedHl",  { fg = cor.cinza })
  hl(0, "DapStoppedLine",           { bg = "#2a2a1a" }) -- destaque sutil da linha atual

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
