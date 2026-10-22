"""Check the skill and its manifests before anything is released.

Usage: python tools/validate.py [--tag vX.Y.Z]

Fails (exit 1) when:
  - SKILL.md frontmatter is missing, the name isn't kebab-case or doesn't match its folder,
    or the description is empty or longer than 1024 characters
  - a file SKILL.md points to (assets/…, references/…, scripts/…) doesn't exist
  - plugin.json and marketplace.json disagree on the plugin name, or plugin.json has no version
  - CHANGELOG.md has no section for the current version
  - --tag is given and doesn't equal "v" + the plugin.json version
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILL_DIR = ROOT / "skills" / "ui-ux-sketchbook"
errors: list[str] = []


def check(cond: bool, msg: str) -> None:
    if not cond:
        errors.append(msg)


def frontmatter(text: str) -> dict:
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        return {}
    out = {}
    for line in m.group(1).splitlines():
        if ":" in line and not line.startswith(" "):
            k, v = line.split(":", 1)
            out[k.strip()] = v.strip()
    return out


def main() -> None:
    skill_md = SKILL_DIR / "SKILL.md"
    check(skill_md.exists(), f"missing {skill_md.relative_to(ROOT)}")
    if not skill_md.exists():
        report()
    text = skill_md.read_text(encoding="utf-8")
    fm = frontmatter(text)
    name, desc = fm.get("name", ""), fm.get("description", "")
    check(bool(fm), "SKILL.md has no YAML frontmatter")
    check(bool(re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name)) and len(name) <= 64, f"skill name {name!r} must be kebab-case, max 64 chars")
    check(name == SKILL_DIR.name, f"skill name {name!r} must match its folder {SKILL_DIR.name!r}")
    check(0 < len(desc) <= 1024, f"description must be 1-1024 chars (is {len(desc)})")

    # Every asset/reference/script path the instructions mention must exist.
    mentioned = set(re.findall(r"`((?:assets|references|scripts)/[\w./-]+?\.\w+)`", text))
    for rel in sorted(mentioned):
        check((SKILL_DIR / rel).exists(), f"SKILL.md mentions {rel}, which doesn't exist")
    check(len(mentioned) >= 5, "SKILL.md should point to its bundled files")

    plugin = json.loads((ROOT / ".claude-plugin" / "plugin.json").read_text(encoding="utf-8"))
    market = json.loads((ROOT / ".claude-plugin" / "marketplace.json").read_text(encoding="utf-8"))
    version = plugin.get("version", "")
    check(bool(re.fullmatch(r"\d+\.\d+\.\d+", version)), f"plugin.json version {version!r} must be X.Y.Z")
    check(plugin.get("name") == name, "plugin.json name must equal the skill name")
    entries = [p for p in market.get("plugins", []) if p.get("name") == plugin.get("name")]
    check(len(entries) == 1, "marketplace.json must list the plugin exactly once by the same name")

    changelog = (ROOT / "CHANGELOG.md").read_text(encoding="utf-8") if (ROOT / "CHANGELOG.md").exists() else ""
    check(f"## [{version}]" in changelog, f"CHANGELOG.md has no '## [{version}]' section")

    if "--tag" in sys.argv:
        tag = sys.argv[sys.argv.index("--tag") + 1]
        check(tag == f"v{version}", f"tag {tag} doesn't match plugin.json version v{version}")

    print(f"skill: {name}  version: {version}  files checked: {len(mentioned)}")
    report()


def report() -> None:
    if errors:
        print("\n".join(f"ERROR: {e}" for e in errors))
        sys.exit(1)
    print("OK")


if __name__ == "__main__":
    main()
