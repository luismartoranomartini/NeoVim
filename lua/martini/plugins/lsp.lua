-- =========================================================
-- lua/martini/plugins/lsp.lua
-- Servidores LSP (Neovim 0.12 API nativa — sem nvim-lspconfig) e
-- keymaps ativados em LspAttach.
--
-- completion.lua carrega ANTES deste arquivo e define
-- vim.lsp.config["*"].capabilities — os servidores abaixo herdam isso.
--
-- NOTA: docker-language-server NÃO está presente aqui — não foi
-- confirmado no repositório real na última verificação (ago/2026).
-- Adicione com configurar_lsp("docker", "docker-langserver", ...)
-- se/quando for commitado.
-- =========================================================

-- ── Keymaps LSP (ativados ao conectar) ───────────────────
-- gd/K/[d/]d DELIBERADAMENTE mantidos sem prefixo <leader> — convenção
-- universal do ecossistema Neovim (ver :h lsp-quickstart).
--
-- Rename NÃO usa domínio novo (<leader>l): o README define domínios
-- fixos (b/d/f/g/h/m/r) e <leader>f já hospeda ações LSP via fzf-lua
-- (ex.: <leader>fu = usages/referências). <leader>fr segue a mesma
-- convenção — evita criar um domínio de propósito único.
--
-- gD/gi/gr/gt ADICIONADOS (ago/2026) — mesma convenção sem <leader>
-- de gd/K, cobrindo declaration/implementation/references/type
-- definition que faltavam. Nenhum bind existente foi alterado.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "gd",         vim.lsp.buf.definition,       opts)
    vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,      opts)
    vim.keymap.set("n", "gi",         vim.lsp.buf.implementation,   opts)
    vim.keymap.set("n", "gr",         vim.lsp.buf.references,       opts)
    vim.keymap.set("n", "gt",         vim.lsp.buf.type_definition,  opts)
    vim.keymap.set("n", "K",          vim.lsp.buf.hover,            opts)
    vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,     opts)
    vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,     opts)
    vim.keymap.set("n", "<leader>fr", vim.lsp.buf.rename,           opts)
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
--
-- Settings ENRIQUECIDAS (ago/2026), vindas de uma config vista em
-- outro lugar — mesclada aqui sem tocar nos keymaps acima:
--   analyses: conjunto ampliado (nilness, shadow, modernize, etc.)
--   completeFunctionCalls/usePlaceholders: completion mais rica
--   hints: inlay hints detalhados
--   codelenses, vulncheck, diagnosticsDelay, importShortcut,
--   symbolMatcher, linksInHover, expandWorkspaceToModule,
--   renameMovesSubpackages: recursos do gopls não usados antes
--
-- NOTA: campo `local` do gopls precisa ir entre colchetes+string
-- (["local"] = "..."), pois `local` é palavra reservada em Lua —
-- não pode ser chave de tabela na forma `local = valor`.
do
  local caminho = vim.fn.exepath("gopls")
  if caminho ~= "" then
    vim.lsp.config["gopls"] = {
      cmd          = { caminho },
      filetypes    = { "go", "gomod", "gowork", "gotmpl" },
      root_markers = { "go.mod", "go.work", ".git" },
      settings = {
        gopls = {
          -- Analysis
          staticcheck = true,
          analyses = {
            unreachable      = true,
            unusedparams     = true,
            unusedwrite      = true,
            nilness          = true,
            shadow           = true,
            modernize        = true,
            appends          = true,
            asmdecl          = true,
            assign           = true,
            atomic           = true,
            bools            = true,
            buildtag         = true,
            cgocall          = true,
            composites       = true,
            copylocks        = true,
            deepequalerrors  = true,
            errorsas         = true,
            httpresponse     = true,
            loopclosure      = true,
            lostcancel       = true,
            nilfunc          = true,
            printf           = true,
            tests            = true,
            timeformat       = true,
            unmarshal        = true,
            unsafeptr        = true,
            unusedresult     = true,
          },

          -- Completion
          completeFunctionCalls = true,
          usePlaceholders        = true,

          -- Formatting
          gofumpt     = false,
          ["local"]   = "", -- prefixo do seu módulo, se quiser separar imports internos

          -- Inlay hints
          hints = {
            parameterNames          = true,
            assignVariableTypes     = true,
            rangeVariableTypes      = true,
            constantValues          = true,
            compositeLiteralFields  = true,
            compositeLiteralTypes   = false,
            functionTypeParameters  = true,
            ignoredError            = true,
          },

          -- Navigation
          importShortcut = "Both",
          symbolMatcher  = "FastFuzzy",

          -- Semantic highlighting
          semanticTokens = true,

          -- Code lenses
          codelenses = {
            generate            = true,
            regenerate_cgo      = true,
            run_govulncheck     = true,
            tidy                = true,
            upgrade_dependency  = true,
            vendor              = true,
          },

          -- Vulnerability analysis
          vulncheck = "Prompt",

          -- Diagnostics
          diagnosticsTrigger = "Edit",
          diagnosticsDelay   = "500ms",

          -- Documentation
          linksInHover = true,

          -- Workspace
          expandWorkspaceToModule = true,

          -- Rename
          renameMovesSubpackages = true,
        },
      },
    }
    vim.lsp.enable("gopls")
  else
    vim.notify("LSP não encontrado: gopls", vim.log.levels.WARN)
  end
end

configurar_lsp("ts_ls", "typescript-language-server",
  { "javascript", "typescript" },
  { "package.json", "tsconfig.json", ".git" })

configurar_lsp("pyright", "pyright-langserver",
  { "python" },
  { "pyproject.toml", "setup.py", "setup.cfg", ".git" })

configurar_lsp("html", "vscode-html-language-server",
  { "html", "gotmpl" },
  { ".git" })

configurar_lsp("cssls", "vscode-css-language-server",
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
