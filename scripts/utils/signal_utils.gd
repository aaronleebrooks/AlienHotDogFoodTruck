extends RefCounted
class_name SignalUtils

## Utility functions for managing signal connections

# Signal connection tracking
static var _connections: Dictionary = {}

# Connection management
static func connect_signal(signal_obj: Object, signal_name: String, callable: Callable, connection_id: String = "") -> bool:
	"""Connect a signal and track the connection"""
	if not signal_obj or not signal_obj.has_signal(signal_name):
		print("SignalUtils: Cannot connect signal %s - object or signal not found" % signal_name)
		return false
	
	# Generate connection ID if not provided
	if connection_id.is_empty():
		connection_id = "%s_%s_%s" % [signal_obj.get_class(), signal_name, str(randi())]
	
	# Store connection info
	if not _connections.has(connection_id):
		_connections[connection_id] = {
			"object": signal_obj,
			"signal": signal_name,
			"callable": callable,
			"connected": false
		}
	
	# Connect the signal
	signal_obj.connect(signal_name, callable)
	_connections[connection_id]["connected"] = true
	
	print("SignalUtils: Connected signal %s with ID %s" % [signal_name, connection_id])
	return true

static func disconnect_signal(connection_id: String) -> bool:
	"""Disconnect a signal by connection ID"""
	if not _connections.has(connection_id):
		print("SignalUtils: Connection ID %s not found" % connection_id)
		return false
	
	var connection = _connections[connection_id]
	var signal_obj = connection["object"]
	var signal_name = connection["signal"]
	var callable = connection["callable"]
	
	if signal_obj and signal_obj.has_signal(signal_name):
		signal_obj.disconnect(signal_name, callable)
		connection["connected"] = false
		print("SignalUtils: Disconnected signal %s with ID %s" % [signal_name, connection_id])
		return true
	
	return false

static func disconnect_all_signals() -> void:
	"""Disconnect all tracked signals"""
	for connection_id in _connections:
		disconnect_signal(connection_id)
	_connections.clear()
	print("SignalUtils: Disconnected all tracked signals")

static func get_connection_info(connection_id: String) -> Dictionary:
	"""Get information about a specific connection"""
	if _connections.has(connection_id):
		return _connections[connection_id].duplicate()
	return {}

static func get_all_connections() -> Dictionary:
	"""Get all connection information"""
	return _connections.duplicate()

# Signal emission utilities
static func emit_signal_safe(signal_obj: Object, signal_name: String, args: Array = []) -> bool:
	"""Safely emit a signal with arguments"""
	if not signal_obj or not signal_obj.has_signal(signal_name):
		print("SignalUtils: Cannot emit signal %s - object or signal not found" % signal_name)
		return false
	
	# Emit signal with appropriate number of arguments
	match args.size():
		0:
			signal_obj.emit_signal(signal_name)
		1:
			signal_obj.emit_signal(signal_name, args[0])
		2:
			signal_obj.emit_signal(signal_name, args[0], args[1])
		3:
			signal_obj.emit_signal(signal_name, args[0], args[1], args[2])
		_:
			print("SignalUtils: Too many arguments for signal emission")
			return false
	
	print("SignalUtils: Emitted signal %s with %d arguments" % [signal_name, args.size()])
	return true

# Signal validation
static func validate_signal(signal_obj: Object, signal_name: String) -> bool:
	"""Validate that a signal exists on an object"""
	if not signal_obj:
		return false
	return signal_obj.has_signal(signal_name)

static func get_signal_list(signal_obj: Object) -> Array[String]:
	"""Get list of all signals on an object"""
	var signals: Array[String] = []
	if signal_obj:
		for signal_info in signal_obj.get_signal_list():
			signals.append(signal_info["name"])
	return signals

# Signal debugging
static func print_signal_info(signal_obj: Object) -> void:
	"""Print information about all signals on an object"""
	if not signal_obj:
		print("SignalUtils: Object is null")
		return
	
	print("SignalUtils: Signals for %s:" % signal_obj.get_class())
	for signal_info in signal_obj.get_signal_list():
		print("  - %s" % signal_info["name"])

static func print_connection_info() -> void:
	"""Print information about all tracked connections"""
	print("SignalUtils: Tracked connections:")
	for connection_id in _connections:
		var connection = _connections[connection_id]
		var status = "connected" if connection["connected"] else "disconnected"
		print("  %s: %s.%s (%s)" % [connection_id, connection["object"].get_class(), connection["signal"], status])

# Signal queuing (for deferred execution)
static func queue_signal_emission(signal_obj: Object, signal_name: String, args: Array = []) -> void:
	"""Queue a signal emission for the next frame"""
	if not signal_obj:
		return
	
	# Use call_deferred to emit signal on next frame
	var callable = func(): emit_signal_safe(signal_obj, signal_name, args)
	signal_obj.call_deferred("call", callable)

# Signal batching
static var _queued_signals: Array[Dictionary] = []

static func queue_signal(signal_obj: Object, signal_name: String, args: Array = []) -> void:
	"""Queue a signal for batch emission"""
	_queued_signals.append({
		"object": signal_obj,
		"signal": signal_name,
		"args": args
	})

static func emit_queued_signals() -> void:
	"""Emit all queued signals"""
	for signal_data in _queued_signals:
		emit_signal_safe(signal_data["object"], signal_data["signal"], signal_data["args"])
	_queued_signals.clear()

static func clear_queued_signals() -> void:
	"""Clear all queued signals without emitting them"""
	_queued_signals.clear() 