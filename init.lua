-- =========================================================
-- init.lua
-- TARGET: Neovim 0.12 · WSL / Ubuntu
-- Entry point — loads the patch, plugins, and modules
-- =========================================================

-- PERF: caches compiled Lua bytecode across runs, shaving a small
-- but consistent slice off every "require()" call during startup.
vim.loader.enable()

-- =========================================================
-- PATCH: Neovim 0.12.2 bug — invalid 'buf' key
-- =========================================================
do
  local function fix_buf(opts)
    if type(opts) == "table" and opts.buf ~= nil and opts.buffer == nil then
      opts        = vim.tbl_extend("force", {}, opts)
      opts.buffer = opts.buf
      opts.buf    = nil
    end
    return opts
  end

  local orig_create = vim.api.nvim_create_autocmd
  vim.api.nvim_create_autocmd = function(event, opts)
    return orig_create(event, fix_buf(opts))
  end

  local orig_exec = vim.api.nvim_exec_autocmds
  vim.api.nvim_exec_autocmds = function(event, opts)
    return orig_exec(event, fix_buf(opts))
  end
end

-- =========================================================
-- PLUGINS — loading and boot guard
-- =========================================================
local first_boot = require("martini.loader")

if first_boot then
  vim.notify("Plugins downloaded. Restart Neovim.", vim.log.levels.WARN)
  return
end

-- =========================================================
-- CONFIG — behavior, appearance, and keymaps
-- =========================================================
require("martini.config.options")
require("martini.config.colors")
require("martini.config.keymaps")
require("martini.config.dashboard")

-- =========================================================
-- PLUGINS — per-plugin configuration
-- =========================================================
require("martini.plugins.ui")
require("martini.plugins.lsp")
require("martini.plugins.format")
require("martini.plugins.debug")
require("martini.plugins.runner")
require("martini.plugins.http")
