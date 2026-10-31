# SeaForge Hub — cliente local v0.4

## Objetivo

O arquivo `client/SeaForgeHub.client.lua` é um **script cliente independente**. Ele cria um painel dentro da interface do Roblox, exibe nome do jogador, nível (quando disponível), Beli, fragmentos, FPS, HP e posição. Oferece ajustes locais de campo de visão e de pós-processamento gráfico. **Não altera o servidor e não contém Auto Farm, Auto Boss, Auto Quest ou Auto Raid.**

O script não depende dos arquivos de servidor do minijogo de treinamento em `src/`.

## Teste sem acesso remoto

Leia o código-fonte e execute-o **somente em ambiente controlado e autorizado**, depois de compreender os riscos. No Roblox Studio, teste o arquivo como LocalScript em `StarterPlayerScripts` de uma experiência própria.

## URL do arquivo no GitHub

Arquivo no repositório: `client/SeaForgeHub.client.lua`.

O padrão de carregamento remoto do formato que você solicitou é:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/GiuseppeKamole/preguicinha-online/main/client/SeaForgeHub.client.lua"))()
```

**Esse comando NÃO funciona com o repositório atual privado:** um cliente externo não consegue acessar o Raw sem autenticação. Não adicione tokens do GitHub ao script. Caso decida disponibilizar o arquivo publicamente, use um repositório **separado**, com revisão de conteúdo e sem fotos de pessoas ou dados privados. A publicação não garante compatibilidade com executores.

## Limitações de compatibilidade

Executores de terceiros diferem nas APIs, versão Lua/Luau, HTTP e permissões. Este script usa apenas serviços Roblox e objetos de interface padrão, mas **não foi testado** no Delta nem nos servidores oficiais do Blox Fruits. Se você optar por experimentar executores de terceiros, há riscos para sua conta, aparelho e arquivos.

## Ajustes e botão de sair

- Execute apenas uma instância por cliente: o script fecha a interface anterior com o mesmo nome.
- A opção de campo de visão e o redutor de efeitos mudam somente o visual local.
- O botão "_" minimiza e exibe o botão "SEAFORGE" para reabrir.
- O botão "X" destrói a interface e desconecta a atualização de estatísticas.
- O Roblox e o próprio jogo podem sobrescrever as opções visuais a qualquer momento.
