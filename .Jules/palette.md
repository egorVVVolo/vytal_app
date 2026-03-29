## 2024-05-24 - Semantic Labeling for Custom Gesture Buttons
**Learning:** Custom icon buttons built with `GestureDetector` lack semantic labeling out-of-the-box in this app. Screen readers and users hovering over these buttons will not receive any context or description of their function.
**Action:** Always wrap `GestureDetector` and `InkWell` elements that function as icon-only buttons in a `Tooltip` widget with an appropriate descriptive `message` to provide semantic labeling and improve accessibility.
