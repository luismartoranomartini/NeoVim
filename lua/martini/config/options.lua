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

-- Fold baseado em Treesitter — recolher/expandir funções e blocos com
-- za (alterna) / zc (fecha) / zo (abre) / zR (abre tudo) / zM (fecha tudo).
-- Funciona pra qualquer linguagem com parser Treesitter instalado (Go,
-- JS, Python, etc.), sem precisar de plugin extra.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel  = 99  -- abre tudo por padrão ao abrir o arquivo — sem
                         -- isso o Neovim abre o arquivo com tudo recolhido.

-- Busca de arquivo/texto nativa (:find / :grep), usada pelos atalhos
-- <leader>ff e <leader>fg em config/keymaps.lua. Substituem o fzf-lua
-- (removido em ago/2026 — ver nota de remoção em keymaps.lua).
--
-- "**" faz :find buscar recursivamente a partir do diretório de trabalho
-- atual, não só na pasta do arquivo aberto.
vim.opt.path:append("**")

-- Ignora essas pastas tanto na busca de :find quanto no wildmenu de
-- autocomplete de caminho (:e <Tab>, por exemplo).
vim.opt.wildignore:append({
  "*/node_modules/*",
  "*/.git/*",
  "*/vendor/*",  -- pasta padrão de dependências vendored do Go
})

-- :grep usa ripgrep se disponível no PATH (muito mais rápido que o
-- grep interno do Vim, que lê arquivo por arquivo em Vimscript).
-- Populamos a quickfix list automaticamente, sem preview visual —
-- é essa a troca consciente ao abandonar o fzf-lua.
if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg    = "rg --vimgrep --smart-case"
  vim.opt.grepformat = "%f:%l:%c:%m"
end

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
