# Appod design system

Appod's identity on a modern app system. The source of truth is `lib/ui/theme/app_theme.dart`; shared components are in `lib/ui/widgets/common.dart`.

## Identity

- Logo next to the APPOD wordmark in the Nasa font.
- Brand gradient `#3391FF` to `#00C6B5`, for the selected item and the main highlight.
- Blue accent: `#5E9EFF` on dark, `#1A73E8` on light. Teal: `#2DD4BF` on dark, `#00796B` on light.
- Backgrounds: `#05060A` on dark, `#F6F8FC` on light.

## Type

Space Grotesk for titles, Inter for everything else. Both are bundled under the SIL Open Font License.

## Principles

- The photograph fills the screen. The interface floats over it as glass.
- Swiping moves between days. Pictures fly from the card into their page.
- Text on a photograph is white on a dark fade, in both themes.
- Tapping a picture on its page always shows it whole and uncropped.
- Corner radius 20 for cards, 16 for controls. Touch targets of at least 44.

## Navigation

Every address is defined in `lib/routes.dart`. Screens never write addresses by hand.
