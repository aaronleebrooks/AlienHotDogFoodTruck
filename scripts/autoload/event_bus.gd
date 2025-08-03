extends Node

## EventBus
## 
## Global event bus for system-wide communication.
## 
## This autoload provides a centralized event system that allows systems to
## communicate without direct coupling. It uses Godot's native signal system
## as the foundation while providing additional features like event queuing,
## debugging, and structured event data.
## 
## Features:
##   - Global event emission and listening
##   - Event queuing for performance optimization
##   - Event debugging and logging
##   - Structured event data with type safety
##   - Event history and replay capabilities
##   - Memory leak prevention through proper cleanup
## 
## Example:
##   # Emit an event
##   EventBus.emit_event("hot_dog_produced", {"amount": 1, "price": 5.0})
##   
##   # Listen for events
##   EventBus.register_listener("hot_dog_produced", _on_hot_dog_produced)
## 
## @since: 1.0.0
## @category: Autoload

# Event registration and listeners
var _event_listeners: Dictionary = {}
var _event_history: Array[Dictionary] = []
var _event_queue: Array[Dictionary] = []

# Configuration
@export var max_history_size: int = 1000
@export var enable_debug_mode: bool = false
@export var enable_event_queuing: bool = true
@export var queue_process_interval: float = 0.016  # 60 FPS

# Performance tracking
var _events_emitted: int = 0
var _events_processed: int = 0
var _queue_timer: float = 0.0

# Debug information
var _debug_events: Array[String] = []
var _debug_listeners: Dictionary = {}

## _ready
## 
## Initialize the event bus system.
func _ready():
	_safe_log("EventBus: Initialized")
	_initialize_event_system()

## _process
## 
## Process event queue for performance optimization.
func _process(delta: float):
	if not enable_event_queuing:
		return
		
	_queue_timer += delta
	if _queue_timer >= queue_process_interval:
		_process_event_queue()
		_queue_timer = 0.0

## emit_event
## 
## Emit an event to all registered listeners.
## 
## Parameters:
##   event_name (String): Name of the event to emit
##   event_data (Variant, optional): Data to pass with the event
##   immediate (bool, optional): Whether to process immediately or queue
## 
## Example:
##   EventBus.emit_event("money_changed", {"amount": 100.0})
##   EventBus.emit_event("production_complete", {"hot_dogs": 10}, true)
func emit_event(event_name: String, event_data = null, immediate: bool = false):
	if not event_name or event_name.is_empty():
		_safe_log("EventBus: Cannot emit event - invalid event name")
		return
	
	# Create structured event data
	var event = {
		"event_name": event_name,
		"event_data": event_data,
		"timestamp": Time.get_ticks_msec(),
		"frame": Engine.get_process_frames()
	}
	
	# Add to history
	_add_to_history(event)
	
	# Debug logging
	if enable_debug_mode:
		_log_debug_event(event)
	
	# Process event
	if immediate or not enable_event_queuing:
		_process_event(event)
	else:
		_event_queue.append(event)
	
	_events_emitted += 1

## register_listener
## 
## Register a listener for a specific event.
## 
## Parameters:
##   event_name (String): Name of the event to listen for
##   callback (Callable): Function to call when event is emitted
##   listener_id (String, optional): Unique identifier for the listener
## 
## Returns:
##   String: Listener ID for later removal
## 
## Example:
##   var listener_id = EventBus.register_listener("money_changed", _on_money_changed)
func register_listener(event_name: String, callback: Callable, listener_id: String = "") -> String:
	if not event_name or event_name.is_empty():
		_safe_log("EventBus: Cannot register listener - invalid event name")
		return ""
	
	if not callback.is_valid():
		_safe_log("EventBus: Cannot register listener - invalid callback")
		return ""
	
	# Generate listener ID if not provided
	if listener_id.is_empty():
		listener_id = "%s_%s_%s" % [callback.get_object().get_class(), event_name, str(randi())]
	
	# Initialize event listeners if needed
	if not _event_listeners.has(event_name):
		_event_listeners[event_name] = {}
	
	# Register the listener
	_event_listeners[event_name][listener_id] = callback
	
	# Debug tracking
	if enable_debug_mode:
		_debug_listeners[listener_id] = {
			"event_name": event_name,
			"object": callback.get_object(),
			"method": callback.get_method()
		}
	
	_safe_log("EventBus: Registered listener %s for event %s" % [listener_id, event_name])
	return listener_id

## unregister_listener
## 
## Unregister a listener by ID.
## 
## Parameters:
##   listener_id (String): ID of the listener to remove
## 
## Returns:
##   bool: True if listener was removed, false otherwise
## 
## Example:
##   var success = EventBus.unregister_listener(listener_id)
func unregister_listener(listener_id: String) -> bool:
	for event_name in _event_listeners:
		if _event_listeners[event_name].has(listener_id):
			_event_listeners[event_name].erase(listener_id)
			
			# Clean up empty event entries
			if _event_listeners[event_name].is_empty():
				_event_listeners.erase(event_name)
			
			# Remove from debug tracking
			if enable_debug_mode and _debug_listeners.has(listener_id):
				_debug_listeners.erase(listener_id)
			
			_safe_log("EventBus: Unregistered listener %s" % listener_id)
			return true
	
	_safe_log("EventBus: Listener %s not found" % listener_id)
	return false

