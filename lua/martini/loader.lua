-- =========================================================
-- lua/martini/loader.lua
-- Carregador manual de plugins via git clone
-- Retorna true se for o primeiro boot (plugins recém-baixados)
-- =========================================================

local pack_path = vim.fn.stdpath("data") .. "/site/pack/meus_plugins/start/"
if vim.fn.isdirectory(pack_path) == 0 then vim.fn.mkdir(pack_path, "p") end

local primeiro_boot = false

-- Aceita tanto uma string simples ("dono/repo") quanto uma tabela com
-- branch explícita ({ "dono/repo", branch = "1.0" }) — necessário pro
-- multicursor.nvim, que precisa da branch "1.0" (não a "main").
local function carregar_plugin(entrada)
  local repo, branch
  if type(entrada) == "table" then
    repo   = entrada[1]
    branch = entrada.branch
  else
    repo = entrada
  end

  local nome    = repo:match(".*/(.*)")
  local caminho = pack_path .. nome

  if vim.fn.isdirectory(caminho .. "/.git") == 0 then
    primeiro_boot = true
    print("Baixando: " .. nome .. (branch and (" (branch " .. branch .. ")") or "") .. "...")

    local cmd = { "git", "clone", "--depth", "1" }
    if branch then
      table.insert(cmd, "--branch")
      table.insert(cmd, branch)
    end
    table.insert(cmd, "https://github.com/" .. repo)
    table.insert(cmd, caminho)

    local resultado = vim.fn.system(cmd)
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
  "nvim-treesitter/nvim-treesitter",
  "nvim-treesitter/nvim-treesitter-textobjects",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
  "rafamadriz/friendly-snippets",
  "windwp/nvim-autopairs",
  "windwp/nvim-ts-autotag",
  "kylechui/nvim-surround",
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
  { "jake-stewart/multicursor.nvim", branch = "1.0" },
  "ibhagwan/fzf-lua",
}

for _, entrada in ipairs(plugins) do carregar_plugin(entrada) end
vim.cmd("silent! helptags ALL")

return primeiro_boot
