-- =========================================================
-- lua/martini/loader.lua
-- Carregador manual de plugins via git clone
-- Retorna true se for o primeiro boot (plugins recém-baixados)
-- =========================================================

local pack_path = vim.fn.stdpath("data") .. "/site/pack/meus_plugins/start/"
if vim.fn.isdirectory(pack_path) == 0 then vim.fn.mkdir(pack_path, "p") end

local primeiro_boot = false

local function carregar_plugin(repo)
  local nome    = repo:match(".*/(.*)")
  local caminho = pack_path .. nome

  if vim.fn.isdirectory(caminho .. "/.git") == 0 then
    primeiro_boot = true
    print("Baixando: " .. nome .. "...")
    local resultado = vim.fn.system({
      "git", "clone", "--depth", "1",
      "https://github.com/" .. repo, caminho,
    })
    if vim.v.shell_error ~= 0 then
      vim.notify("FALHA: " .. repo .. "\n" .. resultado, vim.log.levels.ERROR)
      return
    end
  end

  vim.opt.rtp:prepend(caminho)
  package.path = caminho .. "/lua/?.lua;"
              .. caminho .. "/lua/?/init.lua;"
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
}

for _, repo in ipairs(plugins) do carregar_plugin(repo) end
vim.cmd("silent! helptags ALL")

return primeiro_boot
