# Appod design system: Observatory

The photograph leads and the interface steps back. The source of truth is `lib/ui/theme/app_theme.dart`; shared components are in `lib/ui/widgets/common.dart`.

## Principles

- Never crop a picture on its own page. It sits on black, in its own shape.
- One accent, amber, for actions and the current item. No gradients or glows on the interface.
- Text on a photograph is always white on a dark fade, in both themes.
- Every empty or error state says what happened and offers the next step.
- Text and buttons always have a label. Do not rely on an icon alone.

## Color

| Role | Dark | Light |
|------|------|-------|
| Background | `#0B0C0E` | `#F7F8F9` |
| Surface | `#16181B` | `#EDEFF1` |
| Raised surface | `#212429` | `#E1E3E6` |
| Line | `#2A2D32` | `#D9DBDF` |
| Text | `#F2F1EE` | `#15171A` |
| Secondary text | `#A9ACB1` | `#585C63` |
| Accent | `#F5B14C` | `#9A5200` |
| Error | `#FF8A7A` | `#B3261E` |

## Type

| Use | Font |
|-----|------|
| Titles | Newsreader 500 |
| Interface and reading | IBM Plex Sans 400, 500, 600 |
| Dates | IBM Plex Mono 400 |
| APPOD wordmark only | Nasalization |

All are bundled in `assets/`. Newsreader and IBM Plex are under the SIL Open Font License.

## Layout

- Page width: 1240 at most; 760 for reading and settings; 440 for forms.
- Side margins: 32 from 905 wide, otherwise 16.
- Navigation: text tabs at the top from 905 wide, otherwise a bottom bar.
- Grid: 4 columns from 1000 wide, 3 from 600, otherwise 2. Pictures are 4:3.
- Corner radius: 8. Touch targets: at least 44.
