# SeaForge Hub — projeto Luau de demonstração

![Imagem-símbolo do SeaForge Hub](assets/mascote.jpg)

> A imagem-símbolo foi fornecida pelo proprietário do projeto. Antes de distribuí-la publicamente, confirme as permissões de uso da imagem e das pessoas nela retratadas.

**Versão de organização:** 0.3.0 · **Idioma:** português do Brasil · **Ambiente:** Roblox Studio, em uma experiência própria.

Este repositório contém um minijogo de treinamento e uma interface de automações em **Luau original**. O mundo demonstrativo inclui ilhas, inimigos, missões, chefe, raids, frutas e recompensas. O projeto foi criado para fins de desenvolvimento e teste em experiências sob seu controle.

> **Não é um exploit do Blox Fruits, nem uma cópia do HoHo Hub.** Não contém uma `loadstring` para executores; o código é dividido entre servidor e cliente. Não existe garantia de compatibilidade com Delta ou outros executores.

## Instalação rápida

1. Abra um lugar vazio **seu** no Roblox Studio e salve uma cópia.
2. Em **View → Command Bar**, cole o conteúdo integral de [`tools/INSTALAR_NO_STUDIO_CommandBar.lua`](tools/INSTALAR_NO_STUDIO_CommandBar.lua) e execute.
3. Pressione **Play (F5)**. O Studio cria o mundo `SeaForgeDemoWorld` e apresenta a interface `SeaForgeHub`.
4. Teste as funções conforme [`docs/TESTES.md`](docs/TESTES.md).

O instalador substitui `SeaForgeServer` e `SeaForgeClient` de versões anteriores. **Faça backup do seu lugar antes.**

## Conteúdo do repositório

| Caminho | Finalidade |
|---|---|
| `src/SeaForgeServer.server.luau` | Mundo de teste, regras de combate, recompensas e validações no servidor |
| `src/SeaForgeClient.client.luau` | Interface gráfica, automações de demonstração, marcações e navegação |
| `tools/INSTALAR_NO_STUDIO_CommandBar.lua` | Instalação dos dois scripts no Roblox Studio |
| `tools/gerar_instalador.py` | Regenera o instalador a partir dos fontes |
| `tests/test_package.py` | Testa integridade e consistência do instalador |
| `.github/workflows/validar.yml` | Executa os testes estáticos no GitHub Actions |

## Documentação

- [Instalação passo a passo](docs/INSTALACAO.md)
- [Funções e limites](docs/FUNCIONALIDADES.md)
- [Arquitetura](docs/ARQUITETURA.md)
- [Protocolo cliente/servidor](docs/API.md)
- [Testes manuais](docs/TESTES.md)
- [Compatibilidade e limitações](docs/COMPATIBILIDADE.md)
- [Solução de problemas](docs/SOLUCAO_DE_PROBLEMAS.md)
- [Segurança](docs/SEGURANCA.md)
- [Investigação com REA + Codex](docs/REA_CODEX.md)
- [Publicação no GitHub](docs/PUBLICAR_NO_GITHUB.md)
- [Histórico de versões](CHANGELOG.md)
- [Plano de evolução](ROADMAP.md)
- [Contribuições](CONTRIBUTING.md)
- [Situação de licenciamento](LICENCA.md)

## Estado da validação

- Scripts e instalador foram empacotados e conferidos com testes estáticos automatizados.
- **Não foi realizado teste real de execução no Roblox Studio nesta sessão**; nenhum resultado em jogo deve ser considerado aprovado até validação manual.
- Não há persistência de progresso: os dados são zerados quando a sessão de teste termina.

## Comercialização

Você pode construir recursos originais e testar modelos de distribuição em projetos sob seu controle. Antes de vender, conclua testes em vários dispositivos, revise segurança, direitos autorais, documentação e licenciamento. Consulte [`LICENCA.md`](LICENCA.md) antes de publicar.
