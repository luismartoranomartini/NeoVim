-- =========================================================
-- lua/martini/config/keymaps.lua
-- Atalhos globais de teclado
--
-- GRAMÁTICA (formalizada em ago/2026, depois da reestruturação):
--
--   <leader> + [DOMÍNIO] + [VERBO]
--
-- O Vim nativo compõe operador+motion livremente (dw, d$, ciw, yiw...)
-- porque motions/text-objects são um conjunto pequeno reaproveitado por
-- qualquer operador. Nossos atalhos <leader> NÃO são componíveis desse
-- jeito — cada um é um comando fechado, não uma peça combinável. O que
-- adotamos em vez disso é uma CONVENÇÃO MNEMÔNICA de duas posições:
--
--   1ª letra depois do <leader> = DOMÍNIO (o quê)
--   2ª letra                    = VERBO   (a ação dentro do domínio)
--
--   b → buffers          f → find/arquivos (fzf-lua)
--   m → multicursor       g → Go
--   d → debug             r → run (code_runner)
--   h → HTTP (kulala)
--
-- REGRAS DE DESAMBIGUAÇÃO:
--
-- 1) MAIÚSCULAS EVITADAS AO MÁXIMO (ago/2026). Onde antes usávamos
--    maiúscula pra indicar "escopo maior" (bD, dO, gT) ou pra separar
--    um domínio inteiro (R de HTTP), trocamos por uma letra minúscula
--    com mnemônica própria — ver tabela de renomeações no fim deste
--    comentário. Motivo: maiúscula/minúscula no mesmo par de teclas
--    (ex.: "o" e "O" lado a lado) é fácil de errar sob pressão, e
--    Shift some com a vantagem de "uma tecla só" que o resto da
--    convenção tenta manter.
--
-- 2) Dentro do domínio "debug", o verbo é literal e direto:
--      db = breakpoint · dc = continue · do = step over ·
--      di = step into  · dk = step out (ver nota abaixo) ·
--      dr = repl · dt = terminate · du = dap-ui
--
--    NOTA sobre "dk" (step out): não é "step out" por nenhuma letra
--    óbvia sem repetir "o" de "over" — "k" foi escolhido por analogia
--    de movimento (k = pra cima em qualquer motion do Vim, e "sair de
--    uma função" sobe um nível na pilha de chamadas, i.e., "vai pra
--    cima"). Documentado aqui porque não é auto-evidente sozinho.
--
-- 3) A letra "n" é reaproveitada com dois sentidos DIFERENTES conforme
--    o domínio — "novo" em <leader>n/<leader>fn, "next/próximo" em
--    <leader>mn/<leader>hn. Intencional: o domínio (1ª letra) já
--    desambigua ao digitar; só precisa ficar documentado pra não
--    parecer inconsistência ao ler a lista fora de contexto.
--
-- 4) gd/K/[d/]d (LSP) ficam FORA dessa gramática de propósito — são
--    convenção universal do ecossistema Neovim, não nossa (ver
--    plugins/lsp.lua).
--
-- RENOMEAÇÕES feitas ao remover maiúsculas (ago/2026):
--   <leader>bD → <leader>bx   (x = forçar, mesmo verbo de <leader>mx)
--   <leader>dO → <leader>dk   (ver nota 2 acima)
--   <leader>gT → <leader>ga   (a = "all"; ver languages/go.lua)
--   <leader>R* → <leader>h*   (domínio HTTP inteiro, era maiúsculo só
--                              pra não colidir com <leader>r; ver
--                              plugins/http.lua)
--   <leader>fR → <leader>fu   (u = "usages"; ver plugins/fzf.lua)
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

-- Comando explícito de "novo arquivo", separado do gf (que continua
-- semanticamente "go to file"). Agrupado sob <leader>f porque já é o
-- namespace de operações de arquivo do fzf-lua.
vim.keymap.set("n", "<leader>fn", path.new_file, { desc = "Find: novo arquivo (com mkdir -p)" })

-- ── Buffers ───────────────────────────────────────────────
vim.keymap.set("n", "<leader>bd", ":bd<CR>",  { desc = "Fechar buffer" })
vim.keymap.set("n", "<leader>bx", ":bd!<CR>", { desc = "Fechar buffer (forçado)" })

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
vim.keymap.set("n", "<leader>dk", function() dbg().step_out() end,         { desc = "Debug: passo para fora" })
vim.keymap.set("n", "<leader>dr", function() dbg().repl.open() end,        { desc = "Debug: abrir REPL" })
vim.keymap.set("n", "<leader>dt", function() dbg().terminate() end,        { desc = "Debug: encerrar sessão" })
vim.keymap.set("n", "<leader>du", function()
  require("martini.plugins.debug").setup()
  require("dapui").toggle()
end, { desc = "Debug: interface visual" })

-- ── Code runner ───────────────────────────────────────────
vim.keymap.set("n", "<leader>r",  ":RunCode<CR>",    { desc = "Executar arquivo atual" })
vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { desc = "Executar projeto" })
