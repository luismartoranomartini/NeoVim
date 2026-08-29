# Reestruturação da config `martini` — resumo e migração

Baseado na proposta compartilhada (chat do ChatGPT) e confirmado contra o
conteúdo **real** do repositório `luismartoranomartini/NeoVim` em 29/08/2026
(não o snapshot do projeto — havia divergências, ver seção final).

## Estrutura nova

```
init.lua                        (bootstrap: require("martini"))
lua/martini/
├── init.lua                    (patch 0.12.2 + loader + config→languages→plugins)
├── loader.lua                  (git clone dos plugins; corrigido, ver abaixo)
├── config/                     "configura o Neovim"
│   ├── init.lua
│   ├── options.lua
│   ├── diagnostics.lua         (NOVO — extraído de options.lua)
│   ├── colors.lua
│   ├── keymaps.lua             (reorganizado)
│   └── dashboard.lua
├── languages/                  "configura uma linguagem" (NOVO conceito)
│   ├── init.lua
│   └── go.lua                  (consolida tudo que era Go-específico)
├── plugins/                    "configura um plugin"
│   ├── init.lua
│   ├── treesitter.lua          (extraído de ui.lua)
│   ├── editing.lua             (autopairs+autotag+surround+emmet, extraído de ui.lua)
│   ├── nvim-tree.lua           (extraído de ui.lua)
│   ├── bufferline.lua          (extraído de ui.lua)
│   ├── completion.lua          (cmp+LuaSnip, extraído de lsp.lua)
│   ├── lsp.lua                 (só servidores + keymaps LspAttach)
│   ├── format.lua              (só conform genérico)
│   ├── debug.lua                (só dap/dapui/python/codelldb genéricos)
│   ├── runner.lua               (só code_runner genérico + merge de languages/)
│   ├── http.lua, fzf.lua, multicursor.lua  (inalterados)
└── utils/                      (NOVO)
    ├── path.lua                 (lógica do gf + novo comando <leader>fn)
    └── terminal.lua              (lógica de abrir/fechar terminal)
```

`ui.lua` **deixou de existir** — virou `treesitter.lua` + `editing.lua` +
`nvim-tree.lua` + `bufferline.lua`, com a parte Go-específica indo pra
`languages/go.lua`.

## O que mudou de verdade (funcionalmente)

1. **`loader.lua` corrigido** — dois bugs reais encontrados durante a
   auditoria (pedida no item 9 da proposta):
   - `ibhagwan/fzf-lua` e `jake-stewart/multicursor.nvim` são usados pela
     config mas **nunca estavam na lista do loader**. Se você clonar a
     config do zero numa máquina nova, esses dois plugins não seriam
     baixados e `fzf.lua`/`multicursor.lua` quebrariam. Adicionados
     (`multicursor.nvim` já com `branch = "1.0"`, que era clonado à mão).
   - `navarasu/onedark.nvim` e `EdenEast/nightfox.nvim` eram clonados a
     cada boot/update mas nenhum arquivo dá `require()` neles — removidos.
   - `loader.lua` agora aceita `{ "dono/repo", branch = "x" }` na lista de
     plugins, não só string.

2. **`<leader>fn`** (novo) — cria um arquivo via prompt (`vim.ui.input`),
   com `mkdir -p` automático. Separa a criação explícita de arquivo do
   `gf` (que continua fazendo as duas coisas — navegar E criar ao seguir
   um link pra um arquivo inexistente —, sem regressão de comportamento).

3. **Keymaps de teste do Go renomeados**: `<leader>tf` → `<leader>gr`.
   Agora `gt`/`gT`/`gr` vivem todos sob `<leader>g` (Go). Único rename
   real de tecla que já existia.

4. **`<leader>b`** deixou de ser "toggle breakpoint" e virou o namespace
   de buffers (`bd`/`bD`, que já existiam). Breakpoint virou `<leader>db`
   (com aliases `dc`/`do`/`di`/`dO` espelhando F5/F10/F11/F12 — os
   F-keys continuam funcionando exatamente como antes).

Fora isso, **nenhum comportamento mudou** — todo o resto foi movido de
arquivo, não reescrito. Toda lógica de highlight, LSP, DAP, lint, etc. é
byte-a-byte a mesma, só realocada.

## Decisões que se afastam da proposta original (e por quê)

