-- =========================================================
-- lua/martini/config/options.lua
-- Configurações de comportamento e editor
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
vim.opt.colorcolumn    = "80"
vim.opt.wrap           = true
vim.opt.linebreak      = true
vim.opt.textwidth      = 80
vim.opt.termguicolors  = true
vim.opt.swapfile       = false
vim.opt.backup         = false
vim.opt.writebackup    = false
vim.opt.guifont        = "FiraCode Nerd Font Mono:h11"

vim.o.completeopt = "menu,menuone,noselect"

-- Diagnósticos
local sev = vim.diagnostic.severity
vim.diagnostic.config({
  severity_sort    = true,
  update_in_insert = false,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [sev.ERROR] = "E",
      [sev.WARN]  = "W",
      [sev.INFO]  = "I",
      [sev.HINT]  = "H",
    },
  },
})