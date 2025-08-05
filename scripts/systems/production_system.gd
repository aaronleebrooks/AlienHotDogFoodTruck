extends Node

## ProductionSystem
## 
## Core system for managing hot dog production mechanics.
## 
## This system handles all aspects of hot dog production including
## production rates, capacity management, automation, and upgrades.
## It integrates with the EventBus, SaveManager, and other systems.
## 
## @since: 1.0.0
## @category: Systems

# Production data
var production_data: Resource

# Node references
@onready var production_timer: Timer = $ProductionTimer
@onready var production_queue: Node = $ProductionQueue
@onready var production_stats: Node = $ProductionStats

# Production state
var is_initialized: bool = false
var production_interval: float = 1.0  # Seconds between production cycles

# Signals - System emits these, main scene listens
signal production_started
signal production_stopped
signal hot_dog_produced
signal queue_full
signal queue_updated(current_size: int, max_size: int)
signal production_rate_changed(new_rate: float)
signal capacity_changed(new_capacity: int)

func _ready() -> void:
	"""Initialize the production system"""
	print("ProductionSystem: Initializing...")
	
	# Initialize production data
	production_data = preload("res://scripts/resources/production_data.gd").new()
	
	# Set up timer
	_setup_production_timer()
	
	# Connect to EventBus for game state changes
	_connect_to_event_bus()
	
	# Connect to SaveManager for persistence
	_connect_to_save_manager()
	
	is_initialized = true
	print("ProductionSystem: Initialized successfully")

func _setup_production_timer() -> void:
	"""Set up the production timer"""
	if not production_timer:
		production_timer = Timer.new()
		production_timer.name = "ProductionTimer"
		add_child(production_timer)
	
	production_timer.timeout.connect(_on_production_timer_timeout)
	production_timer.one_shot = false
	production_timer.autostart = false

func _connect_to_event_bus() -> void:
	"""Connect to EventBus for game state changes"""
	if EventBus:
		EventBus.register_listener("game_started", _on_game_started)
		EventBus.register_listener("game_paused", _on_game_paused)
		EventBus.register_listener("game_resumed", _on_game_resumed)
		EventBus.register_listener("game_stopped", _on_game_stopped)

func _connect_to_save_manager() -> void:
	"""Connect to SaveManager for data persistence"""
	# SaveManager currently gets system references from the main scene
	# No registration needed - the system will be found automatically
	pass

## start_production
## 
## Start hot dog production.
## 
## Returns:
##   bool: True if production started, false otherwise
## 
## Example:
##   var started = production_system.start_production()
func start_production() -> bool:
	"""Start hot dog production"""
	if not is_initialized:
		print("ProductionSystem: ERROR - System not initialized")
		return false
	
	if production_data.start_production():
		production_timer.start(production_interval)
		production_started.emit()
		print("ProductionSystem: Production started")
		return true
	
	return false

## stop_production
## 
## Stop hot dog production.
## 
## Returns:
##   bool: True if production stopped, false otherwise
## 
## Example:
##   var stopped = production_system.stop_production()
func stop_production() -> bool:
	"""Stop hot dog production"""
	if not is_initialized:
		return false
	
	if production_data.stop_production():
		production_timer.stop()
		production_stopped.emit()
		print("ProductionSystem: Production stopped")
		return true
	
	return false

## add_to_queue
## 
## Add a hot dog to the production queue.
## 
## Returns:
##   bool: True if added successfully, false if queue is full
## 
## Example:
##   var added = production_system.add_to_queue()
func add_to_queue() -> bool:
	"""Add a hot dog to the production queue"""
	if not is_initialized:
		return false
	
	if production_data.add_to_queue():
		queue_updated.emit(production_data.current_queue_size, production_data.get_current_capacity())
		
		# Start production if this is the first hot dog and not already producing
		if production_data.current_queue_size == 1 and not production_data.is_producing:
			start_production()
		
		# Check if queue is full
		if production_data.current_queue_size >= production_data.get_current_capacity():
			queue_full.emit()
		
		print("ProductionSystem: Added to queue. Size: %d/%d" % [production_data.current_queue_size, production_data.get_current_capacity()])
		return true
	
	print("ProductionSystem: Queue is full!")
	return false

## get_production_rate
## 
## Get the current production rate.
## 
## Returns:
##   float: Current production rate in hot dogs per second
## 
## Example:
##   var rate = production_system.get_production_rate()
func get_production_rate() -> float:
	"""Get the current production rate"""
	if not is_initialized:
		return 0.0
	
	return production_data.get_current_production_rate()

## get_queue_status
## 
## Get the current queue status.
## 
## Returns:
##   Dictionary: Queue status information
## 
## Example:
##   var status = production_system.get_queue_status()
func get_queue_status() -> Dictionary:
	"""Get the current queue status"""
	if not is_initialized:
		return {}
	
	return production_data.get_queue_status()

## get_production_statistics
## 
## Get comprehensive production statistics.
## 
## Returns:
##   Dictionary: Production statistics
## 
## Example:
##   var stats = production_system.get_production_statistics()
func get_production_statistics() -> Dictionary:
	"""Get comprehensive production statistics"""
	if not is_initialized:
		return {}
	
	return production_data.get_production_statistics()

