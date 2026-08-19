---
name: ProForma Design System
colors:
  surface: '#f8f9ff'
  surface-dim: '#d0dbed'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e6eeff'
  surface-container-high: '#dee9fc'
  surface-container-highest: '#d9e3f6'
  on-surface: '#121c2a'
  on-surface-variant: '#44464f'
  inverse-surface: '#27313f'
  inverse-on-surface: '#eaf1ff'
  outline: '#757780'
  outline-variant: '#c5c6d0'
  surface-tint: '#495d91'
  primary: '#000417'
  on-primary: '#ffffff'
  primary-container: '#001b4d'
  on-primary-container: '#7185bc'
  inverse-primary: '#b2c5ff'
  secondary: '#0051d5'
  on-secondary: '#ffffff'
  secondary-container: '#316bf3'
  on-secondary-container: '#fefcff'
  tertiary: '#030609'
  on-tertiary: '#ffffff'
  tertiary-container: '#1a1f23'
  on-tertiary-container: '#82878c'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2ff'
  primary-fixed-dim: '#b2c5ff'
  on-primary-fixed: '#001847'
  on-primary-fixed-variant: '#304578'
  secondary-fixed: '#dbe1ff'
  secondary-fixed-dim: '#b4c5ff'
  on-secondary-fixed: '#00174b'
  on-secondary-fixed-variant: '#003ea8'
  tertiary-fixed: '#dfe3e9'
  tertiary-fixed-dim: '#c3c7cd'
  on-tertiary-fixed: '#171c20'
  on-tertiary-fixed-variant: '#43474c'
  background: '#f8f9ff'
  on-background: '#121c2a'
  surface-variant: '#d9e3f6'
typography:
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  data-mono:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 12px
  margin-mobile: 16px
---

## Brand & Style

The brand personality of the design system is rooted in precision, reliability, and corporate authority. Designed for a mobile-first invoice generator, it prioritizes functional utility over decorative flair, ensuring that financial data remains the hero of the experience.

The design style follows a **Corporate / Modern** aesthetic with elements of **High-Contrast** for readability. It leverages a structured grid, purposeful whitespace, and a sophisticated color palette to evoke a sense of trust and enterprise readiness. The interface feels systematic and robust, mimicking the stability of a physical ledger while maintaining the speed and fluidity of a modern digital tool.

## Colors

The color palette is derived from the professional deep blues and greys found in traditional business documentation. 

- **Primary:** A deep, authoritative Navy (#001B4D) used for headers, primary brand moments, and high-level structural anchors.
- **Secondary:** A vibrant Action Blue (#2563EB) reserved for interactive elements, primary buttons, and critical focus states.
- **Neutral:** A range of slate greys ensures readability. Deep grey (#1F2937) is used for body text, while lighter tints are used for borders and background layering to maintain a clean hierarchy.
- **Semantic:** Standardized red for "Overdue" or "Delete" and green for "Paid" or "Success" should be used sparingly to guide the user’s eye to status changes.

## Typography

This design system utilizes a tiered typography strategy to maximize data density without sacrificing clarity. 

- **Hanken Grotesk** is used for headlines to provide a sharp, modern, and professional character.
- **Inter** handles all body copy and UI controls, chosen for its exceptional legibility and neutral tone.
- **JetBrains Mono** is introduced specifically for numeric data, invoice numbers, and currency values. The monospaced nature ensures that columns of numbers align perfectly, aiding in quick financial auditing.

All labels should use the `label-caps` style (Uppercase) to differentiate metadata from user-entered content.

## Layout & Spacing

The layout is built on a **Fluid Grid** system optimized for mobile constraints. 

- **Rhythm:** A 4px baseline grid ensures consistent vertical pacing. 
- **Margins:** Standard mobile views use a 16px side margin.
- **Structure:** Forms and line items should utilize "Card-based" grouping. 
- **Data Entry:** For invoice line items, use a horizontal scrollable table or a stacked vertical card layout on narrow devices to ensure all financial columns (Qty, Rate, Total) remain legible.
- **Safe Areas:** Ensure interactive elements (buttons) are placed within easy thumb reach at the bottom of the screen, often using a "Sticky Action Bar" for primary functions like "Generate PDF."

## Elevation & Depth

This design system avoids heavy shadows in favor of **Tonal Layers** and **Low-contrast outlines**. This ensures the UI feels "flat" and printable, echoing the nature of an invoice.

- **Level 0:** Main background (pure white or very light grey).
- **Level 1:** Content cards and input fields. Use a 1px solid border (#D1D5DB) to define boundaries.
- **Elevation:** Use a subtle, highly diffused shadow (0px 4px 12px rgba(0,0,0,0.05)) only for floating action buttons or active modal overlays to indicate temporary presence.
- **Focus States:** Active input fields should transition their border color to the Secondary Blue (#2563EB) with a subtle 2px outer glow.

## Shapes

The shape language is "Soft" yet geometric. A small corner radius (4px to 8px) is applied to maintain the professional, rigid feel of a business document while softening the digital interaction.

- **Input Fields/Buttons:** 4px radius (Soft).
- **Cards/Containers:** 8px radius (rounded-lg).
- **Search Bars:** 24px (rounded-xl) to distinguish them from data entry fields.

## Components

### Buttons
- **Primary:** Solid Secondary Blue background with white text. High-contrast, used for "Save" or "Send."
- **Secondary:** White background with Primary Navy border and text. Used for "Add Item" or "Cancel."
- **Ghost:** No background, Navy text. Used for tertiary actions like "View Details."

### Input Fields
- Structured with a persistent label in `label-caps` above the field.
- Use a 1px border. Background should be slightly off-white (#F9FAFB) to indicate interactivity.
- Error states must include a red border and a small descriptive error icon.

### Invoice Line Items
- Each item is a simplified row with a title, quantity, and price. 
- Use a "Swipe to Delete" gesture for mobile efficiency.
- Totals at the bottom should be anchored in a high-contrast container using the Primary Navy color for the "Total Amount" to ensure it is the most visible element on the page.

### Chips
- Used for invoice status (e.g., Draft, Sent, Paid). 
- Use a low-saturation background with high-saturation text of the same hue for maximum accessibility.