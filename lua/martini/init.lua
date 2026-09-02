-- =========================================================
-- TARGET: Neovim 0.12 · Arch Linux
-- lua/martini/init.lua
-- Bootstrap: patch 0.12.2 + lazy.nvim + ordem de carregamento
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
-- PLUGINS — bootstrap via lazy.nvim (set/2026, substitui loader.lua)
-- Ver lua/martini/lazy.lua pro motivo da troca e o que mudou.
-- =========================================================
local primeiro_boot = require("martini.lazy")

if primeiro_boot then
  vim.notify("Plugins sendo instalados pelo lazy.nvim. Aguarde a janela terminar e reinicie o Neovim.", vim.log.levels.WARN)
  return
end

-- =========================================================
-- CONFIG — comportamento, aparência e atalhos
-- Delegado a config/init.lua (agregador correto, mesma lógica já
-- usada em plugins/init.lua abaixo) — inclui config/diagnostics.lua.
-- =========================================================
require("martini.config")

-- =========================================================
-- PLUGINS — configuração de cada plugin
-- Delegado a plugins/init.lua. UM único require aqui evita
-- duplicar/divergir a lista de plugins em dois arquivos.
-- =========================================================
require("martini.plugins")
