-- =========================================================
-- lua/martini/plugins/fzf.lua
-- Busca fuzzy via fzf-lua (arquivos, texto, buffers, LSP)
-- Requisito: binário fzf no PATH (já instalado via pacman)
-- =========================================================

pcall(function()
  local fzf = require("fzf-lua")

  fzf.setup({
    winopts = {
      height  = 0.85,
      width   = 0.85,
      preview = {
        default  = "bat",       -- usa 'bat' se existir; cai para builtin se não
        layout   = "flex",
      },
    },
    fzf_colors = true,  -- respeita as cores do seu colors.lua
  })

  -- Registra o fzf-lua como fonte de UI (vim.ui.select) — troca o menu
  -- padrão do Neovim (ex: code actions do LSP) pelo seletor fuzzy
  fzf.register_ui_select()
end)

-- =========================================================
-- Atalhos (prefixo <leader>f de "Find")
-- =========================================================
local map = vim.keymap.set

map("n", "<leader>ff", function() require("fzf-lua").files() end,
  { desc = "Fzf: buscar arquivos" })

map("n", "<leader>fg", function() require("fzf-lua").live_grep() end,
  { desc = "Fzf: buscar texto no projeto (ripgrep)" })

map("n", "<leader>fb", function() require("fzf-lua").buffers() end,
  { desc = "Fzf: buscar entre buffers abertos" })

map("n", "<leader>fh", function() require("fzf-lua").oldfiles() end,
  { desc = "Fzf: arquivos recentes" })

map("n", "<leader>fw", function() require("fzf-lua").grep_cword() end,
  { desc = "Fzf: buscar palavra sob o cursor no projeto" })

map("n", "<leader>fr", function() require("fzf-lua").resume() end,
  { desc = "Fzf: retomar última busca" })

-- LSP integrado (referências, símbolos, definições) via fzf-lua
map("n", "<leader>fd", function() require("fzf-lua").lsp_definitions() end,
  { desc = "Fzf: definição (LSP)" })

map("n", "<leader>fs", function() require("fzf-lua").lsp_document_symbols() end,
  { desc = "Fzf: símbolos do arquivo (LSP)" })

-- RENOMEADO (ago/2026, remoção de maiúsculas): era <leader>fR.
-- "u" de "usages" ("find usages", termo padrão de IDEs pra referências).
map("n", "<leader>fu", function() require("fzf-lua").lsp_references() end,
  { desc = "Fzf: referências / usages (LSP)" })
