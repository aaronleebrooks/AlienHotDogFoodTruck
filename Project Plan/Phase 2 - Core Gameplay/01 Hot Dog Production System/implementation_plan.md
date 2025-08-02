# Hot Dog Production System - Implementation Plan

## Overview
This document provides a detailed step-by-step implementation plan for the Hot Dog Production System, the core mechanic that drives the hot dog idle game, incorporating proper Godot 4.4 event patterns and best practices.

## Key Architecture Principles

### 1. Signal-Based Communication
- **Production System emits signals** for state changes
- **Main Scene listens** and coordinates with other systems
- **UI components** receive updates through main scene coordination
- **No direct method calls** between systems

### 2. Unique Name Identifiers
- **Use `%ProductionSystem`** for direct access when needed
- **Set `unique_name_in_owner = true`** in scene file
- **Clean node references** without parent chains

### 3. Proper System Design
- **Self-contained system** with clear responsibilities
- **Emit signals** for all state changes
- **Receive signals** for game state changes (pause/resume)

## Implementation Timeline
**Estimated Duration**: 3-4 days
**Sessions**: 6-8 coding sessions of 2-3 hours each

## Day 1: Core Production Mechanics

### Session 1: Basic Production System (2-3 hours)

#### Step 1: Create Production System Scene
```bash
# Create the production system scene
mkdir -p scenes/systems
touch scenes/systems/production_system.tscn
touch scripts/systems/production_system.gd
```

```gdscript
# scripts/systems/production_system.gd
extends Node

## Production system for managing hot dog production

# Production settings
@export var production_rate: float = 1.0  # Hot dogs per second
@export var max_queue_size: int = 10

# Production state
var is_producing: bool = false
var current_queue_size: int = 0
var total_produced: int = 0

# Node references
@onready var production_timer: Timer = $ProductionTimer
@onready var production_queue: Node = $ProductionQueue
@onready var production_stats: Node = $ProductionStats

# Signals - System emits these, main scene listens
signal production_started
signal production_stopped
signal hot_dog_produced
signal queue_full
signal queue_updated(current_size: int, max_size: int)

func _ready() -> void:
	"""Initialize the production system"""
	print("ProductionSystem: Initialized")
	
	# Connect timer signal
	production_timer.timeout.connect(_on_production_timer_timeout)
	
	# Connect GameManager signals for pause/resume
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_resumed.connect(_on_game_resumed)

func start_production() -> void:
	"""Start hot dog production"""
	if not is_producing and current_queue_size > 0:
		is_producing = true
		production_timer.start()
		production_started.emit()
		print("ProductionSystem: Production started")

func stop_production() -> void:
	"""Stop hot dog production"""
	if is_producing:
		is_producing = false
		production_timer.stop()
		production_stopped.emit()
		print("ProductionSystem: Production stopped")

func add_to_queue() -> bool:
	"""Add a hot dog to the production queue"""
	if current_queue_size < max_queue_size:
		current_queue_size += 1
		queue_updated.emit(current_queue_size, max_queue_size)
		print("ProductionSystem: Added to queue. Size: %d" % current_queue_size)
		
		# Start production if not already producing
		if not is_producing:
			start_production()
		
		return true
	else:
		queue_full.emit()
		print("ProductionSystem: Queue is full")
		return false

func _on_production_timer_timeout() -> void:
	"""Handle production timer timeout"""
	if current_queue_size > 0:
		current_queue_size -= 1
		total_produced += 1
		hot_dog_produced.emit()
		queue_updated.emit(current_queue_size, max_queue_size)
		print("ProductionSystem: Hot dog produced. Total: %d" % total_produced)
		
		# Continue production if queue has items
		if current_queue_size > 0:
			production_timer.start()
		else:
			stop_production()

func _on_game_started() -> void:
	"""Handle game started"""
	print("ProductionSystem: Game started")

func _on_game_paused() -> void:
	"""Handle game paused"""
	print("ProductionSystem: Game paused")
	stop_production()

func _on_game_resumed() -> void:
	"""Handle game resumed"""
	print("ProductionSystem: Game resumed")
	if current_queue_size > 0:
		start_production()

func get_production_stats() -> Dictionary:
	"""Get current production statistics"""
	return {
		"is_producing": is_producing,
		"current_queue_size": current_queue_size,
		"max_queue_size": max_queue_size,
		"total_produced": total_produced,
		"production_rate": production_rate
	}

func _exit_tree() -> void:
	"""Clean up when system is removed"""
	# Disconnect all signals to prevent memory leaks
	if production_timer:
		production_timer.timeout.disconnect(_on_production_timer_timeout)
```

