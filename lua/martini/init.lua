-- =========================================================
-- lua/martini/init.lua
-- Ponto de entrada real da configuração martini.
--
-- Ordem de carregamento (importa por causa de dependências):
--   1. patch de compatibilidade do Neovim 0.12.2
--   2. loader (git clone dos plugins) + boot guard
--   3. config/      → comportamento e aparência do PRÓPRIO Neovim
--   4. languages/    → tudo que é específico de uma linguagem (Go, etc.)
--   5. plugins/      → configuração de cada plugin de terceiros
--
-- languages/ carrega ANTES de plugins/ porque martini.languages.go
-- registra vim.filetype.add() para *.tmpl/*.gohtml, e o LSP de HTML
-- (plugins/lsp.lua) referencia o filetype "gotmpl" resultante.
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
-- CONFIG → LANGUAGES → PLUGINS
-- =========================================================
require("martini.config")
require("martini.languages")
require("martini.plugins")
