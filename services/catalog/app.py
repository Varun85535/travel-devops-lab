import json
from http.server import BaseHTTPRequestHandler, HTTPServer

destinations = [
    {"id": 1, "name": "Bengaluru", "price": 2500},
    {"id": 2, "name": "Mysuru", "price": 1800},
    {"id": 3, "name": "Goa", "price": 5000}
]


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/destinations":
            data = destinations
            status = 200
        elif self.path == "/health":
            data = {"status": "ok"}
            status = 200
        else:
            data = {"error": "Page not found"}
            status = 404

        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())


print("Catalog running on port 8000")
HTTPServer(("0.0.0.0", 8000), Handler).serve_forever()
