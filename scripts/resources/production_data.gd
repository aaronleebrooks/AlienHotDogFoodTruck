extends BaseResource

## ProductionData
## 
## Resource class for storing hot dog production data and configuration.
## 
## This resource contains all the data needed for the production system,
## including rates, capacity, efficiency, and statistics.
## 
## @since: 1.0.0
## @category: Resources

# Production Configuration
@export var base_production_rate: float = 1.0  # Hot dogs per second
@export var max_capacity: int = 10  # Maximum hot dogs in queue
@export var base_efficiency: float = 1.0  # Production efficiency multiplier

# Production State
@export var current_queue_size: int = 0
@export var total_produced: int = 0
@export var is_producing: bool = false
@export var last_production_time: float = 0.0

# Production Statistics
@export var lifetime_produced: int = 0
@export var session_produced: int = 0
@export var peak_production_rate: float = 0.0
@export var average_production_rate: float = 0.0

# Upgrade Levels
@export var production_rate_level: int = 1
@export var capacity_level: int = 1
@export var efficiency_level: int = 1

# Production History
@export var production_history: Array[Dictionary] = []
@export var max_history_size: int = 100

func _init() -> void:
	"""Initialize the production data resource"""
	resource_name = "ProductionData"
	_setup_default_values()

func _setup_default_values() -> void:
	"""Set up default values for the production data"""
	base_production_rate = 1.0
	max_capacity = 10
	base_efficiency = 1.0
	current_queue_size = 0
	total_produced = 0
	is_producing = false
	last_production_time = 0.0
	lifetime_produced = 0
	session_produced = 0
	peak_production_rate = 0.0
	average_production_rate = 0.0
	production_rate_level = 1
	capacity_level = 1
	efficiency_level = 1
	production_history = []
	max_history_size = 100

## get_current_production_rate
## 
## Get the current production rate with all modifiers applied.
## 
## Returns:
##   float: Current production rate in hot dogs per second
## 
## Example:
##   var rate = production_data.get_current_production_rate()
func get_current_production_rate() -> float:
	"""Get the current production rate with all modifiers applied"""
	var rate = base_production_rate
	
	# Apply production rate upgrades
	rate *= (1.0 + (production_rate_level - 1) * 0.2)  # 20% increase per level
	
	# Apply efficiency multiplier
	rate *= base_efficiency * (1.0 + (efficiency_level - 1) * 0.1)  # 10% efficiency per level
	
	return rate

## get_current_capacity
## 
## Get the current maximum capacity with upgrades applied.
## 
## Returns:
##   int: Current maximum capacity
## 
## Example:
##   var capacity = production_data.get_current_capacity()
func get_current_capacity() -> int:
	"""Get the current maximum capacity with upgrades applied"""
	return max_capacity + (capacity_level - 1) * 5  # 5 additional capacity per level

## can_add_to_queue
## 
## Check if a hot dog can be added to the production queue.
## 
## Returns:
##   bool: True if queue has space, false otherwise
## 
## Example:
##   if production_data.can_add_to_queue():
##       production_data.add_to_queue()
func can_add_to_queue() -> bool:
	"""Check if a hot dog can be added to the production queue"""
	return current_queue_size < get_current_capacity()

## add_to_queue
## 
## Add a hot dog to the production queue.
## 
## Returns:
##   bool: True if added successfully, false if queue is full
## 
## Example:
##   var added = production_data.add_to_queue()
func add_to_queue() -> bool:
	"""Add a hot dog to the production queue"""
	if can_add_to_queue():
		current_queue_size += 1
		_emit_production_event("queue_updated", {
			"current_size": current_queue_size,
			"max_size": get_current_capacity()
		})
		return true
	return false

## remove_from_queue
## 
## Remove a hot dog from the production queue.
## 
## Returns:
##   bool: True if removed successfully, false if queue is empty
## 
## Example:
##   var removed = production_data.remove_from_queue()
func remove_from_queue() -> bool:
	"""Remove a hot dog from the production queue"""
	if current_queue_size > 0:
		current_queue_size -= 1
		total_produced += 1
		lifetime_produced += 1
		session_produced += 1
		
		_emit_production_event("hot_dog_produced", {
			"total_produced": total_produced,
			"lifetime_produced": lifetime_produced,
			"session_produced": session_produced
		})
		
		_update_production_statistics()
		return true
	return false

## start_production
## 
## Start the production process.
## 
## Returns:
##   bool: True if production started, false if already producing or no queue
## 
## Example:
##   var started = production_data.start_production()
func start_production() -> bool:
	"""Start the production process"""
	if not is_producing and current_queue_size > 0:
		is_producing = true
		last_production_time = Time.get_ticks_msec()
		
		_emit_production_event("production_started", {
			"queue_size": current_queue_size,
			"production_rate": get_current_production_rate()
		})
		
		return true
	return false

