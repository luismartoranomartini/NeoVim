-- =========================================================
-- lua/martini/plugins/debug.lua
-- Debugger via nvim-dap, dap-ui, dap-go e dap-python
-- =========================================================

pcall(function()
  local dap   = require("dap")
  local dapui = require("dapui")

  dapui.setup()
  require("dap-python").setup("python3")
  require("dap-go").setup({
    delve = {
      path = vim.fn.exepath("dlv"),
    },
  })

  -- Abre a interface visual automaticamente ao iniciar o debug
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  -- Fecha ao encerrar a sessão
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end)
