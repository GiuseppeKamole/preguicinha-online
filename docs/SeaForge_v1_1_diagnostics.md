# SeaForge Hub v1.1 — Guia de diagnóstico

Esta versão corrige problemas de observabilidade, conflito de movimentação e exibição de frutas no código cliente. Não foi testada em servidores oficiais do Blox Fruits. Não contorna proteções nem pode confirmar que o servidor aceitou ataques, missões, recompensas ou raids.

## Alterações
- Botão **Verificar recursos / copiar relatório** na interface. O relatório descreve somente objetos que o cliente pode observar.
- Prioridade de movimentação para coleta de frutas em relação ao combate, evitando dois comandos Humanoid:MoveTo simultâneos.
- Identificação genérica de frutas em Tool e Model com Handle/PrimaryPart; resultados continuam limitados aos objetos replicados ao cliente.
- ESP corrigido para aplicar Highlight sobre a BasePart de frutas do tipo Tool.
- Evita selecionar a missão antiga do nível 2575 em níveis 2600 ou acima, cujos dados ainda não estão catalogados.
- Autoataque só chama Tool:Activate() quando a ferramenta está equipada no Character.
- Armazena as últimas 60 mensagens locais.

## Como diagnosticar
1. Execute a versão v1.1 e deixe todas as automações desligadas.
2. Pressione **Verificar recursos / copiar relatório**.
3. Ative somente UMA função por vez e observe o que realmente acontece no jogo.
4. Gere o relatório novamente. No Lovable, registre o status do teste e cole apenas os trechos relevantes do log.
5. Não inclua senhas, tokens, identificadores pessoais ou informações privadas.
6. Se o painel disser que uma tentativa foi enviada, isso **não** confirma que o servidor a aceitou.

## Exemplos públicos para arquitetura de experiências próprias Roblox
- [Roblox NPC AI](https://github.com/spavdigital/roblox-npc-ai) — IA de NPCs no servidor e pathfinding, MIT.
- [DialogService](https://github.com/i3Crk/DialogService) — fluxo de diálogo com NPCs, MIT.
- [Puppet](https://github.com/CrossBeast/Puppet) — framework de NPCs, MIT.
- [Pathfinding do Roblox](https://create.roblox.com/docs/pt-br/characters/pathfinding) — orientação oficial.
- [Remote events e callbacks](https://create.roblox.com/docs/scripting/events/remote) — cliente e servidor.

Esses projetos não são módulos que habilitam recursos no Blox Fruits oficial: servem como referências de projeto e para testes em uma experiência própria.
