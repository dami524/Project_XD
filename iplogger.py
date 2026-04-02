from flask import Flask, jsonify
import geocoder
import requests
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import secrets
import json
import time
from urllib.parse import urlparse, parse_qs

app = Flask(__name__)

HOST = "127.0.0.1"
PORT = 5000
SECRET_KEY = "a9Gk3Pq7L1rT5zX"  # your 15-char secret

def valid_auth(headers):
    return headers.get("Authorization") == "CrossNet"

class PrivateHandler(BaseHTTPRequestHandler):

    def do_POST(self):
        # Protect Lua file
        if not valid_auth(self.headers):
            self.send_response(403)
            self.end_headers()
            return

        if self.path == f"/{SECRET_KEY}.lua":
            try:
                with open("iplogger.luau", "rb") as f:  # your Lua file
                    lua_code = f.read()
                self.send_response(200)
                self.send_header("Content-Type", "text/plain")
                self.end_headers()
                self.wfile.write(lua_code)
            except FileNotFoundError:
                self.send_response(404)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

    def do_GET(self):
        if self.path.startswith("/get_ip"):
            if not valid_auth(self.headers):
                self.send_response(403)
                self.end_headers()
                return

            # IPv4 from actual connection
            parsed = urlparse(self.path)
            params = parse_qs(parsed.query)

            # IPv4 sent from Lua
            client_ipv4 = params.get("ip", ["Not available"])[0]

            # Geo info from forwarded IP
            geo_ip = self.headers.get("X-Forwarded-For", client_ipv4).split(",")[0].strip()

            try:
                ip_data = requests.get(
                    f"http://ip-api.com/json/{geo_ip}?fields=status,country,regionName,city,zip,lat,lon,isp,proxy,query"
                ).json()

                if ip_data.get("status") != "success":
                    raise Exception("IP lookup failed")

                returned_ip = ip_data.get("query", "")
                ipv6 = returned_ip if ":" in returned_ip else "Not available"

                response = {
                    "ipv4": client_ipv4,
                    "ipv6": ipv6,
                    "city": ip_data.get("city"),
                    "region": ip_data.get("regionName"),
                    "country": ip_data.get("country"),
                    "zip": ip_data.get("zip"),
                    "lat": ip_data.get("lat"),
                    "lon": ip_data.get("lon"),
                    "isp": ip_data.get("isp"),
                    "proxy": ip_data.get("proxy", False)
                }

                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps(response).encode())

            except Exception as e:
                self.send_response(500)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({
                    "error": str(e)
                }).encode())
            return

        self.send_response(404)
        self.end_headers()

if __name__ == "__main__":
    server = ThreadingHTTPServer((HOST, PORT), PrivateHandler)
    server.serve_forever()