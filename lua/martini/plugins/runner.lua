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
      python     = "python",
      lua        = "lua",
      html       = "start %",
      -- $dir entra na pasta do arquivo e roda todos os .go do pacote
      go         = "cd $dir && go run .",
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

-- <leader>gn : testa apenas a função de teste sob o cursor (go nearest)
vim.keymap.set("n", "<leader>gn", function()
  local dir = vim.fn.expand("%:p:h")
  local linha_atual = vim.fn.line(".")
  local nome_funcao = nil

  -- Sobe a partir da linha do cursor procurando "func Test..."
  for l = linha_atual, 1, -1 do
    local texto = vim.fn.getline(l)
    local nome = texto:match("^func%s+(Test%w+)%s*%(")
    if nome then
      nome_funcao = nome
      break
    end
  end

  if not nome_funcao then
    vim.notify("Nenhuma função de teste encontrada acima do cursor", vim.log.levels.WARN)
    return
  end

  local cmd = string.format(
    "cd %s && go test -v -run ^%s$",
    vim.fn.fnameescape(dir), nome_funcao
  )
  vim.cmd("botright split | resize 15 | terminal " .. cmd)
end, { desc = "Go: testar função sob o cursor" })
