# martini.nvim

Configuração própria do Neovim (sem plugin manager) voltada para
desenvolvimento em Go, com debugging, testes, cliente HTTP e terminal
integrados ao fluxo normal do editor.

Neovim 0.12 · Arch Linux (ambiente primário) · Windows 11 e Fedora
(compatibilidade mantida).

## Princípios

Formalizados durante a reestruturação de agosto/2026, pra qualquer decisão
futura ter um critério claro em vez de "porque sim":

1. **Preferir builtin do Neovim.** Um plugin só entra se resolver um
   problema real que a API nativa (LSP, Treesitter, terminal, diagnostics)
   não resolve bem.
2. **Keymaps devem ter semântica consistente.** Cada prefixo `<leader>X`
   pertence a UM domínio (ver tabela abaixo) — nunca reaproveitado pra
   coisas sem relação.
3. **Configuração deve ser legível sem documentação externa.** Comentário
   no próprio arquivo > README explicando o arquivo.
4. **Go é uma linguagem de primeira classe.** Testes e debugging fazem
   parte do fluxo normal de escrever Go, não um apêndice.
5. **Evitar abstrações desnecessárias e não virar uma IDE monolítica.**
   Cada plugin resolve UM problema; a config não tenta emular VSCode.
6. **Sem plugin manager.** Todo plugin é clonado via `git clone --depth 1`
   por `loader.lua`, sem lazy.nvim/packer/etc.

## Estrutura

```
init.lua                        bootstrap: require("martini")
lua/martini/
├── init.lua                    patch 0.12.2 + loader + require("martini.config") + require("martini.plugins")
├── loader.lua                  clona plugins via git; aceita { "dono/repo", branch = "x" }
├── config/                     REGRA: configura o Neovim, não plugins
│   ├── init.lua                 agrega os módulos abaixo, nesta ordem
│   ├── options.lua             vim.opt / vim.g
│   ├── diagnostics.lua         vim.diagnostic.config
│   ├── colors.lua               tema (paleta + todos os vim.api.nvim_set_hl)
│   ├── keymaps.lua             atalhos globais
│   └── dashboard.lua           tela inicial
├── languages/                  REGRA: tudo específico de UMA linguagem
│   ├── init.lua
│   └── go.lua                  templates .tmpl, lint, imports, testes, dap-go
├── plugins/                    REGRA: configura plugins, não o Neovim
│   ├── init.lua                 agrega os módulos abaixo, nesta ordem
│   ├── treesitter.lua, textobjects.lua, editing.lua, nvim-tree.lua, bufferline.lua
│   ├── completion.lua          nvim-cmp + LuaSnip
│   ├── lsp.lua                 servidores LSP (API nativa 0.12, sem lspconfig)
│   ├── format.lua              conform.nvim (genérico)
│   ├── debug.lua               nvim-dap + dap-ui + python + codelldb (lazy)
│   ├── runner.lua              code_runner.nvim
│   ├── http.lua                kulala.nvim
│   ├── multicursor.lua         multicursor.nvim
│   └── finder.lua              fzf-lua (sem <leader>) + register_ui_select()
└── utils/                      helpers compartilhados entre plugins/config
    ├── path.lua                 gf + criação de arquivo (<leader>fn)
    └── terminal.lua              abrir/fechar terminal
```

Ao adicionar uma nova linguagem (TypeScript, Rust, etc.), o padrão é criar
`languages/<nome>.lua` seguindo o formato de `go.lua`: expõe
`M.runner_filetypes` (lido por `plugins/runner.lua`) e, se houver debugger,
`M.setup_debug()` (chamado por `plugins/debug.lua`).

## Atalhos

`<leader>` = `Espaço`. Gramática: `<leader>` + **domínio** (1ª letra) +
**verbo** (2ª letra) — ver o comentário completo em `config/keymaps.lua`
pra regras de desambiguação. **Maiúsculas evitadas ao máximo** (ago/2026):
onde antes um domínio ou uma ação usava Shift, foi trocado por uma letra
minúscula com mnemônica própria.

| Prefixo | Domínio |
|---|---|
| `<leader>b` | Buffers |
| `<leader>d` | Debug |
| `<leader>f` | Find (`:find`/`:grep` nativos) + arquivo |
| `<leader>g` | Go |
| `<leader>h` | HTTP requests (kulala) |
| `<leader>m` | Multicursor |
| `<leader>r` | Run (code_runner) |

### Geral

| Atalho | Ação |
|---|---|
| `<leader>n` | Nova aba |
| `<leader>e` | Toggle explorador (nvim-tree) |
| `<leader>w` | Fecha a aba atual |
| `<leader>bd` / `<leader>bx` | Fecha buffer / fecha buffer forçado |
| `gf` | Cria/abre o arquivo sob o cursor (relativo à pasta atual) |
| `<leader>fn` | Cria arquivo novo via prompt (com `mkdir -p`) |
| `<leader>fu` | Referências / usages do símbolo (LSP, quickfix nativa) |
| `<leader>t` / `<leader>vs` | Terminal horizontal / vertical |
| `Ctrl-t` | Toggle terminal |

### LSP (ativos ao conectar)

`gd`, `K`, `[d`, `]d` — convenção padrão do ecossistema Neovim, sem prefixo
`<leader>` de propósito (ver `plugins/lsp.lua`).

### Debug

