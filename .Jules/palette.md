## 2024-05-24 - Semantic Labeling for Custom Gesture Buttons
**Learning:** Custom icon buttons built with `GestureDetector` lack semantic labeling out-of-the-box in this app. Screen readers and users hovering over these buttons will not receive any context or description of their function.
**Action:** Always wrap `GestureDetector` and `InkWell` elements that function as icon-only buttons in a `Tooltip` widget with an appropriate descriptive `message` to provide semantic labeling and improve accessibility.
## 2024-03-22 - Add Tooltips to Icon Buttons
**Learning:** Found multiple instances of `IconButton` across different screens (`ai_posture_screen.dart`, `edit_profile_screen.dart`, `profile_screen.dart`) that lacked tooltips. In Flutter, adding a `tooltip` property to an `IconButton` not only displays a helpful text hint on long press/hover, but it also automatically provides a semantic label for screen readers. Some existing buttons (like in `growth_screen.dart`) correctly had them, but many did not.
**Action:** When adding or reviewing `IconButton`s in the future, always ensure a concise, descriptive `tooltip` is included to improve both general usability and accessibility.

## 2024-05-19 - Add Tooltips to custom Icon Buttons
**Learning:** Wrapping `GestureDetector` or `InkWell` custom icon-only buttons with `Tooltip` provides critical visual cues and semantic labels for screen readers. IconButton provides this built-in via `tooltip` but custom ones need explicit wrapping.
**Action:** Always wrap custom icon-only buttons with a `Tooltip` widget and provide descriptive localized strings or hardcoded fallbacks to improve micro-UX and accessibility.
## 2026-03-28 - Custom IconButtons Require Tooltips
**Learning:** While Flutter's standard `IconButton` widget takes a `tooltip` parameter and automatically sets up semantic labels, custom icon buttons created using `GestureDetector` or `InkWell` wrapped around an `Icon` or `Container` do not automatically provide any accessibility semantics. Found this pattern in `plan_screen.dart` (`_headerBtn`) where the custom buttons lacked screen reader context.
**Action:** Always wrap custom icon buttons (`GestureDetector` + `Icon`) with a `Tooltip(message: '...')` widget. This provides both visual hover/long-press hints and critical screen reader semantic labels.
## 2024-04-01 - Wrap Custom Gestures in Tooltips
**Learning:** Found multiple instances of custom icon buttons built using `GestureDetector` (e.g., `_headerBtn` in `plan_screen.dart`, `_DeviceTile` in `profile_screen.dart`, `_buildPickerCard` in `edit_profile_screen.dart`) that did not have any explicit ARIA-like labels for screen readers. While native `IconButton`s support a `tooltip` property directly, custom widgets do not natively expose themselves well without additional wrapping.
**Action:** When creating custom interactive icons or elements wrapped with `GestureDetector` or `InkWell`, always wrap them with a `Tooltip` widget. This displays a helpful text hint on long press/hover, and automatically provides a semantic label for screen readers.
## 2026-04-03 - Add Tooltips to Custom Icon Buttons
**Learning:** Discovered that custom icon buttons constructed using `GestureDetector` or `InkWell` around an `Icon` (like the notifications button in `dashboard_screen.dart`) lack inherent accessibility labels and visual hints compared to standard `IconButton`s.
**Action:** Always wrap custom icon-only buttons built with `GestureDetector` or `InkWell` in a `Tooltip` widget. This ensures they provide both a visual cue on hover/long-press and a semantic label for screen readers.
## 2024-04-09 - Custom Icon Button Tooltips
**Learning:** Custom icon buttons (those built using `GestureDetector` instead of `IconButton`) lack native tooltips. In Flutter, `Tooltip` widgets act as ARIA labels for screen readers. Using `Tooltip` around `GestureDetector` that wrap `Icon` is a simple micro-UX win that significantly improves accessibility.
**Action:** Always verify if `GestureDetector` wrappers around icons lack `Tooltip`, and wrap them to provide both a visual hint and an accessible screen reader label.
## 2024-05-18 - [Accessibility on Custom Interactive Elements]
**Learning:** When using `GestureDetector` as an action element without `excludeSemantics: true`, Flutter doesn't inherently treat the child elements as a single "button" for screen readers. Using `Semantics(button: true)` wraps the children and announces the entire element correctly. Attempting to use `excludeSemantics: true` with a hardcoded `label` breaks internationalization since screen readers will read the hardcoded label rather than the localized text of the child widgets (like `Text(L10n.t('key'))`).
**Action:** When adding button semantics to interactive widgets that contain localized child text, wrap the widget in `Semantics(button: true)` but DO NOT use `excludeSemantics: true` with a hardcoded label. Allow the localized child text to bubble up naturally.
