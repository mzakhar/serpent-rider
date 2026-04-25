# Serpent Rider

A Dragon Breed-inspired side-scrolling shooter (shmup) built with Godot 4.

## About

Serpent Rider is a fan tribute to **Dragon Breed** (1989), the classic Irem arcade game. This project recreates the core mechanics of the original while adding modern refinements.

Based on the original by [Irem](https://en.wikipedia.org/wiki/Dragon_Breed), released in arcades in 1989.

## Features

### Core Mechanics
- **Serpentine Dragon Body**: 12-segment snake-like tail with natural lag physics
- **Tail Shield**: Hold Z to wrap tail and block incoming projectiles
- **Tail As Weapon**: Tail segments damage enemies on contact
- **Fire Charge**: Hold fire button to charge shot power (4 levels)
- **Dismount**: Press X to dismount and walk on platforms to collect power-ups
- **6 Levels**: Progression with time limits and boss fights

### Weapons (Dragon Breed-style)
- **Red**: Flame breath
- **Yellow**: 8-directional crescent waves
- **White**: 4 homing mini-dragons
- **Blue**: Downward lightning bolts
- Plus standard: Spread, Double, Pierce

### Enemies
- **Basic**: Flying straight enemies
- **Shooters**: Fire at player
- **Bosses**: Multi-phase with varied attack patterns

## Controls

| Action | Key |
|-------|-----|
| Move | WASD / Arrow Keys |
| Fire | Space / Left Click |
| Shield | Z |
| Dismount/Mount | X |
| Pause | Escape |

## Project Structure

```
res/
├── scenes/
│   ├── player/        # Player dragon + rider
│   ├── enemies/       # Enemy types & bosses
│   ├── projectiles/  # All projectile types
│   ├── levels/        # Level scenes (1-6 + boss)
│   └── ui/            # HUD elements
├── scripts/
│   ├── player/       # DragonBody, PlayerController
│   ├── enemies/      # Enemy AI, Spawner, Boss
│   └── systems/       # Weapons, PowerUps, Camera
├── assets/
│   ├── sprites/     # (Placeholders - CC0 ready)
│   ├── audio/
│   └── fonts/
└── autoloads/        # EventBus, GameManager, ScoreManager
```

## Getting Started

### Prerequisites
- Godot 4.2+ (GDScript, GL Compatibility renderer)

### Running
1. Open in Godot 4.2+
2. Press F5 to run

### Development Branches
- **dev**: Active development
- **main**: Stable releases

## Level Design

Each level features:
- Time limit (60-120 seconds)
- Kill target to progress
- Auto-scrolling camera
- 3-layer parallax background
- Unique enemy spawn patterns
- Boss at level end

| Level | Time | Enemies | Notes |
|-------|-----|--------|-------|
| 1 | 120s | 30 | Basic enemies |
| 2 | 90s | 40 | Faster spawns |
| 3 | 60s | 1 | Boss fight |
| 4-6 | - | - | (Extendable) |

## Credits

- **Original Game**: Dragon Breed (Irem, 1989)
- **Engine**: Godot 4 (MIT License)
- **Inspiration**: Classic arcade shmups

## License

This is a fan project for educational/demonstration purposes. The original Dragon Breed is property of Irem.

---

*Inspired by the golden age of arcade gaming*
*Ride the serpent, conquer the enemy*