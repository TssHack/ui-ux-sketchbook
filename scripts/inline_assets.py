"""Inline local stylesheets and scripts into one self-contained HTML file.

Usage: python inline_assets.py page.html out.html

Every <link rel="stylesheet" href="local.css"> becomes <style>…</style> and every
<script src="local.js"></script> becomes <script>…</script>, resolved relative to
page.html. Remote URLs (https://, //) such as Google Fonts are left as they are.
"""
import re
import sys
from pathlib import Path


def is_local(ref: str) -> bool:
    return not re.match(r"^(?:[a-z]+:)?//|^data:", ref, re.I)


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    src = Path(sys.argv[1])
    base = src.parent
    html = src.read_text(encoding="utf-8")

    def css(m: re.Match) -> str:
        href = m.group(1)
        if not is_local(href):
            return m.group(0)
        return "<style>\n" + (base / href).read_text(encoding="utf-8") + "\n</style>"

    def js(m: re.Match) -> str:
        ref = m.group(1)
        if not is_local(ref):
            return m.group(0)
        code = (base / ref).read_text(encoding="utf-8").replace("</script", "<\\/script")
        return "<script>\n" + code + "\n</script>"

    html = re.sub(r'<link\s+rel="stylesheet"\s+href="([^"]+)"\s*/?>', css, html)
    html = re.sub(r'<script\s+src="([^"]+)"\s*>\s*</script>', js, html)
    left = [r for r in re.findall(r'(?:href|src)="([^"]+\.(?:css|js))"', html) if is_local(r)]
    Path(sys.argv[2]).write_text(html, encoding="utf-8")
    print(f"wrote {sys.argv[2]} ({len(html) // 1024} KB)" + (f"; still local: {left}" if left else ""))


if __name__ == "__main__":
    main()
