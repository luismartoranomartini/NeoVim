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
--   b → buffers          f → find/arquivos (nativo: :find/:grep + LSP)
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
--      db = breakpoint · dx = limpar TODOS os breakpoints (ver nota
--      abaixo) · dc = continue · do = step over · di = step into ·
--      dk = step out (ver nota abaixo) · dr = repl · dt = terminate ·
--      du = dap-ui
--
--    NOTA sobre "dk" (step out): não é "step out" por nenhuma letra
--    óbvia sem repetir "o" de "over" — "k" foi escolhido por analogia
--    de movimento (k = pra cima em qualquer motion do Vim, e "sair de
--    uma função" sobe um nível na pilha de chamadas, i.e., "vai pra
--    cima"). Documentado aqui porque não é auto-evidente sozinho.
--
--    NOTA sobre "dx" (clear all breakpoints, set/2026): "x" segue o
--    mesmo mnemônico de "forçar/limpar tudo" já usado em <leader>bx
--    (fechar buffer forçado) e <leader>mx (remover cursor). Diferente
--    de <leader>db, que alterna SÓ o breakpoint da linha atual, dx
--    chama dap.clear_breakpoints() e remove todos de uma vez, em
--    qualquer linha do arquivo — útil depois de várias sessões de
--    debug em sequência, quando breakpoints de teste ficam esquecidos
--    espalhados pelo arquivo.
--
-- 3) A letra "n" é reaproveitada com dois sentidos DIFERENTES conforme
--    o domínio — "novo" em <leader>n/<leader>fn, "next/próximo" em
--    <leader>mn/<leader>hn. Intencional: o domínio (1ª letra) já
--    desambigua ao digitar; só precisa ficar documentado pra não
--    parecer inconsistência ao ler a lista fora de contexto.
--
-- 4) gd/K/[d/]d (LSP) ficam FORA dessa gramática de propósito — são
--    convenção universal do ecossistema Neovim, não nossa (ver
--    plugins/lsp.lua). <leader>fr (rename) e <leader>fu (references)
--    também vivem em plugins/lsp.lua, dentro do autocmd LspAttach,
--    não aqui — só existem quando um servidor LSP está conectado.
--
-- REMOÇÃO (ago/2026): fzf-lua tirado do projeto. Causava colisão real
-- de tecla (<leader>fr apontava tanto pra "fzf resume" quanto pro
-- rename do LSP, dependendo da ordem de carregamento) e nunca chegou
-- a estar na lista de clone do loader.lua — a chamada require("fzf-lua")
-- provavelmente já falhava silenciosamente. <leader>ff/<leader>fg agora
-- usam :find/:grep nativos; <leader>fu usa vim.lsp.buf.references
-- (quickfix list nativa, sem seletor fuzzy).
--
-- REINTRODUÇÃO (set/2026): fzf-lua voltou, mas em plugins/finder.lua,
-- com atalhos SEM <leader> (<C-p>/<C-g>) — evita reabrir a mesma
-- colisão que motivou a remoção anterior. register_ui_select() também
-- foi ativado ali, então qualquer vim.ui.select do Neovim (incluindo
-- o seletor de configuração do dap-go ao apertar F5) passa a usar a
-- janela flutuante do fzf em vez da lista de texto simples.
--
-- RENOMEAÇÕES feitas ao remover maiúsculas (ago/2026):
--   <leader>bD → <leader>bx   (x = forçar, mesmo verbo de <leader>mx)
--   <leader>dO → <leader>dk   (ver nota 2 acima)
--   <leader>gT → <leader>ga   (a = "all"; ver languages/go.lua)
--   <leader>R* → <leader>h*   (domínio HTTP inteiro, era maiúsculo só
--                              pra não colidir com <leader>r; ver
--                              plugins/http.lua)
--   <leader>fR → <leader>fu   (u = "usages"; ver plugins/lsp.lua)
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
-- semanticamente "go to file"). Agrupado sob <leader>f = domínio Find.
vim.keymap.set("n", "<leader>fn", path.new_file, { desc = "Find: novo arquivo (com mkdir -p)" })

-- Buscar arquivo por nome (nativo). Depende de 'path' incluir "**"
-- (ver config/options.lua) pra buscar recursivamente a partir do cwd.
vim.keymap.set("n", "<leader>ff", ":find ", { desc = "Find: buscar arquivo por nome" })

-- Buscar texto no projeto (nativo, via grepprg + quickfix). Se
-- ripgrep estiver instalado e configurado em 'grepprg' (ver
-- config/options.lua), já ignora .git/node_modules automaticamente.
vim.keymap.set("n", "<leader>fg", ":grep ", { desc = "Find: buscar texto no projeto (grep + quickfix)" })

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
vim.keymap.set("n", "<leader>db", function() dbg().toggle_breakpoint() end, { desc = "Debug: breakpoint (linha atual)" })
vim.keymap.set("n", "<leader>dx", function() dbg().clear_breakpoints() end, { desc = "Debug: limpar TODOS os breakpoints" })
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
