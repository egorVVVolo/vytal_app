# Palette UX Plan

1. **Add `Tooltip`s to `GestureDetector` icon buttons in `plan_screen.dart`**
   - Wrap the `_headerBtn` implementation with a `Tooltip` widget. Pass a descriptive `tooltipText` parameter indicating its action (e.g., "Library" and "Add Plan").
2. **Add `Tooltip`s to `GestureDetector` interactive tiles in `profile_screen.dart`**
   - Modify `_DeviceTile` in `lib/screens/profile_screen.dart` by wrapping the `GestureDetector` with a `Tooltip` widget, using the `name` parameter as the tooltip message.
3. **Add `Tooltip`s to `GestureDetector` picker cards in `edit_profile_screen.dart`**
   - The `_buildPickerCard` uses `GestureDetector` but it lacks an explicit tooltip describing the field interaction. Add a `Tooltip` widget around it, using "Edit $label" as the tooltip.
4. **Run Verification Commands**
   - Run `flutter analyze` and `flutter test` to ensure changes are correct and regressions are absent.
5. **Pre-commit checks**
   - Complete pre-commit steps to ensure proper testing, verification, review, and reflection are done.
6. **Submit PR**
   - Commit and submit changes with a clear UX description.
