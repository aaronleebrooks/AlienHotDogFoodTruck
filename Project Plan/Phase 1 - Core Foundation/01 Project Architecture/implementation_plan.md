# Project Architecture Implementation Plan

## Overview
This document provides the step-by-step implementation plan for establishing the project architecture for the hot dog idle game, incorporating proper Godot 4.4 event patterns and best practices.

## Key Architecture Principles

### 1. Event-Driven Communication
- **UI Components emit signals** → **Main Scene listens** → **Main Scene coordinates systems**
- **Systems emit signals** → **Main Scene listens** → **Main Scene updates UI**
- **No direct method calls** between UI and systems
- **Loose coupling** through signal-based communication

### 2. Unique Name Identifiers
- **Use `%` identifiers** for accessing nodes across the scene tree
- **Set `unique_name_in_owner = true`** for nodes that need global access
- **Avoid `get_parent().get_parent()`** chains
- **Clean, maintainable node references**

### 3. Proper Node Hierarchy
- **Main Scene** coordinates all systems and UI
- **UI Components** are self-contained and emit signals
- **Systems** are independent and emit signals
- **Autoloads** provide global services

## Phase 1A: Foundation Setup (Days 1-2)

### Day 1: Project Structure and Standards

#### Morning Session (4 hours)
1. **Project Structure Creation**
   ```bash
   # Create main directories
   mkdir -p scenes/{ui,systems,components}
   mkdir -p scripts/{autoload,scenes,data,utils}
   mkdir -p assets/{ui,fonts,sounds,sprites}
   mkdir -p tests/{unit,integration}
   mkdir -p docs/{architecture,api,guides}
   ```

2. **Coding Standards Definition**
   - Create `docs/coding_standards.md`
   - Define naming conventions
   - Set up `.editorconfig` file
   - Create code templates

#### Afternoon Session (4 hours)
3. **Autoload Script Creation**
   ```gdscript
   # scripts/autoload/game_manager.gd
   extends Node
   
   signal game_state_changed(new_state: String)
   signal money_changed(new_amount: float)
   
   var current_state: String = "menu"
   var player_money: float = 0.0
   
   func _ready():
       print("GameManager initialized")
   
   func change_game_state(new_state: String):
       current_state = new_state
       game_state_changed.emit(new_state)
   ```

4. **Base Classes Setup**
   - Create `scripts/utils/base_component.gd`
   - Create `scripts/utils/base_scene.gd`
   - Create `scripts/data/game_data.gd`

### Day 2: Core Systems Implementation

#### Morning Session (4 hours)
1. **Event System Implementation**
   ```gdscript
   # scripts/autoload/event_manager.gd
   extends Node
   
   # Use Godot's built-in signal system instead of custom events
   # Systems emit signals, main scene coordinates
   
   func _ready():
       print("EventManager initialized")
   
   func _exit_tree():
       # Disconnect all signals to prevent memory leaks
       # This is handled by individual systems
       pass
   ```

2. **Save Manager Implementation**
   ```gdscript
   # scripts/autoload/save_manager.gd
   extends Node
   
   signal save_completed
   signal save_failed
   signal load_completed
   signal load_failed
   
   const SAVE_FILE_PATH = "user://save_data.json"
   var save_data: Dictionary = {}
   
   func _ready():
       print("SaveManager initialized")
   
   func save_game():
       # Implementation details
       save_completed.emit()
   
   func load_game():
       # Implementation details
       load_completed.emit()
   ```

#### Afternoon Session (4 hours)
3. **UI Manager Implementation**
   ```gdscript
   # scripts/autoload/ui_manager.gd
   extends Node
   
   signal screen_changed(new_screen: String, old_screen: String)
   signal ui_ready
   
   var current_screen: String = ""
   var ui_stack: Array[String] = []
   
   func _ready():
       print("UIManager initialized")
       ui_ready.emit()
   
   func show_screen(screen_name: String):
       var old_screen = current_screen
       current_screen = screen_name
       ui_stack.append(screen_name)
       screen_changed.emit(screen_name, old_screen)
   ```

4. **Main Scene Structure**
   ```gdscript
   # scripts/scenes/main_scene.gd
   extends Control
   
   # UI references
   @onready var game_ui: Control = $UI/GameUI
   @onready var menu_ui: Control = $UI/MenuUI
   
   # System references
   @onready var production_system: Node = $Systems/ProductionSystem
   @onready var economy_system: Node = $Systems/EconomySystem
   
   func _ready():
       # Connect UI signals
       game_ui.add_hot_dog_requested.connect(_on_add_hot_dog_requested)
       game_ui.pause_game_requested.connect(_on_pause_game_requested)
       game_ui.save_game_requested.connect(_on_save_game_requested)
       game_ui.menu_requested.connect(_on_menu_requested)
       
       # Connect system signals
       production_system.hot_dog_produced.connect(_on_hot_dog_produced)
       economy_system.money_changed.connect(_on_money_changed)
   
   func _on_add_hot_dog_requested():
       production_system.add_to_queue()
   
   func _on_hot_dog_produced():
       economy_system.sell_hot_dog()
   ```

### Day 3: Scene Organization

