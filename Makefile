.PHONY: install dev test fmt lint smoke

install:
	python -m pip install -r requirements/dev.txt

dev:
	bash scripts/start_local_stack.sh

test:
	pytest tests

fmt:
	python -m black services tests scripts
	cargo fmt --all || true

lint:
	ruff check services tests scripts || true
	cargo clippy --workspace --all-targets || true

smoke:
	python scripts/smoke_test.py
