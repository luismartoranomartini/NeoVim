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
  "kylechui/nvim-surround",
}

for _, repo in ipairs(plugins) do carregar_plugin(repo) end
vim.cmd("silent! helptags ALL")

-- =========================================================
-- :MartiniUpdatePlugins
-- Roda "git pull --ff-only" em cada plugin já clonado, em
-- paralelo (vim.system é assíncrono). Plugins que ainda não
-- foram baixados são ignorados aqui — abrir o Neovim já cuida
-- disso via carregar_plugin().
-- =========================================================
do
  local git_bin = vim.fn.exepath("git")

  local function atualizar_plugins()
    if git_bin == "" then
      vim.notify("git não encontrado no PATH", vim.log.levels.ERROR)
      return
    end

    -- Remove duplicatas da lista (ex.: repo listado duas vezes)
    -- para não disparar dois "git pull" no mesmo diretório.
    local vistos, alvos = {}, {}
    for _, repo in ipairs(plugins) do
      local nome = repo:match(".*/(.*)")
      if not vistos[nome] then
        vistos[nome] = true
        local caminho = pack_path .. nome
        if vim.fn.isdirectory(caminho .. "/.git") == 1 then
          table.insert(alvos, { nome = nome, caminho = caminho })
        end
      end
    end

    local total     = #alvos
    local pendentes = total
    local sucesso   = 0
    local falhas    = {}

    if total == 0 then
      vim.notify("Nenhum plugin clonado para atualizar", vim.log.levels.WARN)
      return
    end

    vim.notify(string.format("Atualizando %d plugins...", total), vim.log.levels.INFO)

    local function finalizar()
      if #falhas == 0 then
        vim.notify(
          string.format("%d/%d plugins atualizados.", sucesso, total),
          vim.log.levels.INFO
        )
      else
        vim.notify(
          string.format(
            "%d/%d atualizados. Falharam:\n%s",
            sucesso, total, table.concat(falhas, "\n")
          ),
          vim.log.levels.WARN
        )
      end
    end

    for _, alvo in ipairs(alvos) do
      vim.system(
        { git_bin, "-C", alvo.caminho, "pull", "--ff-only" },
        { text = true },
        function(resultado)
          vim.schedule(function()
            if resultado.code == 0 then
              sucesso = sucesso + 1
            else
              local msg = (resultado.stderr or ""):gsub("%s+$", "")
              table.insert(falhas, alvo.nome .. ": " .. msg)
            end
            pendentes = pendentes - 1
            if pendentes == 0 then finalizar() end
          end)
        end
      )
    end
  end

  vim.api.nvim_create_user_command("MartiniUpdatePlugins", atualizar_plugins, {
    desc = "Atualiza (git pull --ff-only) todos os plugins clonados via loader.lua",
  })
end

return primeiro_boot
