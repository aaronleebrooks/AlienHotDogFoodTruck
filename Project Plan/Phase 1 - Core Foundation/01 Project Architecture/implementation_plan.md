# Project Architecture Implementation Plan

## Overview
This document provides the step-by-step implementation plan for establishing the project architecture for the hot dog idle game, incorporating proper Godot 4.4 event patterns and best practices.

## Key Architecture Principles

### 1. Signal-Based Communication
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
1. **Resource Management System**
   ```gdscript
   # scripts/autoload/resource_manager.gd
   extends Node
   
   signal resource_loaded(resource_path: String, resource: Resource)
   signal resource_failed(resource_path: String, error: String)
   signal memory_usage_updated(usage: float)
   
   var resource_cache: Dictionary = {}
   var loading_queue: Array[String] = []
   var max_cache_size: int = 100
   
   func _ready():
       print("ResourceManager initialized")
   
   func load_resource(path: String) -> Resource:
       """Load a resource with caching"""
       if resource_cache.has(path):
           return resource_cache[path]
       
       var resource = load(path)
       if resource:
           resource_cache[path] = resource
           resource_loaded.emit(path, resource)
           _cleanup_cache_if_needed()
       else:
           resource_failed.emit(path, "Failed to load resource")
       
       return resource
   
   func _cleanup_cache_if_needed():
       """Clean up cache if it exceeds max size"""
       if resource_cache.size() > max_cache_size:
           var oldest_key = resource_cache.keys()[0]
           resource_cache.erase(oldest_key)
   
   func get_memory_usage() -> float:
       """Get current memory usage"""
       var usage = OS.get_static_memory_usage()
       memory_usage_updated.emit(usage)
       return usage
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

## Phase 1B: UI Framework (Days 3-4)

### Day 3: UI Components

#### Morning Session (4 hours)
1. **Custom Button Component**
   ```gdscript
   # scenes/components/custom_button.tscn + .gd
   extends Button
   
   signal button_clicked(button_id: String)
   
   @export var button_style: String = "default"
   @export var hover_sound: AudioStream
   @export var click_sound: AudioStream
   @export var button_id: String = ""
   
   func _ready():
       setup_button()
       connect_signals()
   
   func setup_button():
       # Apply consistent styling
       add_theme_color_override("font_color", Color.WHITE)
       add_theme_font_size_override("font_size", 16)
   
   func connect_signals():
       pressed.connect(_on_pressed)
       mouse_entered.connect(_on_mouse_entered)
   
   func _on_pressed():
       button_clicked.emit(button_id)
       if click_sound:
           AudioManager.play_sound(click_sound)
   
   func _on_mouse_entered():
       if hover_sound:
           AudioManager.play_sound(hover_sound)
   ```

2. **Custom Panel Component**
   ```gdscript
   # scenes/components/custom_panel.tscn + .gd
   extends Panel
   
   signal panel_opened
   signal panel_closed
   
   @export var panel_title: String = ""
   @export var auto_show: bool = false
   
   func _ready():
       if auto_show:
           show_panel()
   
   func show_panel():
       visible = true
       panel_opened.emit()
   
   func hide_panel():
       visible = false
       panel_closed.emit()
   ```

#### Afternoon Session (4 hours)
3. **Modal Dialog System**
   ```gdscript
   # scenes/components/modal_dialog.tscn + .gd
   extends Control
   
   signal dialog_closed
   signal dialog_confirmed
   signal dialog_cancelled
   
   @export var dialog_title: String = ""
   @export var dialog_content: String = ""
   @export var show_confirm_button: bool = true
   @export var show_cancel_button: bool = true
   
   @onready var title_label: Label = $DialogPanel/TitleLabel
   @onready var content_label: Label = $DialogPanel/ContentLabel
   @onready var confirm_button: Button = $DialogPanel/ConfirmButton
   @onready var cancel_button: Button = $DialogPanel/CancelButton
   
   func _ready():
       connect_signals()
       update_display()
   
   func connect_signals():
       confirm_button.pressed.connect(_on_confirm_pressed)
       cancel_button.pressed.connect(_on_cancel_pressed)
   
   func show_dialog(title: String, content: String):
       dialog_title = title
       dialog_content = content
       update_display()
       visible = true
   
   func update_display():
       title_label.text = dialog_title
       content_label.text = dialog_content
       confirm_button.visible = show_confirm_button
       cancel_button.visible = show_cancel_button
   
   func _on_confirm_pressed():
       dialog_confirmed.emit()
       hide_dialog()
   
   func _on_cancel_pressed():
       dialog_cancelled.emit()
       hide_dialog()
   
   func hide_dialog():
       visible = false
       dialog_closed.emit()
   ```

4. **HUD Framework**
   ```gdscript
   # scenes/ui/hud.tscn + .gd
   extends Control
   
   signal hud_element_clicked(element_name: String)
   
   @onready var money_display: Label = $TopBar/MoneyDisplay
   @onready var time_display: Label = $TopBar/TimeDisplay
   @onready var status_display: Label = $TopBar/StatusDisplay
   
   func _ready():
       setup_hud()
   
   func setup_hud():
       # Initialize HUD elements
       update_money_display(0.0)
       update_time_display(0.0)
       update_status_display("Ready")
   
   func update_money_display(amount: float):
       money_display.text = "Money: $%.2f" % amount
   
   func update_time_display(time: float):
       time_display.text = "Time: %.1fs" % time
   
   func update_status_display(status: String):
       status_display.text = "Status: %s" % status
   ```

### Day 4: Navigation and State Management

#### Morning Session (4 hours)
1. **Scene Management Setup**
   ```gdscript
   # scripts/autoload/scene_manager.gd
   extends Node
   
   signal scene_changed(new_scene: String, old_scene: String)
   signal scene_loaded(scene_name: String)
   signal scene_unloaded(scene_name: String)
   
   var current_scene: Node
   var scene_stack: Array[String] = []
   var loading_scene: String = ""
   
   func _ready():
       print("SceneManager initialized")
   
   func change_scene(scene_path: String, add_to_stack: bool = true):
       loading_scene = scene_path
       
       if current_scene:
           scene_unloaded.emit(current_scene.scene_file_path)
           current_scene.queue_free()
       
       var new_scene = load(scene_path).instantiate()
       get_tree().current_scene.add_child(new_scene)
       current_scene = new_scene
       
       if add_to_stack:
           scene_stack.append(scene_path)
       
       scene_changed.emit(scene_path, "")
       scene_loaded.emit(scene_path)
   
   func go_back():
       if scene_stack.size() > 1:
           scene_stack.pop_back()
           var previous_scene = scene_stack.back()
           change_scene(previous_scene, false)
   ```

2. **Menu System**
   ```gdscript
   # scenes/ui/main_menu.tscn + .gd
   extends Control
   
   signal start_game_requested
   signal continue_game_requested
   signal settings_requested
   signal quit_game_requested
   
   @onready var start_button: Button = $MenuPanel/StartButton
   @onready var continue_button: Button = $MenuPanel/ContinueButton
   @onready var settings_button: Button = $MenuPanel/SettingsButton
   @onready var quit_button: Button = $MenuPanel/QuitButton
   
   func _ready():
       connect_signals()
       update_button_states()
   
   func connect_signals():
       start_button.pressed.connect(_on_start_pressed)
       continue_button.pressed.connect(_on_continue_pressed)
       settings_button.pressed.connect(_on_settings_pressed)
       quit_button.pressed.connect(_on_quit_pressed)
   
   func _on_start_pressed():
       start_game_requested.emit()
   
   func _on_continue_pressed():
       continue_game_requested.emit()
   
   func _on_settings_pressed():
       settings_requested.emit()
   
   func _on_quit_pressed():
       quit_game_requested.emit()
   
   func update_button_states():
       # Enable/disable buttons based on game state
       continue_button.disabled = not SaveManager.has_save_file()
   ```

#### Afternoon Session (4 hours)
3. **Settings System**
   ```gdscript
   # scenes/ui/settings_panel.tscn + .gd
   extends Control
   
   signal setting_changed(setting_name: String, value: Variant)
   signal settings_saved
   signal settings_cancelled
   
   @onready var music_slider: HSlider = $SettingsPanel/MusicSlider
   @onready var sfx_slider: HSlider = $SettingsPanel/SFXSlider
   @onready var fullscreen_toggle: CheckBox = $SettingsPanel/FullscreenToggle
   @onready var save_button: Button = $SettingsPanel/SaveButton
   @onready var cancel_button: Button = $SettingsPanel/CancelButton
   
   func _ready():
       connect_signals()
       load_current_settings()
   
   func connect_signals():
       music_slider.value_changed.connect(_on_music_changed)
       sfx_slider.value_changed.connect(_on_sfx_changed)
       fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
       save_button.pressed.connect(_on_save_pressed)
       cancel_button.pressed.connect(_on_cancel_pressed)
   
   func _on_music_changed(value: float):
       setting_changed.emit("music_volume", value)
   
   func _on_sfx_changed(value: float):
       setting_changed.emit("sfx_volume", value)
   
   func _on_fullscreen_toggled(button_pressed: bool):
       setting_changed.emit("fullscreen", button_pressed)
   
   func _on_save_pressed():
       save_settings()
       settings_saved.emit()
   
   func _on_cancel_pressed():
       load_current_settings()
       settings_cancelled.emit()
   
   func load_current_settings():
       # Load settings from SaveManager
       pass
   
   func save_settings():
       # Save settings to SaveManager
       pass
   ```

4. **Loading Screen System**
   ```gdscript
   # scenes/ui/loading_screen.tscn + .gd
   extends Control
   
   signal loading_completed
   signal loading_progress(progress: float)
   
   @onready var progress_bar: ProgressBar = $LoadingPanel/ProgressBar
   @onready var status_label: Label = $LoadingPanel/StatusLabel
   @onready var loading_animation: AnimationPlayer = $LoadingPanel/LoadingAnimation
   
   var loading_tasks: Array[String] = []
   var completed_tasks: int = 0
   
   func _ready():
       setup_loading_screen()
   
   func setup_loading_screen():
       progress_bar.max_value = 100.0
       progress_bar.value = 0.0
       status_label.text = "Initializing..."
       loading_animation.play("loading_spin")
   
   func start_loading(tasks: Array[String]):
       loading_tasks = tasks
       completed_tasks = 0
       update_progress()
   
   func complete_task(task_name: String):
       completed_tasks += 1
       status_label.text = "Completed: %s" % task_name
       update_progress()
   
   func update_progress():
       var progress = (float(completed_tasks) / float(loading_tasks.size())) * 100.0
       progress_bar.value = progress
       loading_progress.emit(progress)
       
       if completed_tasks >= loading_tasks.size():
           loading_completed.emit()
   ```

## Phase 1C: Data Management (Days 5-6)

### Day 5: Save System Foundation

#### Morning Session (4 hours)
1. **Save Data Structures**
   ```gdscript
   # scripts/data/save_data.gd
   class_name SaveData
   extends Resource
   
   @export var version: String = "1.0.0"
   @export var save_date: String = ""
   @export var game_data: GameData
   @export var settings: Dictionary = {}
   
   func to_dict() -> Dictionary:
       return {
           "version": version,
           "save_date": save_date,
           "game_data": game_data.to_dict(),
           "settings": settings
       }
   
   static func from_dict(data: Dictionary) -> SaveData:
       var save_data = SaveData.new()
       save_data.version = data.get("version", "1.0.0")
       save_data.save_date = data.get("save_date", "")
       save_data.game_data = GameData.from_dict(data.get("game_data", {}))
       save_data.settings = data.get("settings", {})
       return save_data
   ```

2. **Save Manager Core**
   ```gdscript
   # scripts/autoload/save_manager.gd
   extends Node
   
   signal save_completed
   signal save_failed(error: String)
   signal load_completed
   signal load_failed(error: String)
   signal auto_save_triggered
   
   const SAVE_PATH = "user://saves/"
   const AUTO_SAVE_INTERVAL = 30.0
   
   var auto_save_timer: Timer
   var current_save_data: SaveData
   var is_saving: bool = false
   
   func _ready():
       setup_auto_save()
       load_game()
   
   func setup_auto_save():
       auto_save_timer = Timer.new()
       auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
       auto_save_timer.timeout.connect(auto_save)
       add_child(auto_save_timer)
       auto_save_timer.start()
   
   func save_game() -> bool:
       if is_saving:
           return false
       
       is_saving = true
       
       # Collect data from all systems
       current_save_data = SaveData.new()
       current_save_data.game_data = collect_game_data()
       current_save_data.settings = collect_settings()
       current_save_data.save_date = Time.get_datetime_string_from_system()
       
       # Save to file
       var result = write_save_file()
       
       is_saving = false
       
       if result:
           save_completed.emit()
       else:
           save_failed.emit("Failed to write save file")
       
       return result
   
   func load_game() -> bool:
       var result = read_save_file()
       
       if result:
           apply_loaded_data()
           load_completed.emit()
       else:
           load_failed.emit("Failed to read save file")
       
       return result
   
   func auto_save():
       auto_save_triggered.emit()
       save_game()
   
   func collect_game_data() -> GameData:
       # Collect data from GameManager and other systems
       var game_data = GameData.new()
       game_data.player_money = GameManager.player_money
       game_data.game_time = GameManager.get_game_time()
       return game_data
   
   func collect_settings() -> Dictionary:
       # Collect settings from various systems
       return {
           "music_volume": AudioManager.get_music_volume(),
           "sfx_volume": AudioManager.get_sfx_volume(),
           "fullscreen": DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
       }
   
   func write_save_file() -> bool:
       # Implementation for writing save file
       return true
   
   func read_save_file() -> bool:
       # Implementation for reading save file
       return true
   
   func apply_loaded_data():
       # Apply loaded data to all systems
       if current_save_data:
           GameManager.player_money = current_save_data.game_data.player_money
           # Apply other data...
   ```

#### Afternoon Session (4 hours)
3. **Save Operations**
   - Implement save file writing
   - Create save file validation
   - Set up save file backup system

4. **Load Operations**
   - Implement save file reading
   - Create load error handling
   - Set up save file migration

### Day 6: Game Data Management

#### Morning Session (4 hours)
1. **Game Data Implementation**
   ```gdscript
   # scripts/data/game_data.gd
   class_name GameData
   extends Resource
   
   @export var player_money: float = 0.0
   @export var game_time: float = 0.0
   @export var hot_dogs_made: int = 0
   @export var hot_dogs_sold: int = 0
   @export var current_level: int = 1
   @export var upgrades: Dictionary = {}
   @export var achievements: Array[String] = []
   
   func add_money(amount: float):
       player_money += amount
       # Signal is emitted by the system that calls this method
   
   func spend_money(amount: float) -> bool:
       if player_money >= amount:
           player_money -= amount
           return true
       return false
   
   func to_dict() -> Dictionary:
       return {
           "player_money": player_money,
           "game_time": game_time,
           "hot_dogs_made": hot_dogs_made,
           "hot_dogs_sold": hot_dogs_sold,
           "current_level": current_level,
           "upgrades": upgrades,
           "achievements": achievements
       }
   
   static func from_dict(data: Dictionary) -> GameData:
       var game_data = GameData.new()
       game_data.player_money = data.get("player_money", 0.0)
       game_data.game_time = data.get("game_time", 0.0)
       game_data.hot_dogs_made = data.get("hot_dogs_made", 0)
       game_data.hot_dogs_sold = data.get("hot_dogs_sold", 0)
       game_data.current_level = data.get("current_level", 1)
       game_data.upgrades = data.get("upgrades", {})
       game_data.achievements = data.get("achievements", [])
       return game_data
   ```

2. **Data Validation System**
   ```gdscript
   # scripts/data/data_validator.gd
   class_name DataValidator
   extends RefCounted
   
   static func validate_game_data(data: Dictionary) -> Dictionary:
       var errors: Array[String] = []
       var warnings: Array[String] = []
       
       # Validate required fields
       if not data.has("player_money"):
           errors.append("Missing player_money field")
       elif data.player_money < 0:
           warnings.append("Player money is negative")
       
       if not data.has("game_time"):
           errors.append("Missing game_time field")
       elif data.game_time < 0:
           warnings.append("Game time is negative")
       
       # Validate data types
       if data.has("hot_dogs_made") and not data.hot_dogs_made is int:
           errors.append("hot_dogs_made must be an integer")
       
       if data.has("current_level") and not data.current_level is int:
           errors.append("current_level must be an integer")
       
       return {
           "is_valid": errors.size() == 0,
           "errors": errors,
           "warnings": warnings
       }
   
   static func validate_save_data(data: Dictionary) -> Dictionary:
       var errors: Array[String] = []
       var warnings: Array[String] = []
       
       # Validate save file structure
       if not data.has("version"):
           errors.append("Missing version field")
       
       if not data.has("game_data"):
           errors.append("Missing game_data field")
       else:
           var game_data_validation = validate_game_data(data.game_data)
           errors.append_array(game_data_validation.errors)
           warnings.append_array(game_data_validation.warnings)
       
       return {
           "is_valid": errors.size() == 0,
           "errors": errors,
           "warnings": warnings
       }
   ```

#### Afternoon Session (4 hours)
3. **Performance Monitoring**
   ```gdscript
   # scripts/autoload/performance_monitor.gd
   extends Node
   
   signal performance_warning(metric: String, value: float)
   signal performance_optimization_suggested(suggestion: String)
   signal frame_rate_dropped(fps: float)
   signal memory_usage_high(usage: float)
   
   var frame_rate_history: Array[float] = []
   var memory_usage_history: Array[float] = []
   var max_history_size: int = 100
   var warning_thresholds: Dictionary = {
       "fps": 30.0,
       "memory_mb": 512.0,
       "cpu_percent": 80.0
   }
   
   func _ready():
       print("PerformanceMonitor initialized")
   
   func _process(_delta: float):
       monitor_performance()
   
   func monitor_performance():
       var current_fps = Engine.get_frames_per_second()
       var current_memory = OS.get_static_memory_usage() / 1024.0 / 1024.0  # MB
       
       # Record history
       frame_rate_history.append(current_fps)
       memory_usage_history.append(current_memory)
       
       # Limit history size
       if frame_rate_history.size() > max_history_size:
           frame_rate_history.pop_front()
       if memory_usage_history.size() > max_history_size:
           memory_usage_history.pop_front()
       
       # Check for warnings
       if current_fps < warning_thresholds.fps:
           frame_rate_dropped.emit(current_fps)
           performance_warning.emit("low_fps", current_fps)
       
       if current_memory > warning_thresholds.memory_mb:
           memory_usage_high.emit(current_memory)
           performance_warning.emit("high_memory", current_memory)
   
   func get_average_fps() -> float:
       if frame_rate_history.size() == 0:
           return 0.0
       
       var sum = 0.0
       for fps in frame_rate_history:
           sum += fps
       return sum / frame_rate_history.size()
   
   func get_average_memory_usage() -> float:
       if memory_usage_history.size() == 0:
           return 0.0
       
       var sum = 0.0
       for memory in memory_usage_history:
           sum += memory
       return sum / memory_usage_history.size()
   
   func suggest_optimizations() -> Array[String]:
       var suggestions: Array[String] = []
       
       var avg_fps = get_average_fps()
       var avg_memory = get_average_memory_usage()
       
       if avg_fps < 45.0:
           suggestions.append("Consider reducing visual effects or lowering resolution")
       
       if avg_memory > 256.0:
           suggestions.append("Consider implementing object pooling or reducing asset quality")
       
       return suggestions
   ```

4. **Testing Framework Setup**
   ```gdscript
   # tests/test_runner.gd
   extends GutTest
   
   # Base test class for all game tests
   class_name GameTest
   
   var test_data: Dictionary = {}
   
   func setup():
       # Common setup for all tests
       test_data.clear()
   
   func teardown():
       # Common cleanup for all tests
       test_data.clear()
   
   func assert_signal_emitted(signal_name: String, object: Object):
       """Assert that a signal was emitted"""
       var signal_emitted = false
       object.get_signal_list()
       # Implementation depends on GUT version
   
   func assert_signal_not_emitted(signal_name: String, object: Object):
       """Assert that a signal was not emitted"""
       # Implementation depends on GUT version
   
   func create_mock_system(system_name: String) -> Node:
       """Create a mock system for testing"""
       var mock = Node.new()
       mock.name = system_name
       add_child_autofree(mock)
       return mock
   ```

## Phase 1D: Integration and Testing (Day 7)

### Day 7: Final Integration

#### Morning Session (4 hours)
1. **System Integration**
   ```gdscript
   # scripts/scenes/main_scene.gd - Updated with all systems
   extends Control
   
   # UI references
   @onready var game_ui: Control = $UI/GameUI
   @onready var menu_ui: Control = $UI/MenuUI
   @onready var settings_ui: Control = $UI/SettingsUI
   @onready var loading_ui: Control = $UI/LoadingUI
   
   # System references
   @onready var production_system: Node = $Systems/ProductionSystem
   @onready var economy_system: Node = $Systems/EconomySystem
   
   # Current active UI
   var current_ui: Control
   
   func _ready() -> void:
       # Connect UI signals
       game_ui.add_hot_dog_requested.connect(_on_add_hot_dog_requested)
       game_ui.pause_game_requested.connect(_on_pause_game_requested)
       game_ui.save_game_requested.connect(_on_save_game_requested)
       game_ui.menu_requested.connect(_on_menu_requested)
       
       menu_ui.start_game_requested.connect(_on_start_game_requested)
       menu_ui.continue_game_requested.connect(_on_continue_game_requested)
       menu_ui.settings_requested.connect(_on_settings_requested)
       menu_ui.quit_game_requested.connect(_on_quit_game_requested)
       
       settings_ui.setting_changed.connect(_on_setting_changed)
       settings_ui.settings_saved.connect(_on_settings_saved)
       
       # Connect system signals
       production_system.hot_dog_produced.connect(_on_hot_dog_produced)
       economy_system.money_changed.connect(_on_money_changed)
       
       # Connect autoload signals
       UIManager.screen_changed.connect(_on_screen_changed)
       SaveManager.save_completed.connect(_on_save_completed)
       SaveManager.load_completed.connect(_on_load_completed)
       
       # Show initial UI (menu)
       show_ui("menu")
   
   func show_ui(ui_name: String) -> void:
       # Hide current UI
       if current_ui:
           current_ui.visible = false
       
       # Show new UI
       match ui_name:
           "menu":
               current_ui = menu_ui
           "game":
               current_ui = game_ui
           "settings":
               current_ui = settings_ui
           "loading":
               current_ui = loading_ui
           _:
               print("MainScene: Unknown UI: %s" % ui_name)
               return
       
       current_ui.visible = true
       print("MainScene: Showing UI: %s" % ui_name)
   
   # Signal handlers for UI
   func _on_add_hot_dog_requested() -> void:
       production_system.add_to_queue()
   
   func _on_pause_game_requested() -> void:
       if GameManager.is_game_running:
           GameManager.pause_game()
       else:
           GameManager.resume_game()
   
   func _on_save_game_requested() -> void:
       SaveManager.save_game()
   
   func _on_menu_requested() -> void:
       UIManager.show_screen("menu")
   
   func _on_start_game_requested() -> void:
       GameManager.start_game()
       UIManager.show_screen("game")
   
   func _on_continue_game_requested() -> void:
       SaveManager.load_game()
       UIManager.show_screen("game")
   
   func _on_settings_requested() -> void:
       UIManager.show_screen("settings")
   
   func _on_quit_game_requested() -> void:
       get_tree().quit()
   
   func _on_setting_changed(setting_name: String, value: Variant) -> void:
       # Apply setting changes
       match setting_name:
           "music_volume":
               AudioManager.set_music_volume(value)
           "sfx_volume":
               AudioManager.set_sfx_volume(value)
           "fullscreen":
               if value:
                   DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
               else:
                   DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
   
   func _on_settings_saved() -> void:
       UIManager.show_screen("menu")
   
   # Signal handlers for systems
   func _on_hot_dog_produced() -> void:
       economy_system.sell_hot_dog()
   
   func _on_money_changed(new_amount: float, change: float) -> void:
       game_ui.update_money_display(new_amount)
   
   # Signal handlers for autoloads
   func _on_screen_changed(new_screen: String, old_screen: String) -> void:
       show_ui(new_screen)
   
   func _on_save_completed() -> void:
       print("MainScene: Save completed")
   
   func _on_load_completed() -> void:
       print("MainScene: Load completed")
   ```

2. **Performance Testing**
   - Run performance benchmarks
   - Test memory usage
   - Validate frame rate targets

#### Afternoon Session (4 hours)
3. **Documentation**
   - Complete architecture documentation
   - Create API documentation
   - Write development guides

4. **Final Testing**
   - Run full integration tests
   - Test error scenarios
   - Validate save/load functionality

## Implementation Notes

### Key Design Decisions
1. **Autoload Order**: GameManager → ResourceManager → SaveManager → UIManager → SceneManager → PerformanceMonitor
2. **Signal-Based Architecture**: All systems communicate via signals
3. **Component-Based Design**: Reusable components for UI elements
4. **Data-Driven Approach**: Game data separated from logic

### Performance Considerations
- Use object pooling for frequently created objects
- Implement lazy loading for assets
- Cache frequently accessed data
- Monitor memory usage and cleanup

### Testing Strategy
- Unit tests for all core systems
- Integration tests for system interactions
- Performance tests for critical paths
- Manual testing for UI interactions

### Future Extensibility
- Architecture supports adding new game systems
- UI framework can accommodate new screens
- Save system can handle new data types
- Signal system can support new features

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