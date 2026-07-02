-- =========================================================
-- lua/martini/plugins/http.lua
-- Cliente HTTP (kulala.nvim) — testa APIs via arquivos .http
-- Requisitos: Neovim 0.12+, curl, git, tree-sitter-cli (todos já presentes)
-- =========================================================

pcall(function()
  require("kulala").setup({
    -- Ambiente padrão (dev/test/prod definidos em http-client.env.json)
    default_env = "dev",

    ui = {
      display_mode    = "split",  -- resposta em janela dividida
      split_direction = "right",  -- abre à direita
      default_view    = "body",   -- mostra o corpo da resposta primeiro
    },

    -- Formatação da resposta JSON
    response_format = {
      indent      = 2,
      expand_tabs = true,
      sort_keys   = false,
    },

    -- Lê variáveis de ambiente no formato do REST Client do VSCode,
    -- garantindo compatibilidade com arquivos .http já existentes
    vscode_rest_client_environmentvars = true,
  })
end)

-- Ativa o filetype "http" para arquivos .http e .rest
vim.filetype.add({
  extension = {
    http = "http",
    rest = "http",
  },
})

-- =========================================================
-- Atalhos (prefixo <leader>R de "Request")
-- =========================================================
local map = vim.keymap.set

map("n", "<leader>Rs", function() require("kulala").run() end,
  { desc = "HTTP: enviar requisicao sob o cursor" })

map("n", "<leader>Ra", function() require("kulala").run_all() end,
  { desc = "HTTP: enviar todas as requisicoes do arquivo" })

map("n", "<leader>Rb", function() require("kulala").scratchpad() end,
  { desc = "HTTP: abrir scratchpad (rascunho rapido)" })

map("n", "<leader>Rc", function() require("kulala").copy() end,
  { desc = "HTTP: copiar requisicao como comando curl" })

map("n", "<leader>Rn", function() require("kulala").jump_next() end,
  { desc = "HTTP: proxima requisicao" })

map("n", "<leader>Rp", function() require("kulala").jump_prev() end,
  { desc = "HTTP: requisicao anterior" })

map("n", "<leader>Rq", function() require("kulala").close() end,
  { desc = "HTTP: fechar janela de resposta" })
