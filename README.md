Title
Atalhos de Teclado — Configuração Neovim (martini)

Author
Luís Martini

Date
2026-07-08 (atualizado)

Atalhos de Teclado
Levantamento feito diretamente dos arquivos-fonte da configuração (lua/martini/config/ e lua/martini/plugins/). Nenhum atalho aqui foi inferido ou suposto — todos aparecem literalmente em vim.keymap.set(...) nos arquivos indicados entre parênteses no título de cada tabela. Atalhos que vêm de plugins de terceiros (não definidos nos seus arquivos) aparecem em seções separadas, claramente identificadas como tal, com a fonte oficial usada para confirmar cada um.

<leader> está definido como <Space> em options.lua.

Esta versão inclui as alterações mais recentes confirmadas na configuração:

O par de atalhos para salvar todos os buffers (<leader>W / <leader>WQ).
A atualização da implementação de navegação entre diagnósticos, que passou a usar vim.diagnostic.jump em vez das funções vim.diagnostic.goto_prev / goto_next, descontinuadas desde o Neovim 0.11 conforme a página oficial de deprecações (:help deprecated).
A extensão do gf para resolver sempre o caminho absoluto real do arquivo atual antes de montar o alvo (corrigindo o caso em que o arquivo é aberto por caminho relativo), e para abrir URLs (http/https) e arquivos .html/.htm diretamente no navegador do sistema via xdg-open, em vez de como texto dentro do Neovim.
O atalho customizado <Tab> do nvim-tree (ui.lua), antes citado só em texto corrido, agora em tabela própria.
Os atalhos de navegação da janela de resposta do kulala.nvim (Body, Headers, Verbose etc.), confirmados na documentação oficial do plugin.
Navegação e arquivos (keymaps.lua)
Atalho	Modo	Ação
<leader>n	Normal	Abre uma nova aba (:tabnew)
<leader>e	Normal	Alterna o explorador de arquivos (:NvimTreeToggle)
<leader>t	Normal	Abre terminal em split inferior e entra em modo de inserção
<leader>bd	Normal	Fecha o buffer atual (:bd). Se houver alterações não salvas, o Neovim recusa até salvar ou usar <leader>bD
<leader>bD	Normal	Fecha o buffer atual à força, descartando alterações não salvas (:bd!)
<leader>w	Normal	Fecha a aba atual (:tabclose) — diferente de fechar buffer: fecha a janela/espaço de trabalho inteiro, não só o conteúdo carregado
gf	Normal	Resolve o alvo sob o cursor a partir do caminho absoluto real do arquivo atual. Se for URL ou .html/.htm, abre no navegador do sistema (xdg-open). Caso contrário, abre/cria o arquivo em nova aba do Neovim, criando subpastas ausentes quando necessário
Detalhe técnico sobre o gf com URLs/HTML: o comando usa vim.fn.jobstart({"xdg-open", alvo}, {detach = true}). Essa é a forma confiável no Linux — vim.system() combinado com xdg-open tem uma falha silenciosa conhecida e documentada no repositório oficial do Neovim (neovim/neovim, issue #24567), então o gf evita esse caminho.

Atenção com caminhos que começam com / dentro do HTML: em href/src, uma barra inicial é relativa à raiz do site, não à raiz do sistema de arquivos Linux. O gf trata um alvo começando com / como caminho absoluto real do disco — então um src="/js/arquivo.js" tentará gravar em /js/ na raiz do sistema, o que normalmente falha por permissão (erro E212), já que essa pasta pertence ao usuário root. A correção é usar caminho relativo no HTML (ex.: src="js/arquivo.js"), sem a barra inicial.

Salvar buffers (keymaps.lua)
Atalho	Modo	Ação
<leader>W	Normal	Salva todos os buffers modificados (:wa)
<leader>WQ	Normal	Salva todos os buffers e sai do Neovim (:xa)
Terminal (keymaps.lua)
Atalho	Modo	Ação
<Esc>	Terminal	Sai do modo terminal para o modo normal
<C-w>	Terminal	Sai do modo terminal e navega entre splits
<C-q>	Terminal	Sai do modo terminal e fecha a janela
<C-t>	Normal	Alterna (abre/fecha) o terminal inferior
<C-t>	Terminal	Fecha a janela do terminal
Depurador — nvim-dap (keymaps.lua)
Atalho	Modo	Ação
<F5>	Normal	Inicia ou continua a sessão de depuração (dap.continue())
<F10>	Normal	Passo sobre a linha atual (step_over)
<F11>	Normal	Passo para dentro da função (step_into)
<F12>	Normal	Passo para fora da função (step_out)
<leader>b	Normal	Alterna breakpoint na linha atual
<leader>dr	Normal	Abre o REPL de depuração
<leader>dt	Normal	Encerra a sessão de depuração
<leader>du	Normal	Alterna a interface visual do dap-ui
Quando dap.continue() é acionado (<F5>) num arquivo .go com mais de uma configuração de depuração disponível, o nvim-dap-go apresenta um menu de escolha. As opções confirmadas diretamente no código-fonte do plugin (leoluz/nvim-dap-go, arquivo lua/dap-go.lua) são: Debug, Debug (Arguments), Debug (Arguments & Build Flags), Debug Package, Attach, Debug test e Debug test (go.mod).

Execução de código — code_runner (keymaps.lua)
Atalho	Modo	Ação
<leader>r	Normal	Executa o arquivo atual (:RunCode)
<leader>rp	Normal	Executa o projeto (:RunProject)
Testes em Go (runner.lua)
Atalho	Modo	Ação
<leader>gt	Normal	Testa o pacote do arquivo atual em modo verboso (go test -v)
<leader>gT	Normal	Testa o projeto inteiro (go test ./...)
<leader>tf	Normal	Testa apenas a função de teste localizada acima do cursor (go test -run ^Nome$)
Cliente HTTP — kulala.nvim (http.lua, prefixo <leader>R)
Atalho	Modo	Ação
<leader>Rs	Normal	Envia a requisição sob o cursor
<leader>Ra	Normal	Envia todas as requisições do arquivo
<leader>Rb	Normal	Abre o scratchpad (rascunho rápido)
<leader>Rc	Normal	Copia a requisição como comando curl
<leader>Rn	Normal	Vai para a próxima requisição
<leader>Rp	Normal	Vai para a requisição anterior
<leader>Rq	Normal	Fecha a janela de resposta
Navegação dentro da janela de resposta (atalhos padrão do plugin, não definidos no seu http.lua): confirmados na documentação oficial (neovim.getkulala.net/docs/usage/basic-usage). Ativos só quando o foco está na janela de resposta (buffer kulala://ui), sem <leader>:

Tecla	Ação
B	Mostra a aba Body (corpo da resposta)
H	Mostra a aba Headers (cabeçalhos)
A	Mostra a aba All (tudo junto)
V	Mostra a aba Verbose
S	Mostra a aba Stats (estatísticas)
O	Mostra a aba Script output (saída de script)
R	Mostra a aba Report (relatório)
[	Volta na história de respostas anteriores
]	Avança na história de respostas
X	Limpa a história de respostas
Enter	Pula para a requisição correspondente no arquivo .http
?	Abre a janela de ajuda com esses atalhos
LSP — ativados ao conectar (lsp.lua, autocmd LspAttach)
Atalho	Modo	Ação
gd	Normal	Vai para a definição do símbolo (vim.lsp.buf.definition)
K	Normal	Mostra informação flutuante do símbolo (vim.lsp.buf.hover)
[d	Normal	Vai para o diagnóstico anterior, com janela flutuante da mensagem (vim.diagnostic.jump({count = -1, float = true}))
]d	Normal	Vai para o próximo diagnóstico, com janela flutuante da mensagem (vim.diagnostic.jump({count = 1, float = true}))
Observação verificada na documentação oficial do Neovim (:help deprecated, :help diagnostic.txt): desde a versão 0.11, o próprio núcleo do Neovim já cria automaticamente os atalhos ]d, [d, ]D, [D e <C-w>d para qualquer buffer, sem exigir LSP conectado nem configuração própria. O mapeamento feito em lsp.lua é, portanto, redundante em termos de tecla — ele existe para garantir o comportamento com float = true de forma explícita dentro do escopo do seu LspAttach.

Explorador de arquivos — nvim-tree (ui.lua)
Atalho	Modo	Ação
<Tab>	Normal (dentro do nvim-tree)	Abre o nó (arquivo/pasta) sob o cursor em nova aba
Atalhos padrão do plugin (não definidos no seu ui.lua): o restante da navegação dentro do nvim-tree vem de api.config.mappings.default_on_attach(bufnr), que registra o conjunto padrão de atalhos internos do próprio plugin. A lista completa e atualizada pode ser conferida com :help nvim-tree-mappings-default dentro do próprio Neovim. Dois exemplos já confirmados na documentação oficial do projeto, por serem de uso frequente:

Atalho (dentro do nvim-tree)	Ação
r	Renomeia o arquivo ou pasta sob o cursor
<C-r>	Renomeia omitindo a extensão do nome no campo de edição
Dashboard inicial (dashboard.lua, atalhos locais ao buffer da tela inicial)
Atalho	Modo	Ação
n	Normal (buffer do dashboard)	Novo arquivo (:enew + modo de inserção)
e	Normal (buffer do dashboard)	Alterna o explorador de arquivos
c	Normal (buffer do dashboard)	Abre o arquivo de configuração ($MYVIMRC)
t	Normal (buffer do dashboard)	Abre terminal em split inferior
q	Normal (buffer do dashboard)	Sai do Neovim (:qa)
