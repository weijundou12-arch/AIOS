#!/usr/bin/env bash
set -euo pipefail

uvicorn services.api_gateway.app.main:app --host 127.0.0.1 --port 8080 &
uvicorn services.planner_service.app.main:app --host 127.0.0.1 --port 8100 &
uvicorn services.model_router.app.main:app --host 127.0.0.1 --port 8110 &
uvicorn services.asr_service.app.main:app --host 127.0.0.1 --port 8130 &
uvicorn services.tts_service.app.main:app --host 127.0.0.1 --port 8140 &
uvicorn services.embedding_service.app.main:app --host 127.0.0.1 --port 8150 &
uvicorn services.rag_service.app.main:app --host 127.0.0.1 --port 8160 &
uvicorn services.session_service.app.main:app --host 127.0.0.1 --port 8190 &

echo "[AIOS] Local stack started."
echo "Remember to stop background processes manually or use stop_local_stack.sh."