`F5`/`F10`/`F11`/`F12` (convenção universal de debugger) + aliases
`<leader>dc`/`do`/`di`/`dk`. `dk` = step out (ver nota no `keymaps.lua`
sobre a escolha da letra). Mais: `<leader>db` alterna breakpoint na linha
atual · `<leader>dx` limpa **todos** os breakpoints do arquivo de uma vez
(`dap.clear_breakpoints()`, set/2026 — evita ter que ir linha por linha
com `db` depois de várias sessões de debug) · `<leader>dr` REPL ·
`<leader>dt` terminar sessão · `<leader>du` toggle dap-ui.

Ao apertar `F5` sem sessão ativa, o `dap-go` mostra uma lista de
configurações (Debug, Debug Package, Attach, Debug test...) — desde
set/2026 essa lista aparece como janela flutuante do fzf-lua, não mais
como lista de texto simples (ver "Find" abaixo).

### Go

`<leader>gt` testa o pacote atual · `<leader>ga` testa o projeto inteiro
("a" de "all") · `<leader>gr` testa só a função sob o cursor.

### HTTP (`<leader>h`, renomeado de `<leader>R`)

`hs` enviar requisição · `ha` enviar todas · `hb` scratchpad · `hc` copiar
como curl · `hn`/`hp` próxima/anterior · `hq` fechar janela de resposta.

### Find — dois mecanismos coexistindo de propósito

Depois de uma primeira remoção do fzf-lua (ago/2026 — colidia com
`<leader>fr`, o rename do LSP) e uma reintrodução posterior (set/2026),
a solução foi separar por completo os dois métodos de busca em
namespaces diferentes, evitando qualquer colisão:

| Atalho | Motor | Ação |
|---|---|---|
| `<leader>ff` | nativo (`:find`) | Buscar arquivo por nome, sem preview |
| `<leader>fg` | nativo (`:grep` + ripgrep) | Buscar texto no projeto, popula quickfix |
| `Ctrl-p` | fzf-lua | Buscar arquivo por nome, com preview fuzzy |
| `Ctrl-g` | fzf-lua | Buscar texto (live grep) no projeto, com preview |

`Ctrl-p`/`Ctrl-g` foram escolhidos por sobrescreverem comportamento nativo
de baixo valor em modo normal (`Ctrl-p` == `k`; `Ctrl-g` só mostra o nome
do arquivo atual) — ver `plugins/finder.lua`.

`plugins/finder.lua` também chama `fzf.register_ui_select()`, que faz
**qualquer** `vim.ui.select()` do Neovim usar a janela flutuante do fzf
em vez do prompt de texto simples nativo. Isso afeta, entre outros: o
seletor de configuração do `dap-go` (`F5`) e menus de code action do LSP
com múltiplas opções.

### Multicursor

`<C-Up>`/`<C-Down>` cursor na linha de cima/abaixo · `<leader>ma`
seleciona todas as ocorrências da palavra sob o cursor · `<leader>mn`/`mp`
próxima/anterior ocorrência · `<leader>mh`/`ml` navega entre cursores ·
`<leader>mx` remove cursor · `<leader>mq` ativa/desativa. Ver
`plugins/multicursor.lua` pra lista completa.

## Plugins gerenciados por `loader.lua`

Sem lazy.nvim/packer — `git clone --depth 1` direto em
`~/.local/share/nvim/site/pack/meus_plugins/start/`. `:MartiniUpdatePlugins`
roda `git pull --ff-only` em todos de uma vez. `loader.lua` aceita tanto
uma string (`"dono/repo"`) quanto uma tabela com branch explícita
(`{ "dono/repo", branch = "1.0" }`) — necessário pro `multicursor.nvim`,
que precisa da branch `1.0`, não a `main`.

## ⚠️ Divergências conhecidas, corrigidas em set/2026

Uma auditoria confirmou três problemas reais entre o que o código exige
e o que `loader.lua` de fato baixava — todos corrigidos:

1. **`lua/martini/init.lua` pulava `config/diagnostics.lua`.** O bootstrap
   listava `options`/`colors`/`keymaps`/`dashboard` individualmente em vez
   de delegar a `config/init.lua` (que já agregava os cinco, incluindo
   diagnostics). Resultado: `vim.diagnostic.config()` nunca rodava — sinais
   customizados (E/W/I/H) e o virtual_text estilo Error Lens ficavam sem
   efeito, mesmo com o arquivo presente e correto. Corrigido trocando para
   `require("martini.config")`.
2. **Três plugins usados no código mas ausentes do `loader.lua`:**
   `multicursor.nvim` (branch `1.0`), `nvim-ts-autotag` e `nvim-surround`.
   O primeiro falhava com erro visível (`vim.notify` capturado em
   `multicursor.lua`); os outros dois falhavam em silêncio total — o
   `pcall` em `editing.lua` engolia o erro sem notificar. Autotag de
   HTML/JSX e os comandos `ys`/`cs`/`ds` do surround simplesmente não
   existiam, sem nenhum aviso.
3. **`"folke/tokyonight.nvim"` duplicado** na lista do `loader.lua` —
   inofensivo (clone idempotente), mas removido por higiene.

`navarasu/onedark.nvim` e `EdenEast/nightfox.nvim` continuam na lista
mesmo sem `require()` visível em nenhum arquivo — mantidos por ora, caso
sejam usados como colorscheme alternativo não documentado; a remoção fica
pendente de confirmação.
