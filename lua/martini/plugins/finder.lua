-- =========================================================
-- lua/martini/plugins/finder.lua
-- Busca fuzzy de arquivos e texto via fzf-lua.
-- Requisito: binário `fzf` instalado no sistema.
--
-- SEM <leader> de propósito: <leader>ff/<leader>fg já pertencem ao
-- :find/:grep nativos (ver config/keymaps.lua e config/options.lua),
-- que já resolvem busca simples sem depender de plugin. fzf-lua entra
-- como complemento — preview visual + fuzzy match de verdade — em
-- teclas fora do namespace <leader>, então não reintroduz a colisão
-- que motivou a remoção anterior do fzf-lua (<leader>fr batia com o
-- rename do LSP; ver nota de remoção em keymaps.lua).
--
-- <C-p> e <C-g> escolhidos por serem, nativamente, de baixo valor em
-- modo normal:
--   <C-p> == equivalente a 'k' (sobe uma linha) — redundante
--   <C-g> == mostra nome/status do arquivo atual — baixo uso no dia a dia
-- =========================================================

pcall(function()
  local fzf = require("fzf-lua")

  fzf.setup({
    winopts = {
      height  = 0.85,
      width   = 0.85,
      preview = {
        default  = "bat",  -- usa `bat` se disponível; cai para `cat` se não
        vertical = "up:45%",
      },
    },
    files = {
      -- Respeita .gitignore e ignora a pasta .git
      cmd = "fd --type f --hidden --exclude .git",
    },
  })

  -- register_ui_select() faz o fzf-lua assumir QUALQUER vim.ui.select do
  -- Neovim — não só busca de arquivo/grep. Isso troca a lista de texto
  -- simples que aparecia no seletor de configuração do dap-go (F5), e
  -- também code actions do LSP com múltiplas opções, pela mesma janela
  -- flutuante com borda usada no <C-p>/<C-g>.
  fzf.register_ui_select()
end)

-- =========================================================
-- Atalhos — sem prefixo <leader>
-- =========================================================
local map = vim.keymap.set

-- <C-p> : busca arquivos pelo nome no diretório do projeto
map("n", "<C-p>", function()
  require("fzf-lua").files()
end, { desc = "fzf: buscar arquivos pelo nome" })

-- <C-g> : busca texto (grep) em todos os arquivos do projeto
map("n", "<C-g>", function()
  require("fzf-lua").live_grep()
end, { desc = "fzf: buscar texto (grep) no projeto" })
