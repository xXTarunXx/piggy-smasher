import http.server
import socketserver
import os

PORT = 8000
DIRECTORY = "builds/web"

class CrossOriginIsolatedHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()

if __name__ == "__main__":
    if not os.path.exists(DIRECTORY):
        os.makedirs(DIRECTORY, exist_ok=True)
    
    with socketserver.TCPServer(("", PORT), CrossOriginIsolatedHandler) as httpd:
        print(f"Serving Godot Web build from '{DIRECTORY}' at http://localhost:{PORT}")
        print("Press Ctrl+C to stop the server.")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")
