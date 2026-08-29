-- =========================================================
-- lua/martini/config/options.lua
-- Configurações de comportamento e editor (puro vim.opt/vim.g)
-- Diagnósticos ficaram em config/diagnostics.lua.
-- =========================================================

vim.g.mapleader = " "

vim.opt.number         = true
vim.opt.relativenumber = false
vim.opt.clipboard      = "unnamedplus"
vim.opt.tabstop        = 4
vim.opt.shiftwidth     = 4
vim.opt.expandtab      = true
vim.opt.cursorline     = true
vim.opt.signcolumn     = "yes"
vim.opt.fillchars      = { vert = "│" }
vim.opt.colorcolumn    = "120"
vim.opt.wrap           = true
vim.opt.linebreak      = true
vim.opt.textwidth      = 100
vim.opt.termguicolors  = true
vim.opt.swapfile       = false
vim.opt.backup         = false
vim.opt.writebackup    = false
vim.opt.guifont        = "FiraCode Nerd Font Mono:h11"

vim.o.completeopt = "menu,menuone,noselect"

-- Cursor em formato de barra vertical (em vez do bloco padrão) apenas
-- dentro do modo Terminal ("t"). Não altera o cursor nos outros modos.
vim.opt.guicursor:append("t:ver25")

-- Quebra de linha AUTOMÁTICA (hard wrap) ao ultrapassar textwidth (100),
-- restrita a arquivos de TEXTO/PROSA — markdown, mensagens de commit,
-- texto puro, reStructuredText, AsciiDoc, LaTeX. A flag "t" do
-- formatoptions insere uma quebra de linha de verdade enquanto você
-- digita — diferente de wrap/linebreak acima, que só quebram
-- visualmente sem alterar o conteúdo do arquivo.
--
-- IMPORTANTE: formatoptions global é sempre sobrescrito pelos ftplugins
-- embutidos do Neovim (ex.: /usr/share/nvim/runtime/ftplugin/markdown.vim
-- roda "setlocal formatoptions=..." ao abrir o arquivo). Por isso é
-- reaplicado via autocmd FileType, que roda DEPOIS do ftplugin embutido.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "gitcommit", "text", "rst", "asciidoc", "tex" },
  callback = function()
    vim.opt_local.formatoptions:append("t")
  end,
})
