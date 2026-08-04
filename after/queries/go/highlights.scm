; extends
;
; A query base do go (nvim-treesitter) captura "chan" (e provavelmente
; "map", "interface", "struct" — todas palavras reservadas que também
; abrem uma expressão de tipo) como @type.builtin, igual a int/string/
; bool/etc. Isso faz essas keywords ficarem com a MESMA cor dos tipos
; builtin de verdade (mesmo grupo, mesma prioridade — não é coincidência
; visual).
;
; Usamos um grupo próprio (@keyword.type) em vez de @keyword genérico
; para poder estilizar essas quatro palavras (cor + itálico) sem afetar
; if/for/return/etc., que continuam em @keyword sem itálico.
; Como este arquivo está em after/queries/, ele é lido DEPOIS da query
; base, então esta captura vence no empate de prioridade.

[
  "chan"
  "map"
  "interface"
  "struct"
] @keyword.type
