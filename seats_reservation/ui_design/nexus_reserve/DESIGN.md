---
name: Nexus Reserve
colors:
  surface: '#f9f9ff'
  surface-dim: '#cfdaf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eeff'
  surface-container-high: '#dee8ff'
  surface-container-highest: '#d8e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#434653'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
  outline: '#737784'
  outline-variant: '#c3c6d5'
  surface-tint: '#1d59c1'
  primary: '#003c90'
  on-primary: '#ffffff'
  primary-container: '#0f52ba'
  on-primary-container: '#bcceff'
  inverse-primary: '#b0c6ff'
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
  tertiary: '#3d4143'
  on-tertiary: '#ffffff'
  tertiary-container: '#55585a'
  on-tertiary-container: '#ccced0'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d9e2ff'
  primary-fixed-dim: '#b0c6ff'
  on-primary-fixed: '#001945'
  on-primary-fixed-variant: '#00419c'
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#e0e3e5'
  tertiary-fixed-dim: '#c4c7c9'
  on-tertiary-fixed: '#191c1e'
  on-tertiary-fixed-variant: '#444749'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
typography:
  display:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
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
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 0.25rem
  sm: 0.5rem
  md: 1rem
  lg: 1.5rem
  xl: 2rem
  2xl: 3rem
  gutter: 1rem
  margin-mobile: 1rem
  margin-desktop: 2.5rem
---

## Brand & Style

The design system is engineered for efficiency, reliability, and professional clarity. Targeted at educational and corporate software environments, the UI prioritizes functional density without sacrificing breathing room. 

The aesthetic follows a **Corporate / Modern** direction, utilizing high-quality whitespace and a systematic approach to hierarchy. It avoids unnecessary ornamentation, focusing instead on user confidence through predictable patterns and clear state communication. The emotional response should be one of "effortless organization"—users should feel that the system is stable, responsive, and authoritative.

## Colors

The palette is anchored by a trustworthy **Sapphire Blue** primary, which signals professionalism and depth. 

- **Primary:** Used for main actions, active navigation states, and primary brand moments.
- **Secondary/Neutral:** A range of cool grays and slates provide structural scaffolding and text hierarchy.
- **Surface:** The background uses a crisp white, while secondary surfaces use a very light blue-gray tint to distinguish content areas from the base.
- **Semantic/Status:** These are critical for seat reservation. **Emerald Green** denotes availability, **Amber** indicates a temporary hold or pending status, and **Rose Red** signals occupied or restricted zones. These must maintain high contrast against surface colors for accessibility.

## Typography

The design system utilizes **Inter** for all roles. Inter’s tall x-height and systematic spacing make it ideal for data-heavy reservation screens and small-scale labels.

- **Headlines:** Use tighter letter-spacing and heavier weights to establish a strong structural anchor.
- **Body:** Standardized at 16px for optimal readability in professional settings. 
- **Labels:** Used for seat numbers, status badges, and metadata. These often utilize a medium or semi-bold weight to remain legible even at smaller sizes or within colored backgrounds.
- **Accessibility:** Ensure a minimum contrast ratio of 4.5:1 for all text elements.

## Layout & Spacing

This design system employs a **12-column fluid grid** for desktop and a **4-column grid** for mobile. 

The spacing rhythm is built on a **4px baseline**, ensuring all components align perfectly. Use "md" (16px) for standard padding within cards and containers. For the seat reservation map, use a flexible "No grid" approach within the container to allow for realistic spatial mapping, but maintain strict adherence to "sm" (8px) and "xs" (4px) gaps between individual seat units to signify adjacency.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** and **Ambient Shadows**. 

1. **Floor (Base):** Primary background color (#FFFFFF).
2. **Surface (Cards/Containers):** Uses a subtle 1px border (#E2E8F0) to define boundaries, rather than heavy shadows.
3. **Elevated (Modals/Popovers):** Uses an extra-diffused, low-opacity shadow (0px 10px 15px -3px rgba(0, 0, 0, 0.05)) to suggest it is floating above the map.

Avoid high-contrast shadows. The depth should feel "light" and airy, mirroring the cleanliness of a modern office or lab environment.

## Shapes

The shape language is consistently **Rounded**. 

- **Seats:** Should use the standard `rounded` (8px) to feel approachable but efficient.
- **Buttons & Inputs:** Use `rounded` (8px) for a modern, professional feel.
- **Badges/Status Indicators:** Should use `rounded-xl` or fully pill-shaped styles to differentiate them from functional buttons.
- **Container Cards:** Use `rounded-lg` (16px) for major dashboard sections to create a softer, more modern framing of complex data.

## Components

### Buttons
- **Primary:** Solid Sapphire Blue with white text. High-contrast, 8px rounded corners.
- **Secondary:** Transparent background with Sapphire Blue border and text. 
- **Ghost:** No border, Slate Gray text; used for low-priority actions like "Cancel."

### Seat Icons
- **States:** Available (Outline + Green Tint), Selected (Primary Blue + Glow), Occupied (Light Gray + Red Slash or Icon), Pending (Amber Border).
- **Interaction:** On hover, seats should scale slightly (1.05x) and show a tooltip with the seat ID and user details.

### Status Badges
- Small, pill-shaped elements with low-opacity background tints (e.g., 10% Green background with 100% Green text). This ensures the color is present without being visually overwhelming.

### Input Fields
- Understated borders (#CBD5E1). On focus, the border transitions to Primary Blue with a subtle outer glow to guide the user's attention.

### Reservation Cards
- Used in the "My Bookings" list. Features a vertical bar on the left side that color-coordinates with the reservation status (Green/Amber/Red) for instant scannability.