## unregister_all_listeners
## 
## Unregister all listeners for a specific event or all events.
## 
## Parameters:
##   event_name (String, optional): Specific event name, or empty for all events
## 
## Example:
##   EventBus.unregister_all_listeners("money_changed")
##   EventBus.unregister_all_listeners()  # Remove all listeners
func unregister_all_listeners(event_name: String = ""):
	if event_name.is_empty():
		# Remove all listeners
		_event_listeners.clear()
		if enable_debug_mode:
			_debug_listeners.clear()
		_safe_log("EventBus: Unregistered all listeners")
	else:
		# Remove listeners for specific event
		if _event_listeners.has(event_name):
			var removed_count = _event_listeners[event_name].size()
			_event_listeners.erase(event_name)
			
			# Remove from debug tracking
			if enable_debug_mode:
				for listener_id in _debug_listeners.keys():
					if _debug_listeners[listener_id]["event_name"] == event_name:
						_debug_listeners.erase(listener_id)
			
			_safe_log("EventBus: Unregistered %d listeners for event %s" % [removed_count, event_name])

## get_event_stats
## 
## Get statistics about event system usage.
## 
## Returns:
##   Dictionary: Event statistics
func get_event_stats() -> Dictionary:
	return {
		"events_emitted": _events_emitted,
		"events_processed": _events_processed,
		"active_listeners": _get_total_listeners(),
		"event_types": _event_listeners.keys(),
		"queue_size": _event_queue.size(),
		"history_size": _event_history.size()
	}

## enable_debug_mode
## 
## Enable or disable debug mode for event tracking.
## 
## Parameters:
##   enabled (bool): Whether to enable debug mode
func set_debug_mode(enabled: bool):
	enable_debug_mode = enabled
	_safe_log("EventBus: Debug mode %s" % ("enabled" if enabled else "disabled"))

## get_debug_info
## 
## Get debug information about events and listeners.
## 
## Returns:
##   Dictionary: Debug information
func get_debug_info() -> Dictionary:
	return {
		"debug_mode": enable_debug_mode,
		"debug_events": _debug_events.duplicate(),
		"debug_listeners": _debug_listeners.duplicate(),
		"event_listeners": _event_listeners.duplicate()
	}

## clear_event_history
## 
## Clear the event history.
func clear_event_history():
	_event_history.clear()
	_safe_log("EventBus: Event history cleared")

## get_event_history
## 
## Get the event history.
## 
## Returns:
##   Array: Array of event dictionaries
func get_event_history() -> Array:
	return _event_history.duplicate()

# Private helper functions

func _initialize_event_system():
	"""Initialize the event system"""
	_safe_log("EventBus: Event system initialized")
	_safe_log("EventBus: Debug mode: %s" % enable_debug_mode)
	_safe_log("EventBus: Event queuing: %s" % enable_event_queuing)

func _process_event(event: Dictionary):
	"""Process a single event"""
	var event_name = event["event_name"]
	var event_data = event["event_data"]
	
	if not _event_listeners.has(event_name):
		return
	
	# Call all registered listeners
	for listener_id in _event_listeners[event_name]:
		var callback = _event_listeners[event_name][listener_id]
		if callback.is_valid():
			callback.call(event_data)
		else:
			# Remove invalid callback
			_event_listeners[event_name].erase(listener_id)
			_safe_log("EventBus: Removed invalid callback for listener %s" % listener_id)
	
	_events_processed += 1

func _process_event_queue():
	"""Process all queued events"""
	var events_to_process = _event_queue.duplicate()
	_event_queue.clear()
	
	for event in events_to_process:
		_process_event(event)

func _add_to_history(event: Dictionary):
	"""Add event to history with size limit"""
	_event_history.append(event)
	
	# Maintain history size limit
	if _event_history.size() > max_history_size:
		_event_history.pop_front()

func _log_debug_event(event: Dictionary):
	"""Log event for debugging"""
	var debug_info = "Event: %s -> %s" % [event["event_name"], str(event["event_data"])]
	_debug_events.append(debug_info)
	
	# Keep debug events list manageable
	if _debug_events.size() > 100:
		_debug_events.pop_front()
	
	_safe_log("EventBus: %s" % debug_info)

func _get_total_listeners() -> int:
	"""Get total number of active listeners"""
	var total = 0
	for event_name in _event_listeners:
		total += _event_listeners[event_name].size()
	return total

func _safe_log(message: String):
	"""Safely log messages using ErrorHandler if available"""
	if ClassDB.class_exists("ErrorHandler"):
		ErrorHandler.log_info("EVENT_BUS_INFO", message)
	else:
		print(message)

## _exit_tree
## 
## Clean up event system on exit.
func _exit_tree():
	unregister_all_listeners()
	clear_event_history()
	_safe_log("EventBus: Cleaned up event system") 
