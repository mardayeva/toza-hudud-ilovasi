# Design System Specification: The Environmental Curator

## 1. Overview & Creative North Star: "The Environmental Curator"
This design system moves beyond the utilitarian nature of waste management to position environmental stewardship as a high-end, civic responsibility. We are moving away from the "government form" aesthetic and toward a "Digital Curator" experience.

**The Creative North Star** for this system is **Eco-Architectural Minimalalism**. 
We treat the interface as an architectural space—clean, structured, and flooded with light. By utilizing intentional asymmetry, overlapping layers, and high-contrast typography, we create an experience that feels sophisticated and authoritative. We do not use "boxes"; we use "space" and "volume" to guide the citizen’s journey.

---

## 2. Colors & The "No-Line" Philosophy
The color strategy uses a deep, rhythmic green palette rooted in nature but refined for digital precision.

### The "No-Line" Rule
**Explicit Instruction:** You are prohibited from using 1px solid borders to define sections. In this design system, boundaries are created through:
- **Tonal Shifts:** Placing a `surface_container_lowest` card on top of a `surface_container` background.
- **Structural Padding:** Using the Spacing Scale to create "islands" of information.
- **Soft Shadows:** Using elevation to imply a boundary without a hard edge.

### Tonal Textures
- **Signature Gradients:** For primary CTAs and hero headers, use a subtle linear gradient (135°) from `primary` (#0d631b) to `primary_container` (#2e7d32). This adds "soul" and depth to flat surfaces.
- **Glassmorphism:** For floating search bars or navigation overlays, use a semi-transparent `surface_container_lowest` (80% opacity) with a `20px` backdrop-blur. This ensures the UI feels integrated into the environment rather than "pasted" on.

---

## 3. Typography: The Editorial Rhythm
We use **Inter** to achieve a modern, Swiss-inspired legibility. The hierarchy is designed to feel like a premium editorial magazine—bold headers balanced by functional, spacious labels.

- **Display & Headlines:** Use `display-md` and `headline-lg` for data summaries and hero titles. These should be set with a slight negative letter-spacing (-0.02em) to feel "tight" and authoritative.
- **The Functional Layer:** `body-lg` is your workhorse. Ensure a line-height of 1.6 to maintain the "high whitespace" requirement.
- **Utility Labels:** `label-md` and `label-sm` should be used for metadata and status badges, often in uppercase with slight letter-spacing (0.05em) to differentiate from body text.

---

## 4. Elevation & Depth: Atmospheric Layering
Depth is achieved through **Tonal Layering** rather than traditional structural lines. Imagine the UI as stacked sheets of fine, semi-translucent paper.

- **The Layering Principle:** 
    1. Base Level: `surface` (#f9f9f9).
    2. Section Level: `surface_container_low` (#f3f3f3).
    3. Content Card: `surface_container_lowest` (#ffffff).
- **Ambient Shadows:** When a card requires "lift" (e.g., a hover state or a modal), use an extra-diffused shadow:
    - *Shadow:* `0px 12px 32px rgba(26, 28, 28, 0.06)`. 
    - Note the use of `on_surface` (#1a1c1c) at a very low opacity rather than pure black.
- **The "Ghost Border" Fallback:** If a border is essential for accessibility (e.g., inside a high-density form), use the `outline_variant` token at **15% opacity**. Never use a 100% opaque border.

---

## 5. Components

### 5.1 Buttons (Action Volumes)
- **Primary:** Gradient fill (`primary` to `primary_container`), `lg` (16px) corner radius. No border. Text is `on_primary`.
- **Secondary:** `surface_container_high` background with `on_secondary_container` text. This provides a soft, tactile feel.
- **Tertiary:** No background. Bold `primary` text. Use for low-priority navigation.

### 5.2 Input Fields & Search
- **The Floating Search:** A `xl` (24px) rounded container using `surface_container_lowest` with an Ambient Shadow. The search icon should use the `primary` color to draw the eye.
- **Form Fields:** Use `surface_container_low` as the field background. On focus, transition the background to `surface_container_lowest` and apply a 1px "Ghost Border" using the `primary` token.

### 5.3 Cards & Lists
- **The "No-Divider" List:** List items are separated by vertical whitespace (16px) or a subtle shift to `surface_container_low` on hover. Never use horizontal 1px lines.
- **Status Badges:** Use `secondary_container` for neutral/active states and `tertiary_fixed` for urgent waste alerts. Radius should be `full` (pill shape).

### 5.4 Specialized Components
- **The Route Progress Tracker:** A vertical, "organic" line (2px width) using `outline_variant`, with `primary` nodes. The line should be dashed to imply a path through the city.
- **Capacity Gauges:** Soft, horizontal bars using `primary_fixed` as the background and `primary` as the progress fill, with `lg` (16px) rounding.

---

## 6. Do’s and Don’ts

### Do:
- **Do** embrace asymmetrical margins. Allow a container to bleed off one side of the grid to create a modern, editorial feel.
- **Do** use `primary_fixed` for large background areas that need to feel "fresh" and "clean."
- **Do** use `xl` (1.5rem) corner radii for main containers to emphasize the "Soft Professional" aesthetic.

### Don't:
- **Don't** use pure black (#000000) for text. Use `on_surface` (#1a1c1c) to maintain a premium, soft-contrast look.
- **Don't** stack more than three levels of depth. Surface > Container > Card is the limit.
- **Don't** use standard Material shadows. Always use the Ambient Shadow formula (low opacity, high blur).
- **Don't** cram content. If a screen feels full, increase the page height and add more whitespace between sections. The "Toza Hudud" brand must breathe.