import datetime
import json
import os
import urllib.request
from http.server import BaseHTTPRequestHandler, HTTPServer

DISCORD_WEBHOOK_URL = os.getenv("DISCORD_WEBHOOK_URL", "")
ALLOWED_SERVICES = {
    "auth-service": 8001,
    "flag-service": 8002,
    "targeting-service": 8003,
    "evaluation-service": 8004,
    "analytics-service": 8005,
}


def log_json(level, event, **kwargs):
    entry = {
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "level": level,
        "service": "self-healing-webhook",
        "event": event,
    }
    entry.update(kwargs)
    print(json.dumps(entry), flush=True)


def reset_chaos_endpoint(service_name):
    port = ALLOWED_SERVICES.get(service_name)
    if not port:
        return "unknown_service_port"
    url = f"http://{service_name}:{port}/chaos/fail?enable=false"
    try:
        req = urllib.request.Request(url, method="POST")
        with urllib.request.urlopen(req, timeout=3) as resp:
            if resp.status < 300:
                return f"Chaos mode reset via {url} (HTTP {resp.status})"
    except Exception as exc:
        return f"chaos_reset_error: {exc}"
    return "chaos_endpoint_unreachable"


class SelfHealingHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok", "service": "self-healing-webhook"}).encode("utf-8"))
            return
        self.send_response(404)
        self.end_headers()

    def do_POST(self):
        if not self.path.startswith("/webhook/self-heal"):
            self.send_response(404)
            self.end_headers()
            return

        content_len = int(self.headers.get("Content-Length", 0))
        raw_body = self.rfile.read(content_len).decode("utf-8") if content_len > 0 else "{}"
        try:
            payload = json.loads(raw_body)
        except Exception:
            payload = {}

        alerts = payload.get("alerts", [])
        target_services = set()
        for alert in alerts:
            status = alert.get("status", payload.get("status", "firing"))
            labels = alert.get("labels", {})
            svc = labels.get("service") or labels.get("service_name") or labels.get("deployment")
            if status == "firing" and svc in ALLOWED_SERVICES:
                target_services.add(svc)

        if not target_services and payload.get("service") in ALLOWED_SERVICES:
            target_services.add(payload["service"])

        remediated = []
        for svc in target_services:
            log_json("WARN", "self_healing_triggered", target_service=svc)
            res = reset_chaos_endpoint(svc)
            log_json("INFO", "self_healing_completed", target_service=svc, detail=res)
            remediated.append({"service": svc, "result": res})

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({"status": "processed", "remediated": remediated}).encode("utf-8"))

    def log_message(self, format, *args):
        return


if __name__ == "__main__":
    port = int(os.getenv("PORT", "8090"))
    log_json("INFO", "self_healing_webhook_started", port=port)
    HTTPServer(("0.0.0.0", port), SelfHealingHandler).serve_forever()
