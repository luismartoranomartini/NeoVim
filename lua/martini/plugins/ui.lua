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
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.fn.matchadd("GoFormatVerb", [=[%[-+ #0]*[0-9]*\.\?[0-9]*[sdvTqxXobeEfFgGpc]]=])
  end,
})

-- Autopairs
pcall(function()
  require("nvim-autopairs").setup({ check_ts = true })
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
vim.g.user_emmet_mode           = "i"
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
      group_empty   = true,
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
