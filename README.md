# Resumo da redução (set/2026)

Escopo: Go + JavaScript/TypeScript (web) + C, com autocomplete e
atualização automática de plugins. Todos os arquivos com sintaxe
validada via `luac5.4 -p`.

## CORREÇÃO IMPORTANTE (segunda rodada)

A primeira versão desta pasta reescreveu `loader.lua` (carregador
manual via `git clone`), mas você confirmou que o repositório real já
tinha migrado para **lazy.nvim** — `loader.lua` foi substituído por
`lua/martini/lazy.lua`, e o `init.lua` raiz chama
`require("martini.lazy")`, não `require("martini.loader")`.

`loader.lua` foi **removido** desta pasta — não faz mais sentido
usá-lo. A lista de plugins mínima e a atualização automática agora
vivem em `lazy.lua`, usando a API do próprio lazy.nvim
(`require("lazy").update({ show = false })` num `VimEnter`) em vez de
`git pull` cru — isso preserva o lockfile (`lazy-lock.json`), que é a
razão de o projeto ter trocado de mecanismo.

## Removido

| Item | Motivo |
|---|---|
| `nvim-tree.lua`, `bufferline.lua` | Não pedidos; `<leader>e` agora abre `:Lexplore` (netrw nativo, zero plugin) |
| `dashboard.lua` | Não pedido |
| `onedark.nvim`, `nightfox.nvim` | Nunca usados (só `tokyonight` era aplicado em `colors.lua`) |
| `pyright` (lsp.lua) | Python fora do escopo |
| `dap-python` (debug.lua) | Python fora do escopo |
| `nvim-lint`/formatters de Python | idem |
| `<leader>ff`/`<leader>fg` (keymaps.lua) | Duplicavam `<C-p>`/`<C-g>` do fzf-lua. Os comandos `:find`/`:grep` continuam disponíveis, só sem atalho dedicado |
| Python/Ruby/PHP/Perl/Rust/Java/sh (runner.lua) | Fora do escopo declarado |

## Mantido (por decisão sua)

multicursor.nvim, kulala.nvim (HTTP), fzf-lua, debugger para Go **e** C
(codelldb), textobjects (Treesitter), editing.lua (autopairs/autotag/
surround/emmet — relevante pra JSX/HTML).

## Adicionado

- **`c`/`cpp` em `conform.nvim`** (`clang-format`) — não existia antes.
- **`typescriptreact`** no `ts_ls` e no Treesitter (`tsx`) — coerente
  com `editing.lua`/`completion.lua`, que já assumiam `jsx`/`tsx`.
- **Atualização automática de plugins no startup**: `loader.lua` agora
  dispara `git pull --ff-only` em background (via `vim.system`,
  assíncrono — não trava a abertura do Neovim) 500ms após o
  `VimEnter`. `:MartiniUpdatePlugins` continua disponível pra rodar
  na hora.

## Bugs corrigidos nos arquivos que você enviou

Os `.txt` enviados vieram com caracteres específicos apagados em
vários pontos — `$`, `*` — aparentemente por alguma conversão/render
anterior. Achei e corrigi os seguintes, comparando com a sintaxe
correta de cada API:

1. **`loader.lua`** — `repo:match("./(.)")` não extraía nada;
   deveria ser `repo:match(".*/(.*)")` (nome do plugin a partir de
   `"dono/repo"`).
2. **`runner.lua`** — os comandos de C/C++ estavam sem o compilador:
   `"cd fileName -o /tmp/fileNameWithoutExt"` (sem `$`, sem `gcc`).
   Reconstruí como `"cd $dir && gcc -g $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt"`.
3. **`debug.lua`** — o adapter do codelldb tinha
   `port = "latex\n{port}"` (claramente corrompido); corrigido para
   `port = "${port}"` e `args = { "--port", "${port}" }`.
4. **`go.lua`** — `go = "cd $`dir && go run ."` → `"cd $dir && go run ."`;
   e o regex de nome de teste `Test[%w_]` (sem quantificador) →
   `Test[%w_]*`, senão só casava nomes de teste com exatamente um
   caractere depois de `Test`.
5. **`options.lua`** — `vim.opt.path:append("")` e
   `wildignore` sem `*` nas pontas (`"/node_modules/"`) não faziam
   nada; corrigido para `"**"` e `"*/node_modules/*"` etc.
6. **`go.lua`** — `golangci-lint` ainda usava a flag da v1
   (`--out-format json`); troquei para `--output.json.path=stdout`
   (v2), conforme já era o padrão correto documentado.

## Como aplicar

Substitua a pasta `lua/martini/` do seu repositório pelo conteúdo
desta pasta (mesma estrutura). Como a lista de plugins mudou
(6 plugins removidos), o lazy.nvim vai detectar plugins órfãos —
depois de colar, rode:

```vim
:Lazy clean
```

pra remover do disco (`~/.local/share/nvim/lazy/`) os plugins que
saíram da lista (onedark.nvim, nightfox.nvim, nvim-tree.lua,
nvim-web-devicons, bufferline.nvim, nvim-dap-python). Não precisa
apagar a pasta inteira nem gerar um "primeiro boot" — o lazy.nvim só
baixa o que é novo e limpa o que sobrou.

O `lazy-lock.json` vai mudar (menos entradas) — comite ele junto.
