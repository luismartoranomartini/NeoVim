-- =========================================================
-- TARGET: Neovim 0.12 · Arch Linux
-- lua/martini/init.lua
-- Bootstrap: patch 0.12.2 + loader de plugins + ordem de carregamento
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
-- Delegado a config/init.lua (agregador correto, mesma lógica já
-- usada em plugins/init.lua abaixo). ANTES este bloco listava
-- options/colors/keymaps/dashboard individualmente e PULAVA
-- config/diagnostics.lua — vim.diagnostic.config() nunca era chamado,
-- então os sinais/virtual_text customizados definidos ali (E/W/I/H,
-- texto inline estilo Error Lens) nunca entravam em vigor, mesmo o
-- arquivo existindo e estando correto. UM único require aqui evita
-- esse tipo de divergência entre a lista de módulos e o que
-- config/init.lua realmente agrega.
-- =========================================================
require("martini.config")

-- =========================================================
-- PLUGINS — configuração de cada plugin
-- Delegado a plugins/init.lua (já existia, correto, mas nunca era
-- chamado — causa raiz do erro "module 'martini.plugins.ui' not
-- found"). UM único require aqui evita duplicar/divergir a lista
-- de plugins em dois arquivos.
-- =========================================================
require("martini.plugins")