| Proposta | O que fiz | Motivo |
|---|---|---|
| `gd`/`K`/etc. → `<leader>l*` | Mantidos sem prefixo | São a convenção universal do Neovim (`:h lsp-quickstart`); mudar quebra compatibilidade com qualquer tutorial/material do ecossistema |
| `<leader>t` → grupo (`tt`, `tv`) | `<leader>t` continua tecla única | Vocês já haviam tentado isso com `<leader>tv` e revertido: o Neovim dispara `<leader>t` imediatamente (é um mapeamento completo), e o `v`/`t` seguinte vira texto literal no terminal recém-aberto. `<leader>vs` continua separado por essa razão, documentada no próprio código |
| `<leader>r` → HTTP | Mantido `<leader>r` = run code, `<leader>R` = HTTP | Já era uma separação coerente por case-sensitivity; não havia conflito real pra resolver |
| `<leader>f` → arquivos (genérico) | Mantido como namespace do fzf-lua + `fn` novo | `<leader>f` já pertencia inteiro ao fzf-lua (`ff/fg/fb/fh/fw/fr/fd/fs/fR`) — a proposta não tinha visão desses arquivos ao sugerir isso |
| "`w` conflita com motion nativa" | Nenhuma mudança | Verificado: é `<leader>w`, não `w` puro. Não há conflito — a crítica não se aplicava ao código real |
| `<leader>g` → git | Virou namespace de Go | Vocês não têm plugin de git na config; repurposed pra Go, coerente com "Go é linguagem de primeira classe" |

## docker-language-server

Não incluí em `plugins/lsp.lua` — conferido no repositório real (29/08/2026)
e **não está presente**. Se você já adicionou e ainda não deu commit,
me mande o trecho que eu incluo.

## Como aplicar no repositório real

1. Delete `lua/martini/plugins/ui.lua` (foi fragmentado em 4 arquivos).
2. Copie os 26 arquivos do zip mantendo a estrutura de pastas exata.
3. `after/queries/go/highlights.scm` **não muda** — nenhuma referência a
   ele foi tocada.
4. Rode `:MartiniUpdatePlugins` ou reinicie o Neovim uma vez pra o loader
   clonar `fzf-lua`/`multicursor.nvim` caso ainda não estejam no
   `pack_path` (eles já devem estar, já que você os usa — é só o
   registro no loader que faltava).
5. `:checkhealth` e abra um arquivo `.go` pra confirmar LSP, Treesitter,
   highlight de verbos (`%s`, `%d`) e `<leader>gt`/`<leader>gr` funcionando.

## Adendo (ago/2026) — remoção de maiúsculas dos atalhos `<leader>`

Depois da entrega inicial, formalizamos a gramática de atalhos
(`<leader>` + domínio + verbo, documentada no cabeçalho de
`config/keymaps.lua`) e removemos toda maiúscula de atalho `<leader>`,
por risco de erro sob pressão (letras visualmente quase idênticas, tipo
`o`/`O`). Renomeações:

| Antes | Depois | Onde |
|---|---|---|
| `<leader>bD` | `<leader>bx` | `config/keymaps.lua` |
| `<leader>dO` | `<leader>dk` | `config/keymaps.lua` |
| `<leader>gT` | `<leader>ga` | `languages/go.lua` |
| `<leader>R*` (domínio inteiro) | `<leader>h*` | `plugins/http.lua` |
| `<leader>fR` | `<leader>fu` | `plugins/fzf.lua` |
| `<leader>mA` | `<leader>ma` | `plugins/multicursor.lua` (pego numa auditoria posterior — passou batido na primeira rodada) |
| `<leader>mN` | `<leader>mp` | `plugins/multicursor.lua` (idem) |
| `<leader>mS` | `<leader>msp` | `plugins/multicursor.lua` (idem — 3 letras, pois "mp" já estava ocupado) |

Se você já tinha memorizado os nomes antigos, os únicos que mudam de
verdade na prática do dia a dia são `bD`, `dO`, `gT`, todo o grupo HTTP
(`R*`→`h*`), e `fR`.

## Divergência encontrada (fyi)

O snapshot de arquivos que eu tinha no projeto (upload anterior) estava
desatualizado em relação ao repositório real em praticamente todos os
arquivos — a maior parte das diferenças eram melhorias que vocês já
haviam commitado (nvim-surround, autotag, decorator de pastas do
nvim-tree, dap-go lazy, codelldb, etc.) e que o snapshot não refletia.
Usei o conteúdo real do GitHub como fonte de verdade para toda a
reestrutura.

