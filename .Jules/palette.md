## 2024-03-22 - Add Tooltips to Icon Buttons
**Learning:** Found multiple instances of `IconButton` across different screens (`ai_posture_screen.dart`, `edit_profile_screen.dart`, `profile_screen.dart`) that lacked tooltips. In Flutter, adding a `tooltip` property to an `IconButton` not only displays a helpful text hint on long press/hover, but it also automatically provides a semantic label for screen readers. Some existing buttons (like in `growth_screen.dart`) correctly had them, but many did not.
**Action:** When adding or reviewing `IconButton`s in the future, always ensure a concise, descriptive `tooltip` is included to improve both general usability and accessibility.

## 2026-03-28 - Custom IconButtons Require Tooltips
**Learning:** While Flutter's standard `IconButton` widget takes a `tooltip` parameter and automatically sets up semantic labels, custom icon buttons created using `GestureDetector` or `InkWell` wrapped around an `Icon` or `Container` do not automatically provide any accessibility semantics. Found this pattern in `plan_screen.dart` (`_headerBtn`) where the custom buttons lacked screen reader context.
**Action:** Always wrap custom icon buttons (`GestureDetector` + `Icon`) with a `Tooltip(message: '...')` widget. This provides both visual hover/long-press hints and critical screen reader semantic labels.