#### Step 2: Create Production System Scene
```gdscript
# scenes/systems/production_system.tscn
[gd_scene load_steps=2 format=3 uid="uid://..."]
[ext_resource type="Script" path="res://scripts/systems/production_system.gd" id="1_0x0x0"]

[node name="ProductionSystem" type="Node"]
unique_name_in_owner = true
script = ExtResource("1_0x0x0")

[node name="HotDogStand" type="Node2D" parent="."]

[node name="ProductionTimer" type="Timer" parent="."]
wait_time = 1.0
autostart = false

[node name="ProductionQueue" type="Node" parent="."]

[node name="ProductionStats" type="Node" parent="."]
```

#### Step 3: Integrate with Main Scene
```gdscript
# In scripts/scenes/main_scene.gd
extends Control

# System references
@onready var production_system: Node = $Systems/ProductionSystem

func _ready() -> void:
	# Connect production system signals
	production_system.hot_dog_produced.connect(_on_hot_dog_produced)
	production_system.production_started.connect(_on_production_started)
	production_system.production_stopped.connect(_on_production_stopped)
	production_system.queue_updated.connect(_on_queue_updated)

func _on_hot_dog_produced() -> void:
	"""Handle hot dog production"""
	print("MainScene: Hot dog produced")
	# Coordinate with economy system
	economy_system.sell_hot_dog()

func _on_production_started() -> void:
	"""Handle production started"""
	print("MainScene: Production started")
	# Update UI if needed

func _on_production_stopped() -> void:
	"""Handle production stopped"""
	print("MainScene: Production stopped")
	# Update UI if needed

func _on_queue_updated(current_size: int, max_size: int) -> void:
	"""Handle queue updates"""
	print("MainScene: Queue updated - %d/%d" % [current_size, max_size])
	# Update UI queue display
```

### Session 2: Production UI Components (2-3 hours)

#### Step 1: Create Production Display UI
```bash
# Create UI scene for production display
mkdir -p scenes/ui
touch scenes/ui/production_display.tscn
touch scripts/ui/production_display.gd
```

```gdscript
# scripts/ui/production_display.gd
extends Control

## Production display UI component

# UI emits signals, main scene listens
signal add_hot_dog_requested
signal upgrade_production_requested

@onready var queue_label: Label = $QueueInfo/QueueLabel
@onready var rate_label: Label = $ProductionInfo/RateLabel
@onready var total_label: Label = $ProductionInfo/TotalLabel
@onready var add_button: Button = $Controls/AddButton
@onready var upgrade_button: Button = $Controls/UpgradeButton
@onready var progress_bar: ProgressBar = $QueueInfo/ProgressBar

func _ready() -> void:
	"""Initialize the production display"""
	add_button.pressed.connect(_on_add_button_pressed)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)

func _on_add_button_pressed() -> void:
	"""Handle add hot dog button press"""
	add_hot_dog_requested.emit()

func _on_upgrade_button_pressed() -> void:
	"""Handle upgrade button press"""
	upgrade_production_requested.emit()

func update_queue_display(current: int, max_size: int) -> void:
	"""Update queue display"""
	queue_label.text = "Queue: %d/%d" % [current, max_size]
	progress_bar.max_value = max_size
	progress_bar.value = current

func update_production_rate(rate: float) -> void:
	"""Update production rate display"""
	rate_label.text = "Rate: %.1f/s" % rate

func update_total_produced(total: int) -> void:
	"""Update total produced display"""
	total_label.text = "Total: %d" % total

func set_production_active(active: bool) -> void:
	"""Update production status display"""
	if active:
		rate_label.modulate = Color.GREEN
	else:
		rate_label.modulate = Color.RED
```

