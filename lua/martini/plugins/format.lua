-- =========================================================
-- lua/martini/plugins/format.lua
-- Formatação automática via conform.nvim e linting via nvim-lint
-- =========================================================

-- Linting com golangci-lint para Go
pcall(function()
  local lint = require("lint")

  -- Localiza o executável correto no Windows
  local golangci = vim.fn.exepath("golangci-lint")
  if golangci == "" then
    vim.notify("golangci-lint não encontrado no PATH", vim.log.levels.WARN)
    return
  end

  -- Sobrescreve o comando para usar o caminho completo
  lint.linters.golangcilint = {
    cmd        = golangci,
    stdin      = false,
    args       = { "run", "--out-format", "json", "--issues-exit-code=1" },
    stream     = "stdout",
    ignore_exitcode = true,
    parser     = require("lint.linters.golangcilint").parser,
  }

  lint.linters_by_ft = {
    go = { "golangcilint" },
  }

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern  = "*.go",
    callback = function() lint.try_lint() end,
  })
end)

pcall(function()
  require("conform").setup({
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      python     = { "black" },
      html       = { "prettier" },
      css        = { "prettier" },
    },
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback",
    },
  })
end)

-- =========================================================
-- Organizar imports em Go ao salvar (via gopls)
-- Adiciona/remove imports automaticamente antes do write.
-- gopls expõe isso como code action "source.organizeImports";
-- não é formatação, então o conform.nvim não cobre isso —
-- precisa ser disparado manualmente contra o LSP.
-- =========================================================
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function(args)
    local params = vim.lsp.util.make_range_params(0, "utf-8")
    params.context = { only = { "source.organizeImports" } }

    local result = vim.lsp.buf_request_sync(args.buf, "textDocument/codeAction", params, 1000)
    if not result then return end

    for _, res in pairs(result) do
      for _, action in pairs(res.result or {}) do
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
        elseif action.command then
          vim.lsp.buf.execute_command(action.command)
        end
      end
    end
  end,
})
