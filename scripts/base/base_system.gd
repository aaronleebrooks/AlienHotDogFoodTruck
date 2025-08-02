extends Node

## BaseSystem
## 
## Enhanced base class for all game systems with comprehensive lifecycle management.
## 
## This class provides a robust foundation for game systems with advanced features
## including dependency management, state tracking, performance monitoring, and
## graceful lifecycle control.
## 
## Features:
##   - System state management (UNINITIALIZED, INITIALIZING, READY, PAUSED, ERROR, SHUTDOWN)
##   - Dependency tracking and validation
##   - Performance monitoring and metrics
##   - Memory usage tracking
##   - Graceful pause/resume functionality
##   - Error recovery mechanisms
##   - Comprehensive logging and debugging
## 
## Example:
##   class_name ProductionSystem
##   extends BaseSystem
##   
##   func _ready():
##       system_name = "ProductionSystem"
##       dependencies = ["EconomySystem", "ResourceManager"]
##       super._ready()
## 
## @since: 1.0.0
## @category: Base

# System state enumeration
enum SystemState {
	UNINITIALIZED,
	INITIALIZING,
	READY,
	PAUSED,
	ERROR,
	SHUTDOWN
}

# System configuration
@export var system_name: String = "UnnamedSystem"
@export var auto_initialize: bool = true
@export var enable_performance_monitoring: bool = true
@export var enable_dependency_checking: bool = true

# System state
var system_state: SystemState = SystemState.UNINITIALIZED
var previous_state: SystemState = SystemState.UNINITIALIZED
var state_change_time: int = 0

# Dependency management
var dependencies: Array[String] = []
var dependents: Array[String] = []
var dependency_status: Dictionary = {}

# Performance monitoring
var performance_metrics: Dictionary = {}
var memory_usage: Dictionary = {}
var performance_alerts: Array[String] = []
var operation_times: Dictionary = {}

# Error tracking
var error_count: int = 0
var last_error: Dictionary = {}
var error_history: Array[Dictionary] = []

# Lifecycle events
signal system_state_changed(new_state: SystemState, old_state: SystemState)
signal system_initialized(system_name: String)
signal system_paused(system_name: String)
signal system_resumed(system_name: String)
signal system_error(system_name: String, error_details: Dictionary)
signal system_shutdown(system_name: String)
signal dependency_ready(dependency_name: String)
signal performance_alert(alert_message: String)

## _ready
## 
## Initialize the system when the node is ready.
## 
## This function sets up the system and optionally auto-initializes it.
## It also starts performance monitoring if enabled.
## 
## @since: 1.0.0
func _ready() -> void:
	"""Initialize the system when the node is ready"""
	# Set up performance monitoring
	if enable_performance_monitoring:
		_start_performance_monitoring()
	
	# Auto-initialize if enabled
	if auto_initialize:
		call_deferred("initialize_system")

## initialize_system
## 
## Initialize the system with dependency checking and state management.
## 
## This function performs a complete system initialization including
## dependency validation, state transitions, and error handling.
## 
## Returns:
##   bool: True if initialization was successful, false otherwise
## 
## Example:
##   var success = production_system.initialize_system()
##   if not success:
##       print("Failed to initialize production system")
## 
## @since: 1.0.0
func initialize_system() -> bool:
	"""Initialize the system with dependency checking and state management"""
	# Check if already initialized
	if system_state != SystemState.UNINITIALIZED:
		ErrorHandler.log_warning("SYSTEM_ALREADY_INITIALIZED", "System %s already initialized" % system_name)
		return system_state == SystemState.READY
	
	# Transition to initializing state
	_change_state(SystemState.INITIALIZING)
	
	# Check dependencies if enabled
	if enable_dependency_checking and not dependencies.is_empty():
		if not _wait_for_dependencies():
			_change_state(SystemState.ERROR)
			ErrorHandler.log_error("SYSTEM_DEPENDENCY_FAILED", "Failed to initialize dependencies for %s" % system_name)
			return false
	
	# Perform system-specific initialization
	var init_success = _initialize_system()
	if not init_success:
		_change_state(SystemState.ERROR)
		ErrorHandler.log_error("SYSTEM_INIT_FAILED", "System-specific initialization failed for %s" % system_name)
		return false
	
	# Transition to ready state
	_change_state(SystemState.READY)
	
	# Notify dependents
	_notify_dependents()
	
	# Emit initialization signal
	system_initialized.emit(system_name)
	
	ErrorHandler.log_info("SYSTEM_INIT_SUCCESS", "System %s initialized successfully" % system_name)
	return true

