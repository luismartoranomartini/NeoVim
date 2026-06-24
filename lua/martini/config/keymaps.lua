-- =========================================================
-- lua/martini/config/keymaps.lua
-- Atalhos globais de teclado
-- =========================================================

-- Arquivos e navegação
vim.keymap.set("n", "<leader>n",  ":tabnew<CR>")
vim.keymap.set("n", "<leader>e",  ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>t",  ":botright split | resize 15 | terminal<CR>i")

-- Buffers e abas
vim.keymap.set("n", "<leader>bd", ":bd<CR>",       { desc = "Fechar buffer" })
vim.keymap.set("n", "<leader>bD", ":bd!<CR>",      { desc = "Fechar buffer (forçado)" })
vim.keymap.set("n", "<leader>w",  ":tabclose<CR>", { desc = "Fechar aba atual" })

-- Criar/abrir arquivo sob o cursor em nova aba
vim.keymap.set("n", "gf", function()
  local arquivo = vim.fn.expand("<cfile>")
  vim.cmd("tabedit " .. vim.fn.fnameescape(arquivo))
  if not vim.uv.fs_stat(arquivo) then vim.cmd("write") end
end, { desc = "Criar/Abrir arquivo sob o cursor (nova aba)" })

-- Terminal
vim.keymap.set("t", "<Esc>",  "<C-\\><C-n>",       { desc = "Sair do modo terminal" })
vim.keymap.set("t", "<C-w>",  "<C-\\><C-n><C-w>",  { desc = "Navegar splits de dentro do terminal" })
vim.keymap.set("t", "<C-q>",  "<C-\\><C-n><C-w>q", { desc = "Fechar terminal" })

local function toggle_terminal()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      vim.api.nvim_win_close(win, false)
      return
    end
  end
  vim.cmd("botright split | resize 15 | terminal")
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<C-t>", toggle_terminal,         { desc = "Toggle terminal" })
vim.keymap.set("t", "<C-t>", "<C-\\><C-n><C-w>q",    { desc = "Fechar terminal com Ctrl+t" })

-- Debugger
vim.keymap.set("n", "<F5>",       function() require("dap").continue() end)
vim.keymap.set("n", "<leader>b",  function() require("dap").toggle_breakpoint() end)
vim.keymap.set("n", "<leader>du", function() require("dapui").toggle() end)

-- Code runner  (<leader>r reservado — não usar outros <leader>r*)
vim.keymap.set("n", "<leader>r",  ":RunCode<CR>",    { desc = "Executar arquivo atual" })
vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { desc = "Executar projeto" })
<<<<<<< HEAD

-- =========================================================
-- LSP — ativados apenas quando um servidor está conectado
-- Prefixo <leader>l para não colidir com <leader>r (runner)
-- =========================================================
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf }

    -- Navegação
    vim.keymap.set("n", "gd",         vim.lsp.buf.definition,      vim.tbl_extend("force", opts, { desc = "Ir para definição" }))
    vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,     vim.tbl_extend("force", opts, { desc = "Ir para declaração" }))
    vim.keymap.set("n", "gr",         vim.lsp.buf.references,      vim.tbl_extend("force", opts, { desc = "Listar referências" }))
    vim.keymap.set("n", "gi",         vim.lsp.buf.implementation,  vim.tbl_extend("force", opts, { desc = "Ir para implementação" }))
    vim.keymap.set("n", "K",          vim.lsp.buf.hover,           vim.tbl_extend("force", opts, { desc = "Documentação (hover)" }))

    -- Refactoring
    vim.keymap.set("n",        "<leader>lr", vim.lsp.buf.rename,        vim.tbl_extend("force", opts, { desc = "LSP: Renomear símbolo" }))
    vim.keymap.set({ "n","v" },"<leader>la", vim.lsp.buf.code_action,   vim.tbl_extend("force", opts, { desc = "LSP: Code action" }))

    -- Diagnósticos
    vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float,  vim.tbl_extend("force", opts, { desc = "LSP: Diagnóstico inline" }))
    vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,   vim.tbl_extend("force", opts, { desc = "Diagnóstico anterior" }))
    vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,   vim.tbl_extend("force", opts, { desc = "Próximo diagnóstico" }))
  end,
})
=======
>>>>>>> 789bee1ed595f3e8200a2f9d7294bfbccc7fe7eb
