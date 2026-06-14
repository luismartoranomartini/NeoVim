-- =========================================================
-- lua/martini/plugins/lsp.lua
-- LSP (Neovim 0.12 API), nvim-cmp e LuaSnip
-- =========================================================

-- Verifica se a posição atual tem uma abreviação Emmet válida
local emmet_fts = { html = true, css = true, scss = true, jsx = true, tsx = true }

local function emmet_expandable()
  if not emmet_fts[vim.bo.filetype] then return false end
  local col    = vim.fn.col(".") - 1
  local before = vim.fn.getline("."):sub(1, col)
  return before:match("[%w%.#%[%]>%)%*]+$") ~= nil
end

-- ── nvim-cmp + LuaSnip ───────────────────────────────────
local ok_cmp,  cmp     = pcall(require, "cmp")
local ok_snip, luasnip = pcall(require, "luasnip")

if ok_cmp and ok_snip then
  pcall(function()
    require("luasnip.loaders.from_vscode").lazy_load()
  end)

  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  vim.lsp.config["*"] = { capabilities = capabilities }

  cmp.setup({
    snippet = {
      expand = function(args) luasnip.lsp_expand(args.body) end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"]      = cmp.mapping.confirm({ select = true }),
      ["<C-e>"]     = cmp.mapping.abort(),
      ["<C-d>"]     = cmp.mapping.scroll_docs(4),
      ["<C-u>"]     = cmp.mapping.scroll_docs(-4),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif emmet_expandable() then
          cmp.close()
          vim.schedule(function()
            vim.fn.feedkeys(
              vim.api.nvim_replace_termcodes("<plug>(emmet-expand-abbr)", true, false, true), ""
            )
          end)
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources(
      { { name = "nvim_lsp" } },
      { { name = "luasnip"  } },
      { { name = "buffer"   } }
    ),
    window = {
      completion    = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
  })

  pcall(function()
    cmp.event:on("confirm_done",
      require("nvim-autopairs.completion.cmp").on_confirm_done())
  end)
end

-- ── Keymaps LSP (ativados ao conectar) ───────────────────
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "gd",         vim.lsp.buf.definition,  opts)
    vim.keymap.set("n", "K",          vim.lsp.buf.hover,        opts)
    vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d",         vim.diagnostic.goto_next, opts)
  end,
})

-- ── Servidores LSP ───────────────────────────────────────
local function configurar_lsp(nome, executavel, filetypes, root_markers)
  local caminho = vim.fn.exepath(executavel)
  if caminho == "" then
    vim.notify("LSP não encontrado: " .. executavel, vim.log.levels.WARN)
    return
  end
  vim.lsp.config[nome] = {
    cmd          = { caminho, "--stdio" },
    filetypes    = filetypes,
    root_markers = root_markers,
  }
  vim.lsp.enable(nome)
end

-- gopls não aceita --stdio; usa stdio por padrão sem flags
do
  local caminho = vim.fn.exepath("gopls.exe")
  if caminho ~= "" then
    vim.lsp.config["gopls"] = {
      cmd          = { caminho },
      filetypes    = { "go", "gomod", "gowork" },
      root_markers = { "go.mod", "go.work", ".git" },
      settings = {
        gopls = {
          analyses        = { unusedparams = true },
          staticcheck     = true,
          semanticTokens  = true,
        },
      },
    }
    vim.lsp.enable("gopls")
  else
    vim.notify("LSP não encontrado: gopls.exe", vim.log.levels.WARN)
  end
end

configurar_lsp("ts_ls",   "typescript-language-server.cmd",
  { "javascript", "typescript" },
  { "package.json", "tsconfig.json", ".git" })

configurar_lsp("pyright", "pyright-langserver.cmd",
  { "python" },
  { "pyproject.toml", "setup.py", "setup.cfg", ".git" })

configurar_lsp("html",    "vscode-html-language-server.cmd",
  { "html" },
  { ".git" })

configurar_lsp("cssls",   "vscode-css-language-server.cmd",
  { "css", "scss", "less" },
  { ".git" })