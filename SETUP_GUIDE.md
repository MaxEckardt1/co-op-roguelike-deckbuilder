# Co-op Roguelike Deckbuilder - Setup & Architecture Guide

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/MaxEckardt1/co-op-roguelike-deckbuilder.git
   cd co-op-roguelike-deckbuilder
   ```

2. **Open in Godot 4.x** and click the **Play** button (F5)

3. **Game Flow:**
   - Map Screen → Click a level
   - Team Setup Screen → Click "Start Combat"
   - Combat Screen → Watch the battle unfold or click "End Turn"

---

## How Everything Works Together

### The Game Flow

```
MAP SCREEN
    ↓ (Player clicks level)
TEAM SETUP SCREEN
    ↓ (Player clicks "Start Combat")
COMBAT SCREEN
    ↓ (Combat happens via TurnSystem)
VICTORY/DEFEAT
    ↓ (Player returns to map)
[REPEAT]
```

---

## Core Systems Explained

### 1. **Character System** (`scripts/entities/character.gd`)

**What it does:** Represents any unit in the game (player character, enemy)

**Key Properties:**
- `max_health` / `current_health` - Health points
- `attack` - Damage dealt per turn
- `defense` - Damage reduction
- `speed` - Turn order priority (higher = goes first)
- `items` - List of item IDs player has
- `abilities` - List of ability IDs available
- `is_alive` - True/False status

**Key Methods:**
```gdscript
char.take_damage(10)              # Deal damage (reduced by defense)
char.heal(5)                      # Restore health
char.perform_attack(target)       # Attack another character
char.add_item("sword_id")         # Add item to inventory
char.add_ability("power_strike")  # Learn an ability
```

**Example:**
```gdscript
var player = Character.new()
player.attack = 12
player.defense = 5
player.speed = 10
player.perform_attack(enemy)  # Deals ~12 damage to enemy
```

---

### 2. **GameManager** (`scripts/core/game_manager.gd`)

**What it does:** Global game state - initializes teams and enemies

**Key Properties:**
- `player1_team` - Array of 2 characters for Player 1
- `player2_team` - Array of 2 characters for Player 2
- `current_enemies` - Array of enemy characters
- `combat_active` - Boolean flag for active combat

**Key Methods:**
```gdscript
GameManager.initialize_enemies(3)          # Create 3 random enemies
GameManager.is_team_alive(player1_team)    # Check if team still alive
GameManager.get_alive_characters(team)     # Get only living characters
GameManager.start_combat()                 # Initialize combat
```

**How it initializes teams:**
```gdscript
# Creates Player 1 with 2 characters:
# - Character 1: HP=100, ATK=12, DEF=5, SPD=10
# - Character 2: HP=80, ATK=15, DEF=3, SPD=12

# Creates Player 2 with 2 characters (same stats as Player 1)

# Creates 3 random enemies with varied stats
```

---

### 3. **TurnSystem** (`scripts/combat/turn_system.gd`)

**What it does:** Manages turn order and who gets to act next

**Key Properties:**
- `turn_order` - Array of all characters sorted by speed (fastest first)
- `current_turn_index` - Which character's turn it is now
- `all_characters` - Every character in combat

**Key Methods:**
```gdscript
turn_system.initialize_turn_order(p1_team, p2_team, enemies)
turn_system.get_current_character()        # Returns whose turn it is
turn_system.end_turn()                     # Move to next character
turn_system.refresh_turn_order()           # Update after death
turn_system.get_turn_order_info()          # Get UI display data
```

**How it works:**
```
1. Initialize turn order: Characters sorted by speed
   Example: [Enemy(SPD=12), Player1Char2(SPD=12), Player1Char1(SPD=10), ...]
   
2. get_current_character() returns: Enemy (fastest)

3. Enemy takes their action

4. end_turn() called → Move to next character

5. get_current_character() returns: Player1Char2

6. Repeat until all characters acted
```

---

### 4. **ItemSystem** (`scripts/core/item_system.gd`)

**What it does:** Database of all items and abilities in the game

**Item Example:**
```gdscript
var sword = {
    "id": "iron_sword",
    "name": "Iron Sword",
    "rarity": "common",
    "attack": 5,
    "defense": 0,
    "health": 0,
    "speed": 0
}
```

**Ability Example:**
```gdscript
var power_strike = {
    "id": "power_strike",
    "name": "Power Strike",
    "damage": 20,
    "cooldown": 2,
    "mana_cost": 10
}
```

**Rarities & Colors:**
- **Common** (Gray) - Basic items
- **Uncommon** (Green) - Better items
- **Rare** (Blue) - Strong items
- **Epic** (Purple) - Very strong
- **Legendary** (Orange) - Best items

---

### 5. **CombatManager** (`scripts/combat/combat_manager.gd`)

**What it does:** Orchestrates the entire battle - actions, logging, win/lose

**Key Methods:**
```gdscript
combat_manager.perform_action(actor, target, action_type)  # Execute attack
combat_manager.check_win_condition()                        # See who won
combat_manager.get_combat_log()                             # Get all events
```

**Combat Flow:**
```
1. Combat starts
2. TurnSystem initializes turn order
3. Loop:
   - Get current character from TurnSystem
   - Character performs action (attack, ability, etc)
   - Log action to combat log
   - Check if anyone died
   - If someone died, refresh turn order
   - Move to next turn
4. Check win condition:
   - If all enemies dead → VICTORY
   - If all players dead → DEFEAT
