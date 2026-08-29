-- =========================================================
-- lua/martini/plugins/bufferline.lua
-- Extraído de plugins/ui.lua durante a reestruturação (ago/2026).
-- =========================================================

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
