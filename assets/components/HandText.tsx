import { rng } from "./rough";

/**
 * Latin lettering where every letter sits a little differently, like the
 * hand-printed titles in the sketch. Lines break only between words.
 * Not for Persian: splitting would break the letter joins.
 */
export function HandText({ text, seed = 1, className }: { text: string; seed?: number; className?: string }) {
  const r = rng(seed);
  const words = text.split(" ");
  return (
    <span className={`hand-text ${className ?? ""}`}>
      {/* Screen readers get one plain copy of the words: aria-label on a span is not read reliably */}
      <span className="visually-hidden">{text}</span>
      {words.map((word, w) => (
        <span key={w} className="hand-text__word" aria-hidden="true">
          {[...word].map((ch, i) => {
            const rot = (r() - 0.5) * 9;
            const dy = (r() - 0.5) * 0.12;
            const sc = 0.92 + r() * 0.16;
            return (
              <span key={i} style={{ transform: `translateY(${dy}em) rotate(${rot}deg) scale(${sc})` }}>
                {ch}
              </span>
            );
          })}
        </span>
      ))}
    </span>
  );
}
