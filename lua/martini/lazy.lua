-- =========================================================
-- lua/martini/lazy.lua
-- Bootstrap do lazy.nvim, substituindo loader.lua (set/2026).
--
-- POR QUE A TROCA: loader.lua fazia git clone --depth 1 no branch padrão
-- de cada plugin, sem trava de versão nenhuma — uma config que funciona
-- hoje podia quebrar amanhã com um push de qualquer um dos ~29 plugins,
-- sem lockfile, comando de update ou rollback. lazy.nvim resolve isso
-- automaticamente: grava lazy-lock.json com o commit exato de cada
-- plugin após instalar/atualizar. Comitando esse arquivo no repo, toda
-- reinstalação (Arch/Fedora/Windows) usa exatamente as mesmas versões.
--
-- TODOS os plugins abaixo usam lazy = false (carregamento no boot,
-- igual ao loader.lua antigo) DE PROPÓSITO — não é lazy loading de
-- verdade ainda. O resto do código (go.lua, colors.lua, debug.lua, etc.)
-- faz require() desses plugins diretamente no topo do arquivo, assumindo
-- que já estão no runtimepath quando plugins/init.lua roda. Lazy
-- loading por evento (InsertEnter, BufReadPost, cmd, etc.) exigiria
-- refatorar esses requires em cada plugins/*.lua pra rodar sob demanda
-- — mudança maior, fora do escopo desta correção. O ganho aqui é
-- reprodutibilidade automática, não redução de tempo de boot.
-- =========================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local primeiro_boot_lazy = vim.fn.isdirectory(lazypath) == 0

if primeiro_boot_lazy then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Mesma lista de plugins do loader.lua antigo, com a MESMA sintaxe
-- { "dono/repo", branch = "x" } já usada lá pro multicursor.nvim —
-- lazy.nvim entende esse formato nativamente.
local plugins = {
  { "folke/tokyonight.nvim",  lazy = false },
  { "navarasu/onedark.nvim",  lazy = false },
  { "EdenEast/nightfox.nvim", lazy = false },
  { "nvim-treesitter/nvim-treesitter",              lazy = false },
  { "nvim-treesitter/nvim-treesitter-textobjects",  lazy = false },
  { "hrsh7th/nvim-cmp",         lazy = false },
  { "hrsh7th/cmp-nvim-lsp",     lazy = false },
  { "hrsh7th/cmp-buffer",       lazy = false },
  { "L3MON4D3/LuaSnip",         lazy = false },
  { "saadparwaiz1/cmp_luasnip", lazy = false },
  { "rafamadriz/friendly-snippets", lazy = false },
  { "windwp/nvim-autopairs",  lazy = false },
  { "windwp/nvim-ts-autotag", lazy = false },
  { "kylechui/nvim-surround", lazy = false },
  { "stevearc/conform.nvim",  lazy = false },
  { "mfussenegger/nvim-lint", lazy = false },
  { "mfussenegger/nvim-dap",  lazy = false },
  { "nvim-neotest/nvim-nio",       lazy = false },
  { "rcarriga/nvim-dap-ui",        lazy = false },
  { "mfussenegger/nvim-dap-python", lazy = false },
  { "leoluz/nvim-dap-go",          lazy = false },
  { "mattn/emmet-vim", lazy = false },
  { "nvim-tree/nvim-tree.lua",        lazy = false },
  { "nvim-tree/nvim-web-devicons",    lazy = false },
  { "akinsho/bufferline.nvim",        lazy = false },
  { "CRAG666/code_runner.nvim",       lazy = false },
  { "mistweaverco/kulala.nvim",       lazy = false },
  { "jake-stewart/multicursor.nvim", branch = "1.0", lazy = false },
  { "ibhagwan/fzf-lua", lazy = false },
}

-- Detecta se algum plugin ainda não foi clonado ANTES de chamar setup()
-- — mesma lógica de "primeiro_boot" que loader.lua tinha, só que agora
-- delegando a instalação em si pro lazy.nvim (install.missing = true).
-- Preservamos o aviso de restart porque, no primeiro boot, a instalação
-- roda numa janela flutuante própria do lazy.nvim — se plugins/init.lua
-- tentasse dar require() nos plugins ainda sendo baixados, falharia.
local plugins_root = vim.fn.stdpath("data") .. "/lazy/"
local faltando = false
for _, spec in ipairs(plugins) do
  local repo = spec[1]
  local nome = repo:match(".*/(.*)")
  if vim.fn.isdirectory(plugins_root .. nome) == 0 then
    faltando = true
    break
  end
end

require("lazy").setup(plugins, {
  root = plugins_root,
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
  install = { missing = true },
  -- Não notifica sozinho sobre updates disponíveis nem sobre mudanças
  -- de config detectadas — updates continuam deliberados, via
  -- :Lazy update rodado manualmente, igual ao :MartiniUpdatePlugins
  -- de antes (mesmo princípio: "atualizações devem ser deliberadas").
  checker         = { enabled = false },
  change_detection = { notify = false },
})

return primeiro_boot_lazy or faltando