## stop_production
## 
## Stop the production process.
## 
## Returns:
##   bool: True if production stopped, false if not producing
## 
## Example:
##   var stopped = production_data.stop_production()
func stop_production() -> bool:
	"""Stop the production process"""
	if is_producing:
		is_producing = false
		
		_emit_production_event("production_stopped", {
			"queue_size": current_queue_size,
			"total_produced": total_produced
		})
		
		return true
	return false

## get_production_progress
## 
## Get the current production progress as a percentage.
## 
## Returns:
##   float: Production progress as a percentage (0.0 to 1.0)
## 
## Example:
##   var progress = production_data.get_production_progress()
func get_production_progress() -> float:
	"""Get the current production progress as a percentage"""
	if current_queue_size == 0:
		return 0.0
	
	var capacity = get_current_capacity()
	return float(current_queue_size) / float(capacity)

## get_queue_status
## 
## Get the current queue status information.
## 
## Returns:
##   Dictionary: Queue status information
## 
## Example:
##   var status = production_data.get_queue_status()
func get_queue_status() -> Dictionary:
	"""Get the current queue status information"""
	return {
		"current_size": current_queue_size,
		"max_size": get_current_capacity(),
		"is_full": current_queue_size >= get_current_capacity(),
		"is_empty": current_queue_size == 0,
		"progress": get_production_progress()
	}

## get_production_statistics
## 
## Get comprehensive production statistics.
## 
## Returns:
##   Dictionary: Production statistics
## 
## Example:
##   var stats = production_data.get_production_statistics()
func get_production_statistics() -> Dictionary:
	"""Get comprehensive production statistics"""
	return {
		"current_rate": get_current_production_rate(),
		"peak_rate": peak_production_rate,
		"average_rate": average_production_rate,
		"total_produced": total_produced,
		"lifetime_produced": lifetime_produced,
		"session_produced": session_produced,
		"production_rate_level": production_rate_level,
		"capacity_level": capacity_level,
		"efficiency_level": efficiency_level,
		"is_producing": is_producing
	}

func _update_production_statistics() -> void:
	"""Update production statistics"""
	var current_rate = get_current_production_rate()
	
	# Update peak production rate
	if current_rate > peak_production_rate:
		peak_production_rate = current_rate
	
	# Update average production rate (simplified calculation)
	if total_produced > 0:
		var session_time = (Time.get_ticks_msec() - last_production_time) / 1000.0
		if session_time > 0:
			average_production_rate = float(session_produced) / session_time

func _emit_production_event(event_name: String, event_data: Dictionary) -> void:
	"""Emit a production event through the EventBus"""
	if EventBus:
		EventBus.emit_event("production_" + event_name, event_data)
	
	# Add to production history
	_add_to_history(event_name, event_data)

func _add_to_history(event_name: String, event_data: Dictionary) -> void:
	"""Add an event to the production history"""
	var history_entry = {
		"timestamp": Time.get_ticks_msec(),
		"event": event_name,
		"data": event_data
	}
	
	production_history.append(history_entry)
	
	# Limit history size
	if production_history.size() > max_history_size:
		production_history.pop_front()

## reset_session
## 
## Reset session-specific data.
## 
## Example:
##   production_data.reset_session()
func reset_session() -> void:
	"""Reset session-specific data"""
	session_produced = 0
	last_production_time = Time.get_ticks_msec()

## upgrade_production_rate
## 
## Upgrade the production rate level.
## 
## Returns:
##   bool: True if upgrade successful, false if max level reached
## 
## Example:
##   var upgraded = production_data.upgrade_production_rate()
func upgrade_production_rate() -> bool:
	"""Upgrade the production rate level"""
	production_rate_level += 1
	
	_emit_production_event("rate_upgraded", {
		"new_level": production_rate_level,
		"new_rate": get_current_production_rate()
	})
	
	return true

## upgrade_capacity
## 
## Upgrade the capacity level.
## 
## Returns:
##   bool: True if upgrade successful, false if max level reached
## 
## Example:
##   var upgraded = production_data.upgrade_capacity()
func upgrade_capacity() -> bool:
	"""Upgrade the capacity level"""
	capacity_level += 1
	
	_emit_production_event("capacity_upgraded", {
		"new_level": capacity_level,
		"new_capacity": get_current_capacity()
	})
	
	return true

## upgrade_efficiency
## 
## Upgrade the efficiency level.
## 
## Returns:
##   bool: True if upgrade successful, false if max level reached
## 
## Example:
##   var upgraded = production_data.upgrade_efficiency()
func upgrade_efficiency() -> bool:
	"""Upgrade the efficiency level"""
	efficiency_level += 1
	
	_emit_production_event("efficiency_upgraded", {
		"new_level": efficiency_level,
		"new_efficiency": base_efficiency * (1.0 + (efficiency_level - 1) * 0.1)
	})
	
	return true 