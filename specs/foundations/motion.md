# Motion

## Durations (`--duration-*`)

| Token | Seconds | Usage |
|-------|--------:|--------|
| `--duration-instant` | 0.1 | Micro press, frequency scale |
| `--duration-fast` | 0.18 | Bottom sheet, CTA spring-adjacent |
| `--duration-normal` | 0.25 | Tab / dropdown |
| `--duration-medium` | 0.3 | Frequency inline spring |
| `--duration-slow` | 0.4 | Splash dismiss |
| `--duration-emphasis` | 0.45 | Carousel settle |
| `--duration-reveal` | 0.5 | Splash tagline |
| `--duration-splash` | 0.6 | Delay before tagline |

## Springs

Spring parameters are tokenized for the main repeated patterns (CTA button, frequency row, splash logo, carousel). See `AppTheme.Motion` in Swift.

## Related

- [token-reference.md](../tokens/token-reference.md)
