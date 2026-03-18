
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def main() -> None:
    required = [
        ROOT / "README.md",
        ROOT / "registry/tools/fs.merge_pdf.yaml",
        ROOT / "services/api_gateway/app/main.py",
        ROOT / "services/planner_service/app/main.py",
        ROOT / "crates/tool-executor/src/main.rs",
    ]
    missing = [str(p.relative_to(ROOT)) for p in required if not p.exists()]
    if missing:
        raise SystemExit("Missing files: " + json.dumps(missing))
    print("AIOS smoke test passed.")

if __name__ == "__main__":
    main()
