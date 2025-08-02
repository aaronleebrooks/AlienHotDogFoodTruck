extends BaseSystem

## ProductionSystem
## 
## Enhanced production system for managing hot dog production with lifecycle management.
## 
## This system handles the production of hot dogs with advanced features including
## dependency management, performance monitoring, and graceful state transitions.
## 
## Features:
##   - Hot dog production queue management
##   - Production rate control
##   - Performance tracking for production operations
##   - Dependency on EconomySystem for transactions
##   - Graceful pause/resume functionality
##   - Production statistics and monitoring
## 
## Example:
##   production_system.add_to_queue()
##   production_system.start_production()
##   var stats = production_system.get_production_stats()
## 
## @since: 1.0.0
## @category: System

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

# Signals
signal production_started
signal production_stopped
signal hot_dog_produced
signal queue_full

## _ready
## 
## Initialize the production system when the node is ready.
## 
## This function sets up the system name, dependencies, and connects
## to the enhanced BaseSystem lifecycle.
## 
## @since: 1.0.0
func _ready() -> void:
	"""Initialize the production system when the node is ready"""
	# Set system name for BaseSystem
	system_name = "ProductionSystem"
	
	# Set dependencies
	dependencies = ["EconomySystem"]
	
	# Call parent initialization
	super._ready()

## _initialize_system
## 
## System-specific initialization logic.
## 
## This function performs production-specific initialization including
## timer setup and signal connections.
## 
## Returns:
##   bool: True if initialization was successful, false otherwise
## 
## @since: 1.0.0
func _initialize_system() -> bool:
	"""System-specific initialization logic"""
	print("ProductionSystem: Initializing production system")
	
	# Set up timer
	if production_timer:
		production_timer.timeout.connect(_on_production_timer_timeout)
		production_timer.wait_time = 1.0 / production_rate
	
	# Connect GameManager signals
	if GameManager:
		GameManager.game_started.connect(_on_game_started)
		GameManager.game_paused.connect(_on_game_paused)
		GameManager.game_resumed.connect(_on_game_resumed)
	
	return true

## _pause_system
## 
## System-specific pause logic.
## 
## This function pauses production while preserving the current state.
## 
## Returns:
##   bool: True if pause was successful, false otherwise
## 
## @since: 1.0.0
func _pause_system() -> bool:
	"""System-specific pause logic"""
	print("ProductionSystem: Pausing production system")
	stop_production()
	return true

## _resume_system
## 
## System-specific resume logic.
## 
## This function resumes production from the paused state.
## 
## Returns:
##   bool: True if resume was successful, false otherwise
## 
## @since: 1.0.0
func _resume_system() -> bool:
	"""System-specific resume logic"""
	print("ProductionSystem: Resuming production system")
	if current_queue_size > 0:
		start_production()
	return true

## _shutdown_system
## 
## System-specific shutdown logic.
## 
## This function performs production-specific cleanup.
## 
## Returns:
##   bool: True if shutdown was successful, false otherwise
## 
## @since: 1.0.0
func _shutdown_system() -> bool:
	"""System-specific shutdown logic"""
	print("ProductionSystem: Shutting down production system")
	stop_production()
	
	# Disconnect signals
	if production_timer and production_timer.timeout.is_connected(_on_production_timer_timeout):
		production_timer.timeout.disconnect(_on_production_timer_timeout)
	
	if GameManager:
		if GameManager.game_started.is_connected(_on_game_started):
			GameManager.game_started.disconnect(_on_game_started)
		if GameManager.game_paused.is_connected(_on_game_paused):
			GameManager.game_paused.disconnect(_on_game_paused)
		if GameManager.game_resumed.is_connected(_on_game_resumed):
			GameManager.game_resumed.disconnect(_on_game_resumed)
	
	return true

