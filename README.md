# Serpent Rider

A Dragon Breed-inspired side-scrolling shooter (shmup) built with Godot 4.

## About

Serpent Rider is a fan tribute to **Dragon Breed** (1989), the classic Irem arcade game. This project recreates the core mechanics of the original while adding modern refinements.

Based on the original by [Irem](https://en.wikipedia.org/wiki/Dragon_Breed), released in arcades in 1989.

## Features

- **Serpentine Dragon Body**: Snake-like tail chain that follows head movement with natural lag physics
- **Tail Shield Mechanic**: Wrap tail around player to block incoming projectiles
- **Auto-Scrolling Levels**: Horizontal camera scroll with parallax backgrounds
- **Weapon Power-Ups**: Multiple projectile types (fireball, spread, wave, pierce)
- **Score & Multiplier System**: Build combos for higher scores

## Controls

| Action | Key |
|-------|-----|
| Move | WASD / Arrow Keys |
| Fire | Space / Left Click |
| Shield | Z |

## Project Structure

```
res/
├── scenes/
│   ├── player/        # Player dragon + rider
│   ├── enemies/       # Enemy types
│   ├── projectiles/  # Projectile scenes
│   ├── levels/       # Level scenes
│   └── ui/            # HUD elements
├── scripts/
│   ├── player/       # Player controller scripts
│   ├── enemies/      # Enemy AI
│   └── systems/      # Shared systems
├── assets/
│   ├── sprites/     # (Placeholders - replace with art)
│   ├── audio/
│   └── fonts/
└── autoloads/        # Global singletons
```

## Getting Started

### Prerequisites

- Godot 4.x (GDScript)
- VS Code or any code editor

### Running

1. Clone this repository
2. Open in Godot 4.2+
3. Press F5 to run

### Development

- **dev branch**: Active development
- **main branch**: Stable releases

## Credits

- **Original Game**: Dragon Breed (Irem, 1989)
- **Engine**: Godot 4 (MIT License)
- **Inspiration**: Classic arcade shmups

## License

This is a fan project for educational/demonstration purposes. The original Dragon Breed is property of Irem.

---

*Inspired by the golden age of arcade gaming*