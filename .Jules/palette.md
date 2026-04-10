## 2024-03-22 - Add Tooltips to Icon Buttons
**Learning:** Found multiple instances of `IconButton` across different screens (`ai_posture_screen.dart`, `edit_profile_screen.dart`, `profile_screen.dart`) that lacked tooltips. In Flutter, adding a `tooltip` property to an `IconButton` not only displays a helpful text hint on long press/hover, but it also automatically provides a semantic label for screen readers. Some existing buttons (like in `growth_screen.dart`) correctly had them, but many did not.
**Action:** When adding or reviewing `IconButton`s in the future, always ensure a concise, descriptive `tooltip` is included to improve both general usability and accessibility.

## 2024-04-09 - Custom Icon Button Tooltips
**Learning:** Custom icon buttons (those built using `GestureDetector` instead of `IconButton`) lack native tooltips. In Flutter, `Tooltip` widgets act as ARIA labels for screen readers. Using `Tooltip` around `GestureDetector` that wrap `Icon` is a simple micro-UX win that significantly improves accessibility.
**Action:** Always verify if `GestureDetector` wrappers around icons lack `Tooltip`, and wrap them to provide both a visual hint and an accessible screen reader label.
