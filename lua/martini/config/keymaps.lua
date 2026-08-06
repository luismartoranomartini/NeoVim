-- =========================================================
-- lua/martini/config/keymaps.lua
-- Global keymaps
-- =========================================================

-- Files and navigation
vim.keymap.set("n", "<leader>n",  ":tabnew<CR>")
vim.keymap.set("n", "<leader>e",  ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>t",  ":botright split | resize 15 | terminal<CR>i")

-- Buffers and tabs
vim.keymap.set("n", "<leader>bd", ":bd<CR>",       { desc = "Close buffer" })
vim.keymap.set("n", "<leader>bD", ":bd!<CR>",      { desc = "Close buffer (forced)" })
vim.keymap.set("n", "<leader>w",  ":tabclose<CR>", { desc = "Close current tab" })

-- Create/open the file under the cursor in a new tab.
-- Resolves the path relative to the CURRENT FILE'S FOLDER (not Neovim's
-- working directory), so href="style.css" creates the CSS next to the HTML.
vim.keymap.set("n", "gf", function()
  local target = vim.fn.expand("<cfile>")
  if target == "" then
    vim.notify("No filename under the cursor", vim.log.levels.WARN)
    return
  end

  -- If the path isn't absolute, join it with the current file's folder
  if not target:match("^/") then
    local current_dir = vim.fn.expand("%:p:h")
    target = current_dir .. "/" .. target
  end

  vim.cmd("tabedit " .. vim.fn.fnameescape(target))
  -- If the file doesn't exist on disk yet, write it to create it
  if not vim.uv.fs_stat(target) then
    vim.cmd("write")
  end
end, { desc = "Create/open the file under the cursor (relative to current folder)" })

-- Terminal
vim.keymap.set("t", "<Esc>",  "<C-\\><C-n>",       { desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-w>",  "<C-\\><C-n><C-w>",  { desc = "Navigate splits from inside the terminal" })
vim.keymap.set("t", "<C-q>",  "<C-\\><C-n><C-w>q", { desc = "Close terminal" })

local function toggle_terminal()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      vim.api.nvim_win_close(win, false)
      return
    end
  end
  vim.cmd("botright split | resize 15 | terminal")
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<C-t>", toggle_terminal,      { desc = "Toggle terminal" })
vim.keymap.set("t", "<C-t>", "<C-\\><C-n><C-w>q",  { desc = "Close terminal with Ctrl+t" })

-- Debugger
-- PERF: each action first calls debug_plugin.ensure(), which lazily
-- configures dap/dapui/dap-go/dap-python only on first actual use,
-- instead of on every boot.
local debug_plugin = require("martini.plugins.debug")

vim.keymap.set("n", "<F5>", function()
  debug_plugin.ensure()
  require("dap").continue()
end, { desc = "Debug: continue / start" })

vim.keymap.set("n", "<F10>", function()
  debug_plugin.ensure()
  require("dap").step_over()
end, { desc = "Debug: step over" })

vim.keymap.set("n", "<F11>", function()
  debug_plugin.ensure()
  require("dap").step_into()
end, { desc = "Debug: step into" })

vim.keymap.set("n", "<F12>", function()
  debug_plugin.ensure()
  require("dap").step_out()
end, { desc = "Debug: step out" })

vim.keymap.set("n", "<leader>b", function()
  debug_plugin.ensure()
  require("dap").toggle_breakpoint()
end, { desc = "Debug: breakpoint" })

vim.keymap.set("n", "<leader>dr", function()
  debug_plugin.ensure()
  require("dap").repl.open()
end, { desc = "Debug: open REPL" })

vim.keymap.set("n", "<leader>dt", function()
  debug_plugin.ensure()
  require("dap").terminate()
end, { desc = "Debug: terminate session" })

vim.keymap.set("n", "<leader>du", function()
  debug_plugin.ensure()
  require("dapui").toggle()
end, { desc = "Debug: visual interface" })

-- Code runner
vim.keymap.set("n", "<leader>r",  ":RunCode<CR>",    { desc = "Run current file" })
vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { desc = "Run project" })
