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
├── init.lua                    patch 0.12.2 + loader + ordem de carregamento
├── loader.lua                  clona plugins via git; :MartiniUpdatePlugins
├── config/                     REGRA: configura o Neovim, não plugins
│   ├── options.lua             vim.opt / vim.g
│   ├── diagnostics.lua         vim.diagnostic.config
│   ├── colors.lua              tema (paleta + todos os vim.api.nvim_set_hl)
│   ├── keymaps.lua             atalhos globais
│   └── dashboard.lua           tela inicial
├── languages/                  REGRA: tudo específico de UMA linguagem
│   └── go.lua                  templates .tmpl, lint, imports, testes, dap-go
├── plugins/                    REGRA: configura plugins, não o Neovim
│   ├── treesitter.lua, editing.lua, nvim-tree.lua, bufferline.lua
│   ├── completion.lua          nvim-cmp + LuaSnip
│   ├── lsp.lua                 servidores LSP (API nativa 0.12, sem lspconfig)
│   ├── format.lua              conform.nvim (genérico)
│   ├── debug.lua               nvim-dap + dap-ui + python + codelldb
│   ├── runner.lua              code_runner.nvim
│   ├── http.lua, fzf.lua, multicursor.lua
└── utils/                      helpers compartilhados entre plugins/config
    ├── path.lua                 gf + criação de arquivo (<leader>fn)
    └── terminal.lua              abrir/fechar terminal
```

Ao adicionar uma nova linguagem (TypeScript, Rust, etc.), o padrão é criar
`languages/<nome>.lua` seguindo o formato de `go.lua`: expõe
`M.runner_filetypes` (lido por `plugins/runner.lua`) e, se houver debugger,
`M.setup_debug()` (chamado por `plugins/debug.lua`).

## Atalhos

`<leader>` = `Espaço`.

| Prefixo | Domínio |
|---|---|
| `<leader>b` | Buffers |
| `<leader>d` | Debug |
| `<leader>f` | Find (fzf-lua) + arquivo |
| `<leader>g` | Go |
| `<leader>m` | Multicursor |
| `<leader>r` | Run (code_runner) |
| `<leader>R` | HTTP requests (kulala) |

### Geral

| Atalho | Ação |
|---|---|
| `<leader>n` | Nova aba |
| `<leader>e` | Toggle explorador (nvim-tree) |
| `<leader>w` | Fecha a aba atual |
| `<leader>bd` / `<leader>bD` | Fecha buffer / fecha buffer forçado |
| `gf` | Cria/abre o arquivo sob o cursor (relativo à pasta atual) |
| `<leader>fn` | Cria arquivo novo via prompt (com `mkdir -p`) |
| `<leader>t` / `<leader>vs` | Terminal horizontal / vertical |
| `Ctrl-t` | Toggle terminal |

### LSP (ativos ao conectar)

`gd`, `K`, `[d`, `]d` — convenção padrão do ecossistema Neovim, sem prefixo
`<leader>` de propósito (ver `plugins/lsp.lua`).

### Debug

`F5`/`F10`/`F11`/`F12` (convenção universal de debugger) + aliases
`<leader>dc`/`do`/`di`/`dO`. Mais: `<leader>db` breakpoint, `<leader>dr` REPL,
`<leader>dt` terminar sessão, `<leader>du` toggle dap-ui.

### Go

`<leader>gt` testa o pacote atual · `<leader>gT` testa o projeto inteiro ·
`<leader>gr` testa só a função sob o cursor.

### HTTP, Find, Multicursor

Inalterados na reestruturação — ver `plugins/http.lua`, `plugins/fzf.lua`,
`plugins/multicursor.lua` pra lista completa e atualizada de cada um.

## Plugins gerenciados por `loader.lua`

Sem lazy.nvim/packer — `git clone --depth 1` direto em
`~/.local/share/nvim/site/pack/meus_plugins/start/`. `:MartiniUpdatePlugins`
roda `git pull --ff-only` em todos de uma vez.

## ⚠️ Divergência conhecida: este README vs. o código

Uma versão anterior deste README (datada de 08/07/2026) descrevia três
funcionalidades que **não existem** nos arquivos-fonte reais, confirmado
em 29/08/2026:

1. `<leader>W` / `<leader>WQ` — salvar todos os buffers / salvar e sair
2. `gf` resolvendo URLs (`http`/`https`) e arquivos `.html`/`.htm` via
   `vim.fn.jobstart({"xdg-open", alvo}, {detach = true})`
3. `[d`/`]d` usando `vim.diagnostic.jump` em vez de `goto_prev`/`goto_next`
   (que são as que o `lsp.lua` real ainda usa)

Este README já reflete só o que existe de fato no código pós-reestruração.
Se você quiser essas três funcionalidades implementadas de verdade (elas
são melhorias reais — `goto_prev`/`goto_next` estão depreciadas desde o
Neovim 0.11), é só pedir.
