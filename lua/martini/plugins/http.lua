-- =========================================================
-- lua/martini/plugins/http.lua
-- HTTP client (kulala.nvim) — tests APIs via .http files
-- Requirements: Neovim 0.12+, curl, git, tree-sitter-cli (already present)
-- =========================================================

-- Enable the "http" filetype for .http and .rest files
vim.filetype.add({
  extension = {
    http = "http",
    rest = "http",
  },
})

-- PERF: kulala's setup() only runs the first time an .http/.rest buffer
-- is opened or an <leader>h keymap is used, instead of on every boot.
local kulala_ready = false

local function setup_kulala()
  if kulala_ready then return end
  kulala_ready = true

  pcall(function()
    require("kulala").setup({
      -- Default environment (dev/test/prod defined in http-client.env.json)
      default_env = "dev",

      ui = {
        display_mode    = "split",  -- response in a split window
        split_direction = "right",  -- opens to the right
        default_view    = "body",   -- shows the response body first
      },

      -- JSON response formatting
      response_format = {
        indent      = 2,
        expand_tabs = true,
        sort_keys   = false,
      },

      -- Reads environment variables in VSCode's REST Client format,
      -- keeping compatibility with existing .http files
      vscode_rest_client_environmentvars = true,
    })
  end)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern  = "http",
  callback = function()
    vim.schedule(setup_kulala)
  end,
})

-- =========================================================
-- Keymaps (prefix <leader>h for "HTTP" — renamed from <leader>R (ago/2026, uppercase removal))
-- =========================================================
local map = vim.keymap.set

map("n", "<leader>hs", function()
  setup_kulala()
  require("kulala").run()
end, { desc = "HTTP: send request under cursor" })

map("n", "<leader>ha", function()
  setup_kulala()
  require("kulala").run_all()
end, { desc = "HTTP: send all requests in file" })

map("n", "<leader>hb", function()
  setup_kulala()
  require("kulala").scratchpad()
end, { desc = "HTTP: open scratchpad" })

map("n", "<leader>hc", function()
  setup_kulala()
  require("kulala").copy()
end, { desc = "HTTP: copy request as curl command" })

map("n", "<leader>hn", function()
  setup_kulala()
  require("kulala").jump_next()
end, { desc = "HTTP: next request" })

map("n", "<leader>hp", function()
  setup_kulala()
  require("kulala").jump_prev()
end, { desc = "HTTP: previous request" })

map("n", "<leader>hq", function()
  setup_kulala()
  require("kulala").close()
end, { desc = "HTTP: close response window" })
