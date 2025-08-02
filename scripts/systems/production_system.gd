extends BaseSystem

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

# Signals
signal production_started
signal production_stopped
signal hot_dog_produced
signal queue_full

func _ready() -> void:
	"""Initialize the production system"""
	# Set system name for BaseSystem
	system_name = "ProductionSystem"
	
	# Call parent initialization
	super._ready()
	
	# Connect timer signal
	production_timer.timeout.connect(_on_production_timer_timeout)
	
	# Connect GameManager signals
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_resumed.connect(_on_game_resumed)

func _initialize_system() -> void:
	"""Override BaseSystem initialization"""
	print("ProductionSystem: Initializing production system")
	# Call parent initialization
	super._initialize_system()

func start_production() -> void:
	"""Start hot dog production"""
	if not is_producing and current_queue_size < max_queue_size and is_system_ready():
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
	if current_queue_size < max_queue_size and is_system_ready():
		current_queue_size += 1
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
	if current_queue_size > 0 and is_system_ready():
		current_queue_size -= 1
		total_produced += 1
		hot_dog_produced.emit()
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
		"current_queue_size": current_queue_size,
		"max_queue_size": max_queue_size,
		"total_produced": total_produced,
		"is_producing": is_producing,
		"production_rate": production_rate
	}

func set_current_queue_size(size: int) -> void:
	"""Set the current queue size (for save/load)"""
	current_queue_size = size
	print("ProductionSystem: Queue size set to %d" % size)

func set_total_produced(amount: int) -> void:
	"""Set the total produced amount (for save/load)"""
	total_produced = amount
	print("ProductionSystem: Total produced set to %d" % amount)

func cleanup() -> void:
	"""Override BaseSystem cleanup"""
	print("ProductionSystem: Cleaning up production system")
	stop_production()
	
	# Disconnect signals
	if production_timer:
		production_timer.timeout.disconnect(_on_production_timer_timeout)
	
	# Call parent cleanup
	super.cleanup()

func _exit_tree() -> void:
	"""Clean up when system is removed"""
	cleanup() 