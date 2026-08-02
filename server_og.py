#!/usr/bin/env python3
"""Servidor de Appod: sirve el build web + metadata OG dinámica.

- `/apod/YYYY-MM-DD` → HTML con og:image dinámico (la imagen de NASA de ese
  día). Los crawlers de WhatsApp/Telegram leen esta metadata para la preview;
  los humanos son redirigidos a la SPA con hash (`/#/apod/YYYY-MM-DD`).
- Cualquier otra ruta → archivos estáticos del build (SPA).

Uso: NASA_KEY=<key> python3 server_og.py [puerto] [dir_build]
"""
import json
import os
import re
import sys
import urllib.parse
import urllib.request
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8899
BUILD_DIR = Path(sys.argv[2]) if len(sys.argv) > 2 else Path(__file__).parent / "build" / "web"
NASA_KEY = os.environ.get("NASA_KEY", "")

APOD_RE = re.compile(r"^/apod/(\d{4}-\d{2}-\d{2})/?$")


def fetch_apod(date: str) -> dict | None:
    """Consulta la API de NASA para una fecha. Devuelve el APOD o None."""
    try:
        url = f"https://api.nasa.gov/planetary/apod?api_key={urllib.parse.quote(NASA_KEY)}&date={date}"
        req = urllib.request.Request(url, headers={"User-Agent": "Appod-OG/1.0"})
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read())
    except Exception:
        return None


def og_page(date: str) -> tuple[str, int]:
    """Genera HTML con OG tags para la fecha (preview con imagen de NASA)."""
    apod = fetch_apod(date)
    if apod is None:
        return (
            "<html><head><title>Appod</title></head><body>"
            "<p>No se pudo cargar el APOD de esta fecha.</p></body></html>",
            502,
        )
    title = apod.get("title", "Imagen del día de la NASA")
    media_type = apod.get("media_type", "image")
    image = apod.get("url", "")
    # Los videos de YouTube no sirven como og:image; usar thumbnail
    if media_type == "video" and "youtube" in image:
        vid = image.split("/embed/")[-1].split("?")[0]
        image = f"https://img.youtube.com/vi/{vid}/hqdefault.jpg"
    app_url = f"https://{os.environ.get('APP_HOST', 'localhost')}/#/apod/{date}"
    html = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8"/>
<title>Appod · {title}</title>
<meta property="og:title" content="Appod · {title}"/>
<meta property="og:description" content="La imagen astronómica del día de la NASA — {date}"/>
<meta property="og:type" content="article"/>
<meta property="og:image" content="{image}"/>
<meta property="og:url" content="{app_url}"/>
<meta name="twitter:card" content="summary_large_image"/>
<meta name="twitter:title" content="Appod · {title}"/>
<meta name="twitter:image" content="{image}"/>
<meta http-equiv="refresh" content="0; url={app_url}"/>
</head>
<body>
<p>Redirigiendo a Appod…</p>
</body>
</html>"""
    return html, 200


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(BUILD_DIR), **kwargs)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        m = APOD_RE.match(parsed.path)
        if m:
            date = m.group(1)
            html, code = og_page(date)
            self.send_response(code)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(html.encode())))
            self.end_headers()
            self.wfile.write(html.encode())
            return
        # SPA: rutas sin archivo real → index.html (hash routing)
        candidate = BUILD_DIR / parsed.path.lstrip("/")
        if parsed.path != "/" and not candidate.exists():
            self.path = "/index.html"
        super().do_GET()

    def log_message(self, fmt, *args):
        print(f"[og-server] {fmt % args}")


if __name__ == "__main__":
    if not NASA_KEY:
        print("AVISO: NASA_KEY no definida; las páginas OG devolverán 502.")
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    print(f"Serving {BUILD_DIR} en :{PORT} con OG dinámico")
    server.serve_forever()
