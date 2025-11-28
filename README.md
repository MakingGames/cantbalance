# Cant

**A meditative physics puzzle game about weight, tension, and letting go.**

---

## Overview

Cant is the anti-Tetris. Where Tetris demands speed and clearing, Cant asks for patience and accumulation. Place weighted shapes onto a balancing beam, building a precarious tower while keeping the scale from tipping past its breaking point.

Built with Flutter and Flame/Forge2D physics engine.

**Bundle ID:** `com.emberbright.cant`

---

## Game Modes

### Challenge Mode

The core experience. A tilting beam controlled by your phone's accelerometer. Place shapes, keep balance, survive as long as possible.

**Progressive Difficulty (7 Levels):**

| Level | Score | New Mechanic |
|-------|-------|--------------|
| 1 - Basics | 0+ | Manual placement only |
| 2 - Auto-Spawn | 5+ | Shapes fall automatically |
| 3 - Heavy Gravity | 10+ | Gravity increases |
| 4 - Shape Variety | 16+ | Circles and triangles appear |
| 5 - Wind Gusts | 22+ | Random wind pushes shapes |
| 6 - Beam Instability | 30+ | Slippery beam, random nudges |
| 7 - Time Pressure | 40+ | Must place shapes quickly |

**Loss Conditions:** Shape falls off, or time runs out (level 7+)

---

### Campaign Mode

40 structured levels across 8 chapters. Each level has a target number of shapes to place.

| Chapter | Levels | Theme | Mechanics |
|---------|--------|-------|-----------|
| 1 | 1-5 | The Basics | Manual placement only |
| 2 | 6-10 | Falling Objects | Auto-spawn enabled |
| 3 | 11-15 | Heavy World | Increased gravity (12-16) |
| 4 | 16-20 | Shape Mastery | All shape types |
| 5 | 21-25 | Wind & Weather | Wind gusts |
| 6 | 26-30 | Unstable Ground | Slippery beam, random nudges |
| 7 | 31-35 | Time Crunch | Time pressure per shape |
| 8 | 36-40 | Mastery | All mechanics combined |

**Win:** Place target shapes (3-20 per level)
**Loss:** Any shape falls or time expires

---

### Stacking Mode

A vertical tower-building mode. No fulcrum, no tilt—just stack infinitely upward. Camera follows your growing tower.

**Features:**
- Drag-to-place anywhere above the platform
- Height tracking in meters
- Shape count scoring
- Next shape preview
- Physics Test Panel (toggleable via flask icon):
  - High Friction
  - High Damping
  - Magnetic Attraction
  - Sticky/Velcro contacts

**Loss:** Any shape falls below the base platform

---

### Sandbox Mode

No rules. No scoring. Tap anywhere to spawn squares. Pure physics experimentation.

---

## Physics System

### World Constants

| Property | Value |
|----------|-------|
| Base Gravity | 10.0 (can increase to 18.0) |
| Camera Zoom | 10.0 px/unit |

### Beam Properties

| Property | Value |
|----------|-------|
| Width | 25.0 units |
| Density | 2.0 |
| Friction | 0.8 (0.3 when slippery) |
| Restitution | 0.1 |

### Shape Sizes

| Size | Dimensions | Density | Color |
|------|------------|---------|-------|
| Small | 1.0 units | 0.8 | Light gray |
| Medium | 1.5 units | 1.0 | Medium gray |
| Large | 2.2 units | 1.3 | Dark gray |

### Shape Types

- **Square:** Stable box geometry
- **Circle:** Rolls easily, standard physics
- **Triangle:** Equilateral, 10% lighter, 30% less friction (naturally unstable)

### Physics Modifiers (Stacking Mode)

| Modifier | Effect |
|----------|--------|
| High Friction | 2.0 (vs 0.8 default) |
| High Damping | Linear 2.0, Angular 3.0 |
| Magnetic Attraction | Shapes pull together within 1.5 units |
| Sticky/Velcro | Maximum friction 5.0 |

---

## Mechanics

### Tilt Control

Phone accelerometer controls beam rotation. Tilt your device to balance the shapes.

- Threshold indicator at ~30 degrees
- Torque strength: 200.0

### Auto-Spawn System

Shapes spawn automatically in higher levels:

- Initial interval: 5.0 seconds
- Decreases by 0.3s per shape placed
- Minimum: 1.5 seconds
- Grace period: 3.0 seconds at start

### Wind System (Level 5+)

- Gust interval: 2-5 seconds random
- Force: 15-40 units
- Duration: 0.8 seconds
- Direction: Random left/right

### Time Pressure (Level 7+)

- Initial limit: 8.0 seconds per shape
- Decreases by 0.2s per shape
- Minimum: 4.0 seconds

---

## Features

### Theme System

- Dark mode (default): Black background, light UI
- Light mode: Light background, dark UI
- Toggle in main menu (top-right)
- Persisted to device storage

### Progress Tracking

- **Challenge:** High score saved
- **Campaign:** Stars per level, chapter progress
- **Stacking:** Height and shape count

### Haptic Feedback

- Light: Shape placed
- Medium: Game over
- Heavy: New high score

### Tutorial

First-launch overlay explaining basic mechanics.

---

## Technical Stack

- **Framework:** Flutter
- **Game Engine:** Flame 1.21.0
- **Physics:** Forge2D (Box2D port)
- **Sensors:** sensors_plus
- **Storage:** shared_preferences

---

## Mode Comparison

| Feature | Challenge | Campaign | Sandbox | Stacking |
|---------|-----------|----------|---------|----------|
| Scoring | High score | Target count | None | Height + count |
| Levels | 7 progressive | 40 discrete | None | Infinite |
| Auto-spawn | Yes | Per level | No | No |
| Wind | Level 5+ | Per level | No | No |
| Beam tilt | Phone tilt | Phone tilt | No | No |
| Placement | Drag above beam | Drag above beam | Tap anywhere | Drag anywhere |
| Game over | Fall/time | Fall/time | Never | Fall |
| Physics test | No | No | No | Yes |

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── game/
│   ├── constants.dart           # Physics constants
│   ├── challenge_game.dart      # Challenge mode
│   ├── campaign_game.dart       # Campaign mode
│   ├── sandbox_game.dart        # Sandbox mode
│   ├── stacking_game.dart       # Stacking mode
│   ├── stacking_physics.dart    # Physics test toggles
│   ├── campaign_level.dart      # Level definitions (1-40)
│   ├── game_level.dart          # Challenge levels (1-7)
│   ├── shape_type.dart          # Shape enum
│   └── shape_size.dart          # Size system
├── components/
│   ├── scale_beam.dart          # Balance beam
│   ├── fulcrum.dart             # Pivot support
│   ├── square_shape.dart        # Square physics
│   ├── circle_shape.dart        # Circle physics
│   ├── triangle_shape.dart      # Triangle physics
│   ├── ghost_shape.dart         # Placement preview
│   └── base_platform.dart       # Stacking base
├── screens/
│   ├── main_menu.dart           # Menu UI
│   ├── game_over_overlay.dart   # End game UI
│   ├── level_select.dart        # Campaign selection
│   ├── shape_picker.dart        # Size selector
│   └── tutorial_overlay.dart    # Help screen
├── services/
│   ├── theme_service.dart       # Dark/light mode
│   ├── high_score_service.dart  # Score persistence
│   └── level_progress_service.dart
└── utils/
    ├── colors.dart              # Theme colors
    └── shape_painter.dart       # Canvas rendering
```

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on device
flutter run

# Build for release
flutter build ios
flutter build apk
```

---

## License

Copyright 2024 Emberbright
