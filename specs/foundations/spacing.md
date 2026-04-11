# Spacing

## Scale (8 steps)

| Token | Value | Swift |
|-------|------:|--------|
| `--space-1` | 4px | `AppTheme.Spacing.xs` |
| `--space-2` | 8px | `AppTheme.Spacing.sm` |
| `--space-3` | 12px | `AppTheme.Spacing.sm3` |
| `--space-4` | 16px | `AppTheme.Spacing.md` |
| `--space-5` | 20px | `AppTheme.Spacing.lg` |
| `--space-6` | 24px | `AppTheme.Spacing.xl` |
| `--space-7` | 32px | `AppTheme.Spacing.xl2` |
| `--space-8` | 40px | `AppTheme.Spacing.xxl` |

## Extended tokens

Larger or one-off layout values (`--space-9` … `--space-16`) map to `AppTheme.Spacing.*` extended names (e.g. `xxxl`, `sectionTop`, `dropdownOffsetTop`).

## Usage

- Prefer the **named semantic** spacing on `AppTheme.Spacing` when it matches a spec (e.g. screen horizontal padding).
- Use numeric scale tokens when aligning to the 4px grid only.

## Related

- [token-reference.md](../tokens/token-reference.md)
