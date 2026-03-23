#!/usr/bin/env python3
"""
Sésame Local Server — écoute sur localhost:8765
Reçoit les résultats des sessions HTML et met à jour progress.md
"""
import json
import os
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SESAME_DIR = os.path.join(BASE_DIR, "sesame-prep")
SESSIONS_DIR = os.path.join(SESAME_DIR, "sessions")
PROGRESS_FILE = os.path.join(SESAME_DIR, "progress.md")

os.makedirs(SESSIONS_DIR, exist_ok=True)


def update_progress(session: dict):
    """Met à jour progress.md avec les données de la session."""
    date = session.get("date", datetime.today().strftime("%Y-%m-%d"))
    matiere = session.get("matiere", "?")
    score = session.get("score", "?")
    total = session.get("total", "?")
    duration = session.get("duration_min", "?")
    weak_topics = session.get("weak_topics", [])
    weak_str = ", ".join(weak_topics) if weak_topics else "—"

    new_row = f"| {date} | {matiere} | {score}/{total} | {duration} min | {weak_str} |"

    with open(PROGRESS_FILE, "r", encoding="utf-8") as f:
        content = f.read()

    # Trouve la table "Semaine en cours" et insère la ligne
    marker = "| | | | | |"
    if marker in content:
        content = content.replace(marker, new_row + "\n" + marker, 1)
    else:
        # Ajoute à la fin de la table si le placeholder n'existe plus
        table_header = "| Date | Matière travaillée | Durée | Ressenti | Notes |"
        if table_header in content:
            idx = content.find(table_header)
            # Trouve la fin de la table
            lines = content[idx:].split("\n")
            insert_after = idx + len(lines[0]) + len(lines[1]) + 2
            content = content[:insert_after] + "\n" + new_row + content[insert_after:]

    # Met à jour la section matière spécifique
    matiere_section = f"### {matiere.split(' ')[0]}"  # ex: "Mathématiques"
    if matiere_section in content:
        # Met à jour "Dernière session"
        import re
        pattern = rf"({re.escape(matiere_section)}.*?- Dernière session :)[^\n]*"
        replacement = rf"\1 {date} — {score}/{total}"
        content = re.sub(pattern, replacement, content, flags=re.DOTALL, count=1)

        if weak_topics:
            pattern2 = rf"({re.escape(matiere_section)}.*?- À revoir :)[^\n]*"
            replacement2 = rf"\1 {weak_str}"
            content = re.sub(pattern2, replacement2, content, flags=re.DOTALL, count=1)

    with open(PROGRESS_FILE, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"[progress.md] Mis à jour — {matiere} {score}/{total} le {date}")


class SesameHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Supprime les logs HTTP verbeux
        pass

    def do_OPTIONS(self):
        self.send_response(200)
        self._cors_headers()
        self.end_headers()

    def _cors_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def do_GET(self):
        parsed = urlparse(self.path)

        if parsed.path == "/ping":
            self._json({"status": "ok"})

        elif parsed.path == "/sessions":
            sessions = []
            if os.path.isdir(SESSIONS_DIR):
                for fname in sorted(os.listdir(SESSIONS_DIR)):
                    if fname.endswith(".json"):
                        try:
                            with open(os.path.join(SESSIONS_DIR, fname), encoding="utf-8") as f:
                                sessions.append(json.load(f))
                        except Exception:
                            pass
            self._json(sessions)

        elif parsed.path == "/daily-exists":
            from urllib.parse import parse_qs
            params = parse_qs(parsed.query)
            date = params.get("date", [datetime.today().strftime("%Y-%m-%d")])[0]
            daily_file = os.path.join(SESAME_DIR, "daily", f"{date}.html")
            self._json({"exists": os.path.isfile(daily_file), "file": f"daily/{date}.html"})

        else:
            self.send_response(404)
            self.end_headers()

    def _json(self, data):
        body = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(200)
        self._cors_headers()
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        parsed = urlparse(self.path)

        if parsed.path == "/session":
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length)
            try:
                session = json.loads(body)
                date = session.get("date", datetime.today().strftime("%Y-%m-%d"))

                # Sauvegarde la session brute
                session_file = os.path.join(SESSIONS_DIR, f"{date}.json")
                with open(session_file, "w", encoding="utf-8") as f:
                    json.dump(session, f, ensure_ascii=False, indent=2)
                print(f"[session] Sauvegardée → sessions/{date}.json")

                # Met à jour progress.md
                update_progress(session)

                self.send_response(200)
                self._cors_headers()
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"ok": True}).encode())

            except Exception as e:
                print(f"[erreur] {e}")
                self.send_response(500)
                self._cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode())

        else:
            self.send_response(404)
            self.end_headers()


def main():
    port = 8765
    server = HTTPServer(("localhost", port), SesameHandler)
    print(f"Sésame Server démarré sur http://localhost:{port}")
    print(f"Workspace : {BASE_DIR}")
    print("En attente de résultats de session... (Ctrl+C pour arrêter)\n")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServeur arrêté.")


if __name__ == "__main__":
    main()
