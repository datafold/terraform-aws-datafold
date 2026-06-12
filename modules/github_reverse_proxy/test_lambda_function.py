"""Tests for lambda_function.py — run with `python -m unittest`.

Stdlib-only (unittest + http.server): spins up a local HTTP server that
captures the forwarded request, then invokes lambda_handler the way API
Gateway does. Verifies the body GitHub signed is forwarded byte-identical
so the downstream X-Hub-Signature-256 HMAC check passes, for both the
plain-text and the isBase64Encoded event shapes.

Regression context: non-ASCII characters (em-dash, smart quotes, emoji)
in PR titles/descriptions crashed the handler under urllib3 1.x (the
Datadog Lambda layer ships 1.26.x), surfacing as API Gateway 502s on
single-tenant deployments. To exercise that exact failure mode, run this
suite under urllib3 1.26.x as well as 2.x.
"""
import base64
import hashlib
import hmac
import http.server
import json
import os
import sys
import threading
import unittest

WEBHOOK_SECRET = b"test-webhook-secret"

_captured = {}


class _CapturingHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        _captured["body"] = self.rfile.read(length)
        _captured["headers"] = dict(self.headers)
        self.send_response(200)
        self.send_header("Content-Length", "2")
        self.end_headers()
        self.wfile.write(b"ok")

    def log_message(self, *args):
        pass


_server = http.server.HTTPServer(("127.0.0.1", 0), _CapturingHandler)
threading.Thread(target=_server.serve_forever, daemon=True).start()

# lambda_handler reads PRIVATE_SYSTEM_ENDPOINT via os.getenv at call time,
# but set it before import to mirror the Lambda environment.
os.environ["PRIVATE_SYSTEM_ENDPOINT"] = (
    f"http://127.0.0.1:{_server.server_address[1]}/integrations/github/v1/app_hook"
)

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lambda_function  # noqa: E402


def _github_payload():
    """A webhook payload with non-ASCII characters typical of AI-written PRs."""
    payload = {
        "action": "opened",
        "pull_request": {
            "title": "Fix data sync — handle “smart quotes” and emoji \U0001f680",
            "body": "AI-generated description — it’s typical now",
        },
    }
    return json.dumps(payload, ensure_ascii=False).encode("utf-8")


def _sign(body_bytes):
    return "sha256=" + hmac.new(WEBHOOK_SECRET, body_bytes, hashlib.sha256).hexdigest()


class LambdaHandlerTest(unittest.TestCase):
    def setUp(self):
        _captured.clear()
        self.payload_bytes = _github_payload()
        self.headers = {
            "Content-Type": "application/json",
            "Content-Length": str(len(self.payload_bytes)),
            "X-Hub-Signature-256": _sign(self.payload_bytes),
            "X-GitHub-Event": "pull_request",
        }

    def _assert_forwarded_intact(self, result):
        self.assertEqual(result["statusCode"], 200)
        received = _captured["body"]
        self.assertEqual(received, self.payload_bytes)
        self.assertTrue(
            hmac.compare_digest(_sign(received), self.headers["X-Hub-Signature-256"])
        )

    def test_text_event_with_non_ascii_body(self):
        event = {
            "body": self.payload_bytes.decode("utf-8"),
            "isBase64Encoded": False,
            "headers": self.headers,
        }
        self._assert_forwarded_intact(lambda_function.lambda_handler(event, None))

    def test_base64_encoded_event(self):
        event = {
            "body": base64.b64encode(self.payload_bytes).decode("ascii"),
            "isBase64Encoded": True,
            "headers": self.headers,
        }
        self._assert_forwarded_intact(lambda_function.lambda_handler(event, None))

    def test_empty_body_returns_400(self):
        event = {"body": "", "isBase64Encoded": False, "headers": {}}
        result = lambda_function.lambda_handler(event, None)
        self.assertEqual(result["statusCode"], 400)


if __name__ == "__main__":
    unittest.main()
