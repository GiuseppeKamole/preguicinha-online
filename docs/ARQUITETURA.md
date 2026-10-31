# Arquitetura

A experiência possui dois scripts. `SeaForgeServer.server.luau` implementa o mundo demonstrativo, jogadores, validação de ações e recompensas. `SeaForgeClient.client.luau` implementa o painel, entrada e visualização de informações.

A comunicação ocorre pelo `RemoteEvent` `ReplicatedStorage.SeaForgeAction`. Regras de dano, recompensas e validação devem permanecer no servidor. O instalador gera os dois scripts no local correto por meio da Command Bar.

**Limite:** o servidor usado nesta demonstração não existe no Blox Fruits original.
