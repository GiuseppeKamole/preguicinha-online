# Checklist de testes manuais

Execute em uma experiência de sua propriedade no Roblox Studio:

- [ ] Abrir Play sem erros no Output.
- [ ] Aparecer painel SeaForge e responder aos botões.
- [ ] Criar e exibir Porto, Floresta e Arena.
- [ ] Executar combate e conferir dano nos inimigos de teste.
- [ ] Iniciar e interromper Auto Farm sem travamentos.
- [ ] Selecionar uma missão de teste e receber recompensa.
- [ ] Iniciar raid e confirmar as condições de término.
- [ ] Coletar frutas de teste e verificar reaparecimento.
- [ ] Teleportar entre as ilhas de teste.
- [ ] Testar reinício do personagem e duas pessoas na mesma sessão.
- [ ] Repetir em dispositivo móvel usando o emulador do Studio.

Teste estático: `python -m unittest discover -s tests -v`.

**Não aprovado em produção:** testes estáticos não comprovam execução dentro do Roblox Studio.