#### Step 2: Create Production Display Scene
```gdscript
# scenes/ui/production_display.tscn
[gd_scene load_steps=2 format=3 uid="uid://..."]
[ext_resource type="Script" path="res://scripts/ui/production_display.gd" id="1_0x0x0"]

[node name="ProductionDisplay" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1_0x0x0")

[node name="QueueInfo" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 2
anchor_top = 0.5
anchor_bottom = 0.5
offset_left = 20.0
offset_top = -50.0
offset_right = 200.0
offset_bottom = 50.0

[node name="QueueLabel" type="Label" parent="QueueInfo"]
layout_mode = 2
text = "Queue: 0/10"

[node name="ProgressBar" type="ProgressBar" parent="QueueInfo"]
layout_mode = 2

[node name="ProductionInfo" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 1
anchor_left = 1.0
anchor_right = 1.0
offset_left = -200.0
offset_top = 20.0
offset_right = -20.0
offset_bottom = 100.0

[node name="RateLabel" type="Label" parent="ProductionInfo"]
layout_mode = 2
text = "Rate: 1.0/s"

[node name="TotalLabel" type="Label" parent="ProductionInfo"]
layout_mode = 2
text = "Total: 0"

[node name="Controls" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -50.0
offset_top = -25.0
offset_right = 50.0
offset_bottom = 25.0

[node name="AddButton" type="Button" parent="Controls"]
layout_mode = 2
text = "Add Hot Dog"

[node name="UpgradeButton" type="Button" parent="Controls"]
layout_mode = 2
text = "Upgrade"
```

### Session 3: Integration and Testing (2-3 hours)

#### Step 1: Connect Production Display to Main Scene
```gdscript
# In scripts/scenes/main_scene.gd - add to _ready()
func _ready() -> void:
	# Connect production display signals
	production_display.add_hot_dog_requested.connect(_on_add_hot_dog_requested)
	production_display.upgrade_production_requested.connect(_on_upgrade_production_requested)

func _on_add_hot_dog_requested() -> void:
	"""Handle add hot dog request from UI"""
	production_system.add_to_queue()

func _on_upgrade_production_requested() -> void:
	"""Handle upgrade request from UI"""
	# Implement upgrade logic
	print("MainScene: Upgrade requested")

# Update existing signal handlers to update UI
func _on_queue_updated(current_size: int, max_size: int) -> void:
	"""Handle queue updates"""
	print("MainScene: Queue updated - %d/%d" % [current_size, max_size])
	production_display.update_queue_display(current_size, max_size)

func _on_production_started() -> void:
	"""Handle production started"""
	print("MainScene: Production started")
	production_display.set_production_active(true)

func _on_production_stopped() -> void:
	"""Handle production stopped"""
	print("MainScene: Production stopped")
	production_display.set_production_active(false)
```

#### Step 2: Create Unit Tests
```gdscript
# tests/unit/test_production_system.gd
extends GutTest

func test_production_system_initialization():
	var production_system = preload("res://scenes/systems/production_system.tscn").instantiate()
	add_child_autofree(production_system)
	
	assert_eq(production_system.current_queue_size, 0)
	assert_eq(production_system.total_produced, 0)
	assert_false(production_system.is_producing)

func test_add_to_queue():
	var production_system = preload("res://scenes/systems/production_system.tscn").instantiate()
	add_child_autofree(production_system)
	
	var result = production_system.add_to_queue()
	
	assert_true(result)
	assert_eq(production_system.current_queue_size, 1)

func test_queue_full():
	var production_system = preload("res://scenes/systems/production_system.tscn").instantiate()
	add_child_autofree(production_system)
	
	# Fill queue
	for i in range(production_system.max_queue_size):
		production_system.add_to_queue()
	
	# Try to add one more
	var result = production_system.add_to_queue()
	
	assert_false(result)
	assert_eq(production_system.current_queue_size, production_system.max_queue_size)

func test_signal_emission():
	var production_system = preload("res://scenes/systems/production_system.tscn").instantiate()
	add_child_autofree(production_system)
	
	var signal_emitted = false
	production_system.hot_dog_produced.connect(func(): signal_emitted = true)
	
	# Add to queue and wait for production
	production_system.add_to_queue()
	await get_tree().create_timer(1.1).timeout
	
	assert_true(signal_emitted)
```

## Day 2: Advanced Production Features

### Session 1: Production Upgrades (2-3 hours)

