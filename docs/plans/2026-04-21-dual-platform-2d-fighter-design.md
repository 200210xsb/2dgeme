# Dual-Platform 2D Side-Scroller Fighter Design

## Goal

Build a playable 2D side-scroller action game that can be exported to both Windows (.exe) and Android from one Unity project.

## Design Principles

- One gameplay codebase with an input abstraction layer.
- Keyboard and touch control map to the same movement and combat commands.
- Deterministic combat timing with simple, tunable parameters.
- Low art dependency: start with placeholder assets and prioritize feel.

## Core Systems

### 1) Player Locomotion

- Horizontal movement with acceleration.
- Single jump with grounded detection via overlap circle.
- Facing direction updates based on move axis.

### 2) Combat

- Three-step light combo.
- Combo reset by timeout.
- Hit detection by overlap circle in front of the player.
- Damage, brief hit stop, and optional knockback extension.

### 3) Enemy AI

- Patrol between two points.
- Chase player when inside detection range.
- Attack in close range with cooldown.
- Return to patrol when player exits chase range.

### 4) Health and Death

- Shared `Health` component for player and enemy.
- `TakeDamage` and `Die` flow with event callback.
- Basic invulnerability window for player can be added in phase 2.

### 5) Input Abstraction

- Desktop: Unity Input axes and keys.
- Mobile: UI button events write to shared input state.
- Combat and movement use unified input fields.

## Parameters to Tune First

- Run speed: 6.0
- Jump force: 12.0
- Combo window: 0.45s
- Attack radius: 0.8
- Enemy chase range: 6.0
- Enemy attack range: 1.2
- Enemy attack cooldown: 1.0s

## Milestones

1. Vertical slice: player + one enemy + one small map.
2. Feel pass: movement and hit timing tuning.
3. UI pass: health bar and pause/restart.
4. Platform pass: Windows and Android build validation.

## Risks and Mitigation

- Touch controls feel weak on mobile: increase button size and buffering.
- Inconsistent performance on low-end devices: reduce particles and fixed update load.
- Animation timing mismatch: centralize timings in combat parameters.
