extends Node

## ProductionSystem
## 
## Production system for managing hot dog production.
## 
## This system handles the production of hot dogs with features including
## queue management, production rate control, and performance tracking.
## 
## Features:
##   - Hot dog production queue management
##   - Production rate control
##   - Performance tracking for production operations
##   - Integration with EconomySystem for transactions
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
## This function sets up the production system and connects signals.
## 
## @since: 1.0.0
func _ready() -> void:
	"""Initialize the production system when the node is ready"""
	print("ProductionSystem: Initializing production system")
	
	# Set up timer
	if production_timer:
		production_timer.timeout.connect(_on_production_timer_timeout)
		production_timer.wait_time = 1.0 / production_rate
	
	# Connect GameManager signals
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		game_manager.game_started.connect(_on_game_started)
		game_manager.game_paused.connect(_on_game_paused)
		game_manager.game_resumed.connect(_on_game_resumed)

## add_to_queue
## 
## Add a hot dog to the production queue.
## 
## This function adds a hot dog to the production queue and starts
## production if it's not already running.
## 
## Returns:
##   bool: True if hot dog was added to queue, false if queue is full
## 
## @since: 1.0.0
func add_to_queue() -> bool:
	"""Add a hot dog to the production queue"""
	if current_queue_size >= max_queue_size:
		queue_full.emit()
		return false
	
	current_queue_size += 1
	
	# Start production if not already producing
	if not is_producing:
		start_production()
	
	return true

## start_production
## 
## Start the production process.
## 
## This function starts the production timer and begins producing
## hot dogs at the specified rate.
## 
## @since: 1.0.0
func start_production() -> void:
	"""Start the production process"""
	if is_producing:
		return
	
	is_producing = true
	production_started.emit()
	
	if production_timer:
		production_timer.start()

## stop_production
## 
## Stop the production process.
## 
## This function stops the production timer and halts hot dog production.
## 
## @since: 1.0.0
func stop_production() -> void:
	"""Stop the production process"""
	if not is_producing:
		return
	
	is_producing = false
	production_stopped.emit()
	
	if production_timer:
		production_timer.stop()

## _on_production_timer_timeout
## 
## Handle production timer timeout.
## 
## This function is called when the production timer expires and
## produces a hot dog if there are items in the queue.
## 
## @since: 1.0.0
func _on_production_timer_timeout() -> void:
	"""Handle production timer timeout"""
	if current_queue_size > 0:
		current_queue_size -= 1
		total_produced += 1
		
		# Sell the hot dog
		var economy_system = get_node("%EconomySystem")
		if economy_system:
			economy_system.sell_hot_dog()
		
		hot_dog_produced.emit()
		
		# Stop production if queue is empty
		if current_queue_size == 0:
			stop_production()

## get_production_stats
## 
## Get production statistics.
## 
## Returns:
##   Dictionary: Production statistics including queue size, total produced, etc.
## 
## @since: 1.0.0
func get_production_stats() -> Dictionary:
	"""Get production statistics"""
	return {
		"is_producing": is_producing,
		"current_queue_size": current_queue_size,
		"max_queue_size": max_queue_size,
		"total_produced": total_produced,
		"production_rate": production_rate
	}

## _on_game_started
## 
## Handle game started event.
## 
## @since: 1.0.0
func _on_game_started() -> void:
	"""Handle game started event"""
	print("ProductionSystem: Game started")

## _on_game_paused
## 
## Handle game paused event.
## 
## @since: 1.0.0
func _on_game_paused() -> void:
	"""Handle game paused event"""
	print("ProductionSystem: Game paused")
	stop_production()

## _on_game_resumed
## 
## Handle game resumed event.
## 
## @since: 1.0.0
func _on_game_resumed() -> void:
	"""Handle game resumed event"""
	print("ProductionSystem: Game resumed")
	if current_queue_size > 0:
		start_production()

## cleanup
## 
## Clean up the production system.
## 
## This function disconnects signals and cleans up resources.
## 
## @since: 1.0.0
func cleanup() -> void:
	"""Clean up the production system"""
	stop_production()
	
	if production_timer and production_timer.timeout.is_connected(_on_production_timer_timeout):
		production_timer.timeout.disconnect(_on_production_timer_timeout)
	
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		if game_manager.game_started.is_connected(_on_game_started):
			game_manager.game_started.disconnect(_on_game_started)
		if game_manager.game_paused.is_connected(_on_game_paused):
			game_manager.game_paused.disconnect(_on_game_paused)
		if game_manager.game_resumed.is_connected(_on_game_resumed):
			game_manager.game_resumed.disconnect(_on_game_resumed)
	
	print("ProductionSystem: Cleaned up") 
