-- =========================================================
-- lua/martini/loader.lua
-- Manual plugin loader via git clone
-- Returns true if this is the first boot (plugins freshly downloaded)
-- =========================================================
local pack_path = vim.fn.stdpath("data") .. "/site/pack/my_plugins/start/"
if vim.fn.isdirectory(pack_path) == 0 then vim.fn.mkdir(pack_path, "p") end
local first_boot = false
local function load_plugin(repo)
  local name = repo:match(".*/(.*)")
  local path = pack_path .. name
  if vim.fn.isdirectory(path .. "/.git") == 0 then
    first_boot = true
    print("Downloading: " .. name .. "...")
    local result = vim.fn.system({
      "git", "clone", "--depth", "1",
      "https://github.com/" .. repo, path,
    })
    if vim.v.shell_error ~= 0 then
      vim.notify("FAILED: " .. repo .. "\n" .. result, vim.log.levels.ERROR)
      return
    end
  end
  vim.opt.rtp:prepend(path)
  package.path = path .. "/lua/?.lua;"
              .. path .. "/lua/?/init.lua;"
              .. package.path
end
local plugins = {
  "folke/tokyonight.nvim",
  "navarasu/onedark.nvim",
  "EdenEast/nightfox.nvim",
  "folke/tokyonight.nvim",
  "nvim-treesitter/nvim-treesitter",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
  "rafamadriz/friendly-snippets",
  "windwp/nvim-autopairs",
  "stevearc/conform.nvim",
  "mfussenegger/nvim-lint",
  "mfussenegger/nvim-dap",
  "nvim-neotest/nvim-nio",
  "rcarriga/nvim-dap-ui",
  "mfussenegger/nvim-dap-python",
  "leoluz/nvim-dap-go",
  "mattn/emmet-vim",
  "nvim-tree/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons",
  "akinsho/bufferline.nvim",
  "CRAG666/code_runner.nvim",
  "mistweaverco/kulala.nvim",
  "derektata/lorem.nvim",
}
for _, repo in ipairs(plugins) do load_plugin(repo) end
-- Only generate helptags when something new was downloaded — it used to
-- run on EVERY boot, scanning the doc/ folder of all plugins unnecessarily.
if first_boot then
  vim.cmd("silent! helptags ALL")
end

-- =========================================================
-- :UpdatePlugins — updates all shallow-clone plugins
-- Since the clone is --depth 1 (no history), a normal "git pull" fails
-- (there's no complete upstream branch to merge). The solution is:
--   1. git fetch --depth 1 origin  → downloads only the newest commit
--   2. git reset --hard FETCH_HEAD → moves HEAD to the downloaded commit
-- FETCH_HEAD works regardless of the branch name (main, master, etc.),
-- so there's no need to figure out each repo's default branch name.
-- =========================================================
local function update_plugin(repo)
  local name = repo:match(".*/(.*)")
  local path = pack_path .. name

  if vim.fn.isdirectory(path .. "/.git") == 0 then
    vim.notify("Skipped (not installed): " .. name, vim.log.levels.WARN)
    return
  end

  print("Updating: " .. name .. "...")

  local fetch = vim.fn.system({ "git", "-C", path, "fetch", "--depth", "1", "origin" })
  if vim.v.shell_error ~= 0 then
    vim.notify("FAILED (fetch) on " .. name .. ":\n" .. fetch, vim.log.levels.ERROR)
    return
  end

  local reset = vim.fn.system({ "git", "-C", path, "reset", "--hard", "FETCH_HEAD" })
  if vim.v.shell_error ~= 0 then
    vim.notify("FAILED (reset) on " .. name .. ":\n" .. reset, vim.log.levels.ERROR)
  end
end

vim.api.nvim_create_user_command("UpdatePlugins", function()
  for _, repo in ipairs(plugins) do update_plugin(repo) end
  vim.cmd("silent! helptags ALL")
  vim.notify("Plugins updated.", vim.log.levels.INFO)
end, { desc = "Update all plugins (shallow-clone)" })

return first_boot
