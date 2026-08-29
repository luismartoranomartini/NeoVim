-- =========================================================
-- lua/martini/plugins/editing.lua
-- Pequenos plugins de conveniência de edição, agrupados por serem
-- coesos e pequenos individualmente: autopairs, autotag, surround, emmet.
-- Extraído de plugins/ui.lua durante a reestruturação (ago/2026).
-- =========================================================

-- Autopairs
pcall(function()
  require("nvim-autopairs").setup({ check_ts = true })
end)

-- Autotag — fecha/renomeia/atualiza tags HTML/JSX automaticamente
-- conforme digita, usando o Treesitter pra saber onde a tag termina
-- (ex.: digitar <form> já insere </form> com o cursor entre as duas;
-- renomear a tag de abertura atualiza a de fechamento junto).
pcall(function()
  require("nvim-ts-autotag").setup()
end)

-- Surround — seleciona/adiciona/troca delimitadores ("", '', (), [], {}, <>)
-- ao redor de palavra ou seleção visual, no estilo VSCode "Select + wrap".
-- Keymaps padrão do plugin (não usa <leader>):
--   ys{motion}{char}  → adiciona delimitador  (ex.: ysiw" envolve a palavra em "")
--   cs{alvo}{novo}    → troca delimitador      (ex.: cs"' troca " por ')
--   ds{alvo}          → remove delimitador     (ex.: ds" remove as aspas)
--   Visual + S{char}  → envolve a seleção visual no delimitador escolhido
pcall(function()
  require("nvim-surround").setup({})
end)

-- Emmet
-- "iv" habilita as funções de Insert (expandir abreviação com Tab) e
-- de Visual (Ctrl+y depois , pra "wrap with abbreviation" — envolver
-- uma seleção numa tag). Era só "i" antes, e isso desligava por
-- completo qualquer função de modo Visual do plugin, mesmo com o
-- <plug>(emmet-wrap-with-abbreviation) mapeado corretamente.
vim.g.user_emmet_mode           = "iv"
vim.g.user_emmet_install_global = 0

vim.api.nvim_create_autocmd("FileType", {
  pattern  = { "html", "css", "scss", "jsx", "tsx" },
  callback = function() vim.cmd("EmmetInstall") end,
})
