"""Testes de consistencia dos arquivos; nao executam o Roblox Studio."""
import sys, unittest
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from gerar_instalador import build
class Tests(unittest.TestCase):
    def test_instalador(self):
        self.assertEqual((ROOT/"tools/INSTALAR_NO_STUDIO_CommandBar.lua").read_text(encoding="utf-8"),build())
    def test_scripts(self):
        s=(ROOT/"src/SeaForgeServer.server.luau").read_text(encoding="utf-8")
        c=(ROOT/"src/SeaForgeClient.client.luau").read_text(encoding="utf-8")
        self.assertIn("OnServerEvent:Connect",s)
        self.assertIn("OnClientEvent:Connect",c)
        self.assertIn("SeaForgeAction",s+c)
        self.assertNotIn("loadstring(",s+c)
    def test_docs(self):
        for path in ["README.md","docs/INSTALACAO.md","docs/TESTES.md","docs/COMPATIBILIDADE.md","docs/API.md","docs/SEGURANCA.md"]:
            self.assertTrue((ROOT/path).is_file(),path)
    def test_versions(self):
        for path in ["src/SeaForgeServer.server.luau","src/SeaForgeClient.client.luau"]:
            self.assertIn("v0.3",(ROOT/path).read_text(encoding="utf-8"))
if __name__=="__main__": unittest.main()
