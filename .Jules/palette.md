## 2024-03-22 - Add Tooltips to Icon Buttons
**Learning:** Found multiple instances of `IconButton` across different screens (`ai_posture_screen.dart`, `edit_profile_screen.dart`, `profile_screen.dart`) that lacked tooltips. In Flutter, adding a `tooltip` property to an `IconButton` not only displays a helpful text hint on long press/hover, but it also automatically provides a semantic label for screen readers. Some existing buttons (like in `growth_screen.dart`) correctly had them, but many did not.
**Action:** When adding or reviewing `IconButton`s in the future, always ensure a concise, descriptive `tooltip` is included to improve both general usability and accessibility.

## 2024-05-19 - Add Tooltips to custom Icon Buttons
**Learning:** Wrapping `GestureDetector` or `InkWell` custom icon-only buttons with `Tooltip` provides critical visual cues and semantic labels for screen readers. IconButton provides this built-in via `tooltip` but custom ones need explicit wrapping.
**Action:** Always wrap custom icon-only buttons with a `Tooltip` widget and provide descriptive localized strings or hardcoded fallbacks to improve micro-UX and accessibility.
