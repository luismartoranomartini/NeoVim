-- =========================================================
-- TARGET: Neovim 0.12 · Windows 11 nativo
-- Entrada principal — carrega o patch, os plugins e os módulos
-- =========================================================

-- =========================================================
-- PATCH: Bug no Neovim 0.12.2 — chave 'buf' inválida
-- =========================================================
do
  local function corrigir_buf(opts)
    if type(opts) == "table" and opts.buf ~= nil and opts.buffer == nil then
      opts        = vim.tbl_extend("force", {}, opts)
      opts.buffer = opts.buf
      opts.buf    = nil
    end
    return opts
  end

  local orig_create = vim.api.nvim_create_autocmd
  vim.api.nvim_create_autocmd = function(event, opts)
    return orig_create(event, corrigir_buf(opts))
  end

  local orig_exec = vim.api.nvim_exec_autocmds
  vim.api.nvim_exec_autocmds = function(event, opts)
    return orig_exec(event, corrigir_buf(opts))
  end
end

-- =========================================================
-- PLUGINS — carregamento e boot guard
-- =========================================================
local primeiro_boot = require("martini.loader")

if primeiro_boot then
  vim.notify("Plugins baixados. Reinicie o Neovim.", vim.log.levels.WARN)
  return
end

-- =========================================================
-- CONFIG — comportamento, aparência e atalhos
-- =========================================================
require("martini.config.options")
require("martini.config.colors")
require("martini.config.keymaps")
require("martini.config.dashboard")

-- =========================================================
-- PLUGINS — configuração de cada plugin
-- =========================================================
require("martini.plugins.ui")
require("martini.plugins.lsp")
require("martini.plugins.format")
require("martini.plugins.debug")
require("martini.plugins.runner")