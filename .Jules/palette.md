## 2023-10-27 - Semantics for Interactive Widgets
**Learning:** In Flutter, interactive widgets like `GestureDetector` do not automatically expose accessibility information to screen readers, unlike built-in `IconButton`s.
**Action:** Always wrap `GestureDetector` or `InkWell` elements that function as buttons with a `Semantics` widget, setting `button: true` and providing a clear, dynamic `label` (e.g., reflecting state like "Mark as complete" vs "Mark as incomplete").
