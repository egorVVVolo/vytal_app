## 2024-03-22 - Add Tooltips to Icon Buttons
**Learning:** Found multiple instances of `IconButton` across different screens (`ai_posture_screen.dart`, `edit_profile_screen.dart`, `profile_screen.dart`) that lacked tooltips. In Flutter, adding a `tooltip` property to an `IconButton` not only displays a helpful text hint on long press/hover, but it also automatically provides a semantic label for screen readers. Some existing buttons (like in `growth_screen.dart`) correctly had them, but many did not.
**Action:** When adding or reviewing `IconButton`s in the future, always ensure a concise, descriptive `tooltip` is included to improve both general usability and accessibility.

## 2026-04-03 - Add Tooltips to Custom Icon Buttons
**Learning:** Discovered that custom icon buttons constructed using `GestureDetector` or `InkWell` around an `Icon` (like the notifications button in `dashboard_screen.dart`) lack inherent accessibility labels and visual hints compared to standard `IconButton`s.
**Action:** Always wrap custom icon-only buttons built with `GestureDetector` or `InkWell` in a `Tooltip` widget. This ensures they provide both a visual cue on hover/long-press and a semantic label for screen readers.
