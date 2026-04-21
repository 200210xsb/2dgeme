# Dual-Platform 2D Side-Scroller Fighter (Unity)

This repository provides a starter implementation plan and core scripts for a 2D side-scroller action game that targets both Windows (.exe) and Android.

## Tech Stack

- Unity 2022 LTS
- C#
- Built-in 2D physics and animation state machine

## MVP Scope

- Player movement: run, jump, face direction
- Combo attack chain (3-hit)
- Enemy behavior: patrol, chase, attack
- Health and damage system
- Touch input bridge for Android and keyboard fallback for desktop

## Suggested Project Structure

- `docs/plans/2026-04-21-dual-platform-2d-fighter-design.md`
- `unity-scripts/PlayerController2D.cs`
- `unity-scripts/PlayerCombat.cs`
- `unity-scripts/EnemyController2D.cs`
- `unity-scripts/Health.cs`
- `unity-scripts/TouchInputBridge.cs`

## Setup Steps

1. Create a new Unity 2D project.
2. Add a player with `Rigidbody2D`, `Collider2D`, animator, and `Health`.
3. Add enemy prefabs with `Rigidbody2D`, `Collider2D`, `EnemyController2D`, and `Health`.
4. Configure ground and player layers.
5. Add mobile UI buttons and bind them to `TouchInputBridge` methods.

## Build

Windows first test guide: `docs/plans/2026-04-21-windows-exe-test-guide.md`

### Windows (.exe)

1. Open `File > Build Settings`.
2. Select `PC, Mac & Linux Standalone` and target `Windows`.
3. Build to output `.exe`.

### Android

1. Install Android Build Support in Unity Hub.
2. Switch platform to `Android` in `Build Settings`.
3. Configure package name and minimum SDK in `Player Settings`.
4. Build APK or AAB.
