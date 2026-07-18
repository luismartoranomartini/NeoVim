-- =========================================================
-- lua/martini/plugins/lsp.lua
-- LSP (Neovim 0.12 API), nvim-cmp e LuaSnip
-- =========================================================

-- Verifica se a posição atual tem uma abreviação Emmet válida
local emmet_fts = { html = true, css = true, scss = true, jsx = true, tsx = true, gohtmltmpl = true }

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

  -- HTMX: completa atributos hx-* (hx-get, hx-post, hx-trigger, hx-swap
  -- etc.) via yochem/cmp-htmx. Restrito a html e ao filetype customizado
  -- de templates Go (gohtmltmpl, definido em ui.lua), para não poluir o
  -- autocomplete em outros filetypes onde hx-* não faz sentido.
  pcall(function()
    cmp.setup.filetype({ "html", "gohtmltmpl" }, {
      sources = cmp.config.sources(
        { { name = "cmp-htmx"  } },
        { { name = "nvim_lsp" } },
        { { name = "luasnip"  } },
        { { name = "buffer"   } }
      ),
    })
  end)
end

-- ── Keymaps LSP (ativados ao conectar) ───────────────────
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K",  vim.lsp.buf.hover,       opts)
    -- vim.diagnostic.goto_prev/goto_next estão descontinuadas desde o
    -- Neovim 0.11 em favor de vim.diagnostic.jump({count, float}).
    -- float = true reproduz o comportamento antigo de abrir a janela
    -- flutuante com a mensagem do diagnóstico ao pular.
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1,  float = true }) end, opts)
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
  local caminho = vim.fn.exepath("gopls")
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
    vim.notify("LSP não encontrado: gopls", vim.log.levels.WARN)
  end
end

configurar_lsp("ts_ls",   "typescript-language-server",
  { "javascript", "typescript" },
  { "package.json", "tsconfig.json", ".git" })

configurar_lsp("pyright", "pyright-langserver",
  { "python" },
  { "pyproject.toml", "setup.py", "setup.cfg", ".git" })

configurar_lsp("html",    "vscode-html-language-server",
  { "html", "gohtmltmpl" },
  { ".git" })

configurar_lsp("cssls",   "vscode-css-language-server",
  { "css", "scss", "less" },
  { ".git" })

-- clangd: LSP de C/C++. Não usa --stdio (já é o padrão).
do
  local caminho = vim.fn.exepath("clangd")
  if caminho ~= "" then
    vim.lsp.config["clangd"] = {
      cmd          = { caminho },
      filetypes    = { "c", "cpp", "objc", "objcpp" },
      root_markers = { "compile_commands.json", "compile_flags.txt", ".git", "Makefile" },
    }
    vim.lsp.enable("clangd")
  else
    vim.notify("LSP não encontrado: clangd", vim.log.levels.WARN)
  end
end

-- docker_language_server: só Dockerfile.
-- Instalar com:
--   go install github.com/docker/docker-language-server/cmd/docker-language-server@latest
-- O binário usa o subcomando "start" antes do "--stdio" (diferente do
-- padrão {caminho, "--stdio"} do configurar_lsp), por isso um bloco à parte.
--
-- IMPORTANTE: o suporte a Compose (yaml.docker-compose) deste servidor foi
-- removido daqui de propósito. Testado e confirmado quebrado: um
-- docker-compose.yml era analisado com o parser de Dockerfile (erro
-- "unknown instruction: version:"), a versão instalada relata
-- "0.0.0" (build de desenvolvimento, não uma release estável), e o log
-- mostra o servidor rejeitando "$/cancelRequest" — uma notificação padrão
-- do protocolo LSP. Some com isso as várias issues abertas com a tag
-- "compose" no repositório oficial (github.com/docker/docker-language-server),
-- a maioria de 2025: o suporte a Compose desse projeto ainda é imaturo.
-- yamlls (abaixo) assume esse papel de forma mais estável.
do
  local caminho = vim.fn.exepath("docker-language-server")
  if caminho ~= "" then
    vim.lsp.config["docker_language_server"] = {
      cmd          = { caminho, "start", "--stdio" },
      filetypes    = { "dockerfile" },
      root_markers = { "Dockerfile", ".git" },
    }
    vim.lsp.enable("docker_language_server")
  else
    vim.notify("LSP não encontrado: docker-language-server", vim.log.levels.WARN)
  end
end

-- yamlls: YAML genérico + esquema do Kubernetes + Compose.
-- Instalar com: npm install -g yaml-language-server
-- "kubernetes" é uma palavra reservada aceita pelo yaml-language-server:
-- ele detecta manifestos Kubernetes pelo conteúdo (apiVersion/kind), não
-- só pelo nome do arquivo — confirmado na documentação oficial do projeto
-- (redhat-developer/yaml-language-server). schemaStore habilita detecção
-- automática de outros esquemas comuns do JSON Schema Store — inclusive
-- o do Docker Compose, cobrindo o filetype yaml.docker-compose que
-- tiramos do docker_language_server acima (ver comentário ali para o
-- motivo). Não é uma feature Docker-específica (não linka nomes de
-- imagem, por exemplo), mas valida a estrutura do arquivo de forma
-- estável.
do
  local caminho = vim.fn.exepath("yaml-language-server")
  if caminho ~= "" then
    vim.lsp.config["yamlls"] = {
      cmd          = { caminho, "--stdio" },
      filetypes    = { "yaml", "yaml.docker-compose" },
      root_markers = { ".git" },
      settings = {
        yaml = {
          schemaStore = { enable = true },
          schemas     = { kubernetes = "*.yaml" },
        },
      },
    }
    vim.lsp.enable("yamlls")
  else
    vim.notify("LSP não encontrado: yaml-language-server", vim.log.levels.WARN)
  end
end

-- sqlls (joe-re/sql-language-server): sucessor oficial do sqls, que está
-- descontinuado — confirmado no fórum oficial do Neovim e em fontes
-- atualizadas de 2025/2026. Instalar com:
--   npm install -g sql-language-server
-- O binário exige o subcomando "up" e a flag "--method stdio" (diferente
-- do "--stdio" simples do configurar_lsp), por isso um bloco à parte.
--
-- IMPORTANTE: sem um arquivo de credenciais, o sqlls valida sintaxe SQL
-- mas NÃO sugere nomes reais de tabelas/colunas do seu banco. Para isso,
-- crie um dos dois:
--   pessoal:  ~/.config/sql-language-server/.sqllsrc.json
--   por projeto: <raiz-do-projeto>/.sqllsrc.json
-- Formato (exemplo Postgres), documentado em joe-re/sql-language-server:
--   { "name": "meu-projeto", "adapter": "postgres", "host": "localhost",
--     "port": 5432, "user": "postgres", "database": "meu_banco" }
do
  local caminho = vim.fn.exepath("sql-language-server")
  if caminho ~= "" then
    vim.lsp.config["sqlls"] = {
      cmd          = { caminho, "up", "--method", "stdio" },
      filetypes    = { "sql" },
      root_markers = { ".sqllsrc.json", ".git" },
    }
    vim.lsp.enable("sqlls")
  else
    vim.notify("LSP não encontrado: sql-language-server", vim.log.levels.WARN)
  end
end