#### Step 1: Upgrade System Integration
```gdscript
# Add to scripts/systems/production_system.gd
@export var base_production_rate: float = 1.0
@export var production_rate_multiplier: float = 1.0
@export var base_queue_size: int = 10
@export var queue_size_multiplier: int = 0

func get_current_production_rate() -> float:
	"""Get current production rate with upgrades"""
	return base_production_rate * production_rate_multiplier

func get_current_queue_size() -> int:
	"""Get current max queue size with upgrades"""
	return base_queue_size + queue_size_multiplier

func upgrade_production_rate() -> bool:
	"""Upgrade production rate"""
	# Check if player can afford upgrade
	var upgrade_cost = get_production_rate_upgrade_cost()
	if EconomySystem.can_afford(upgrade_cost):
		EconomySystem.spend_money(upgrade_cost, "Production Rate Upgrade")
		production_rate_multiplier += 0.2
		production_rate = get_current_production_rate()
		production_rate_changed.emit(production_rate)
		return true
	return false

func upgrade_queue_size() -> bool:
	"""Upgrade queue size"""
	var upgrade_cost = get_queue_size_upgrade_cost()
	if EconomySystem.can_afford(upgrade_cost):
		EconomySystem.spend_money(upgrade_cost, "Queue Size Upgrade")
		queue_size_multiplier += 5
		max_queue_size = get_current_queue_size()
		queue_size_upgraded.emit(max_queue_size)
		return true
	return false

# Add new signals
signal production_rate_changed(new_rate: float)
signal queue_size_upgraded(new_size: int)
```

#### Step 2: Upgrade UI Integration
```gdscript
# Update scripts/ui/production_display.gd
func update_upgrade_buttons() -> void:
	"""Update upgrade button states"""
	var can_afford_rate = EconomySystem.can_afford(get_production_rate_upgrade_cost())
	var can_afford_queue = EconomySystem.can_afford(get_queue_size_upgrade_cost())
	
	upgrade_rate_button.disabled = not can_afford_rate
	upgrade_queue_button.disabled = not can_afford_queue

func get_production_rate_upgrade_cost() -> float:
	"""Get cost for production rate upgrade"""
	# Implementation based on current level
	return 50.0

func get_queue_size_upgrade_cost() -> float:
	"""Get cost for queue size upgrade"""
	# Implementation based on current level
	return 30.0
```

### Session 2: Production Efficiency (2-3 hours)

#### Step 1: Efficiency System
```gdscript
# Add to scripts/systems/production_system.gd
@export var base_efficiency: float = 1.0
@export var efficiency_multiplier: float = 1.0
@export var efficiency_decay_rate: float = 0.1

func get_current_efficiency() -> float:
	"""Get current production efficiency"""
	return base_efficiency * efficiency_multiplier

func update_efficiency() -> void:
	"""Update efficiency based on various factors"""
	# Efficiency can be affected by:
	# - Staff happiness
	# - Equipment condition
	# - Work environment
	# - Time of day
	var new_efficiency = calculate_efficiency()
	efficiency_multiplier = new_efficiency
	efficiency_updated.emit(new_efficiency)

func calculate_efficiency() -> float:
	"""Calculate efficiency based on various factors"""
	var efficiency = 1.0
	
	# Staff factors
	if StaffSystem:
		efficiency *= StaffSystem.get_average_happiness()
	
	# Equipment factors
	if EquipmentSystem:
		efficiency *= EquipmentSystem.get_condition_multiplier()
	
	# Time factors
	var current_hour = Time.get_datetime_dict_from_system()["hour"]
	if current_hour >= 22 or current_hour <= 6:
		efficiency *= 0.7  # Night shift penalty
	
	return efficiency

# Add new signal
signal efficiency_updated(new_efficiency: float)
```

## Day 3: Production Analytics and Optimization

### Session 1: Production Analytics (2-3 hours)

#### Step 1: Analytics System
```gdscript
# Add to scripts/systems/production_system.gd
var production_history: Array[Dictionary] = []
var hourly_production: Dictionary = {}
var daily_production: Dictionary = {}

func record_production() -> void:
	"""Record production for analytics"""
	var current_time = Time.get_datetime_dict_from_system()
	var record = {
		"timestamp": current_time,
		"total_produced": total_produced,
		"queue_size": current_queue_size,
		"efficiency": get_current_efficiency(),
		"production_rate": get_current_production_rate()
	}
	production_history.append(record)
	
	# Update hourly stats
	var hour_key = "%d-%d-%d-%d" % [current_time["year"], current_time["month"], current_time["day"], current_time["hour"]]
	if not hourly_production.has(hour_key):
		hourly_production[hour_key] = 0
	hourly_production[hour_key] += 1
	
	# Update daily stats
	var day_key = "%d-%d-%d" % [current_time["year"], current_time["month"], current_time["day"]]
	if not daily_production.has(day_key):
		daily_production[day_key] = 0
	daily_production[day_key] += 1

func get_production_stats() -> Dictionary:
	"""Get comprehensive production statistics"""
	return {
		"current_stats": {
			"is_producing": is_producing,
			"current_queue_size": current_queue_size,
			"max_queue_size": max_queue_size,
			"total_produced": total_produced,
			"production_rate": get_current_production_rate(),
			"efficiency": get_current_efficiency()
		},
		"historical_stats": {
			"production_history": production_history,
			"hourly_production": hourly_production,
			"daily_production": daily_production
		},
		"upgrade_stats": {
			"production_rate_multiplier": production_rate_multiplier,
			"queue_size_multiplier": queue_size_multiplier,
			"efficiency_multiplier": efficiency_multiplier
		}
	}
```

