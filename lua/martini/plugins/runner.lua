-- =========================================================
-- lua/martini/plugins/runner.lua
-- Execução de arquivos via code_runner (<leader>r)
-- Variáveis do plugin:
--   $dir                pasta absoluta do arquivo
--   $fileName           nome do arquivo com extensão
--   $fileNameWithoutExt nome sem extensão
-- Sempre caminhos absolutos ($dir) — caminhos relativos falham.
--
-- Os atalhos de teste do Go (<leader>gt/<leader>gT/<leader>gr) e a
-- entrada "go" desta tabela de filetypes foram movidos/são
-- contribuídos por languages/go.lua durante a reestruturação
-- (ago/2026) — este arquivo só monta a base genérica e mescla o
-- que cada languages/*.lua contribuir (extensível pra Rust,
-- TypeScript etc. no futuro sem tocar aqui).
-- =========================================================

local base_filetypes = {
  -- Interpretadas (rodam direto)
  python     = "python3 -u",
  lua        = "lua",
  javascript = "node",
  typescript = "npx tsx",
  sh         = "bash",
  bash       = "bash",
  ruby       = "ruby",
  php        = "php",
  perl       = "perl",

  -- Compiladas: compilam em binário temporário e executam
  -- -g inclui símbolos de debug no binário — sem isso, o codelldb
  -- roda o processo mas não consegue mapear endereço de memória
  -- para linha de código, e os breakpoints não param em lugar
  -- nenhum. Não afeta a execução normal via <leader>r.
  c = "cd $dir && gcc -g $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",

  cpp = "cd $dir && g++ -g $fileName -o /tmp/$fileNameWithoutExt -std=c++17 && /tmp/$fileNameWithoutExt",

  rust = "cd $dir && rustc $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",

  java = "cd $dir && javac $fileName && java $fileNameWithoutExt",

  -- Abre no navegador padrão do sistema
  html = "xdg-open $dir/$fileName",
}

local go         = require("martini.languages.go")
local filetypes  = vim.tbl_extend("force", base_filetypes, go.runner_filetypes or {})

pcall(function()
  require("code_runner").setup({
    mode        = "term",
    focus       = true,
    startinsert = false,
    term = {
      position = "bot",  -- terminal na parte inferior
      size     = 12,
    },
    filetype = filetypes,
  })
end)
