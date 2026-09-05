-- =========================================================
-- lua/martini/plugins/editing.lua
-- Pequenos plugins de conveniência de edição, agrupados por serem
-- coesos e pequenos individualmente: autopairs, autotag, surround, emmet.
-- =========================================================

-- Autopairs
pcall(function()
  require("nvim-autopairs").setup({ check_ts = true })
end)

-- Autotag — fecha/renomeia/atualiza tags HTML/JSX automaticamente
-- conforme digita, usando o Treesitter pra saber onde a tag termina.
pcall(function()
  require("nvim-ts-autotag").setup()
end)

-- Surround — seleciona/adiciona/troca delimitadores ("", '', (), [], {}, <>)
-- ao redor de palavra ou seleção visual, no estilo VSCode "Select + wrap".
-- Keymaps padrão do plugin (não usa <leader>):
--   ys{motion}{char} → adiciona delimitador (ex.: ysiw" envolve a palavra em "")
--   cs{alvo}{novo}   → troca delimitador (ex.: cs"' troca " por ')
--   ds{alvo}         → remove delimitador (ex.: ds" remove as aspas)
--   Visual + S{char} → envolve a seleção visual no delimitador escolhido
pcall(function()
  require("nvim-surround").setup({})
end)

-- Emmet — abreviações de HTML/CSS/JSX expandidas via Tab (ver
-- plugins/completion.lua, integração com nvim-cmp).
vim.g.user_emmet_mode = "iv"
vim.g.user_emmet_install_global = 0

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "css", "scss", "jsx", "tsx" },
  callback = function() vim.cmd("EmmetInstall") end,
})
