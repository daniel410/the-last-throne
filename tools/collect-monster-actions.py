"""격리 Studio의 압축 캡처를 루프백에서 받고 프레임별 바이트를 기록한다."""
import argparse
import base64
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import subprocess
import tempfile
import threading
from uuid import uuid4
import xml.etree.ElementTree as ET

parser = argparse.ArgumentParser()
parser.add_argument('place', type=Path)
parser.add_argument('log', type=Path)
args = parser.parse_args()
rows = {}
endpoint = '/'+uuid4().hex


class FrameReceiver(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != endpoint:
            self.send_error(404)
            return
        size = int(self.headers.get('Content-Length', 0))
        if not 0 < size < 500000:
            self.send_error(400)
            return
        row = json.loads(self.rfile.read(size))
        key = (row['kind'], row['frame'])
        assert key not in rows
        base64.b64decode(row['data'], validate=True)
        rows[key] = row['data']
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'ok')

    def log_message(self, *args):
        pass


with ThreadingHTTPServer(('127.0.0.1', 0), FrameReceiver) as server, tempfile.TemporaryDirectory() as tmp:
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    script = Path(tmp)/'review.luau'
    url = 'http://127.0.0.1:'+str(server.server_port)+endpoint
    src = Path(__file__).with_name('capture-monster-actions.luau').read_text()
    # Enable localhost collection only on the disposable Place copy.
    tree = ET.parse(args.place)
    http = next((n for n in tree.getroot().findall('Item') if n.get('class') == 'HttpService'), None)
    if http is None:
        http = ET.SubElement(tree.getroot(), 'Item', {'class': 'HttpService', 'referent': 'CaptureHttp'})
        ET.SubElement(http, 'Properties')
    props = http.find('Properties')
    enabled = props.find("bool[@name='HttpEnabled']")
    if enabled is None:
        enabled = ET.SubElement(props, 'bool', {'name': 'HttpEnabled'})
    enabled.text = 'true'
    place = Path(tmp)/'capture.rbxlx'
    tree.write(place, encoding='utf-8')
    script.write_text('assert(game.PlaceId==0)\n_G.MonsterCaptureURL='+json.dumps(url)+'\n'+src)
    result = subprocess.run(['run-in-roblox', '--place', str(place), '--script', str(script)],
                            capture_output=True, text=True)
    server.shutdown()
    args.log.write_text(result.stdout+result.stderr)
    result.check_returncode()
    if 'MONSTER_CAPTURE_PASS' not in result.stdout or len(rows) != 96:
        raise RuntimeError(f'Studio capture incomplete ({len(rows)} frames). See {args.log}')
    with args.log.open('a') as stream:
        for (kind, frame), data in rows.items():
            stream.write(f'MONSTER_PIXELS {kind} {frame} {data}\n')
