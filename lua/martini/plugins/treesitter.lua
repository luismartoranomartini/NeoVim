-- =========================================================
-- lua/martini/plugins/treesitter.lua
-- Extraído de plugins/ui.lua durante a reestruturação (ago/2026).
-- Highlights específicos de Go (verbos de printf, ações de template)
-- ficaram em languages/go.lua — aqui só o genérico.
-- =========================================================

-- Treesitter — API nova (branch "main" do nvim-treesitter).
-- O módulo "nvim-treesitter.configs" foi REMOVIDO na reescrita de 2024;
-- não existe mais ensure_installed/highlight.enable via configs.setup().
-- Agora install() baixa e compila os parsers (idempotente — não reinstala
-- se já presentes), e o highlight é ativado manualmente por buffer via
-- vim.treesitter.start() no autocmd FileType logo abaixo.
--
-- NOTA (abr/2026): o repositório nvim-treesitter/nvim-treesitter foi
-- arquivado pelo dono. A branch "main" que usamos aqui continua
-- funcionando normalmente (arquivado ≠ apagado), só não recebe mais
-- atualizações nem parsers novos. Sem ação necessária agora.
local ts_langs = { "lua", "javascript", "typescript", "go", "python", "html", "css", "c", "yaml" }

pcall(function()
  require("nvim-treesitter").install(ts_langs)
end)

-- Força o início do Treesitter highlight ao abrir arquivos.
-- Necessário no 0.12 onde não existe mais highlight={enable=true}.
vim.api.nvim_create_autocmd("FileType", {
  pattern = ts_langs,
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
