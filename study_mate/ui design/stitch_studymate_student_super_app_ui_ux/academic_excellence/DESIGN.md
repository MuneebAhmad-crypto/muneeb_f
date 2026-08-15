---
name: Academic Excellence
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#434656'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#747688'
  outline-variant: '#c4c5d9'
  surface-tint: '#124af0'
  primary: '#0040e0'
  on-primary: '#ffffff'
  primary-container: '#2e5bff'
  on-primary-container: '#efefff'
  inverse-primary: '#b8c3ff'
  secondary: '#a04100'
  on-secondary: '#ffffff'
  secondary-container: '#fe6b00'
  on-secondary-container: '#572000'
  tertiary: '#485667'
  on-tertiary: '#ffffff'
  tertiary-container: '#616e80'
  on-tertiary-container: '#e8f1ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dde1ff'
  primary-fixed-dim: '#b8c3ff'
  on-primary-fixed: '#001356'
  on-primary-fixed-variant: '#0035be'
  secondary-fixed: '#ffdbcc'
  secondary-fixed-dim: '#ffb693'
  on-secondary-fixed: '#351000'
  on-secondary-fixed-variant: '#7a3000'
  tertiary-fixed: '#d6e4f9'
  tertiary-fixed-dim: '#bac8dc'
  on-tertiary-fixed: '#0f1c2c'
  on-tertiary-fixed-variant: '#3a4859'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 16px
  md: 24px
  lg: 32px
  xl: 48px
  container-max: 1200px
  gutter: 20px
---

## Brand & Style

This design system is built for a "Student Super App" that balances high-utility productivity with a premium, approachable aesthetic. The brand personality is **scholarly yet modern**, evoking a sense of calm focus and organized ambition. 

The visual style leans into **Modern Minimalism** with a **Corporate-Refined** edge. It utilizes generous whitespace to reduce cognitive load—essential for students managing complex schedules—while employing subtle depth through tonal layering rather than aggressive shadows. The interface should feel like a high-end stationery set: precise, clean, and intentional.

## Colors

The palette is anchored by **Deep Indigo** to promote concentration and a sense of institutional trust. The primary action color is a **Vibrant Orange**, providing a high-energy contrast that draws the eye to essential tasks and "Done" states without feeling abrasive.

- **Surface Strategy:** Use `neutral` (Off-white) for the main application background. Use pure white for cards and containers to create a subtle lift.
- **Dark Mode:** When implemented, the background shifts to a deep charcoal-navy (`#0D1B2A`), with surfaces using slightly lighter opacities of the primary blue to maintain depth.
- **Semantic Usage:** Semantic colors should be used sparingly in small UI elements like status pips, progress bars, and unobtrusive toast notifications to prevent visual clutter.

## Typography

The design system utilizes **Inter** exclusively to achieve a systematic, utilitarian feel that remains highly readable at small sizes (essential for densified schedules and grade views).

- **Hierarchy:** Use `headline-xl` for dashboard greetings and major section headers. 
- **Readability:** Body text should maintain a minimum of `body-md` for primary content. `body-sm` is reserved for secondary metadata or captions.
- **Rhythm:** Line heights are set to 1.5x for body text to ensure comfortable long-form reading during study sessions.

## Layout & Spacing

The layout follows a **Fluid Grid** model with strict 8px incremental stepping. 

- **Mobile:** 4-column grid with 16px side margins and 16px gutters.
- **Tablet/Desktop:** 12-column grid. On desktop, the content is capped at a `container-max` of 1200px to maintain line-length readability for educational content.
- **Density:** High-density views (like grade books) should use `xs` and `sm` spacing, while immersive "Focus Modes" should increase padding to `lg` to minimize distractions.

## Elevation & Depth

This design system uses **Tonal Layers** combined with **Ambient Shadows** to define hierarchy.

1.  **Level 0 (Base):** Background color (`neutral`).
2.  **Level 1 (Cards):** White surface with a very soft, diffused shadow: `0 4px 20px rgba(0, 0, 0, 0.05)`.
3.  **Level 2 (Modals/Popovers):** White surface with a more defined shadow: `0 12px 32px rgba(0, 0, 0, 0.12)`.

Avoid heavy borders. Instead, use a subtle `1px` stroke in a slightly darker neutral shade to define boundaries on white backgrounds if elevation is not sufficient.

## Shapes

The shape language is consistently **Rounded** to feel friendly and accessible. 

- **Cards & Modals:** Use `rounded-xl` (1.5rem / 24px) to emphasize the "Super App" containerized feel.
- **Buttons & Inputs:** Use `rounded-lg` (1rem / 16px) for a modern, tactile appearance.
- **Chips & Tags:** Use pill-shaped (full radius) to distinguish them from actionable buttons.

## Components

### Buttons
- **Primary:** Solid `secondary_color_hex` (Orange) with white text. High contrast for major actions like "Submit" or "Add Course".
- **Secondary:** Light blue tint background with `primary_color_hex` (Indigo) text. Used for "Edit" or "Filter".
- **Ghost:** No background, `primary_color_hex` text. Used for "Cancel" or less frequent navigation.

### Text Fields
- **State:** 1px stroke (neutral-300). On focus, the stroke thickens to 2px and changes to `primary_color_hex`.
- **Label:** Always visible above the input using `label-md` styling.

### Chips & Navigation
- **Chips:** Used for course categories (e.g., "MATH101"). Use a subtle tint of the primary color.
- **Bottom Nav (Mobile):** Fixed blur background (Glassmorphism) with 10% opacity white. Active states use the primary indigo.

### Progress Indicators
- **Linear Progress:** 8px height, rounded ends. Use `success` green for completed tasks and `primary` blue for in-progress courses.
- **Skeleton States:** Use a pulsing `neutral` gray for loading states to maintain the perception of speed.

### Cards
- Standard containers for assignments and classes. Include a subtle 16px padding and `rounded-xl` corners.