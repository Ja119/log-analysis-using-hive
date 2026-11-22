#!/usr/bin/env python3
import os
from datetime import datetime
from http.server import HTTPServer, SimpleHTTPRequestHandler

PORT = 8080
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LOG_FILE = os.path.join(BASE_DIR, "..", "data", "sample_access.log")

class AccessLoggingHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BASE_DIR, **kwargs)

    def log_message(self, format, *args):
        pass  # Suppress default console logs

    def end_headers(self):
        super().end_headers()
        client_ip = self.client_address[0]
        now = datetime.now().strftime("%d/%b/%Y:%H:%M:%S +0000")
        request_line = getattr(self, "requestline", f"GET {self.path} HTTP/1.1")
        status_code = getattr(self, "response_code", 200)
        content_length = self.headers.get("Content-Length", "4523")
        referer = self.headers.get("Referer", "-")
        user_agent = self.headers.get("User-Agent", "Mozilla/5.0")

        # Apache/Nginx Combined Log format:
        log_entry = f'{client_ip} - - [{now}] "{request_line}" {status_code} {content_length} "{referer}" "{user_agent}"\n'

        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(log_entry)
        print(f"[LOGGED] {log_entry.strip()}")

    def do_POST(self):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        response = b'{"status": "success", "message": "Item added to cart"}'
        self.send_header("Content-Length", str(len(response)))
        self.end_headers()
        self.wfile.write(response)

if __name__ == "__main__":
    print(f"Server running at http://localhost:{PORT}")
    HTTPServer(("", PORT), AccessLoggingHandler).serve_forever()