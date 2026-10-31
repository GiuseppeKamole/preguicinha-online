#!/usr/bin/env python3
"""Gera o instalador Command Bar a partir dos fontes Luau."""
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
SERVER = ROOT / "src" / "SeaForgeServer.server.luau"
CLIENT = ROOT / "src" / "SeaForgeClient.client.luau"
OUTPUT = ROOT / "tools" / "INSTALAR_NO_STUDIO_CommandBar.lua"
def wrap(source: str, name: str) -> str:
    assert "]======]" not in source, f"Delimitador reservado no arquivo {name}"
    return "local " + name + " = [======[\n" + source.rstrip("\n") + "\n]======]\n"
def build() -> str:
    server = SERVER.read_text(encoding="utf-8")
    client = CLIENT.read_text(encoding="utf-8")
    header = """-- SeaForge Hub v0.3: instalador somente para Command Bar do Roblox Studio.
-- Abrir um lugar SEU no Studio; colar e executar TODO este arquivo na Command Bar.
-- Substitui os scripts chamados SeaForgeServer e SeaForgeClient, se ja existirem.
-- Nao usa executor, nao e um carregador para Blox Fruits.
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
"""
    footer = """local function install(parent, name, kind, source)
    local previous = parent:FindFirstChild(name)
    if previous then
        assert(previous.ClassName == kind, "Nome ocupado: " .. name)
        previous:Destroy()
    end
    local scriptObject = Instance.new(kind)
    scriptObject.Name = name
    scriptObject.Source = source
    scriptObject.Parent = parent
end
install(ServerScriptService, "SeaForgeServer", "Script", serverSource)
install(StarterPlayerScripts, "SeaForgeClient", "LocalScript", clientSource)
print("[SeaForge v0.3] Instalacao concluida. Use Play (F5) na SUA experiencia.")
"""
    return header + wrap(server, "serverSource") + wrap(client, "clientSource") + footer
if __name__ == "__main__":
    OUTPUT.write_text(build(), encoding="utf-8")
    print(f"Instalador atualizado: {OUTPUT}")
