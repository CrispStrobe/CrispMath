"""Local HTTP contract fixture, not an AI model. Used only by browser tests."""
import argparse
import json
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

requests = []
class Handler(BaseHTTPRequestHandler):
    def reply(self, status, data):
        encoded = json.dumps(data).encode()
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.send_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.send_header('Content-Length', str(len(encoded)))
        self.end_headers()
        try:
            self.wfile.write(encoded)
        except (BrokenPipeError, ConnectionResetError):
            pass
    def do_OPTIONS(self):
        self.reply(200, {})
    def do_GET(self):
        self.reply(200, requests)
    def do_POST(self):
        body = json.loads(self.rfile.read(int(self.headers['Content-Length'])))
        requests.append(body)
        if body.get('model') != 'browser-contract-fixture' or self.headers.get('Authorization') != 'Bearer fixture-key':
            self.reply(401, {'error': 'Unexpected test configuration'})
            return
        question = body['messages'][-1]['content']
        if question == 'simulate failure':
            self.reply(503, {'error': 'Deliberate test failure'})
            return
        if question == 'slow request':
            time.sleep(4)
        expressions = {'two plus two': '2+2', 'five plus seven': '5+7', 'slow request': '1+1'}
        self.reply(200, {'choices': [{'message': {'content': expressions.get(question, 'unknown_request')}}]})

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--port', type=int, default=8769)
    args = parser.parse_args()
    ThreadingHTTPServer(('127.0.0.1', args.port), Handler).serve_forever()
