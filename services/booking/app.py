import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.request import urlopen


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            status = 200
            data = {"status": "ok"}

        elif self.path == "/quote":
            try:
                with urlopen(
                    os.getenv("CATALOG_URL", "http://localhost:8000") + "/destinations",
                    timeout=3
                ) as response:
                    destinations = json.load(response)

                destination = destinations[0]

                status = 200
                data = {
                    "destination": destination["name"],
                    "price": destination["price"],
                    "message": "Travel quote received"
                }

            except (OSError, ValueError, IndexError, KeyError):
                status = 503
                data = {"error": "Catalog service unavailable"}

        else:
            status = 404
            data = {"error": "Page not found"}

        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())


print("Booking running on port 8001")
HTTPServer(("0.0.0.0", 8001), Handler).serve_forever()
