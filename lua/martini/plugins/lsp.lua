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
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "gd",         vim.lsp.buf.definition,  opts)
    vim.keymap.set("n", "K",          vim.lsp.buf.hover,        opts)
    vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d",         vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>fr", vim.lsp.buf.rename,       opts)
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
          analyses       = { unusedparams = true },
          staticcheck    = true,
          semanticTokens = true,
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