### Session 2: Performance Optimization (2-3 hours)

#### Step 1: Performance Monitoring
```gdscript
# Add to scripts/systems/production_system.gd
var performance_metrics: Dictionary = {}
var last_update_time: float = 0.0

func _process(delta: float) -> void:
	"""Update performance metrics"""
	last_update_time += delta
	
	# Update metrics every second
	if last_update_time >= 1.0:
		update_performance_metrics()
		last_update_time = 0.0

func update_performance_metrics() -> void:
	"""Update performance metrics"""
	var current_time = Time.get_time_dict_from_system()
	var metrics = {
		"timestamp": current_time,
		"queue_size": current_queue_size,
		"is_producing": is_producing,
		"efficiency": get_current_efficiency(),
		"production_rate": get_current_production_rate(),
		"memory_usage": OS.get_static_memory_usage()
	}
	
	performance_metrics[Time.get_unix_time_from_system()] = metrics
	
	# Emit performance signal if metrics are concerning
	if metrics["efficiency"] < 0.5:
		performance_warning.emit("low_efficiency", metrics["efficiency"])

# Add new signal
signal performance_warning(metric: String, value: float)
```

## Testing and Validation

### Unit Tests
```gdscript
# tests/unit/test_production_analytics.gd
extends GutTest

func test_production_recording():
	var production_system = preload("res://scenes/systems/production_system.tscn").instantiate()
	add_child_autofree(production_system)
	
	production_system.record_production()
	
	assert_eq(production_system.production_history.size(), 1)
	assert_eq(production_system.production_history[0]["total_produced"], 0)

func test_efficiency_calculation():
	var production_system = preload("res://scenes/systems/production_system.tscn").instantiate()
	add_child_autofree(production_system)
	
	var efficiency = production_system.calculate_efficiency()
	
	assert_greater(efficiency, 0.0)
	assert_less_or_equal(efficiency, 1.0)
```

### Integration Tests
```gdscript
# tests/integration/test_production_integration.gd
extends GutTest

func test_production_economy_integration():
	var main_scene = preload("res://scenes/main/main_scene.tscn").instantiate()
	add_child_autofree(main_scene)
	
	# Simulate production
	main_scene.production_system.add_to_queue()
	await get_tree().create_timer(1.1).timeout
	
	# Verify economy was updated
	assert_greater(main_scene.economy_system.get_current_money(), 100.0)
```

## Key Design Decisions

### 1. Signal-Based Communication
- **Production System emits signals** for all state changes
- **Main Scene coordinates** between production and other systems
- **UI components** receive updates through main scene
- **No direct coupling** between systems

### 2. Unique Name Identifiers
- **Use `%ProductionSystem`** for direct access when needed
- **Set `unique_name_in_owner = true`** in scene file
- **Clean node references** without parent chains

### 3. Performance Considerations
- **Efficiency calculations** updated periodically, not every frame
- **Analytics data** stored efficiently with cleanup
- **Signal batching** for high-frequency updates
- **Memory management** with proper cleanup

### 4. Extensibility
- **Upgrade system** easily extensible for new upgrade types
- **Efficiency system** can incorporate new factors
- **Analytics system** can track new metrics
- **Performance monitoring** can detect new issues

## Godot 4.4 Best Practices

### Signal Management
- **Typed signals** for better type safety
- **Proper disconnection** in `_exit_tree()`
- **Signal documentation** with clear parameters
- **Signal batching** for performance

### Node Access Patterns
- **Prefer `%` identifiers** over parent chains
- **Set `unique_name_in_owner = true`** for global access
- **Use `@onready`** for better performance
- **Proper node lifecycle** management

### Resource Management
- **Use `@export`** for inspector integration
- **Proper resource cleanup** in `_exit_tree()`
- **Memory monitoring** and optimization
- **Performance metrics** tracking 