from pathlib import Path
import yaml

registry = Path("registry/tools")
for file in sorted(registry.glob("*.yaml")):
    with open(file, "r", encoding="utf-8") as f:
        manifest = yaml.safe_load(f)
    print(f"Loaded: {manifest['id']}")