#### Morning Session (4 hours)
1. **Main Scene Setup**
   ```gdscript
   # scenes/main/main_scene.tscn
   [gd_scene load_steps=X format=3 uid="uid://..."]
   
   [node name="MainScene" type="Control"]
   unique_name_in_owner = true
   script = ExtResource("1_0x0x0")
   
   [node name="UI" type="Control" parent="."]
   
   [node name="GameUI" parent="UI" instance=ExtResource("2_0x0x0")]
   
   [node name="MenuUI" parent="UI" instance=ExtResource("3_0x0x0")]
   
   [node name="Systems" type="Node" parent="."]
   
   [node name="ProductionSystem" parent="Systems" instance=ExtResource("4_0x0x0")]
   unique_name_in_owner = true
   
   [node name="EconomySystem" parent="Systems" instance=ExtResource("5_0x0x0")]
   unique_name_in_owner = true
   ```

2. **UI Component Implementation**
   ```gdscript
   # scripts/ui/game_ui.gd
   extends Control
   
   # UI emits signals, main scene listens
   signal add_hot_dog_requested
   signal pause_game_requested
   signal save_game_requested
   signal menu_requested
   
   @onready var money_label: Label = $TopBar/MoneyLabel
   @onready var add_hot_dog_button: Button = $GameArea/AddHotDogButton
   
   func _ready():
       add_hot_dog_button.pressed.connect(_on_add_hot_dog_pressed)
   
   func _on_add_hot_dog_pressed():
       add_hot_dog_requested.emit()
   
   func update_money_display(amount: float):
       money_label.text = "Money: $%.2f" % amount
   ```

#### Afternoon Session (4 hours)
3. **System Implementation**
   ```gdscript
   # scripts/systems/production_system.gd
   extends Node
   
   signal hot_dog_produced
   signal production_started
   signal production_stopped
   
   var is_producing: bool = false
   var current_queue_size: int = 0
   
   func add_to_queue():
       current_queue_size += 1
       if not is_producing:
           start_production()
   
   func start_production():
       is_producing = true
       production_started.emit()
   
   func _on_production_timer_timeout():
       if current_queue_size > 0:
           current_queue_size -= 1
           hot_dog_produced.emit()
   ```

4. **Signal Connection Patterns**
   ```gdscript
   # Proper signal connection in main scene
   func _ready():
       # Connect UI signals (UI → Main Scene)
       game_ui.add_hot_dog_requested.connect(_on_add_hot_dog_requested)
       
       # Connect system signals (Systems → Main Scene)
       production_system.hot_dog_produced.connect(_on_hot_dog_produced)
       
       # Connect autoload signals (Autoloads → Main Scene)
       UIManager.screen_changed.connect(_on_screen_changed)
   ```

### Day 4: Testing and Validation

#### Morning Session (4 hours)
1. **Signal Testing**
   ```gdscript
   # tests/unit/test_signal_communication.gd
   extends GutTest
   
   func test_ui_emits_signals():
       var game_ui = preload("res://scenes/ui/game_ui.tscn").instantiate()
       add_child_autofree(game_ui)
       
       var signal_emitted = false
       game_ui.add_hot_dog_requested.connect(func(): signal_emitted = true)
       
       game_ui._on_add_hot_dog_pressed()
       
       assert_true(signal_emitted)
   ```

2. **Integration Testing**
   ```gdscript
   # tests/integration/test_production_flow.gd
   extends GutTest
   
   func test_hot_dog_production_flow():
       var main_scene = preload("res://scenes/main/main_scene.tscn").instantiate()
       add_child_autofree(main_scene)
       
       # Simulate UI interaction
       main_scene._on_add_hot_dog_requested()
       
       # Verify system response
       assert_eq(main_scene.production_system.current_queue_size, 1)
   ```

#### Afternoon Session (4 hours)
3. **Performance Testing**
   - Test signal emission frequency
   - Monitor memory usage
   - Validate cleanup patterns

4. **Documentation**
   - Update architecture documentation
   - Create signal flow diagrams
   - Document unique name usage

## Key Design Decisions

### 1. Signal-Based Communication
- **UI Components**: Emit signals for user actions
- **Systems**: Emit signals for state changes
- **Main Scene**: Listens to all signals and coordinates
- **Autoloads**: Provide global services and emit global signals

### 2. Unique Name Identifiers
- **Main Scene**: `%MainScene` for global access
- **Systems**: `%ProductionSystem`, `%EconomySystem` for direct access
- **UI Components**: Use `%` identifiers when needed across scenes

### 3. Proper Cleanup
- **Signal Disconnection**: All systems disconnect signals in `_exit_tree()`
- **Memory Management**: Proper resource cleanup
- **Node Removal**: Clean removal from scene tree

### 4. Testing Strategy
- **Unit Tests**: Test individual signal emissions
- **Integration Tests**: Test complete signal flows
- **Performance Tests**: Monitor signal frequency and memory usage

## Performance Considerations
- Use signal batching for high-frequency updates
- Implement signal throttling where appropriate
- Monitor signal connection/disconnection overhead
- Cache frequently accessed node references

## Future Extensibility
- Architecture supports adding new UI components
- Systems can be added without modifying existing code
- Signal-based communication enables loose coupling
- Unique names provide clean access patterns

## Godot 4.4 Best Practices Integration

### Signal Management
- Use typed signals for better type safety
- Implement proper signal disconnection patterns
- Document all signals with clear parameter descriptions
- Use signal batching for performance optimization

### Node Access Patterns
- Prefer `%` identifiers over `get_parent()` chains
- Set `unique_name_in_owner = true` for global access
- Use `@onready` for better performance
- Implement proper node lifecycle management

### Resource Management
- Use `@export` annotations for inspector integration
- Implement proper resource cleanup
- Use `Resource` classes for data structures
- Follow Godot's resource lifecycle patterns 