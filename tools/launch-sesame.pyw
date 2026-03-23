"""
Sésame Launcher — double-clic pour tout démarrer
- Lance sesame-server.py (si pas déjà actif)
- Ouvre le hub dans le navigateur
"""
import os
import subprocess
import urllib.request
import time

# ─── CHEMINS ────────────────────────────────────────────────────────────────
BASE_DIR   = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SESAME_DIR = os.path.join(BASE_DIR, "sesame-prep")
SERVER_PY  = os.path.join(BASE_DIR, "tools", "sesame-server.py")
PORT = 8765


def server_already_running():
    try:
        urllib.request.urlopen(f"http://localhost:{PORT}/ping", timeout=1)
        return True
    except:
        return False


# ─── LANCEUR ────────────────────────────────────────────────────────────────
def main():
    # 1. Démarre sesame-server.py si pas déjà actif
    if not server_already_running():
        subprocess.Popen(
            ["python", SERVER_PY],
            cwd=BASE_DIR,
            creationflags=subprocess.CREATE_NO_WINDOW
        )
        # Attendre que le serveur soit prêt
        for _ in range(10):
            time.sleep(0.5)
            if server_already_running():
                break

    # 2. Ouvre le tableau de bord (hub)
    hub_path = os.path.join(SESAME_DIR, "hub.html")
    os.startfile(hub_path)

    # 3. Garde le processus vivant
    while True:
        time.sleep(60)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        import traceback
        log_path = os.path.join(BASE_DIR, "launch-error.log")
        with open(log_path, "w", encoding="utf-8") as f:
            traceback.print_exc(file=f)
        import tkinter as tk
        from tkinter import messagebox
        root = tk.Tk(); root.withdraw()
        messagebox.showerror("Sésame — Erreur critique", f"{e}\n\nVoir launch-error.log")
        root.destroy()