## upgrade_production_rate
## 
## Upgrade the production rate.
## 
## Returns:
##   bool: True if upgrade successful, false otherwise
## 
## Example:
##   var upgraded = production_system.upgrade_production_rate()
func upgrade_production_rate() -> bool:
	"""Upgrade the production rate"""
	if not is_initialized:
		return false
	
	# Check if player can afford the upgrade
	var current_level = production_data.production_rate_level
	var upgrade_cost = _get_upgrade_cost("rate", current_level)
	
	if not _can_afford_upgrade(upgrade_cost):
		print("ProductionSystem: Cannot afford production rate upgrade. Cost: $%.2f" % upgrade_cost)
		return false
	
	# Spend money on upgrade
	if not _spend_money_on_upgrade(upgrade_cost, "Production Rate Upgrade"):
		return false
	
	# Perform the upgrade
	if production_data.upgrade_production_rate():
		var new_rate = production_data.get_current_production_rate()
		production_rate_changed.emit(new_rate)
		print("ProductionSystem: Production rate upgraded to: %.2f (Cost: $%.2f)" % [new_rate, upgrade_cost])
		return true
	
	return false

## upgrade_capacity
## 
## Upgrade the production capacity.
## 
## Returns:
##   bool: True if upgrade successful, false otherwise
## 
## Example:
##   var upgraded = production_system.upgrade_capacity()
func upgrade_capacity() -> bool:
	"""Upgrade the production capacity"""
	if not is_initialized:
		return false
	
	# Check if player can afford the upgrade
	var current_level = production_data.capacity_level
	var upgrade_cost = _get_upgrade_cost("capacity", current_level)
	
	if not _can_afford_upgrade(upgrade_cost):
		print("ProductionSystem: Cannot afford capacity upgrade. Cost: $%.2f" % upgrade_cost)
		return false
	
	# Spend money on upgrade
	if not _spend_money_on_upgrade(upgrade_cost, "Capacity Upgrade"):
		return false
	
	# Perform the upgrade
	if production_data.upgrade_capacity():
		var new_capacity = production_data.get_current_capacity()
		capacity_changed.emit(new_capacity)
		print("ProductionSystem: Capacity upgraded to: %d (Cost: $%.2f)" % [new_capacity, upgrade_cost])
		return true
	
	return false

## upgrade_efficiency
## 
## Upgrade the production efficiency.
## 
## Returns:
##   bool: True if upgrade successful, false otherwise
## 
## Example:
##   var upgraded = production_system.upgrade_efficiency()
func upgrade_efficiency() -> bool:
	"""Upgrade the production efficiency"""
	if not is_initialized:
		return false
	
	# Check if player can afford the upgrade
	var current_level = production_data.efficiency_level
	var upgrade_cost = _get_upgrade_cost("efficiency", current_level)
	
	if not _can_afford_upgrade(upgrade_cost):
		print("ProductionSystem: Cannot afford efficiency upgrade. Cost: $%.2f" % upgrade_cost)
		return false
	
	# Spend money on upgrade
	if not _spend_money_on_upgrade(upgrade_cost, "Efficiency Upgrade"):
		return false
	
	# Perform the upgrade
	if production_data.upgrade_efficiency():
		var new_rate = production_data.get_current_production_rate()
		production_rate_changed.emit(new_rate)
		print("ProductionSystem: Efficiency upgraded. New rate: %.2f (Cost: $%.2f)" % [new_rate, upgrade_cost])
		return true
	
	return false

## set_production_interval
## 
## Set the production interval (time between production cycles).
## 
## Parameters:
##   interval (float): Time in seconds between production cycles
## 
## Example:
##   production_system.set_production_interval(0.5)
func set_production_interval(interval: float) -> void:
	"""Set the production interval"""
	production_interval = max(0.1, interval)  # Minimum 0.1 seconds
	
	if production_timer and production_timer.time_left > 0:
		production_timer.start(production_interval)
	
	print("ProductionSystem: Production interval set to: %.2f seconds" % production_interval)

## is_producing
## 
## Check if production is currently active.
## 
## Returns:
##   bool: True if producing, false otherwise
## 
## Example:
##   if production_system.is_producing():
##       print("Production is active")
func is_producing() -> bool:
	"""Check if production is currently active"""
	if not is_initialized:
		return false
	
	return production_data.is_producing

## can_add_to_queue
## 
## Check if a hot dog can be added to the queue.
## 
## Returns:
##   bool: True if queue has space, false otherwise
## 
## Example:
##   if production_system.can_add_to_queue():
##       production_system.add_to_queue()
func can_add_to_queue() -> bool:
	"""Check if a hot dog can be added to the queue"""
	if not is_initialized:
		return false
	
	return production_data.can_add_to_queue()

