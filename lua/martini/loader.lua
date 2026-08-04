-- =========================================================
-- lua/martini/loader.lua
-- Carregador manual de plugins via git clone
-- Retorna true se for o primeiro boot (plugins recém-baixados)
-- =========================================================
local pack_path = vim.fn.stdpath("data") .. "/site/pack/meus_plugins/start/"
if vim.fn.isdirectory(pack_path) == 0 then vim.fn.mkdir(pack_path, "p") end
local primeiro_boot = false

local plugins = {
  "folke/tokyonight.nvim",
  "navarasu/onedark.nvim",
  "EdenEast/nightfox.nvim",
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

  -- O Neovim já adiciona automaticamente pack/*/start/* ao runtimepath
  -- antes do init.lua rodar. Prependar de novo aqui duplicaria o caminho,
  -- o que faz o LuaSnip (from_vscode.lazy_load) carregar cada snippet
  -- do friendly-snippets duas vezes. Por isso, só adiciona se ainda não estiver lá.
  if not vim.tbl_contains(vim.opt.rtp:get(), caminho) then
    vim.opt.rtp:prepend(caminho)
  end
  package.path = caminho .. "/lua/?.lua;"
              .. caminho .. "/lua/?/init.lua;"
              .. package.path
end

for _, repo in ipairs(plugins) do carregar_plugin(repo) end
vim.cmd("silent! helptags ALL")

-- =========================================================
-- Comando manual de atualização
-- Roda 'git pull' em cada plugin já clonado (não afeta os que
-- ainda não existem — esses são baixados no próximo boot).
-- =========================================================
vim.api.nvim_create_user_command("MartiniUpdatePlugins", function()
  local atualizados = 0
  local falhas       = {}

  for _, repo in ipairs(plugins) do
    local nome    = repo:match(".*/(.*)")
    local caminho = pack_path .. nome

    if vim.fn.isdirectory(caminho .. "/.git") == 1 then
      print("Atualizando: " .. nome .. "...")
      local resultado = vim.fn.system({ "git", "-C", caminho, "pull" })
      if vim.v.shell_error ~= 0 then
        table.insert(falhas, nome .. ": " .. resultado)
      else
        atualizados = atualizados + 1
      end
    end
  end

  if #falhas > 0 then
    vim.notify(
      "Atualizados: " .. atualizados .. "\nFalhas:\n" .. table.concat(falhas, "\n"),
      vim.log.levels.ERROR
    )
  else
    vim.notify("Todos os " .. atualizados .. " plugins foram atualizados.", vim.log.levels.INFO)
  end
end, { desc = "Atualiza todos os plugins via git pull" })

return primeiro_boot
