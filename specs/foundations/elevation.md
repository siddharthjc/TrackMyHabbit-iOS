# Elevation & shadow

Shadows are expressed in `tokens.css` as logical blur, Y offset, and opacity. SwiftUI applies them via `AppTheme.Elevation` (`ShadowToken`) and `.appShadow(_:)`.

| Token name | Role |
|------------|------|
| Sheet / bottom sheet | `--shadow-sheet-*` — soft lift under rounded sheet |
| Floating circular actions | `--shadow-floating-*` — nav icon circles |
| Cards (day stack) | `--shadow-card-*` — active vs inactive depth |
| CTA (empty state) | `--shadow-cta-*` — tight outer shadow |
| Liquid glass bar | `--shadow-glass-*` — dark + light rim |
| Photo label on card | `--shadow-photo-label-*` — text legibility |

Shadow **color** generally uses `--color-shadow-neutral` (`#5E5E72` family).

## Related

- `AppTheme.swift` — `Elevation`
- [token-reference.md](../tokens/token-reference.md)
