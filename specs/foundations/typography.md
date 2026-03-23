# Typography

## Families

| Role | Custom font | Token |
|------|-------------|--------|
| UI sans | Geist (`Geist-*`) | `--font-sans` |
| Display serif (marketing) | Season Mix trial | `--font-serif-display` |

Registered in `FontRegistration.swift`; use `customFont(_:size:lineHeight:tracking:)` or `textStyle(_:)`.

## Sizes (Layer 2)

| Token | Size | Typical use |
|-------|------|-------------|
| `--font-size-xs` | 12px | Meta labels |
| `--font-size-sm` | 14px | Secondary lines |
| `--font-size-md` | 16px | Body, buttons |
| `--font-size-lg` | 20px | Titles (nav) |
| `--font-size-xl` | 24px | Headlines, habit name |
| `--font-size-display` | 40px | Empty calendar placeholder icon scale |

Swift mirrors these as `AppTheme.Typography.Size.*`.

## Weights

Use `CustomFont` cases (`.medium`, `.semibold`, etc.) aligned with `--font-weight-*` in `tokens.css`.

## Related

- [token-reference.md](../tokens/token-reference.md)
- `Theme/Typography.swift`
