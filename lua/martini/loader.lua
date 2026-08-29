-- =========================================================
-- lua/martini/loader.lua
-- Carregador manual de plugins via git clone
-- Retorna true se for o primeiro boot (plugins recém-baixados)
--
-- AUDITORIA (ago/2026): dois plugins usados na configuração real
-- (ibhagwan/fzf-lua e jake-stewart/multicursor.nvim) nunca estavam
-- nesta lista — provavelmente clonados manualmente em algum momento.
-- Adicionados abaixo. Também removidos navarasu/onedark.nvim e
-- EdenEast/nightfox.nvim: continuavam sendo clonados a cada update,
-- mas nenhum arquivo da config chama require() neles (só
-- tokyonight.nvim é usado, em config/colors.lua) — peso morto.
-- =========================================================

local pack_path = vim.fn.stdpath("data") .. "/site/pack/meus_plugins/start/"
if vim.fn.isdirectory(pack_path) == 0 then vim.fn.mkdir(pack_path, "p") end

local primeiro_boot = false

-- `spec` pode ser uma string "dono/repo" ou uma tabela
-- { "dono/repo", branch = "1.0" } quando precisa de uma branch específica
-- (ex.: multicursor.nvim, cuja main não é a branch estável recomendada).
local function normalizar(spec)
  if type(spec) == "string" then
    return { repo = spec, branch = nil }
  end
  return { repo = spec[1], branch = spec.branch }
end

local function carregar_plugin(spec)
  local info    = normalizar(spec)
  local nome    = info.repo:match(".*/(.*)")
  local caminho = pack_path .. nome

  if vim.fn.isdirectory(caminho .. "/.git") == 0 then
    primeiro_boot = true
    print("Baixando: " .. nome .. (info.branch and (" (branch " .. info.branch .. ")") or "") .. "...")

    local cmd = { "git", "clone", "--depth", "1" }
    if info.branch then
      table.insert(cmd, "--branch")
      table.insert(cmd, info.branch)
    end
    table.insert(cmd, "https://github.com/" .. info.repo)
    table.insert(cmd, caminho)

    local resultado = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify("FALHA: " .. info.repo .. "\n" .. resultado, vim.log.levels.ERROR)
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
  "nvim-treesitter/nvim-treesitter",
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
  "ibhagwan/fzf-lua",
  { "jake-stewart/multicursor.nvim", branch = "1.0" },
}

for _, spec in ipairs(plugins) do carregar_plugin(spec) end
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
    for _, spec in ipairs(plugins) do
      local info = normalizar(spec)
      local nome = info.repo:match(".*/(.*)")
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
