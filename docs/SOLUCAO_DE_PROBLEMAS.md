# Solução de problemas

**Interface não aparece:** verifique `StarterPlayerScripts.SeaForgeClient`, `ReplicatedStorage.SeaForgeAction` e mensagens da aba Output.

**Mundo não aparece:** confirme `ServerScriptService.SeaForgeServer` e execute Play, não apenas Run em uma janela sem personagem.

**Instalador falha:** execute na Command Bar do Roblox Studio, não no PowerShell ou no executor de jogo. Verifique se os scripts com os nomes de instalação têm os tipos esperados.

**Github Actions falhou:** execute `python tools/gerar_instalador.py` e depois `python -m unittest discover -s tests -v` antes de enviar alterações.
