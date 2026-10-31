# Comunicação cliente / servidor

O canal demonstrativo é o RemoteEvent `SeaForgeAction`. O cliente envia ações ao servidor e recebe avisos, resultados e atualizações. Para descobrir os nomes de comandos efetivamente implementados, examine os tratamentos `OnServerEvent` e `OnClientEvent` nos arquivos em `src/`.

Nunca confie em distâncias, quantidades ou recompensas enviadas pelo cliente: valide no servidor e aplique limitação de frequência. Este documento descreve a arquitetura de demonstração e não é uma API do Blox Fruits.