# Event handlers
func _on_production_timer_timeout() -> void:
	"""Handle production timer timeout"""
	if not is_initialized or not production_data.is_producing:
		return
	
	# Produce a hot dog
	if production_data.remove_from_queue():
		hot_dog_produced.emit()
		queue_updated.emit(production_data.current_queue_size, production_data.get_current_capacity())
		
		print("ProductionSystem: Hot dog produced! Queue: %d/%d" % [production_data.current_queue_size, production_data.get_current_capacity()])
		
		# Stop production if queue is empty
		if production_data.current_queue_size == 0:
			stop_production()

func _on_game_started(event_data: Dictionary) -> void:
	"""Handle game started event"""
	print("ProductionSystem: Game started")
	# Production can be started manually by the player

func _on_game_paused(event_data: Dictionary) -> void:
	"""Handle game paused event"""
	print("ProductionSystem: Game paused - pausing production")
	if production_data.is_producing:
		production_timer.paused = true

func _on_game_resumed(event_data: Dictionary) -> void:
	"""Handle game resumed event"""
	print("ProductionSystem: Game resumed - resuming production")
	if production_data.is_producing:
		production_timer.paused = false

func _on_game_stopped(event_data: Dictionary) -> void:
	"""Handle game stopped event"""
	print("ProductionSystem: Game stopped - stopping production")
	stop_production()

# SaveManager integration
func get_save_data() -> Dictionary:
	"""Get data to save"""
	if not is_initialized:
		return {}
	
	return {
		"production_data": production_data,
		"is_producing": production_data.is_producing,
		"production_interval": production_interval
	}

func load_save_data(data: Dictionary) -> void:
	"""Load data from save"""
	if not is_initialized:
		return
	
	if data.has("production_data"):
		production_data = data.production_data
	
	if data.has("is_producing") and data.is_producing:
		start_production()
	
	if data.has("production_interval"):
		set_production_interval(data.production_interval)
	
	print("ProductionSystem: Save data loaded")

# Cleanup
func _exit_tree() -> void:
	"""Clean up when the system is removed"""
	if EventBus:
		EventBus.unregister_listener("game_started")
		EventBus.unregister_listener("game_paused")
		EventBus.unregister_listener("game_resumed")
		EventBus.unregister_listener("game_stopped")
	
	# SaveManager doesn't use registration system
	# No cleanup needed
	
	print("ProductionSystem: Cleaned up")

# Upgrade cost helper methods
func _get_upgrade_cost(upgrade_type: String, current_level: int) -> float:
	"""Get the cost for a specific upgrade type and level"""
	# Try to get game config from autoload or create default
	var game_config = null
	if get_node_or_null("/root/GameConfig"):
		game_config = get_node("/root/GameConfig")
	else:
		# Create a default config if not available
		game_config = preload("res://scripts/resources/game_config.gd").new()
	
	return game_config.get_upgrade_cost(upgrade_type, current_level)

func _can_afford_upgrade(cost: float) -> bool:
	"""Check if the player can afford an upgrade"""
	var economy_system = get_node_or_null("/root/EconomySystem")
	if not economy_system:
		print("ProductionSystem: WARNING - EconomySystem not found, allowing upgrade")
		return true
	
	return economy_system.get_current_money() >= cost

func _spend_money_on_upgrade(cost: float, description: String) -> bool:
	"""Spend money on an upgrade"""
	var economy_system = get_node_or_null("/root/EconomySystem")
	if not economy_system:
		print("ProductionSystem: WARNING - EconomySystem not found, skipping payment")
		return true
	
	return economy_system.spend_money(cost, description)

## get_upgrade_costs
## 
## Get the costs for all available upgrades.
## 
## Returns:
##   Dictionary: Costs for each upgrade type
## 
## Example:
##   var costs = production_system.get_upgrade_costs()
func get_upgrade_costs() -> Dictionary:
	"""Get the costs for all available upgrades"""
	if not is_initialized:
		return {}
	
	var current_levels = {
		"rate": production_data.production_rate_level,
		"capacity": production_data.capacity_level,
		"efficiency": production_data.efficiency_level
	}
	
	var game_config = null
	if get_node_or_null("/root/GameConfig"):
		game_config = get_node("/root/GameConfig")
	else:
		game_config = preload("res://scripts/resources/game_config.gd").new()
	
	return game_config.get_all_upgrade_costs(current_levels)

## can_afford_upgrade
## 
## Check if the player can afford a specific upgrade.
## 
## Parameters:
##   upgrade_type (String): Type of upgrade ("rate", "capacity", "efficiency")
## 
## Returns:
##   bool: True if player can afford the upgrade
## 
## Example:
##   if production_system.can_afford_upgrade("rate"):
##       production_system.upgrade_production_rate()
func can_afford_upgrade(upgrade_type: String) -> bool:
	"""Check if the player can afford a specific upgrade"""
	if not is_initialized:
		return false
	
	var current_level = 1
	match upgrade_type:
		"rate":
			current_level = production_data.production_rate_level
		"capacity":
			current_level = production_data.capacity_level
		"efficiency":
			current_level = production_data.efficiency_level
		_:
			return false
	
	var upgrade_cost = _get_upgrade_cost(upgrade_type, current_level)
	return _can_afford_upgrade(upgrade_cost) 
