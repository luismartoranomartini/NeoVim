-- =========================================================
-- lua/martini/plugins/ui.lua
-- Treesitter, autopairs, nvim-tree, bufferline e emmet
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

-- Colore verbos de formatação do Go (%s, %d, %v, %+v, %.2f, etc.).
-- O Treesitter do Go marca sequências de escape reais (\n, \t) como
-- @string.escape, mas NÃO tem um nó separado pra verbos de printf —
-- pro compilador/parser, eles são só conteúdo comum da string. Por
-- isso usa matchadd (highlight por regex, sobreposto ao Treesitter)
-- em vez de depender de captura nativa. Grupo "GoFormatVerb" definido
-- em config/colors.lua.
vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
  pattern = "go",
  callback = function()
    if vim.bo.filetype == "go" then
      -- Generalizado: qualquer letra (a-z/A-Z) como verbo, em vez de
      -- listar cada uma (%s %d %v %w ...) — cobre todo verbo atual e
      -- futuro do pacote fmt sem precisar atualizar essa lista depois.
      pcall(vim.fn.matchadd, "GoFormatVerb", "%[-+ 0#]*\\d*\\.\\?\\d*[a-zA-Z%]")
    end
  end,
})

-- Treesitter
pcall(function()
  require("nvim-treesitter.configs").setup({
    ensure_installed = { "lua", "javascript", "typescript", "go", "python", "html", "css", "c" },
    auto_install     = true,
    highlight        = { enable = true },
    indent           = { enable = true },
  })
end)

-- Força o início do Treesitter highlight ao abrir arquivos.
-- Necessário no 0.12 onde highlight={enable=true} nem sempre dispara sozinho.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "javascript", "typescript", "go", "python", "html", "css", "c" },
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- Autopairs
pcall(function()
  require("nvim-autopairs").setup({ check_ts = true })
end)

-- Emmet
vim.g.user_emmet_mode           = "i"
vim.g.user_emmet_install_global = 0

vim.api.nvim_create_autocmd("FileType", {
  pattern  = { "html", "css", "scss", "jsx", "tsx" },
  callback = function(args)
    vim.cmd("EmmetInstall")

    -- Envolve a seleção com uma tag/abreviação Emmet (equivalente ao
    -- "Wrap with Abbreviation" do VS Code).
    -- IMPORTANTE: com user_emmet_mode = "i" (definido acima), o
    -- install_plugin() do emmet-vim só registra <Plug>s de modo
    -- Insert — o item de modo Visual (que faria o wrap) é pulado
    -- inteiro e o <Plug> correspondente nunca chega a existir, com
    -- qualquer nome. A saída é chamar a função autoload diretamente:
    -- ela existe sempre, independente do user_emmet_mode. É
    -- exatamente o que o emmet-vim executaria internamente no modo
    -- Visual (ver plugin/emmet.vim, item mode='v', key=','):
    --   emmet#expandAbbr(2, "") → com seleção ativa, envolve o texto.
    vim.keymap.set("v", "<leader>ew", ':call emmet#expandAbbr(2,"")<CR>',
      { buffer = args.buf, silent = true, desc = "Emmet: envolver seleção com tag" })
    vim.keymap.set("v", "<C-y>,", ':call emmet#expandAbbr(2,"")<CR>',
      { buffer = args.buf, silent = true, desc = "Emmet: envolver seleção com tag (Ctrl+Y ,)" })
  end,
})

-- nvim-tree
pcall(function()
  require("nvim-web-devicons").setup()

  -- Decorator customizado: colore pastas específicas pelo nome.
  -- API real do nvim-tree para isso — não existe opção de "cor por
  -- nome de pasta" no setup() direto, é feito via classe de decorator
  -- (nvim_tree.api.decorator.UserDecorator). Os highlight groups
  -- usados aqui (NvimTreeFolderCmd, etc.) são definidos em
  -- config/colors.lua, dentro de aplicar_highlights(), pra
  -- sobreviverem a troca de colorscheme.
  local pastas_coloridas = {
    cmd       = "NvimTreeFolderCmd",
    views     = "NvimTreeFolderViews",
    static    = "NvimTreeFolderStatic",
    templates = "NvimTreeFolderTemplates",
  }

  local ok_decorator, UserDecorator = pcall(function()
    return require("nvim-tree.api").decorator.UserDecorator
  end)

  local FolderColorDecorator = nil
  if ok_decorator then
    FolderColorDecorator = UserDecorator:extend()

    -- :new() é chamado automaticamente pela framework interna do
    -- nvim-tree (biblioteca "classic"), uma vez por render — sem
    -- argumentos, sem setmetatable manual (isso é feito pelo
    -- :extend() por baixo dos panos). Só define campos em self.
    function FolderColorDecorator:new()
      self.enabled        = true
      self.highlight_range = "all" -- colore ícone + nome
    end

    function FolderColorDecorator:highlight_group(node)
      if node.type ~= "directory" then return nil end
      -- nvim-tree junta pastas com um único filho numa linha só
      -- (group_empty = true), então o node.name pode vir composto
      -- (ex: "cmd/app" em vez de só "cmd"). Casa pelo primeiro
      -- segmento antes da "/", cobrindo os dois casos.
      -- group_empty pode juntar VÁRIOS níveis numa linha só (ex:
      -- "012_interface/cmd/app"), e "cmd" pode acabar no meio do
      -- nome composto, não só no início. Percorre cada segmento
      -- separado por "/" até achar um que bata com a tabela.
      for segmento in node.name:gmatch("[^/]+") do
        if pastas_coloridas[segmento] then
          return pastas_coloridas[segmento]
        end
      end
      return nil
    end
  end

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
      -- Registra a CLASSE do decorator (não uma instância — o
      -- nvim-tree instancia via :new() internamente a cada render).
      decorators = ok_decorator
        and { "Git", "Open", "Hidden", "Modified", "Bookmark", "Diagnostics", "Copied", "Cut", FolderColorDecorator }
        or  { "Git", "Open", "Hidden", "Modified", "Bookmark", "Diagnostics", "Copied", "Cut" },
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

-- Surround: envolve seleções/objetos com (), {}, [], "", '', tags HTML, etc.
-- Equivalente ao "Surround with" do VSCode.
pcall(function()
  require("nvim-surround").setup({})
end)
