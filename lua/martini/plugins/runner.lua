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
      go         = "cd $dir && go run .",
    },
  })
end)

vim.keymap.set("n", "<leader>gt", function()
  local dir = vim.fn.expand("%:p:h")
  vim.cmd("botright split | resize 15 | terminal cd " .. vim.fn.fnameescape(dir) .. " && go test -v")
end, { desc = "Go: testar pacote atual" })

vim.keymap.set("n", "<leader>gT", function()
  vim.cmd("botright split | resize 15 | terminal go test ./...")
end, { desc = "Go: testar projeto inteiro" })

vim.keymap.set("n", "<leader>tf", function()
  local dir = vim.fn.expand("%:p:h")
  local linha_atual = vim.fn.line(".")
  local nome_funcao = nil

  for l = linha_atual, 1, -1 do
    local texto = vim.fn.getline(l)
    local nome = texto:match("^func%s+(Test[%w_]*)%s*%(")
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