## pause_system
## 
## Pause the system gracefully.
## 
## This function pauses the system while preserving its state.
## It can be resumed later without data loss.
## 
## Returns:
##   bool: True if pause was successful, false otherwise
## 
## Example:
##   production_system.pause_system()
## 
## @since: 1.0.0
func pause_system() -> bool:
	"""Pause the system gracefully"""
	if system_state != SystemState.READY:
		ErrorHandler.log_warning("SYSTEM_PAUSE_INVALID_STATE", "Cannot pause system %s in state %s" % [system_name, SystemState.keys()[system_state]])
		return false
	
	# Perform system-specific pause logic
	var pause_success = _pause_system()
	if not pause_success:
		ErrorHandler.log_error("SYSTEM_PAUSE_FAILED", "Failed to pause system %s" % system_name)
		return false
	
	# Change state
	_change_state(SystemState.PAUSED)
	
	# Emit pause signal
	system_paused.emit(system_name)
	
	ErrorHandler.log_info("SYSTEM_PAUSE_SUCCESS", "System %s paused successfully" % system_name)
	return true

## resume_system
## 
## Resume the system from pause.
## 
## This function resumes the system from its paused state.
## 
## Returns:
##   bool: True if resume was successful, false otherwise
## 
## Example:
##   production_system.resume_system()
## 
## @since: 1.0.0
func resume_system() -> bool:
	"""Resume the system from pause"""
	if system_state != SystemState.PAUSED:
		ErrorHandler.log_warning("SYSTEM_RESUME_INVALID_STATE", "Cannot resume system %s in state %s" % [system_name, SystemState.keys()[system_state]])
		return false
	
	# Perform system-specific resume logic
	var resume_success = _resume_system()
	if not resume_success:
		ErrorHandler.log_error("SYSTEM_RESUME_FAILED", "Failed to resume system %s" % system_name)
		return false
	
	# Change state
	_change_state(SystemState.READY)
	
	# Emit resume signal
	system_resumed.emit(system_name)
	
	ErrorHandler.log_info("SYSTEM_RESUME_SUCCESS", "System %s resumed successfully" % system_name)
	return true

## shutdown_system
## 
## Shutdown the system gracefully.
## 
## This function performs a complete shutdown with cleanup.
## The system cannot be resumed after shutdown.
## 
## Returns:
##   bool: True if shutdown was successful, false otherwise
## 
## Example:
##   production_system.shutdown_system()
## 
## @since: 1.0.0
func shutdown_system() -> bool:
	"""Shutdown the system gracefully"""
	if system_state == SystemState.SHUTDOWN:
		ErrorHandler.log_warning("SYSTEM_ALREADY_SHUTDOWN", "System %s already shutdown" % system_name)
		return true
	
	# Perform system-specific shutdown logic
	var shutdown_success = _shutdown_system()
	if not shutdown_success:
		ErrorHandler.log_error("SYSTEM_SHUTDOWN_FAILED", "Failed to shutdown system %s" % system_name)
		return false
	
	# Change state
	_change_state(SystemState.SHUTDOWN)
	
	# Stop performance monitoring
	if enable_performance_monitoring:
		_stop_performance_monitoring()
	
	# Emit shutdown signal
	system_shutdown.emit(system_name)
	
	ErrorHandler.log_info("SYSTEM_SHUTDOWN_SUCCESS", "System %s shutdown successfully" % system_name)
	return true

## is_system_ready
## 
## Check if the system is ready for operation.
## 
## Returns:
##   bool: True if system is ready, false otherwise
## 
## Example:
##   if production_system.is_system_ready():
##       production_system.start_production()
## 
## @since: 1.0.0
func is_system_ready() -> bool:
	"""Check if the system is ready for operation"""
	return system_state == SystemState.READY

## is_system_paused
## 
## Check if the system is paused.
## 
## Returns:
##   bool: True if system is paused, false otherwise
## 
## @since: 1.0.0
func is_system_paused() -> bool:
	"""Check if the system is paused"""
	return system_state == SystemState.PAUSED

## is_system_error
## 
## Check if the system is in error state.
## 
## Returns:
##   bool: True if system is in error state, false otherwise
## 
## @since: 1.0.0
func is_system_error() -> bool:
	"""Check if the system is in error state"""
	return system_state == SystemState.ERROR

