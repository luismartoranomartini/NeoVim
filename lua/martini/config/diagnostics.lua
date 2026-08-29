-- =========================================================
-- lua/martini/config/diagnostics.lua
-- Configuração de vim.diagnostic (extraído de options.lua —
-- diagnósticos são comportamento do editor, não de um plugin,
-- mas mereciam arquivo próprio por serem uma unidade coesa)
-- =========================================================

local sev = vim.diagnostic.severity

vim.diagnostic.config({
  severity_sort    = true,
  update_in_insert = false,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [sev.ERROR] = "E",
      [sev.WARN]  = "W",
      [sev.INFO]  = "I",
      [sev.HINT]  = "H",
    },
  },
  -- Mensagem inline no fim da linha (estilo Error Lens)
  virtual_text = {
    prefix  = "■",  -- quadrado colorido antes da mensagem
    spacing = 2,
    source  = false,
    format  = function(diagnostic)
      return diagnostic.message
    end,
  },
})
