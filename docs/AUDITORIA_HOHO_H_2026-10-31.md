# Auditoria estática do HoHo Hub — 31/10/2026

## Escopo e método

Fontes públicas examinadas sem executar códigos: [acsu123/HOHO_H](https://github.com/acsu123/HOHO_H) e o repositório de destino do carregador [acsu123/HohoV2](https://github.com/acsu123/HohoV2). A análise usou árvore de arquivos e inspeção estática dos textos, dos cabeçalhos e de referências a funções. **Nenhuma função foi testada em servidores oficiais.** A disponibilidade e o funcionamento mudam com atualizações.

Os repositórios consultados não mostram arquivo de licença livre explícita na árvore examinada. A existência de código publicamente legível ou traduzido não autoriza republicar suas partes proprietárias ou vender cópias.

## Inventário de todos os 14 arquivos de HOHO_H

| Arquivo | Tamanho aproximado | Observação verificada | Estado |
|---|---:|---|---|
| `README.md` | 25 B | Título e aviso curto | Texto |
| `Loading_UI` | 99 B | Encaminha execução ao `HohoV2/ScriptLoad.lua` | Carregador |
| `LoadingUi` | 16 B | Apenas texto inerte | Não é carregador |
| `HohoHubPre.lua` | 99 B | Mesmo carregamento remoto de `Loading_UI` | Carregador |
| `new_load.lua` | 6,2 KB | Seletor de jogo; para Blox Fruits aponta ao `HohoHub.lua` | Carregador/GUI |
| `HohoHub.lua` | 2,63 MB | Ofuscado com Luraph 13.5.8 | Lógica não legível diretamente |
| `gionquaini-obfuscated.lua` | 975 KB | Ofuscado com Luraph 13.6.7 | Lógica não legível diretamente |
| `trycrackme4.lua` | 163 KB | Ofuscado com Luraph 14.0.3 | Lógica não legível diretamente |
| `Notification.lua` | 7,6 KB | Biblioteca de notificações e animações | Componente de interface |
| `hoho_lib.lua` | 45,6 KB | Biblioteca de interface: abas, botões, toggles, sliders e menus | Componente de interface |
| `saveinstance.lua` | 29 KB | Exportação de informações de instâncias | Ferramenta de depuração |
| `dex` | 406 KB | Explorador e ferramentas de depuração derivados do Dex | Ferramenta de terceiros |
| `dexv4` | 788 KB | Outra variante do Dex, com editor de propriedades | Ferramenta de terceiros |
| `API-DUMP.json` | 858 KB | Dados de referência de classes/propriedades da API Roblox | Dados; não executável |

**Atenção:** tamanhos de arquivo não provam funcionamento. O arquivo `HohoHub.lua` é um conteúdo diferente do pequeno carregador `Loading_UI`. O seletor antigo e o carregador atual seguem caminhos distintos.

## Repositório associado HohoV2

- `ScriptLoad.lua` possui cerca de 929 linhas. Reconhece jogos por `game.GameId`, cria interface e efetua verificações de chave (`api.check_key`) antes da chamada de carregamento protegido (`api.load_script`).
- `BloxFruit/huhuhud.lua` tem cerca de 7,09 MB e foi gerado por **Luraph 13.8.1**, portanto não permite inferir diretamente o funcionamento de cada automação a partir de análise textual superficial.
- `BloxFruit/languages/English.json`: **1.177 chaves de interface**.
- `BloxFruit/languages/Portuguese.json`: **1.179 chaves de interface**.
- A pasta `BloxFruit/` também contém módulos legíveis de interface, arraste, câmera, UI superior, caminho (AStar), heap, pool de objetos, efeitos, animação e traduções. Isso demonstra uma organização modular, **não** comprova funcionamento das automações.
- Há ainda conteúdo voltado a interferência com mecanismos de proteção. Não é necessário executá-lo nem reproduzi-lo para criar uma experiência própria com recursos semelhantes.

## Funcionalidades referidas pelos rótulos de interface

As contagens abaixo são **ocorrências de palavras nos nomes das 1.177 chaves** do arquivo inglês. Elas se sobrepõem e **não** representam números de módulos funcionais.

| Palavra/categoria | Chaves correspondentes |
|---|---:|
| `Auto` | 314 |
| `Farm` | 96 |
| `Fruit` | 74 |
| `Quest` | 35 |
| `Boss` | 35 |
| `Raid` | 18 |
| `Teleport` | 8 |
| `ESP` | 26 |
| `Race` | 26 |
| `Chest` | 12 |
| `Shop` | 15 |

Exemplos de rótulos existentes: `NORMAL FARM`, `Auto Store Fruit`, `Auto Farm All Bosses`, `Auto Law Raid`, `Show Fruit Spawn Info`, `Fruit Shop`. Esses textos podem estar desatualizados ou fazer referência a funcionalidades não disponíveis na versão executada.

## Conclusões para o SeaForge

1. **Comprovável:** arquitetura de carregamento remoto, bibliotecas de interface, identificadores de jogo, traduções, estrutura modular e presença de blocos ofuscados.
2. **Não comprovável a partir destes arquivos legíveis:** lógica completa de farm, boss, raid, exploração de itens, recompensas e seu funcionamento nas versões atuais do jogo original.
3. **Não transportável diretamente:** código do servidor demonstrativo SeaForge, porque depende de uma experiência sob controle do desenvolvedor.
4. **Desenvolvimento independente possível:** painéis próprios, indicadores locais, ferramentas de visualização e sistemas de missões, NPCs, progressão e coletáveis numa experiência própria no Roblox Studio.
5. **Testes pendentes:** execução de ponta a ponta em Roblox Studio, mobile, persistência, falhas de rede, validação servidor/cliente e revisão de direitos de distribuição.

Não afirmar “100% funcional” sem teste real e sem acesso às implementações completas. Nenhum módulo proprietário foi incorporado neste relatório.