## get_system_info
## 
## Get comprehensive information about the system.
## 
## Returns:
##   Dictionary: System information including state, performance, and errors
## 
## Example:
##   var info = production_system.get_system_info()
##   print("System state: %s" % info.state)
## 
## @since: 1.0.0
func get_system_info() -> Dictionary:
	"""Get comprehensive information about the system"""
	return {
		"name": system_name,
		"state": SystemState.keys()[system_state],
		"previous_state": SystemState.keys()[previous_state],
		"state_change_time": state_change_time,
		"dependencies": dependencies.duplicate(),
		"dependents": dependents.duplicate(),
		"dependency_status": dependency_status.duplicate(),
		"performance_metrics": performance_metrics.duplicate(),
		"memory_usage": memory_usage.duplicate(),
		"performance_alerts": performance_alerts.duplicate(),
		"error_count": error_count,
		"last_error": last_error.duplicate(),
		"error_history": error_history.duplicate()
	}

## track_operation
## 
## Track the performance of an operation.
## 
## This function measures the execution time and memory usage of an operation
## and records it for performance analysis.
## 
## Parameters:
##   operation_name (String): Name of the operation to track
##   operation_func (Callable): Function to execute and track
## 
## Returns:
##   Variant: Result of the operation function
## 
## Example:
##   var result = production_system.track_operation("produce_hot_dog", func(): return produce_hot_dog())
## 
## @since: 1.0.0
func track_operation(operation_name: String, operation_func: Callable) -> Variant:
	"""Track the performance of an operation"""
	if not enable_performance_monitoring:
		return operation_func.call()
	
	var start_time = Time.get_ticks_msec()
	var start_memory = _get_memory_usage()
	
	# Execute operation
	var result = operation_func.call()
	
	var end_time = Time.get_ticks_msec()
	var end_memory = _get_memory_usage()
	
	# Record metrics
	var duration = end_time - start_time
	var memory_delta = end_memory - start_memory
	
	_record_operation_metrics(operation_name, duration, memory_delta)
	
	# Check for performance issues
	_check_performance_alerts(operation_name, duration, memory_delta)
	
	return result

## add_dependency
## 
## Add a dependency to the system.
## 
## Parameters:
##   dependency_name (String): Name of the dependency to add
## 
## Example:
##   production_system.add_dependency("EconomySystem")
## 
## @since: 1.0.0
func add_dependency(dependency_name: String) -> void:
	"""Add a dependency to the system"""
	if not dependencies.has(dependency_name):
		dependencies.append(dependency_name)
		dependency_status[dependency_name] = false

## remove_dependency
## 
## Remove a dependency from the system.
## 
## Parameters:
##   dependency_name (String): Name of the dependency to remove
## 
## @since: 1.0.0
func remove_dependency(dependency_name: String) -> void:
	"""Remove a dependency from the system"""
	dependencies.erase(dependency_name)
	dependency_status.erase(dependency_name)

## notify_dependency_ready
## 
## Notify that a dependency is ready.
## 
## This function is called by other systems to notify that they are ready.
## 
## Parameters:
##   dependency_name (String): Name of the ready dependency
## 
## @since: 1.0.0
func notify_dependency_ready(dependency_name: String) -> void:
	"""Notify that a dependency is ready"""
	if dependencies.has(dependency_name):
		dependency_status[dependency_name] = true
		dependency_ready.emit(dependency_name)
		
		# Check if all dependencies are ready
		if _are_all_dependencies_ready() and system_state == SystemState.INITIALIZING:
			_continue_initialization()

## _change_state
## 
## Change the system state and emit signals.
## 
## Parameters:
##   new_state (SystemState): New state to transition to
## 
## @since: 1.0.0
func _change_state(new_state: SystemState) -> void:
	"""Change the system state and emit signals"""
	if new_state == system_state:
		return
	
	previous_state = system_state
	system_state = new_state
	state_change_time = Time.get_ticks_msec()
	
	system_state_changed.emit(new_state, previous_state)
	
	ErrorHandler.log_info("SYSTEM_STATE_CHANGE", "System %s changed from %s to %s" % [
		system_name, 
		SystemState.keys()[previous_state], 
		SystemState.keys()[new_state]
	])

