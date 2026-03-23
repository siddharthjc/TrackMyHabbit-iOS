# Color

## Principles

- **Layer 1** primitives live in `tokens.css` as `--ds-*` and in Swift as `AppTheme.Neutral` / `AppTheme.Brand`.
- **Layer 2** semantic tokens are `--color-*` in CSS and `AppTheme.Colors` in Swift.
- Text uses a dark neutral (`--color-text`) on light surfaces; inverse text uses `--color-text-inverse`.

## Semantic groups

| Group | Tokens | Usage |
|-------|--------|--------|
| Text | `--color-text`, `--color-text-secondary`, `--color-text-disabled` | Body, supporting, placeholder |
| Surface | `--color-bg-primary`, `--color-bg-secondary`, `--color-bg-tertiary`, `--color-bg-splash` | Sheets, lists, splash |
| Brand | `--color-brand-primary`, `--color-brand-primary-light`, `--color-cta-*` | Accents, primary CTA gradients |
| System | `--color-link`, `--color-destructive` | Links, destructive actions |
| Selection | `--color-surface-selected` | Dropdown active row |
| Border | `--color-border-subtle`, `--color-border-card`, `--color-border-brand` | Dividers, cards, brand outlines |
| Shadow | `--color-shadow-neutral` | Neutral-tinted shadows |

## Interactive states

Documented in `tokens.css` as `--color-interactive-*` for future web; SwiftUI uses overlays and `ButtonStyle` where needed.

## Related

- [token-reference.md](../tokens/token-reference.md)
