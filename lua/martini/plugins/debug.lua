-- =========================================================
-- lua/martini/plugins/debug.lua
-- Debugger via nvim-dap, dap-ui, dap-go, and dap-python
-- =========================================================

-- PERF: setup is deferred until a debug keymap is actually used, instead
-- of eagerly configuring dap/dapui/dap-go/dap-python on every boot.
-- Requiring this module itself stays cheap — it only defines M.ensure().

local M = {}
local ready = false

function M.ensure()
  if ready then return end
  ready = true

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

    -- Open the visual interface automatically when debugging starts
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    -- Close it when the session ends
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end)
end

return M