## _wait_for_dependencies
## 
## Wait for all dependencies to be ready.
## 
## Returns:
##   bool: True if all dependencies are ready, false if timeout
## 
## @since: 1.0.0
func _wait_for_dependencies() -> bool:
	"""Wait for all dependencies to be ready"""
	var timeout = 5000  # 5 seconds timeout
	var start_time = Time.get_ticks_msec()
	
	while not _are_all_dependencies_ready():
		if Time.get_ticks_msec() - start_time > timeout:
			ErrorHandler.log_error("SYSTEM_DEPENDENCY_TIMEOUT", "Timeout waiting for dependencies for %s" % system_name)
			return false
		
		# Use call_deferred instead of await to avoid coroutine issues
		call_deferred("_check_dependencies_again")
		return false  # Will be called again via call_deferred
	
	return true

## _check_dependencies_again
## 
## Check dependencies again after a frame delay.
## 
## @since: 1.0.0
func _check_dependencies_again() -> void:
	"""Check dependencies again after a frame delay"""
	if _are_all_dependencies_ready():
		_continue_initialization()
	else:
		# Schedule another check
		call_deferred("_check_dependencies_again")

## _are_all_dependencies_ready
## 
## Check if all dependencies are ready.
## 
## Returns:
##   bool: True if all dependencies are ready, false otherwise
## 
## @since: 1.0.0
func _are_all_dependencies_ready() -> bool:
	"""Check if all dependencies are ready"""
	for dependency in dependencies:
		if not dependency_status.get(dependency, false):
			return false
	return true

## _notify_dependents
## 
## Notify all dependents that this system is ready.
## 
## @since: 1.0.0
func _notify_dependents() -> void:
	"""Notify all dependents that this system is ready"""
	for dependent in dependents:
		# Find the dependent system and notify it
		var dependent_node = _find_system_by_name(dependent)
		if dependent_node and dependent_node.has_method("notify_dependency_ready"):
			dependent_node.notify_dependency_ready(system_name)

## _find_system_by_name
## 
## Find a system by name in the scene tree.
## 
## Parameters:
##   system_name (String): Name of the system to find
## 
## Returns:
##   Node: The system node, or null if not found
## 
## @since: 1.0.0
func _find_system_by_name(system_name: String) -> Node:
	"""Find a system by name in the scene tree"""
	# Search in the same parent as this system
	var parent = get_parent()
	if parent:
		for child in parent.get_children():
			if child.has_method("get_system_info"):
				var info = child.get_system_info()
				if info.name == system_name:
					return child
	
	return null

## _start_performance_monitoring
## 
## Start performance monitoring for the system.
## 
## @since: 1.0.0
func _start_performance_monitoring() -> void:
	"""Start performance monitoring for the system"""
	performance_metrics = {
		"start_time": Time.get_ticks_msec(),
		"memory_start": _get_memory_usage(),
		"operations_count": 0,
		"total_operation_time": 0.0,
		"average_operation_time": 0.0,
		"peak_memory": 0,
		"current_memory": 0
	}
	
	memory_usage = {
		"start": _get_memory_usage(),
		"current": _get_memory_usage(),
		"peak": _get_memory_usage()
	}

## _stop_performance_monitoring
## 
## Stop performance monitoring for the system.
## 
## @since: 1.0.0
func _stop_performance_monitoring() -> void:
	"""Stop performance monitoring for the system"""
	performance_metrics["end_time"] = Time.get_ticks_msec()
	performance_metrics["total_uptime"] = performance_metrics.end_time - performance_metrics.start_time
	memory_usage["end"] = _get_memory_usage()

## _get_memory_usage
## 
## Get current memory usage for the system.
## 
## Returns:
##   int: Memory usage in bytes
## 
## @since: 1.0.0
func _get_memory_usage() -> int:
	"""Get current memory usage for the system"""
	# This is a simplified implementation
	# In a real system, you might want more detailed memory tracking
	return OS.get_static_memory_usage()

## _record_operation_metrics
## 
## Record metrics for an operation.
## 
## Parameters:
##   operation_name (String): Name of the operation
##   duration (float): Duration in milliseconds
##   memory_delta (int): Memory usage change in bytes
## 
## @since: 1.0.0
func _record_operation_metrics(operation_name: String, duration: float, memory_delta: int) -> void:
	"""Record metrics for an operation"""
	performance_metrics.operations_count += 1
	performance_metrics.total_operation_time += duration
	performance_metrics.average_operation_time = performance_metrics.total_operation_time / performance_metrics.operations_count
	
	# Update memory usage
	memory_usage.current = _get_memory_usage()
	if memory_usage.current > memory_usage.peak:
		memory_usage.peak = memory_usage.current
	
	# Store operation-specific metrics
	if not operation_times.has(operation_name):
		operation_times[operation_name] = []
	operation_times[operation_name].append(duration)
	
	# Keep only the last 100 measurements per operation
	if operation_times[operation_name].size() > 100:
		operation_times[operation_name].pop_front()

