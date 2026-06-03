#!/usr/bin/env bash
# Default container CMD: backend :3012 + Flutter Web :5182 + reverse proxy :5173.
set -euo pipefail

SESSION_BACKEND=backend-dev
tmux kill-session -t "${SESSION_BACKEND}" 2>/dev/null || true
tmux new-session -d -s "${SESSION_BACKEND}" \
  "cd /app/backend && exec npm start"

echo '[dev] Waiting for backend :3012/health ...'
ready=0
for _ in $(seq 1 45); do
  if curl -sf --max-time 1 "http://127.0.0.1:3012/health" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 1
done
if [ "${ready}" -ne 1 ]; then
  echo '[dev] ERROR: backend did not become healthy on :3012 (check tmux attach -t backend-dev)' >&2
  exit 1
fi
echo '[dev] Backend is up.'

cd /app/mobile
flutter pub get

SESSION_PROXY=web-proxy
tmux kill-session -t "${SESSION_PROXY}" 2>/dev/null || true
tmux new-session -d -s "${SESSION_PROXY}" \
  "exec node /app/scripts/web-proxy.js"

SESSION=flutter-dev
tmux kill-session -t "${SESSION}" 2>/dev/null || true
tmux new-session -d -s "${SESSION}" \
  "cd /app/mobile && exec flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5182 --host-vmservice-port 8181"

printf '%s\n' \
  '[dev] Backend API in tmux session: backend-dev  (container :3012, host map 8800:3012)' \
  '[dev] Web reverse proxy in tmux session: web-proxy  (container :5173, host map 8811:5173)' \
  '[dev] Proxy routes:  /  + assets + ws  -> flutter :5182 (127.0.0.1 only)' \
  '[dev] Proxy routes:  /api + /health   -> backend :3012' \
  '[dev] Browser entry (env-1): http://localhost:8811/  (App + API same origin)' \
  '[dev] Do NOT open Flutter :5182 directly; use :5173 proxy only' \
  '[dev] Demo login: 13800138000 / 123456' \
  '[dev] Flutter internal in tmux session: flutter-dev  (:5182, not exposed to host)' \
  '[dev] Attach backend:  tmux attach -t backend-dev' \
  '[dev] Attach proxy:    tmux attach -t web-proxy' \
  '[dev] Attach flutter:  tmux attach -t flutter-dev  (r=reload, R=restart, q=quit)' \
  '[dev] Detach tmux without stopping:  Ctrl+b then d' \
  '[dev] Foreground flutter:  /app/scripts/dev-web.sh' \
  '[dev] Interactive flutter: /app/scripts/flutter-run-web.sh  (API -> :3012, open printed URL)' \
  '[dev] Foreground backend:  /app/scripts/dev-backend.sh'
