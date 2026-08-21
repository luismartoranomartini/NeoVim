-- =========================================================
-- lua/martini/plugins/ui.lua
-- Treesitter, autopairs, nvim-tree, bufferline, emmet e surround
-- =========================================================
-- Reconhece arquivos .tmpl (Go HTML templates).
-- Tratados como "html" para ativar auto-fechamento de tags,
-- Emmet e o LSP de HTML sem depender de parser extra.
vim.filetype.add({
  extension = {
    tmpl   = "html",
    gohtml = "html",
  },
  pattern = {
    -- pega nomes compostos como home.page.tmpl, layout.base.tmpl, etc.
    [".*%.tmpl"] = "html",
  },
})
-- Garante o filetype mesmo em casos que escapem das regras acima
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.tmpl",
  callback = function()
    vim.bo.filetype = "html"
  end,
})
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

-- Verbos de formatação do Go (%s, %d, %v, %+v, %-10.2f, etc.) → highlight
-- manual via matchadd, porque o Treesitter do Go não trata verbos de
-- printf/Sprintf como nó separado dentro da string — fica tudo achatado
-- em @string. O grupo GoFormatVerb já existe em colors.lua; só faltava
-- aplicá-lo. O padrão cobre: flags (-+ #0), largura, precisão (.N) e
-- o verbo final (letra).
--
-- IMPORTANTE #1: usa long-bracket [=[ ... ]=] em vez de [[ ... ]] — o
-- padrão termina em "]" (fim da classe de caracteres do regex) seguido
-- do "]]" de fechamento da string, e o Lua fecha a string cedo na
-- primeira ocorrência de "]]" que encontrar, quebrando o parse (erro
-- "')' expected near ']'"). O nível [=[...]=] só fecha em "]=]".
--
-- IMPORTANTE #2: o padrão começa com UM único "%", não "%%" — verbos
-- de printf no Go usam um só (%s, %d, %v), então "%%" no início do
-- regex nunca dava match em nada (exigia dois "%" seguidos no texto).
--
-- IMPORTANTE #3: matchadd() é POR JANELA, não por buffer. Só disparar
-- no autocmd FileType não é suficiente — FileType só dispara quando o
-- filetype do buffer é definido pela primeira vez. Se o mesmo arquivo
-- é aberto numa aba/split nova (via gd, :tabedit, etc.), essa janela
-- nova nunca recebe o matchadd, mesmo com o highlight já ativo em
-- outra janela do mesmo buffer. Por isso também dispara em BufWinEnter
-- e WinEnter, com uma flag por janela (vim.w) pra não empilhar
-- matches repetidos toda vez que você troca de janela.
local function destacar_verbos_go()
  if vim.bo.filetype ~= "go" then return end
  if vim.w.martini_go_verb_hl then return end
  vim.fn.matchadd("GoFormatVerb", [=[%[-+ #0]*[0-9]*\.\?[0-9]*[sdvTqxXobeEfFgGpc]]=])
  vim.w.martini_go_verb_hl = true
end

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
  callback = destacar_verbos_go,
})

-- Destaque aproximado dos blocos {{ ... }} de template Go dentro de
-- arquivos HTML — via matchadd, pois não existe parser Treesitter
-- mantido e funcional pra essa sintaxe hoje (o parser de terceiros
-- exige setup frágil e mesmo assim não recupera highlight de HTML
-- dentro do bloco). Não dá autocomplete — só contraste visual.
-- \_. casa qualquer caractere incluindo quebra de linha, .\{-} é
-- non-greedy — cobre blocos multi-linha como {{if eq len(x) 0}} ...{{end}}.
-- Mesmo caveat do bloco acima: matchadd() é por janela, então também
-- dispara em BufWinEnter/WinEnter, não só FileType.
local function destacar_template_go()
  if vim.bo.filetype ~= "html" then return end
  if vim.w.martini_go_tmpl_hl then return end
  vim.fn.matchadd("GoTemplateAction", [=[{{-\?\_.\{-}-\?}}]=])
  vim.w.martini_go_tmpl_hl = true
end

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
  callback = destacar_template_go,
})

-- Autopairs
pcall(function()
  require("nvim-autopairs").setup({ check_ts = true })
end)

-- Autotag — fecha/renomeia/atualiza tags HTML/JSX automaticamente
-- conforme digita, usando o Treesitter pra saber onde a tag termina
-- (ex.: digitar <form> já insere </form> com o cursor entre as duas;
-- renomear a tag de abertura atualiza a de fechamento junto).
pcall(function()
  require("nvim-ts-autotag").setup()
end)

-- Surround — seleciona/adiciona/troca delimitadores ("", '', (), [], {}, <>)
-- ao redor de palavra ou seleção visual, no estilo VSCode "Select + wrap".
-- Keymaps padrão do plugin (não usa <leader>):
--   ys{motion}{char}  → adiciona delimitador  (ex.: ysiw" envolve a palavra em "")
--   cs{alvo}{novo}    → troca delimitador      (ex.: cs"' troca " por ')
--   ds{alvo}          → remove delimitador     (ex.: ds" remove as aspas)
--   Visual + S{char}  → envolve a seleção visual no delimitador escolhido
pcall(function()
  require("nvim-surround").setup({})
end)

-- Emmet
-- "iv" habilita as funções de Insert (expandir abreviação com Tab) e
-- de Visual (Ctrl+y depois , pra "wrap with abbreviation" — envolver
-- uma seleção numa tag). Era só "i" antes, e isso desligava por
-- completo qualquer função de modo Visual do plugin, mesmo com o
-- <plug>(emmet-wrap-with-abbreviation) mapeado corretamente.
vim.g.user_emmet_mode           = "iv"
vim.g.user_emmet_install_global = 0
vim.api.nvim_create_autocmd("FileType", {
  pattern  = { "html", "css", "scss", "jsx", "tsx" },
  callback = function() vim.cmd("EmmetInstall") end,
})
-- nvim-tree
pcall(function()
  require("nvim-web-devicons").setup()
  require("nvim-tree").setup({
    view = {
      width = 30,
      side  = "left",
    },
    renderer = {
      group_empty   = false,
      highlight_git = true,
      icons = {
        show = {
          file         = true,
          folder       = true,
          folder_arrow = true,
          git          = true,
        },
      },
    },
    filters = { dotfiles = false },
    git     = { enable = true, ignore = false },
    actions = {
      open_file = { quit_on_open = true },
    },
    on_attach = function(bufnr)
      local api = require("nvim-tree.api")
      -- Keymaps padrão
      api.config.mappings.default_on_attach(bufnr)
      -- Abre em nova aba com <Tab>
      vim.keymap.set("n", "<Tab>", api.node.open.tab, { buffer = bufnr, desc = "Abrir em nova aba" })
    end,
  })
end)
-- Bufferline
pcall(function()
  require("bufferline").setup({
    options = {
      mode                    = "tabs",
      indicator               = { style = "icon" },
      buffer_close_icon       = "󰅖",
      modified_icon           = "●",
      close_icon              = "",
      show_buffer_close_icons = true,
      show_close_icon         = true,
      separator_style         = "slant",
      always_show_bufferline  = false,
      diagnostics             = "nvim_lsp",
      custom_filter = function(bufnr)
        return vim.bo[bufnr].buftype ~= "nofile"
      end,
      close_command = function(tabnum)
        local tabs = vim.api.nvim_list_tabpages()
        if #tabs > 1 then
          local target = tabs[tabnum]
          if target then
            vim.api.nvim_set_current_tabpage(target)
            vim.cmd("tabclose")
          end
        else
          vim.cmd("enew")
        end
      end,
      right_mouse_command = function(tabnum)
        local tabs = vim.api.nvim_list_tabpages()
        if #tabs > 1 then
          local target = tabs[tabnum]
          if target then
            vim.api.nvim_set_current_tabpage(target)
            vim.cmd("tabclose")
          end
        else
          vim.cmd("enew")
        end
      end,
      left_mouse_command = "tabn %d",
    },
  })
end)