## start_production
## 
## Start hot dog production.
## 
## This function starts the production timer and begins producing hot dogs.
## It includes performance tracking for the operation.
## 
## @since: 1.0.0
func start_production() -> void:
	"""Start hot dog production"""
	if not is_producing and current_queue_size < max_queue_size and is_system_ready():
		track_operation("start_production", func():
			is_producing = true
			if production_timer:
				production_timer.start()
			production_started.emit()
			print("ProductionSystem: Production started")
		)

## stop_production
## 
## Stop hot dog production.
## 
## This function stops the production timer and halts hot dog production.
## 
## @since: 1.0.0
func stop_production() -> void:
	"""Stop hot dog production"""
	if is_producing:
		is_producing = false
		if production_timer:
			production_timer.stop()
		production_stopped.emit()
		print("ProductionSystem: Production stopped")

## add_to_queue
## 
## Add a hot dog to the production queue.
## 
## This function adds a hot dog to the production queue and starts
## production if not already running. It includes performance tracking.
## 
## Returns:
##   bool: True if successfully added to queue, false otherwise
## 
## @since: 1.0.0
func add_to_queue() -> bool:
	"""Add a hot dog to the production queue"""
	if current_queue_size < max_queue_size and is_system_ready():
		return track_operation("add_to_queue", func():
			current_queue_size += 1
			print("ProductionSystem: Added to queue. Size: %d" % current_queue_size)
			
			# Start production if not already producing
			if not is_producing:
				start_production()
			
			return true
		)
	else:
		queue_full.emit()
		print("ProductionSystem: Queue is full")
		return false

## _on_production_timer_timeout
## 
## Handle production timer timeout.
## 
## This function is called when the production timer expires and
## produces a hot dog. It includes performance tracking.
## 
## @since: 1.0.0
func _on_production_timer_timeout() -> void:
	"""Handle production timer timeout"""
	if current_queue_size > 0 and is_system_ready():
		track_operation("produce_hot_dog", func():
			current_queue_size -= 1
			total_produced += 1
			hot_dog_produced.emit()
			print("ProductionSystem: Hot dog produced. Total: %d" % total_produced)
			
			# Continue production if queue has items
			if current_queue_size > 0:
				if production_timer:
					production_timer.start()
			else:
				stop_production()
		)

## _on_game_started
## 
## Handle game started event.
## 
## @since: 1.0.0
func _on_game_started() -> void:
	"""Handle game started"""
	print("ProductionSystem: Game started")

## _on_game_paused
## 
## Handle game paused event.
## 
## @since: 1.0.0
func _on_game_paused() -> void:
	"""Handle game paused"""
	print("ProductionSystem: Game paused")
	stop_production()

## _on_game_resumed
## 
## Handle game resumed event.
## 
## @since: 1.0.0
func _on_game_resumed() -> void:
	"""Handle game resumed"""
	print("ProductionSystem: Game resumed")
	if current_queue_size > 0:
		start_production()

## get_production_stats
## 
## Get current production statistics.
## 
## Returns:
##   Dictionary: Production statistics including queue size, totals, and status
## 
## @since: 1.0.0
func get_production_stats() -> Dictionary:
	"""Get current production statistics"""
	return {
		"current_queue_size": current_queue_size,
		"max_queue_size": max_queue_size,
		"total_produced": total_produced,
		"is_producing": is_producing,
		"production_rate": production_rate
	}

## set_current_queue_size
## 
## Set the current queue size (for save/load).
## 
## Parameters:
##   size (int): New queue size
## 
## @since: 1.0.0
func set_current_queue_size(size: int) -> void:
	"""Set the current queue size (for save/load)"""
	current_queue_size = size
	print("ProductionSystem: Queue size set to %d" % size)

## set_total_produced
## 
## Set the total produced amount (for save/load).
## 
## Parameters:
##   amount (int): New total produced amount
## 
## @since: 1.0.0
func set_total_produced(amount: int) -> void:
	"""Set the total produced amount (for save/load)"""
	total_produced = amount
	print("ProductionSystem: Total produced set to %d" % amount) 