-- =========================================================
-- lua/martini/config/colors.lua
-- Fundo preto · paleta harmônica baseada em Tokyo Night
-- =========================================================
local function aplicar_highlights()
  local hl = vim.api.nvim_set_hl
  -- Paleta com saturação equilibrada, tons frios predominantes
  local cor = {
    azul     = "#6e7efa",  -- funções, métodos
    ciano    = "#5ea9ff",  -- pacotes / namespaces 
    dourado  = "#DCC218",  -- tipos e structs
    coral    = "#ff0000",  -- keywords (func, return, if, for)
    verde    = "#6ace6d",  -- strings
    laranja  = "#FFD700",  -- números e constantes
    lavanda  = "#e63bf7",  -- operadores
    roxo     = "#9966ff",  -- booleanos, nil, builtins
    cinza    = "#565f89",  -- comentários
    branco   = "#c0caf5",  -- variáveis e texto
    verbo    = "#ff9d5c",  -- verbos de formatação (%s, %d, %v...)
    escape   = "#ff2975",  -- sequências de escape (\n, \t, \", \\...)
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
  hl(0, "String",          { fg = cor.verde })

  -- Sequências de escape (\n, \t, \", \\...) → cor própria, separada
  -- da dos verbos de formatação (%s, %d...). O Treesitter já separa
  -- isso como nó próprio (@string.escape) — não precisa do truque de
  -- extmark usado para os verbos.
  hl(0, "@string.escape",  { fg = cor.escape })

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

  -- Verbos de formatação (%s, %d, %v, %-5.2f...) em Go/C/Python/JS/TS →
  -- cor própria, aplicada por cima da string via extmark (ver
  -- destacar_verbos_fmt abaixo) — o Treesitter não separa isso da
  -- string em si.
  hl(0, "FormatVerb", { fg = cor.verbo, bold = true })

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

-- =========================================================
-- Verbos de formatação (%s, %d, %v, %-5.2f, %%, ...)
--
-- Cobre Go, C, Python (estilo printf, com flags/largura/precisão) e
-- JavaScript/TypeScript (estilo console.log/util.format, mais simples,
-- sem flags/largura/precisão — confirmado na especificação oficial do
-- Console API, console.spec.whatwg.org/#formatter). HTML/CSS/SQL ficam
-- de fora por não terem esse estilo de formatação nativamente.
--
-- Cada gramática do Treesitter trata o conteúdo de uma string como um
-- bloco só, sem separar os verbos como nós distintos — por isso o
-- Treesitter puro não consegue colorir só o verbo diferente do resto da
-- string. Confirmado para Go numa issue aberta no próprio projeto
-- (tree-sitter/tree-sitter-go#182, nov/2025); as demais gramáticas têm a
-- mesma limitação.
--
-- Solução: localizar as strings via Treesitter (nomes de nó confirmados
-- direto nos arquivos highlights.scm oficiais de cada gramática), buscar
-- o padrão de verbo (diferente por linguagem) dentro do texto de cada
-- uma, e sobrepor a cor certa via extmark (prioridade acima do
-- highlight padrão do Treesitter).
-- =========================================================
local ns_fmt_verb = vim.api.nvim_create_namespace("martini_fmt_verbos")

-- Go/C/Python (estilo printf): % + flags (- + espaço # 0) + largura +
-- . + precisão + verbo. Suporta %-5.2f, %05d etc.
local PADRAO_PRINTF = "%%[%-%+ #0]*%d*%.?%d*[vTtbcdoOqxXUeEfFgGsqp%%]"

-- JavaScript/TypeScript (console.log / util.format): lista mais curta e
-- SEM largura/precisão — confirmado na especificação oficial do Console
-- API (WHATWG, console.spec.whatwg.org/#formatter) e na documentação do
-- Node.js. %j é exclusivo do Node (JSON.stringify do argumento).
local PADRAO_CONSOLE_JS = "%%[sdifoOcj%%]"

-- Nome do node de string em cada gramática, confirmado nos respectivos
-- highlights.scm oficiais:
--   Go:         interpreted_string_literal / raw_string_literal
--   C:          string_literal (tree-sitter/tree-sitter-c)
--   Python:     string (tree-sitter/tree-sitter-python)
--   JS/TS:      string / template_string (tree-sitter/tree-sitter-javascript,
--               reaproveitado pelo tree-sitter-typescript)
local CONFIG_POR_FILETYPE = {
  go         = { lang = "go",         padrao = PADRAO_PRINTF,
                 query = "[(interpreted_string_literal) (raw_string_literal)] @str" },
  c          = { lang = "c",          padrao = PADRAO_PRINTF,
                 query = "(string_literal) @str" },
  python     = { lang = "python",     padrao = PADRAO_PRINTF,
                 query = "(string) @str" },
  javascript = { lang = "javascript", padrao = PADRAO_CONSOLE_JS,
                 query = "[(string) (template_string)] @str" },
  typescript = { lang = "typescript", padrao = PADRAO_CONSOLE_JS,
                 query = "[(string) (template_string)] @str" },
}

local function destacar_verbos_fmt(bufnr)
  bufnr = bufnr or 0
  local cfg = CONFIG_POR_FILETYPE[vim.bo[bufnr].filetype]
  if not cfg then return end

  local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr, cfg.lang)
  if not ok_parser or not parser then return end

  vim.api.nvim_buf_clear_namespace(bufnr, ns_fmt_verb, 0, -1)

  local ok_tree, trees = pcall(function() return parser:parse() end)
  if not ok_tree or not trees or not trees[1] then return end
  local root = trees[1]:root()

  local ok_query, query = pcall(vim.treesitter.query.parse, cfg.lang, cfg.query)
  if not ok_query then return end

  for _, node in query:iter_captures(root, bufnr, 0, -1) do
    local start_row, start_col, end_row, end_col = node:range()
    if start_row == end_row then
      local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1] or ""
      local texto = line:sub(start_col + 1, end_col)
      local pos = 1
      while true do
        local s, e = texto:find(cfg.padrao, pos)
        if not s then break end
        pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_fmt_verb, start_row, start_col + s - 1, {
          end_col  = start_col + e,
          hl_group = "FormatVerb",
          priority = 200, -- acima da prioridade padrão do Treesitter (100)
        })
        pos = e + 1
      end
    end
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = vim.tbl_keys(CONFIG_POR_FILETYPE),
  callback = function(args)
    local bufnr = args.buf
    destacar_verbos_fmt(bufnr)
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave", "BufEnter" }, {
      buffer   = bufnr,
      callback = function() destacar_verbos_fmt(bufnr) end,
    })
  end,
})
