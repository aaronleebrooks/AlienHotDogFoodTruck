extends RefCounted
class_name SignalUtils

## SignalUtils
## 
## Utility functions for managing signal connections safely and efficiently.
## 
## This class provides static utility functions for signal management including
## connection tracking, safe connection/disconnection, validation, and debugging.
## It helps prevent memory leaks and provides better signal management than
## native Godot signal handling.
## 
## Features:
##   - Signal connection tracking and management
##   - Safe signal connection and disconnection
##   - Signal validation and debugging
##   - Connection information retrieval
##   - Batch signal operations
##   - Memory leak prevention
## 
## Example:
##   var connection_id = SignalUtils.connect_signal(button, "pressed", _on_pressed)
##   SignalUtils.disconnect_signal(connection_id)
##   SignalUtils.disconnect_all_signals()
## 
## @since: 1.0.0
## @category: Utility

# Signal connection tracking
static var _connections: Dictionary = {}

## connect_signal
## 
## Connect a signal and track the connection.
## 
## This function safely connects a signal and returns a unique connection ID
## for later disconnection. It validates the signal exists before connecting
## and tracks the connection for management purposes.
## 
## Parameters:
##   signal_obj (Object): Object that emits the signal
##   signal_name (String): Name of the signal to connect
##   callable (Callable): Function to call when signal is emitted
##   connection_id (String, optional): Custom connection ID (auto-generated if empty)
## 
## Returns:
##   String: Unique connection ID for tracking and disconnection
## 
## Example:
##   var connection_id = SignalUtils.connect_signal(button, "pressed", _on_button_pressed)
##   if connection_id.is_empty():
##       print("Failed to connect signal")
## 
## @since: 1.0.0
static func connect_signal(signal_obj: Object, signal_name: String, callable: Callable, connection_id: String = "") -> String:
	"""Connect a signal and track the connection"""
	if not signal_obj or not signal_obj.has_signal(signal_name):
		print("SignalUtils: Cannot connect signal %s - object or signal not found" % signal_name)
		return ""
	
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
	return connection_id

## disconnect_signal
## 
## Disconnect a signal by connection ID.
## 
## This function safely disconnects a signal using its connection ID.
## It validates the connection exists and handles the disconnection
## properly to prevent errors.
## 
## Parameters:
##   connection_id (String): Connection ID returned from connect_signal
## 
## Returns:
##   bool: True if disconnection was successful, false otherwise
## 
## Example:
##   var success = SignalUtils.disconnect_signal(connection_id)
##   if success:
##       print("Signal disconnected successfully")
## 
## @since: 1.0.0
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

## disconnect_all_signals
## 
## Disconnect all tracked signals.
## 
## This function disconnects all signals that have been tracked by
## SignalUtils. It's useful for cleanup when shutting down systems
## or switching scenes.
## 
## Example:
##   SignalUtils.disconnect_all_signals()
##   print("All tracked signals disconnected")
## 
## @since: 1.0.0
static func disconnect_all_signals() -> void:
	"""Disconnect all tracked signals"""
	for connection_id in _connections:
		disconnect_signal(connection_id)
	_connections.clear()
	print("SignalUtils: Disconnected all tracked signals")

## get_connection_info
## 
## Get information about a specific connection.
## 
## This function returns detailed information about a signal connection
## including the object, signal name, callable, and connection status.
## 
## Parameters:
##   connection_id (String): Connection ID to get info for
## 
## Returns:
##   Dictionary: Connection information or empty dictionary if not found
## 
## Example:
##   var info = SignalUtils.get_connection_info(connection_id)
##   if not info.is_empty():
##       print("Signal: %s, Object: %s" % [info.signal, info.object])
## 
## @since: 1.0.0
static func get_connection_info(connection_id: String) -> Dictionary:
	"""Get information about a specific connection"""
	if _connections.has(connection_id):
		return _connections[connection_id].duplicate()
	return {}

## get_all_connections
## 
## Get all connection information.
## 
## This function returns information about all tracked signal connections.
## It's useful for debugging and monitoring signal usage.
## 
## Returns:
##   Dictionary: All connection information indexed by connection ID
## 
## Example:
##   var all_connections = SignalUtils.get_all_connections()
##   print("Total connections: %d" % all_connections.size())
## 
## @since: 1.0.0
static func get_all_connections() -> Dictionary:
	"""Get all connection information"""
	return _connections.duplicate()

