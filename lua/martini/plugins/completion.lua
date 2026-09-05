-- =========================================================
-- lua/martini/plugins/completion.lua
-- nvim-cmp + LuaSnip + capabilities LSP + integração com Emmet no Tab.
-- Carrega ANTES de plugins/lsp.lua: define vim.lsp.config["*"] com as
-- capabilities do cmp_nvim_lsp, que os servidores individuais herdam.
-- =========================================================

-- Verifica se a posição atual tem uma abreviação Emmet válida
local emmet_fts = { html = true, css = true, scss = true, jsx = true, tsx = true, gotmpl = true }

local function emmet_expandable()
  if not emmet_fts[vim.bo.filetype] then return false end
  local col = vim.fn.col(".") - 1
  local before = vim.fn.getline("."):sub(1, col)
  return before:match("[%w%.#%[%]>%)%*]+$") ~= nil
end

local ok_cmp, cmp = pcall(require, "cmp")
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
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<C-d>"] = cmp.mapping.scroll_docs(4),
      ["<C-u>"] = cmp.mapping.scroll_docs(-4),
      -- emmet_expandable() é checado ANTES de cmp.visible(). Se o
      -- cursor está sobre uma abreviação Emmet válida, ela tem
      -- prioridade e o popup do cmp é fechado antes de expandir.
      ["<Tab>"] = cmp.mapping(function(fallback)
        if emmet_expandable() then
          if cmp.visible() then cmp.close() end
          vim.schedule(function()
            vim.fn.feedkeys(
              vim.api.nvim_replace_termcodes("<plug>(emmet-expand-abbr)", true, false, true), ""
            )
          end)
        elseif cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
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
    sources = cmp.config.sources({
      { name = "luasnip", priority = 1000 },
      { name = "nvim_lsp", priority = 750 },
      { name = "buffer", priority = 500 },
    }),
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
  })

  pcall(function()
    cmp.event:on("confirm_done",
      require("nvim-autopairs.completion.cmp").on_confirm_done())
  end)
end
