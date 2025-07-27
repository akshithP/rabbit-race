# Rabbit Race - Endless Runner Game

A fun endless runner game built with Godot 4 where you control a rabbit that must jump over obstacles to survive as long as possible.

## 🎮 Game Features

### Core Gameplay
- **Endless Runner**: The rabbit automatically runs forward while you control jumping
- **Obstacle Avoidance**: Jump over ground obstacles (stumps, rocks, barrels) and flying birds
- **Progressive Difficulty**: Speed and obstacle frequency increase as your score goes up
- **Scoring System**: Earn points based on distance traveled
- **High Score Tracking**: Your best score is saved and displayed

### Controls
- **Space/Up Arrow**: Jump (only works when game is running)
- **Enter**: Start/Restart the game

### Obstacles
- **Ground Obstacles**: Stumps, rocks, and barrels that appear on the ground
- **Flying Birds**: Birds that fly in wave patterns at different heights
- **Increasing Difficulty**: More obstacles spawn as your score increases

## 🛠️ Technical Features

### Game Mechanics
- **Physics-based Movement**: Realistic gravity and jumping physics
- **Collision Detection**: Precise collision detection with obstacles
- **Infinite Scrolling**: Seamless background and ground scrolling
- **Dynamic Obstacle Generation**: Obstacles spawn based on difficulty and distance

### Visual Features
- **Animated Sprites**: Rabbit has idle, running, and jumping animations
- **Parallax Background**: Multiple background layers for depth
- **Smooth Camera Movement**: Camera follows the rabbit's progress
- **Retro Font**: Classic retro-style text display

## 🎯 How to Play

1. **Start the Game**: Press Enter or click the "Press Space To Play" button
2. **Jump Over Obstacles**: Press Space or Up Arrow to jump over obstacles
3. **Survive**: Avoid hitting any obstacles to keep playing
4. **Score Points**: Your score increases the longer you survive
5. **Beat Your High Score**: Try to get the highest score possible!

## 📁 Project Structure

```
rabbit-race/
├── assets/
│   ├── background/          # Background parallax images
│   ├── obstacles/           # Obstacle sprites (stump, rock, barrel, bird)
│   └── rabbit_skins/        # Rabbit character sprites
├── scenes/
│   ├── main.gd             # Main game logic and obstacle generation
│   ├── rabbit.gd           # Rabbit movement and physics
│   ├── bird.gd             # Bird flying animation
│   ├── ground_obstacle.gd  # Ground obstacle behavior
│   └── *.tscn              # Scene files for all game objects
└── README.md               # This file
```

## 🔧 Setup Instructions

1. **Open in Godot 4**: Load the project in Godot 4.x
2. **Input Mapping**: Ensure the following input actions are set up:
   - `jump`: Space, Up Arrow
   - `ui_accept`: Enter
3. **Run the Game**: Open `scenes/main.tscn` and press F5 to play

## 🎨 Customization

### Adding New Obstacles
1. Create a new scene with Area2D as root
2. Add Sprite2D and CollisionShape2D/Polygon2D
3. Add the scene to the `obstacle_types` array in `main.gd`

### Changing Difficulty
- Modify `SPEED_MODIFIER` and `MAX_DIFFICULTY` in `main.gd`
- Adjust `bird_heights` array for different bird spawn heights
- Change `amplitude` and `frequency` in `bird.gd` for different bird movement

### Visual Customization
- Replace sprites in the `assets/` folders
- Modify the retro font in `assets/retro.ttf`
- Adjust camera scale and position in `main.tscn`

## 🐛 Known Issues & Solutions

### Jump Not Working
- **Issue**: Rabbit doesn't jump when pressing space
- **Solution**: Make sure the rabbit has a floor collision to detect with `is_on_floor()`

### Obstacles Not Spawning
- **Issue**: No obstacles appear during gameplay
- **Solution**: Check that obstacle scenes are properly preloaded in `main.gd`

### Performance Issues
- **Issue**: Game runs slowly with many obstacles
- **Solution**: Obstacles are automatically removed when off-screen, but you can adjust the removal distance

## 🚀 Future Enhancements

- **Power-ups**: Collectible items that provide temporary abilities
- **Multiple Characters**: Different rabbit skins with unique abilities
- **Sound Effects**: Background music and sound effects
- **Particle Effects**: Visual effects for jumping and collisions
- **Mobile Support**: Touch controls for mobile devices
- **Level System**: Different environments and themes

## 📝 License

This project is open source and available under the MIT License.

---

**Enjoy playing Rabbit Race!** 🐰🏃‍♂️