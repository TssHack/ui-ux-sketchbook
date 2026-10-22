// Run in the page (browser devtools or a browser tool's JS eval) at each test width.
// Lists elements that leave the viewport or overflow their own box, ignoring
// containers that scroll on purpose. Edit `skipSelectors` for your project.
(() => {
  const skipSelectors = ".carousel__track,.filters,.drawer,.sheet-menu,.sketch-defs,.sketch-box__ink,svg";
  const vw = document.documentElement.clientWidth;
  const name = (e) =>
    e.tagName.toLowerCase() +
    (typeof e.className === "string" && e.className ? "." + e.className.trim().split(/\s+/).slice(0, 2).join(".") : "") +
    (e.id ? "#" + e.id : "");
  const out = [];
  for (const e of document.querySelectorAll("body *")) {
    if (e.closest(skipSelectors)) continue;
    const r = e.getBoundingClientRect();
    if (!r.width) continue;
    if (r.right > vw + 1 || r.left < -1) out.push(`VIEWPORT ${name(e)} [${Math.round(r.left)},${Math.round(r.right)}]`);
    const cs = getComputedStyle(e);
    if (!["auto", "scroll"].includes(cs.overflowX) && e.scrollWidth > e.clientWidth + 2 && e.clientWidth > 0 && cs.display !== "inline")
      out.push(`CONTENT ${name(e)} scroll=${e.scrollWidth} box=${e.clientWidth}`);
  }
  return { vw, pageScrollWidth: document.documentElement.scrollWidth, issues: [...new Set(out)].slice(0, 40) };
})();
