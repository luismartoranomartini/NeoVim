-- =========================================================
-- TARGET: Neovim 0.12 · Arch Linux
-- lua/martini/init.lua
-- Bootstrap: patch 0.12.2 + loader de plugins + ordem de carregamento
-- =========================================================

-- =========================================================
-- Ponto de entrada do Neovim (runtimepath) — delega tudo pra
-- lua/martini/init.lua. Ver esse arquivo pra ordem de carregamento
-- completa (patch, loader, config, plugins).
-- =========================================================
require("martini")
