-- =========================================================
-- lua/martini/plugins/runner.lua
-- Execução de arquivos via code_runner (<leader>r)
-- Variáveis reconhecidas pelo plugin nos comandos abaixo:
--   $fileName          → nome do arquivo com extensão
--   $fileNameWithoutExt → nome do arquivo sem extensão
--   $dir                → diretório do arquivo (sempre "cd $dir"
--                          antes de comandos que dependem de caminho
--                          relativo — caminho absoluto direto falha)
-- Os atalhos de teste do Go (<leader>gt/<leader>ga/<leader>gr) e a
-- entrada "go" desta tabela de filetypes são contribuídos por
-- languages/go.lua — este arquivo só monta a base genérica e mescla
-- o que cada languages/*.lua contribuir.
--
-- ESCOPO REDUZIDO (set/2026) ao que é usado: JS/TS, C/C++, HTML
-- (abrir no navegador), Lua (testar trechos da própria config).
-- Removidos: python, ruby, php, perl, rust, java, sh/bash.
-- =========================================================

local base_filetypes = {
  -- Interpretadas (rodam direto)
  lua = "lua",
  javascript = "node",
  typescript = "npx tsx",

  -- Compiladas: compilam em binário temporário e executam.
  -- -g inclui símbolos de debug no binário — sem isso, o codelldb
  -- roda o processo mas não consegue mapear endereço de memória
  -- para linha de código, e os breakpoints não param em lugar
  -- nenhum (ver plugins/debug.lua). Não afeta a execução normal.
  c = "cd $dir && gcc -g $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",
  cpp = "cd $dir && g++ -g $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",

  -- Abre no navegador padrão do sistema
  html = "xdg-open $dir/$fileName",
}

local go = require("martini.languages.go")
local filetypes = vim.tbl_extend("force", base_filetypes, go.runner_filetypes or {})

pcall(function()
  require("code_runner").setup({
    mode = "term",
    focus = true,
    startinsert = false,
    term = {
      position = "bot", -- terminal na parte inferior
      size = 12,
    },
    filetype = filetypes,
  })
end)
