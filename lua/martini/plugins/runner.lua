-- =========================================================
-- lua/martini/plugins/runner.lua
-- Execução de arquivos via code_runner (<leader>r)
-- Variáveis do plugin:
--   $dir                pasta absoluta do arquivo
--   $fileName           nome do arquivo com extensão
--   $fileNameWithoutExt nome sem extensão
-- Sempre caminhos absolutos ($dir) — caminhos relativos falham.
-- =========================================================

pcall(function()
  require("code_runner").setup({
    mode        = "term",
    focus       = true,
    startinsert = false,
    term = {
      position = "bot",  -- terminal na parte inferior
      size     = 12,
    },
    filetype = {
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

      -- Go: roda o pacote inteiro da pasta
      go = "cd $dir && go run .",

      -- Compiladas: compilam em binário temporário e executam
      c = "cd $dir && gcc $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",

      cpp = "cd $dir && g++ $fileName -o /tmp/$fileNameWithoutExt -std=c++17 && /tmp/$fileNameWithoutExt",

      rust = "cd $dir && rustc $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",

      java = "cd $dir && javac $fileName && java $fileNameWithoutExt",

      -- Abre no navegador padrão do sistema
      html = "xdg-open $dir/$fileName",
    },
  })
end)

-- =========================================================
-- Atalhos de teste para Go
-- =========================================================
-- <leader>gt : testa o pacote do arquivo atual (verbose)
vim.keymap.set("n", "<leader>gt", function()
  local dir = vim.fn.expand("%:p:h")
  vim.cmd("botright split | resize 15 | terminal cd " .. vim.fn.fnameescape(dir) .. " && go test -v")
end, { desc = "Go: testar pacote atual" })

-- <leader>gT : testa o projeto inteiro
vim.keymap.set("n", "<leader>gT", function()
  vim.cmd("botright split | resize 15 | terminal go test ./...")
end, { desc = "Go: testar projeto inteiro" })

-- <leader>tf : testa APENAS a função de teste onde o cursor está
-- posicionado (ou a função de teste mais próxima acima do cursor).
-- Usa go test -run ^NomeDaFuncao$ para escopar a um único teste.
--
-- IMPORTANTE: o padrão de Lua %w NÃO inclui sublinhado. Nomes de teste em Go
-- costumam usar underscore (ex.: Test_Create_Campaign), então o padrão de
-- casamento precisa ser [%w_]* — nunca %w* sozinho, ou o nome é cortado
-- no primeiro underscore.
vim.keymap.set("n", "<leader>tf", function()
  local bufnr      = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local func_name   = nil

  -- Varre da linha do cursor para cima até achar "func TestAlgo(t *testing.T)"
  for lnum = cursor_line, 1, -1 do
    local linha = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
    local nome = linha:match("^func%s+(Test[%w_]*)%s*%(")
    if nome then
      func_name = nome
      break
    end
  end

  if not func_name then
    vim.notify("Nenhuma função de teste encontrada acima do cursor", vim.log.levels.WARN)
    return
  end

  local dir = vim.fn.expand("%:p:h")
  local cmd = string.format(
    "cd %s && go test -v -run ^%s$",
    vim.fn.fnameescape(dir),
    func_name
  )
  vim.cmd("botright split | resize 15 | terminal " .. cmd)
end, { desc = "Go: testar apenas a função de teste sob o cursor" })
