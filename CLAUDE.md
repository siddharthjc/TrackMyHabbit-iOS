# TrackMyHabbit — AI / contributor notes

## UI and design system

This app is **SwiftUI** on iOS. Visual design tokens are documented in `tokens.css` (CSS variables for LLM and cross-platform reference) and implemented at runtime in `TrackMyHabbit/TrackMyHabbit/Theme/AppTheme.swift`.

**Before writing or modifying any UI code:**

1. Read the relevant spec under `specs/components/` (and `specs/foundations/` when changing tokens).
2. Use only tokens from `AppTheme` (mirrors Layer 2 in `tokens.css`). Do not introduce raw hex colors, ad-hoc spacing, or magic numbers in views — add or reuse a semantic token in `AppTheme` first.
3. Run the token audit before committing:

   ```bash
   node scripts/token-audit.js
   ```

   **Zero errors required** (warnings should be addressed when touching those lines).

## Spec index

- Foundations: `specs/foundations/`
- Token map: `specs/tokens/token-reference.md`
- Step 1 audit (Swift inventory): `specs/audit/step-1-audit.md`
