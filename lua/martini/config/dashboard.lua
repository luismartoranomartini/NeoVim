-- =========================================================
-- lua/martini/config/dashboard.lua
-- Tela inicial centralizada com ASCII art e menu
-- =========================================================

local function carregar_dashboard()
  if vim.fn.argc() > 0 then return end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)

  vim.opt_local.number         = false
  vim.opt_local.relativenumber = false
  vim.opt_local.cursorline     = false
  vim.opt_local.signcolumn     = "no"
  vim.opt_local.colorcolumn    = ""

  local win_w = vim.api.nvim_win_get_width(0)
  local win_h = vim.api.nvim_win_get_height(0)

  local function center(str)
    local pad = math.floor((win_w - vim.fn.strdisplaywidth(str)) / 2)
    return string.rep(" ", math.max(0, pad)) .. str
  end

  local ascii = {
    "███╗   ███╗ █████╗ ██████╗ ████████╗██╗███╗   ██╗██╗",
    "████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝██║████╗  ██║██║",
    "██╔████╔██║███████║██████╔╝   ██║   ██║██╔██╗ ██║██║",
    "██║╚██╔╝██║██╔══██║██╔══██╗   ██║   ██║██║╚██╗██║██║",
    "██║ ╚═╝ ██║██║  ██║██║  ██║   ██║   ██║██║ ╚████║██║",
    "╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚═╝",
  }

  local menu = {
    { icon = " ", label = "Novo Arquivo", key = "n" },
    { icon = " ", label = "Explorador",   key = "e" },
    { icon = " ", label = "Configuração", key = "c" },
    { icon = " ", label = "Terminal",     key = "t" },
    { icon = " ", label = "Sair",         key = "q" },
  }

  local content_h = #ascii + 2 + (#menu * 2)
  local top_pad   = math.max(0, math.floor((win_h - content_h) / 2))

  local lines    = {}
  local hl_queue = {}

  for _ = 1, top_pad do table.insert(lines, "") end

  for _, art in ipairs(ascii) do
    local idx = #lines
    table.insert(lines, center(art))
    table.insert(hl_queue, { idx, 0, -1, "Function" })
  end

  table.insert(lines, "")
  table.insert(lines, "")

  local menu_w = 26
  for _, item in ipairs(menu) do
    local label_part = item.icon .. "  " .. item.label
    local gap        = math.max(3, menu_w - vim.fn.strdisplaywidth(label_part))
    local full       = label_part .. string.rep(" ", gap) .. item.key
    local pad        = math.floor((win_w - vim.fn.strdisplaywidth(full)) / 2)
    local centered   = string.rep(" ", math.max(0, pad)) .. full
    local idx        = #lines

    table.insert(lines, centered)
    table.insert(lines, "")

    table.insert(hl_queue, { idx, pad, pad + 3, "DiagnosticOk" })
    table.insert(hl_queue, { idx, pad + vim.fn.strdisplaywidth(label_part) + gap, -1, "DiagnosticWarn" })
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype    = "nofile"

  local ns = vim.api.nvim_create_namespace("martini_dashboard")
  for _, h in ipairs(hl_queue) do
    pcall(vim.api.nvim_buf_add_highlight, buf, ns, h[4], h[1], h[2], h[3])
  end

  local o = { buffer = buf, silent = true, nowait = true }
  vim.keymap.set("n", "n", ":enew<CR>i",          o)
  vim.keymap.set("n", "e", ":NvimTreeToggle<CR>",  o)
  vim.keymap.set("n", "c", ":e $MYVIMRC<CR>",      o)
  vim.keymap.set("n", "t", function()
    vim.cmd("botright split | resize 15 | terminal")
    vim.cmd("startinsert")
  end, o)
  vim.keymap.set("n", "q", ":qa<CR>", o)
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(carregar_dashboard, 50)
  end,
})