```

---

## Data Flow: A Complete Combat Turn

```
┌─ Map Screen (Player clicks "Level 1") ─────────────┐
│                                                      │
├─ Team Setup Scene (Player clicks "Start Combat")   │
│                                                      │
├─ CombatManager created                             │
│  └─ TurnSystem.initialize_turn_order()              │
│     └─ Gets teams from GameManager                  │
│     └─ Gets enemies from GameManager                │
│     └─ Sorts all characters by speed                │
│                                                      │
├─ Combat Loop Starts                                │
│  ├─ TurnSystem.get_current_character()              │
│  │  └─ Returns: first character in turn_order       │
│  │                                                   │
│  ├─ Character performs action                       │
│  │  └─ target.take_damage(damage - target.defense)  │
│  │  └─ If target.current_health <= 0:              │
│  │     └─ target.is_alive = false                   │
│  │                                                   │
│  ├─ CombatManager.perform_action() logs event       │
│  │                                                   │
│  ├─ Check if anyone died                           │
│  │  └─ If yes: TurnSystem.refresh_turn_order()      │
│  │                                                   │
│  ├─ CombatManager.check_win_condition()             │
│  │  ├─ If all enemies dead → VICTORY               │
│  │  ├─ If all players dead → DEFEAT                │
│  │  └─ Else: Continue                               │
│  │                                                   │
│  ├─ TurnSystem.end_turn()                           │
│  │  └─ current_turn_index++                         │
│  │  └─ Skip dead characters                         │
│  │                                                   │
│  └─ [Loop back to get_current_character()]          │
│                                                      │
└─ Combat Ends → Return to Map Screen ──────────────┘
```

---

## File Structure

```
📁 scripts/
  📁 core/
    ├── game_manager.gd        ← Global state, team initialization
    └── item_system.gd         ← Item/ability database
  📁 combat/
    ├── combat_manager.gd      ← Battle orchestration
    ├── turn_system.gd         ← Turn order management
    └── action_system.gd       ← Action handling (placeholder)
  📁 entities/
    └── character.gd           ← Base character class
  📁 ui/
    ├── map_ui.gd
    ├── combat_ui.gd
    └── inventory_ui.gd
📁 scenes/
  📁 map/
    └── map_screen.tscn        ← Level selection
  📁 combat/
    ├── combat_screen.tscn     ← Battle display
    ├── team_setup.tscn        ← Pre-combat setup
    └── ui/
        └── combat_ui.tscn     ← Combat HUD
  📁 components/
    ├── team_member.tscn       ← Player character visual
    └── enemy.tscn             ← Enemy visual
```

---

## Quick Reference: Key Functions

### Starting a Combat

```gdscript
# 1. GameManager initializes teams (already done in _ready())
var p1_team = GameManager.player1_team
var p2_team = GameManager.player2_team

# 2. Create enemies
GameManager.initialize_enemies(3)
var enemies = GameManager.current_enemies

# 3. Create CombatManager
var combat_manager = CombatManager.new()
combat_manager.initialize(p1_team, p2_team, enemies)

# 4. Combat starts automatically in CombatManager._ready()
```

### During Combat

```gdscript
# Get whose turn it is
var current_char = combat_manager.turn_system.get_current_character()

# Character performs action (automatic or player-controlled)
var damage = current_char.perform_attack(target)

# Log the action
combat_manager.log_action(current_char.name + " attacked!")

# End turn
combat_manager.turn_system.end_turn()

# Check if anyone won
var result = combat_manager.check_win_condition()
# Returns: "ongoing", "player_victory", or "player_defeat"
```

### After Combat

```gdscript
# Get combat log (all actions that happened)
var log = combat_manager.get_combat_log()

# Generate loot (to be implemented)
var loot = ItemSystem.generate_loot_drop("legendary")

# Award items to players
player1_team[0].add_item(loot["id"])

# Return to map
get_tree().change_scene_to_file("res://scenes/map/map_screen.tscn")
```

---

## Next Steps to Expand

### Priority 1: Visual Improvements
- Character cards with portraits
- Health bar displays
- Damage numbers floating above characters

### Priority 2: Player Interaction
- Click to select targets
- Choose actions (attack, ability, item use)
- Drag to position team members

### Priority 3: Progression
- Loot drops after victory
- Equipment system to boost stats
- Inventory management

### Priority 4: Advanced Features
- Enemy AI decision making
- Procedural generation
- Co-op multiplayer networking

---

## Tips for Understanding the Code

1. **Start with Character.gd** - It's the simplest and most fundamental
2. **Then GameManager** - Understand how teams are created
3. **Then TurnSystem** - See how turn order works
4. **Then CombatManager** - Watch it all come together
5. **Then ItemSystem** - Add content to your game

Each system builds on the previous one!

---

## Common Questions

**Q: Where do I add new items?**
A: Edit `ItemSystem.gd` in the `_init_items()` function

**Q: How do I change character stats?**
A: Edit `GameManager.gd` in the `_initialize_teams()` function

**Q: How do I add new enemies?**
A: Edit `GameManager.initialize_enemies()` to customize enemy creation

**Q: How do I make combat faster/slower?**
A: Add delays in `CombatManager` between actions

**Q: How do I save player progress?**
A: Implement save/load in `GameManager` (not yet implemented)

---

Still have questions? Let me know what's confusing and I can create focused guides on specific systems! 🚀
