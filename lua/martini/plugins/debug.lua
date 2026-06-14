-- =========================================================
-- lua/martini/plugins/debug.lua
-- Debugger via nvim-dap, dap-ui e dap-python
-- =========================================================

pcall(function()
  require("dapui").setup()
  require("dap-python").setup("python")
  require("dap-go").setup({
    delve = {
      path = vim.fn.exepath("dlv"),  -- caminho do Delve no Windows
    },
  })
end)