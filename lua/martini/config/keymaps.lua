-- =========================================================
-- lua/martini/config/keymaps.lua
-- Atalhos globais de teclado
--
-- REESTRUTURAÇÃO (ago/2026) — prefixos semânticos por grupo:
--   <leader>b  → buffers        (bd, bD)
--   <leader>d  → debug          (db, dc, do, di, dO, dr, dt, du)
--   <leader>f  → find/arquivos  (já era do fzf-lua: ff/fg/fb/fh/fw/fr/fd/fs/fR
--                                 + fn, novo, "criar arquivo")
--   <leader>g  → Go             (gt, gT, gr — ver languages/go.lua)
--   <leader>m  → multicursor    (já existia, inalterado)
--   <leader>r  → run/executar   (r, rp — code_runner)
--   <leader>R  → HTTP/requests  (já existia, inalterado — Rs/Ra/Rb/Rc/Rn/Rp/Rq)
--
-- DECISÕES DELIBERADAS que se afastam da sugestão original de reorganização:
--
-- 1) gd / K / [d / ]d (LSP) NÃO viraram <leader>l*. São convenção universal
--    do ecossistema Neovim (literalmente o exemplo oficial de :h lsp-quickstart
--    e o que toda config baseada em nvim-lspconfig usa) — trocar isso quebraria
--    a compatibilidade com qualquer material de aprendizado de LSP no Neovim.
--
-- 2) <leader>t continua uma tecla ÚNICA e completa (abre terminal horizontal),
--    NÃO virou um prefixo de grupo (ex.: <leader>tt). Já foi tentado quando o
--    terminal vertical existia como <leader>tv: o Neovim, ao ver <leader>t já
--    mapeado como comando completo, dispara <leader>t IMEDIATAMENTE ao digitar
--    o "t" (sem esperar o timeoutlen), e o "v" seguinte vira texto literal
--    dentro do terminal recém-aberto. Por isso o terminal vertical é
--    <leader>vs (tecla própria, fora do namespace de <leader>t) — ver
--    utils/terminal.lua.
--
-- 3) <leader>w continua "fechar aba" (não é a motion nativa `w`, é
--    <leader>w — não há conflito real com "avançar palavra"; a crítica de
--    que isso sobrescreve uma motion fundamental do Vim não se aplica aqui,
--    pois o mapeamento sempre teve o prefixo leader).
-- =========================================================

local path     = require("martini.utils.path")
local terminal = require("martini.utils.terminal")

-- ── Arquivos e navegação ─────────────────────────────────
vim.keymap.set("n", "<leader>n", ":tabnew<CR>")
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>w", ":tabclose<CR>", { desc = "Fechar aba atual" })

-- Cria/abre arquivo sob o cursor em nova aba (ver utils/path.lua)
vim.keymap.set("n", "gf", path.goto_or_create,
  { desc = "Criar/Abrir arquivo sob o cursor (relativo à pasta atual)" })

-- NOVO: comando explícito de "novo arquivo", separado do gf — pedido pela
-- reestruturação (gf deveria continuar semanticamente "go to file", sem
-- acumular responsabilidade de criação via prompt). Agrupado sob <leader>f
-- porque já é o namespace de operações de arquivo do fzf-lua.
vim.keymap.set("n", "<leader>fn", path.new_file, { desc = "Find: novo arquivo (com mkdir -p)" })

-- ── Buffers ───────────────────────────────────────────────
vim.keymap.set("n", "<leader>bd", ":bd<CR>",  { desc = "Fechar buffer" })
vim.keymap.set("n", "<leader>bD", ":bd!<CR>", { desc = "Fechar buffer (forçado)" })

-- ── Terminal ──────────────────────────────────────────────
vim.keymap.set("n", "<leader>t", terminal.open_horizontal, { desc = "Abrir terminal (split horizontal)" })
vim.keymap.set("n", "<leader>vs", terminal.open_vertical,  { desc = "Abrir terminal (split vertical)" })
vim.keymap.set("n", "<C-t>", terminal.toggle,               { desc = "Toggle terminal" })

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>",       { desc = "Sair do modo terminal" })
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>",  { desc = "Navegar splits de dentro do terminal" })
vim.keymap.set("t", "<C-q>", "<C-\\><C-n><C-w>q", { desc = "Fechar terminal" })
vim.keymap.set("t", "<C-t>", "<C-\\><C-n><C-w>q", { desc = "Fechar terminal com Ctrl+t" })

-- ── Debug (nvim-dap / dap-ui) ─────────────────────────────
-- Carregado sob demanda: martini.plugins.debug.setup() só roda
-- dapui/dap-go/dap-python/codelldb na PRIMEIRA ação de debug, não no
-- boot — ver comentário em plugins/debug.lua.
local function dbg()
  require("martini.plugins.debug").setup()
  return require("dap")
end

-- Teclas de função — convenção universal de debugger (VSCode, JetBrains, etc.)
vim.keymap.set("n", "<F5>",  function() dbg().continue() end,   { desc = "Debug: continuar / iniciar" })
vim.keymap.set("n", "<F10>", function() dbg().step_over() end,  { desc = "Debug: passo sobre (step over)" })
vim.keymap.set("n", "<F11>", function() dbg().step_into() end,  { desc = "Debug: passo para dentro (step into)" })
vim.keymap.set("n", "<F12>", function() dbg().step_out() end,   { desc = "Debug: passo para fora (step out)" })

-- Aliases <leader>d* — mesmas ações, para quem prefere não tirar a mão
-- da home row / não decorar teclas de função.
vim.keymap.set("n", "<leader>db", function() dbg().toggle_breakpoint() end, { desc = "Debug: breakpoint" })
vim.keymap.set("n", "<leader>dc", function() dbg().continue() end,         { desc = "Debug: continuar / iniciar" })
vim.keymap.set("n", "<leader>do", function() dbg().step_over() end,        { desc = "Debug: passo sobre" })
vim.keymap.set("n", "<leader>di", function() dbg().step_into() end,        { desc = "Debug: passo para dentro" })
vim.keymap.set("n", "<leader>dO", function() dbg().step_out() end,         { desc = "Debug: passo para fora" })
vim.keymap.set("n", "<leader>dr", function() dbg().repl.open() end,        { desc = "Debug: abrir REPL" })
vim.keymap.set("n", "<leader>dt", function() dbg().terminate() end,        { desc = "Debug: encerrar sessão" })
vim.keymap.set("n", "<leader>du", function()
  require("martini.plugins.debug").setup()
  require("dapui").toggle()
end, { desc = "Debug: interface visual" })

-- ── Code runner ───────────────────────────────────────────
vim.keymap.set("n", "<leader>r",  ":RunCode<CR>",    { desc = "Executar arquivo atual" })
vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { desc = "Executar projeto" })
