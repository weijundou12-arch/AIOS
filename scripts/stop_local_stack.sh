#!/usr/bin/env bash
set -euo pipefail
pkill -f "uvicorn services.api_gateway.app.main:app" || true
pkill -f "uvicorn services.planner_service.app.main:app" || true
pkill -f "uvicorn services.model_router.app.main:app" || true
pkill -f "uvicorn services.asr_service.app.main:app" || true
pkill -f "uvicorn services.tts_service.app.main:app" || true
pkill -f "uvicorn services.embedding_service.app.main:app" || true
pkill -f "uvicorn services.rag_service.app.main:app" || true
pkill -f "uvicorn services.session_service.app.main:app" || true
echo "[AIOS] Requested local stack shutdown."
