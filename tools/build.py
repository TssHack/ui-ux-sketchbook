"""Build release packages and the demo site.

Usage: python tools/build.py [package|site|all]   (default: all)

package -> dist/
  ui-ux-sketchbook.zip      skill folder, for install.ps1 and manual installs
  ui-ux-sketchbook.tar.gz   same, for install.sh
  ui-ux-sketchbook.skill    same zip under the .skill name some agents import directly
  SHA256SUMS
site -> site/
  index.html                the café demo, inlined into one file
  starter/index.html        the bare starter, inlined
"""
import hashlib
import io
import re
import subprocess
import sys
import tarfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
NAME = "ui-ux-sketchbook"
SKILL = ROOT / "skills" / NAME
DIST = ROOT / "dist"
SITE = ROOT / "site"
SKIP = {"__pycache__", ".DS_Store"}


def skill_files():
    for f in sorted(SKILL.rglob("*")):
        if f.is_file() and not SKIP.intersection(f.parts):
            yield f, f"{NAME}/{f.relative_to(SKILL).as_posix()}"


def package() -> None:
    DIST.mkdir(exist_ok=True)
    zbuf = io.BytesIO()
    with zipfile.ZipFile(zbuf, "w", zipfile.ZIP_DEFLATED) as z:
        for f, arc in skill_files():
            # Fixed timestamps so the same sources always give the same archive
            info = zipfile.ZipInfo(arc, date_time=(2026, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            z.writestr(info, f.read_bytes())
    for out in (f"{NAME}.zip", f"{NAME}.skill"):
        (DIST / out).write_bytes(zbuf.getvalue())

    with tarfile.open(DIST / f"{NAME}.tar.gz", "w:gz") as t:
        for f, arc in skill_files():
            info = tarfile.TarInfo(arc)
            data = f.read_bytes()
            info.size, info.mode, info.mtime = len(data), 0o644, 1767225600
            t.addfile(info, io.BytesIO(data))

    sums = []
    for p in sorted(DIST.iterdir()):
        if p.name != "SHA256SUMS":
            sums.append(f"{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.name}")
    (DIST / "SHA256SUMS").write_text("\n".join(sums) + "\n", encoding="utf-8")
    print("\n".join(sums))


def site() -> None:
    inline = SKILL / "scripts" / "inline_assets.py"
    (SITE / "starter").mkdir(parents=True, exist_ok=True)
    jobs = [
        (ROOT / "examples" / "cafe" / "index.html", SITE / "index.html"),
        (SKILL / "assets" / "vanilla" / "starter.html", SITE / "starter" / "index.html"),
    ]
    for src, out in jobs:
        # The starter links sketch.css next to itself; give it a copy so it inlines from one folder.
        if src.name == "starter.html":
            css = src.parent / "sketch.css"
            css.write_text((SKILL / "assets" / "sketch.css").read_text(encoding="utf-8"), encoding="utf-8")
            try:
                subprocess.run([sys.executable, str(inline), str(src), str(out)], check=True)
            finally:
                css.unlink()
        else:
            subprocess.run([sys.executable, str(inline), str(src), str(out)], check=True)
        html = out.read_text(encoding="utf-8")
        left = re.findall(r'<(?:script\s+src|link\s+rel="stylesheet"\s+href)="(?!https?://)([^"]+)"', html)
        if left:
            sys.exit(f"local files still linked from {out.relative_to(ROOT)}: {left}")
    (SITE / ".nojekyll").write_text("", encoding="utf-8")


if __name__ == "__main__":
    what = sys.argv[1] if len(sys.argv) > 1 else "all"
    if what in ("package", "all"):
        package()
    if what in ("site", "all"):
        site()
