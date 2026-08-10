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

  -- Pacotes / namespaces → CIANO (itálico)
  hl(0, "@lsp.type.namespace",    { fg = cor.ciano, italic = true })
  hl(0, "@lsp.type.namespace.go", { fg = cor.ciano, italic = true })
  hl(0, "@namespace",  { fg = cor.ciano, italic = true })
  hl(0, "@module",     { fg = cor.ciano, italic = true })

  -- Tipos e structs → AMARELO
  hl(0, "@lsp.type.type",    { fg = cor.amarelo })
  hl(0, "@lsp.type.type.go", { fg = cor.amarelo })
  hl(0, "@type",            { fg = cor.amarelo })
  hl(0, "@type.builtin",    { fg = cor.amarelo })
  hl(0, "@type.definition", { fg = cor.amarelo })
  hl(0, "Type",             { fg = cor.amarelo })

  -- Keywords → VERMELHO (itálico)
  hl(0, "@keyword",          { fg = cor.vermelho, italic = true })
  hl(0, "@keyword.function", { fg = cor.vermelho, italic = true })
  hl(0, "@keyword.return",   { fg = cor.vermelho, italic = true })
  hl(0, "@keyword.import",   { fg = cor.vermelho, italic = true })
  hl(0, "@conditional",      { fg = cor.vermelho, italic = true })
  hl(0, "@repeat",           { fg = cor.vermelho, italic = true })
  hl(0, "Keyword",           { fg = cor.vermelho, italic = true })
  hl(0, "Statement",         { fg = cor.vermelho, italic = true })

  -- Strings → VERDE
  -- Zeradas para @lsp.type.string* NÃO sobrescrever: assim o extmark do
  -- scanner de verbos/escapes (abaixo) consegue pintar por cima sem
  -- disputa de prioridade com o semantic token do gopls.
  hl(0, "@lsp.type.string",    {})
  hl(0, "@lsp.type.string.go", {})
  hl(0, "@string",         { fg = cor.verde })
  hl(0, "@string.escape",  { fg = cor.verde })
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

  -- Variáveis e parâmetros → BRANCO
  hl(0, "@lsp.type.variable",     { fg = cor.branco })
  hl(0, "@lsp.type.variable.go",  { fg = cor.branco })
  hl(0, "@lsp.type.parameter",    { fg = cor.branco })
  hl(0, "@lsp.type.parameter.go", { fg = cor.branco })
  hl(0, "@variable",        { fg = cor.branco })
  hl(0, "@variable.member", { fg = cor.branco })
  hl(0, "@parameter",       { fg = cor.branco })
  hl(0, "Identifier",       { fg = cor.branco })

  -- Virtual text de diagnóstico (mensagem inline no fim da linha)
  hl(0, "DiagnosticVirtualTextError", { fg = cor.vermelho })
  hl(0, "DiagnosticVirtualTextWarn",  { fg = cor.laranja })
  hl(0, "DiagnosticVirtualTextInfo",  { fg = cor.azul })
  hl(0, "DiagnosticVirtualTextHint",  { fg = cor.cinza })

  -- Sinais do debugger (nvim-dap)
  hl(0, "DapBreakpoint",          { fg = cor.vermelho })
  hl(0, "DapBreakpointCondition", { fg = cor.laranja })
  hl(0, "DapBreakpointRejected",  { fg = cor.cinza })
  hl(0, "DapStopped",             { fg = cor.verde })
  hl(0, "DapLogPoint",            { fg = cor.azul })

  -- Verbos de formatação (%v, %s, %d...) → LARANJA em negrito
  -- Sequências de escape (\n, \t...)      → ROSA em negrito
  -- (aplicadas via extmark pelo scanner abaixo, não por Treesitter)
  hl(0, "GoFormatVerb", { fg = cor.laranja, bold = true })
  hl(0, "GoEscapeSeq",  { fg = cor.rosa,    bold = true })

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
      keywords  = { italic = true, bold = false },
      functions = { italic = true, bold = false },
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
-- Scanner de verbos de formatação e escapes em strings Go
-- Treesitter localiza os nós de string; regex Lua encontra
-- %v, %s, %d... e \n, \t... dentro deles; extmark aplica a cor
-- sem alterar o parser nem o texto do buffer.
-- =========================================================
local go_verbs_ns = vim.api.nvim_create_namespace("martini_go_format_verbs")

-- %[flags][largura][.precisão]verbo — ex: %v %+d %5.2f %-10s %%
local PADRAO_VERBO   = "%%[%-%+ 0#]*%d*%.?%d*[vTtbcdoqxXUeEfFgGsp%%]"
-- \n \t \r \\ \" \' \a \b \f \v — sequências de escape comuns
local PADRAO_ESCAPE  = "\\[ntrbfav\\'\"]"

local function destacar_verbos_go(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  if vim.bo[bufnr].filetype ~= "go" then return end

  vim.api.nvim_buf_clear_namespace(bufnr, go_verbs_ns, 0, -1)

  local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr, "go")
  if not ok_parser or not parser then return end

  local ok_tree, trees = pcall(function() return parser:parse() end)
  if not ok_tree or not trees or not trees[1] then return end

  local ok_query, query = pcall(vim.treesitter.query.parse, "go", [[
    [
      (interpreted_string_literal)
      (raw_string_literal)
    ] @string
  ]])
  if not ok_query then return end

  local root = trees[1]:root()

  for _, node in query:iter_captures(root, bufnr, 0, -1) do
    local start_row, start_col, end_row, end_col = node:range()

    -- Só trata strings de uma linha só (cobre o caso comum de fmt.Printf)
    if start_row == end_row then
      local linha = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
      if linha then
        local trecho = linha:sub(start_col + 1, end_col)

        local pos = 1
        while true do
          local s, e = trecho:find(PADRAO_VERBO, pos)
          if not s then break end
          vim.api.nvim_buf_set_extmark(bufnr, go_verbs_ns, start_row, start_col + s - 1, {
            end_col  = start_col + e,
            hl_group = "GoFormatVerb",
            priority = 200,
          })
          pos = e + 1
        end

        pos = 1
        while true do
          local s, e = trecho:find(PADRAO_ESCAPE, pos)
          if not s then break end
          vim.api.nvim_buf_set_extmark(bufnr, go_verbs_ns, start_row, start_col + s - 1, {
            end_col  = start_col + e,
            hl_group = "GoEscapeSeq",
            priority = 200,
          })
          pos = e + 1
        end
      end
    end
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern  = "go",
  callback = function(args) destacar_verbos_go(args.buf) end,
})

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave", "BufWritePost" }, {
  pattern  = "*.go",
  callback = function(args) destacar_verbos_go(args.buf) end,
})
