-- =========================================================
-- lua/martini/plugins/debug.lua
-- Debugger via nvim-dap, dap-ui, dap-go e dap-python
-- =========================================================

pcall(function()
  require("dapui").setup()
end)

-- Cada adaptador em seu próprio pcall: uma falha em um não pode
-- impedir os outros de registrar suas configs em dap.configurations.
pcall(function()
  require("dap-python").setup("python3")
end)

pcall(function()
  require("dap-go").setup({
    delve = { path = vim.fn.exepath("dlv") },
  })
end)

-- Interface visual: abre/fecha automaticamente com a sessão de debug
pcall(function()
  local dap   = require("dap")
  local dapui = require("dapui")
  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open()  end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end
end)

-- Sinais customizados. FICAM POR ÚLTIMO de propósito: o próprio
-- nvim-dap define seus sinais padrão (texto "B") ao ser carregado
-- via require("dap") acima — se o sign_define rodasse antes disso,
-- o nvim-dap sobrescreveria nossa definição de volta para "B".
vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DapBreakpointSign" })
vim.fn.sign_define("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointSign" })
vim.fn.sign_define("DapBreakpointRejected",  { text = "●", texthl = "DapBreakpointRejectedSign" })
vim.fn.sign_define("DapLogPoint",            { text = "◆", texthl = "DapLogPointSign" })
vim.fn.sign_define("DapStopped",             { text = "→", texthl = "DapStoppedSign", linehl = "DapStoppedLine" })

vim.api.nvim_set_hl(0, "DapBreakpointSign",         { fg = "#ff3b5c" })
vim.api.nvim_set_hl(0, "DapBreakpointRejectedSign", { fg = "#7a8290" })
vim.api.nvim_set_hl(0, "DapLogPointSign",           { fg = "#4fc1ff" })
vim.api.nvim_set_hl(0, "DapStoppedSign",            { fg = "#39ff14" })
vim.api.nvim_set_hl(0, "DapStoppedLine",            { bg = "#1a1a1a" })