## emit_signal_safe
## 
## Safely emit a signal with arguments.
## 
## This function safely emits a signal with up to 3 arguments. It validates
## the signal exists before attempting to emit it.
## 
## Parameters:
##   signal_obj (Object): Object that emits the signal
##   signal_name (String): Name of the signal to emit
##   args (Array, optional): Arguments to pass to the signal (max 3)
## 
## Returns:
##   bool: True if signal was emitted successfully, false otherwise
## 
## Example:
##   var success = SignalUtils.emit_signal_safe(button, "pressed")
##   if success:
##       print("Signal emitted successfully")
## 
## @since: 1.0.0
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

## validate_signal
## 
## Validate that a signal exists on an object.
## 
## This function checks if a signal exists on the given object before
## attempting to connect or emit it.
## 
## Parameters:
##   signal_obj (Object): Object to check for signal
##   signal_name (String): Name of the signal to validate
## 
## Returns:
##   bool: True if signal exists, false otherwise
## 
## Example:
##   if SignalUtils.validate_signal(button, "pressed"):
##       SignalUtils.connect_signal(button, "pressed", _on_pressed)
##   else:
##       print("Signal does not exist")
## 
## @since: 1.0.0
static func validate_signal(signal_obj: Object, signal_name: String) -> bool:
	"""Validate that a signal exists on an object"""
	if not signal_obj:
		return false
	return signal_obj.has_signal(signal_name)

## get_signal_names
## 
## Get list of signal names on an object.
## 
## This function returns an array of all signal names available on
## the given object. It's useful for debugging and introspection.
## 
## Parameters:
##   signal_obj (Object): Object to get signal names from
## 
## Returns:
##   Array[String]: Array of signal names
## 
## Example:
##   var signals = SignalUtils.get_signal_names(button)
##   print("Available signals: %s" % signals)
## 
## @since: 1.0.0
static func get_signal_names(signal_obj: Object) -> Array[String]:
	"""Get list of signal names on an object"""
	var signals: Array[String] = []
	if signal_obj:
		for signal_info in signal_obj.get_signal_list():
			signals.append(signal_info["name"])
	return signals

## print_signal_info
## 
## Print detailed information about an object's signals.
## 
## This function prints comprehensive information about all signals
## on an object, including their names and parameters. It's useful
## for debugging signal-related issues.
## 
## Parameters:
##   signal_obj (Object): Object to print signal info for
## 
## Example:
##   SignalUtils.print_signal_info(button)
##   # Output: Detailed signal information to console
## 
## @since: 1.0.0
static func print_signal_info(signal_obj: Object) -> void:
	"""Print detailed information about an object's signals"""
	if not signal_obj:
		print("SignalUtils: Cannot print signal info for null object")
		return
	
	print("SignalUtils: Signal information for %s:" % signal_obj.get_class())
	for signal_info in signal_obj.get_signal_list():
		print("  - %s" % signal_info["name"])

## get_connection_status
## 
## Get the status of a specific connection.
## 
## This function returns whether a tracked connection is currently
## connected or disconnected.
## 
## Parameters:
##   connection_id (String): Connection ID to check
## 
## Returns:
##   String: "connected" or "disconnected"
## 
## Example:
##   var status = SignalUtils.get_connection_status(connection_id)
##   print("Connection status: %s" % status)
## 
## @since: 1.0.0
static func get_connection_status(connection_id: String) -> String:
	"""Get the status of a specific connection"""
	if _connections.has(connection_id):
		var connection = _connections[connection_id]
		var status = "connected" if connection["connected"] else "disconnected"
		return status
	return "not_found"

## queue_signal_emission
## 
## Queue a signal emission for later execution.
## 
## This function queues a signal emission to be executed on the next
## frame. It's useful for avoiding signal emission during signal
## processing.
## 
## Parameters:
##   signal_obj (Object): Object that emits the signal
##   signal_name (String): Name of the signal to emit
##   args (Array, optional): Arguments to pass to the signal
## 
## Example:
##   SignalUtils.queue_signal_emission(button, "pressed")
##   # Signal will be emitted on the next frame
## 
## @since: 1.0.0
static func queue_signal_emission(signal_obj: Object, signal_name: String, args: Array = []) -> void:
	"""Queue a signal emission for later execution"""
	var callable = func(): emit_signal_safe(signal_obj, signal_name, args)
	callable.call_deferred() 
