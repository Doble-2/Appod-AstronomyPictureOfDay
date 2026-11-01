# Appod design system

Appod's identity in a showcase-level app. The source of truth is `lib/ui/theme/app_theme.dart`; shared components are in `lib/ui/widgets/common.dart`.

## Identity

- Logo next to the APPOD wordmark in the Nasa font.
- Blue accent: `#5E9EFF` on dark, `#1A73E8` on light. Backgrounds: `#0A0C10` on dark, `#F6F8FC` on light.
- Brand gradient `#3391FF` to `#00C6B5`, only on the splash screen.

## Type

Space Grotesk, big and tight, for titles. Inter for everything else. Both are bundled under the SIL Open Font License.

## Signature elements

- **Ambient color:** the picture in focus, heavily blurred, tints the whole screen behind a legibility veil.
- **Carousel:** big cards with neighbors peeking in, scaling as they move.
- **Photo glass:** dark glass with white text for anything on a photograph, in both themes.
- **Floating dock:** navigation and a day's actions are glass pills that float over content.
- **Masonry wall:** the archive in columns of varied heights.

## Shape

Radius 32 for hero cards, sheets and panels; 24 for cards and groups; 16 for controls; pills for buttons and chips. Touch targets of at least 44.

## Motion

Entrances fade and rise, and lists arrive slightly staggered. Cards respond to press and hover, and pictures fly into their page. Everything turns off when the system asks for reduced motion (`reduceMotion` in `common.dart`).

## Navigation

Every address is defined in `lib/routes.dart`. Screens never write addresses by hand.
