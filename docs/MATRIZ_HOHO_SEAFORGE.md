# Matriz de equivalência — HoHo Hub x SeaForge

**Critério:** “encontrado” significa que o nome ou a arquitetura aparece nos arquivos públicos; não significa que o recurso funcionou no jogo original.

| Área | HoHo: evidência pública | SeaForge: estado verificável | Próxima validação segura |
|---|---|---|---|
| Carregador remoto | `Loading_UI` e `ScriptLoad.lua` | Arquivo cliente único disponível em `client/` | Verificar carregamento em ambiente autorizado |
| Interface e notificações | `hoho_lib.lua`, `Notification.lua`, `TopbarUI.lua` | Painel cliente local v0.5 com botões e abas na versão Studio | Testar mouse/toque, telas pequenas e fechamento |
| Indicadores de nível/HP | Rótulos e serviços Roblox no código | Leitura do personagem e valores disponíveis | Verificar variações de estrutura de dados |
| Ajustes gráficos locais | Há opções de câmera e visualização | FOV e efeitos locais implementados | Confirmar restauração após fechar |
| Farm de NPCs | Rótulos e módulo principal ofuscado | Demonstração de treino em experiência própria | Testar ciclo servidor/cliente em Studio |
| Missões | Rótulos e módulo principal ofuscado | Sistema demonstrativo em projeto próprio | Testar aceitação, conclusão e recompensas |
| Chefes e raids | Rótulos e módulo principal ofuscado | Sistema demonstrativo em projeto próprio | Testar spawn, estado e encerramento |
| Frutas, baús e materiais | Rótulos e componentes públicos | Coletáveis demonstrativos em projeto próprio | Testar posse, cooldown e reaparecimento |
| Teleporte entre ilhas | Rótulos e utilitários públicos | Teleportes do mundo próprio | Testar permissões e pontos de chegada |
| Funcionalidades no Blox Fruits oficial | Não verificadas por esta auditoria | Não suportadas pela versão atual | Não confundir ambiente próprio com servidor de terceiros |

## Status do repositório SeaForge

O endereço `GiuseppeKamole/preguicinha-online` foi identificado **público** na data desta auditoria, e o arquivo Raw do cliente v0.5 respondeu com conteúdo Lua legível. Isso resolve a antiga hipótese de falta de acesso público ao Raw, mas **não** demonstra compatibilidade com executores nem faz surgirem automações inexistentes.

## Limites

Não reutilizar binários/ofuscações, contornar chaves, redistribuir módulos sem permissão nem tentar evitar proteções do jogo. O alvo para uma implementação completa e controlável é uma experiência própria.
