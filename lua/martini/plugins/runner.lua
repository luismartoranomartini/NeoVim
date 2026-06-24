-- =========================================================
-- lua/martini/plugins/runner.lua
-- Execução de arquivos sem sair do Neovim via code_runner
-- =========================================================

pcall(function()
  require("code_runner").setup({
    mode        = "term",
    focus       = true,
    startinsert = false,
    filetype = {
      javascript = "node",
      typescript = "npx tsx",
      python     = "python3",
      lua        = "lua",
      html       = "xdg-open %",
      -- $dir entra na pasta do arquivo e roda todos os .go do pacote
      go         = "cd $dir && go run .",
      -- compila e executa: gera binário temporário e roda
      c          = "cd $dir && gcc $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",
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