## _check_performance_alerts
## 
## Check for performance issues and generate alerts.
## 
## Parameters:
##   operation_name (String): Name of the operation
##   duration (float): Duration in milliseconds
##   memory_delta (int): Memory usage change in bytes
## 
## @since: 1.0.0
func _check_performance_alerts(operation_name: String, duration: float, memory_delta: int) -> void:
	"""Check for performance issues and generate alerts"""
	# Check for slow operations (more than one frame at 60fps)
	if duration > 16.0:
		var alert = "Slow operation: %s took %.2fms" % [operation_name, duration]
		performance_alerts.append(alert)
		performance_alert.emit(alert)
	
	# Check for high memory usage (more than 1MB)
	if memory_delta > 1024 * 1024:
		var alert = "High memory usage: %s used %.2fMB" % [operation_name, memory_delta / 1024.0 / 1024.0]
		performance_alerts.append(alert)
		performance_alert.emit(alert)
	
	# Check for memory leaks (sustained high memory usage)
	if memory_usage.current > memory_usage.peak * 1.5:
		var alert = "Potential memory leak: current usage %.2fMB vs peak %.2fMB" % [
			memory_usage.current / 1024.0 / 1024.0,
			memory_usage.peak / 1024.0 / 1024.0
		]
		performance_alerts.append(alert)
		performance_alert.emit(alert)

## _continue_initialization
## 
## Continue initialization after dependencies are ready.
## 
## @since: 1.0.0
func _continue_initialization() -> void:
	"""Continue initialization after dependencies are ready"""
	# This will be called when all dependencies are ready
	# The actual initialization logic is in _initialize_system()
	initialize_system()

## _initialize_system
## 
## System-specific initialization logic.
## 
## Override this function in derived classes to implement
## system-specific initialization.
## 
## Returns:
##   bool: True if initialization was successful, false otherwise
## 
## @since: 1.0.0
func _initialize_system() -> bool:
	"""System-specific initialization logic"""
	# Override in derived classes
	return true

## _pause_system
## 
## System-specific pause logic.
## 
## Override this function in derived classes to implement
## system-specific pause behavior.
## 
## Returns:
##   bool: True if pause was successful, false otherwise
## 
## @since: 1.0.0
func _pause_system() -> bool:
	"""System-specific pause logic"""
	# Override in derived classes
	return true

## _resume_system
## 
## System-specific resume logic.
## 
## Override this function in derived classes to implement
## system-specific resume behavior.
## 
## Returns:
##   bool: True if resume was successful, false otherwise
## 
## @since: 1.0.0
func _resume_system() -> bool:
	"""System-specific resume logic"""
	# Override in derived classes
	return true

## _shutdown_system
## 
## System-specific shutdown logic.
## 
## Override this function in derived classes to implement
## system-specific shutdown behavior.
## 
## Returns:
##   bool: True if shutdown was successful, false otherwise
## 
## @since: 1.0.0
func _shutdown_system() -> bool:
	"""System-specific shutdown logic"""
	# Override in derived classes
	return true

## log_error
## 
## Log an error for the system.
## 
## Parameters:
##   error_code (String): Error code
##   message (String): Error message
##   details (String, optional): Additional error details
## 
## @since: 1.0.0
func log_error(error_code: String, message: String, details: String = "") -> void:
	"""Log an error for the system"""
	error_count += 1
	
	last_error = {
		"code": error_code,
		"message": message,
		"details": details,
		"timestamp": Time.get_ticks_msec(),
		"system_state": SystemState.keys()[system_state]
	}
	
	error_history.append(last_error.duplicate())
	
	# Keep only the last 50 errors
	if error_history.size() > 50:
		error_history.pop_front()
	
	# Change to error state if not already
	if system_state != SystemState.ERROR:
		_change_state(SystemState.ERROR)
	
	# Emit error signal
	system_error.emit(system_name, last_error)
	
	# Log to ErrorHandler
	ErrorHandler.log_error(error_code, message, details)

## cleanup
## 
## Clean up the system when it's being removed.
## 
## @since: 1.0.0
func cleanup() -> void:
	"""Clean up the system when it's being removed"""
	shutdown_system()

## _exit_tree
## 
## Clean up when the node is removed from the scene tree.
## 
## @since: 1.0.0
func _exit_tree() -> void:
	"""Clean up when the node is removed from the scene tree"""
	cleanup() 