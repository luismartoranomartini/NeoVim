-- =========================================================
-- lua/martini/plugins/ui.lua
-- Treesitter, autopairs, nvim-tree, bufferline e emmet
-- =========================================================

-- Reconhece arquivos .tmpl (Go HTML templates) como filetype gohtmltmpl
vim.filetype.add({
  extension = {
    tmpl  = "gohtmltmpl",
    gohtml = "gohtmltmpl",
  },
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
  pattern = { "lua", "javascript", "typescript", "go", "python", "html", "css", "c", "gohtmltmpl" },
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
  pattern  = { "html", "css", "scss", "jsx", "tsx", "gohtmltmpl" },
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
