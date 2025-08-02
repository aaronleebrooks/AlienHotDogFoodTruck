extends Node
class_name BaseSystem

## BaseSystem
## 
## Base class for all game systems with common functionality.
## 
## This class provides standardized system management including initialization,
## enabling/disabling, pausing/resuming, and cleanup. All game systems should
## extend this class to ensure consistent behavior and proper lifecycle management.
## 
## Features:
##   - System state management (initialized, enabled, paused)
##   - Performance tracking and monitoring
##   - Standardized error logging
##   - Automatic cleanup on destruction
##   - Signal-based state change notifications
## 
## Example:
##   class_name MySystem
##   extends BaseSystem
##   
##   func _ready():
##       system_name = "MySystem"
##       super._ready()
## 
## @since: 1.0.0
## @category: System

# System identification
@export var system_name: String = "BaseSystem"
@export var system_version: String = "1.0.0"

# System state
var is_initialized: bool = false
var is_enabled: bool = true
var is_paused: bool = false

# Performance tracking
var last_update_time: float = 0.0
var update_count: int = 0

# Signals
## system_initialized
## 
## Emitted when the system has been successfully initialized.
## 
## This signal indicates that the system is ready to operate and all
## required resources have been loaded. Listeners should wait for this
## signal before interacting with the system.
## 
## Example:
##   system_initialized.connect(_on_system_ready)
##   func _on_system_ready():
##       start_using_system()
signal system_initialized

## system_enabled
## 
## Emitted when the system is enabled.
## 
## This signal indicates that the system has been activated and is
## now processing updates. Listeners can resume normal operation.
## 
## Example:
##   system_enabled.connect(_on_system_enabled)
##   func _on_system_enabled():
##       resume_system_operations()
signal system_enabled

## system_disabled
## 
## Emitted when the system is disabled.
## 
## This signal indicates that the system has been deactivated and is
## no longer processing updates. Listeners should pause operations.
## 
## Example:
##   system_disabled.connect(_on_system_disabled)
##   func _on_system_disabled():
##       pause_system_operations()
signal system_disabled

## system_paused
## 
## Emitted when the system is paused.
## 
## This signal indicates that the system has been temporarily paused
## but remains initialized. Listeners should suspend time-sensitive operations.
## 
## Example:
##   system_paused.connect(_on_system_paused)
##   func _on_system_paused():
##       suspend_time_sensitive_operations()
signal system_paused

## system_resumed
## 
## Emitted when the system is resumed from pause.
## 
## This signal indicates that the system has been unpaused and is
## resuming normal operation. Listeners can restart time-sensitive operations.
## 
## Example:
##   system_resumed.connect(_on_system_resumed)
##   func _on_system_resumed():
##       restart_time_sensitive_operations()
signal system_resumed

## system_error
## 
## Emitted when an error occurs in the system.
## 
## This signal provides error information when the system encounters
## a problem. Listeners should handle errors appropriately.
## 
## Parameters:
##   error_message (String): Description of the error that occurred
## 
## Example:
##   system_error.connect(_on_system_error)
##   func _on_system_error(error_message: String):
##       handle_system_error(error_message)
signal system_error(error_message: String)

func _ready() -> void:
	"""Initialize the base system"""
	_initialize_system()

## _initialize_system
## 
## Initialize the system - override in derived classes.
## 
## This function is called during system initialization and should be
## overridden by derived classes to perform their specific initialization.
## The base implementation sets the initialized flag and emits the
## system_initialized signal.
## 
## Example:
##   func _initialize_system() -> void:
##       # Load system-specific resources
##       load_configuration()
##       # Call parent implementation
##       super._initialize_system()
## 
## @since: 1.0.0
func _initialize_system() -> void:
	"""Initialize the system - override in derived classes"""
	print("%s: Initializing system" % system_name)
	is_initialized = true
	system_initialized.emit()

## enable_system
## 
## Enable the system.
## 
## This function activates the system and allows it to process updates.
## It emits the system_enabled signal when the system is successfully enabled.
## 
## Example:
##   system.enable_system()
##   # System is now active and processing updates
## 
## @since: 1.0.0
func enable_system() -> void:
	"""Enable the system"""
	if not is_enabled:
		is_enabled = true
		print("%s: System enabled" % system_name)
		system_enabled.emit()

## disable_system
## 
## Disable the system.
## 
## This function deactivates the system and stops it from processing updates.
## It emits the system_disabled signal when the system is successfully disabled.
## 
## Example:
##   system.disable_system()
##   # System is now inactive and not processing updates
## 
## @since: 1.0.0
func disable_system() -> void:
	"""Disable the system"""
	if is_enabled:
		is_enabled = false
		print("%s: System disabled" % system_name)
		system_disabled.emit()

## pause_system
## 
## Pause the system.
## 
## This function temporarily pauses the system while keeping it initialized.
## It emits the system_paused signal when the system is successfully paused.
## 
## Example:
##   system.pause_system()
##   # System is paused but remains initialized
## 
## @since: 1.0.0
func pause_system() -> void:
	"""Pause the system"""
	if not is_paused:
		is_paused = true
		print("%s: System paused" % system_name)
		system_paused.emit()

## resume_system
## 
## Resume the system from pause.
## 
## This function unpauses the system and resumes normal operation.
## It emits the system_resumed signal when the system is successfully resumed.
## 
## Example:
##   system.resume_system()
##   # System is now resuming normal operation
## 
## @since: 1.0.0
func resume_system() -> void:
	"""Resume the system"""
	if is_paused:
		is_paused = false
		print("%s: System resumed" % system_name)
		system_resumed.emit()

## is_system_ready
## 
## Check if the system is ready to operate.
## 
## This function returns true if the system is initialized, enabled, and not paused.
## It should be checked before performing system operations.
## 
## Returns:
##   bool: True if the system is ready to operate, false otherwise
## 
## Example:
##   if system.is_system_ready():
##       system.perform_operation()
##   else:
##       print("System not ready")
## 
## @since: 1.0.0
func is_system_ready() -> bool:
	"""Check if the system is ready to operate"""
	return is_initialized and is_enabled and not is_paused

## get_system_info
## 
## Get system information.
## 
## This function returns a dictionary containing comprehensive information
## about the system's current state and performance metrics.
## 
## Returns:
##   Dictionary: System information including name, version, state, and metrics
## 
## Example:
##   var info = system.get_system_info()
##   print("System: %s, Version: %s, Enabled: %s" % [info.name, info.version, info.enabled])
## 
## @since: 1.0.0
func get_system_info() -> Dictionary:
	"""Get system information"""
	return {
		"name": system_name,
		"version": system_version,
		"initialized": is_initialized,
		"enabled": is_enabled,
		"paused": is_paused,
		"update_count": update_count,
		"last_update": last_update_time
	}

## log_error
## 
## Log a system error.
## 
## This function logs an error message and emits the system_error signal.
## It should be used by derived classes to report errors consistently.
## 
## Parameters:
##   error_message (String): The error message to log
## 
## Example:
##   if not validate_data():
##       log_error("Invalid data format")
## 
## @since: 1.0.0
func log_error(error_message: String) -> void:
	"""Log a system error"""
	print("%s: ERROR - %s" % [system_name, error_message])
	system_error.emit(error_message)

## cleanup
## 
## Clean up system resources - override in derived classes.
## 
## This function should be overridden by derived classes to perform
## their specific cleanup operations. The base implementation disables
## the system.
## 
## Example:
##   func cleanup() -> void:
##       # Clean up system-specific resources
##       save_data()
##       disconnect_signals()
##       # Call parent implementation
##       super.cleanup()
## 
## @since: 1.0.0
func cleanup() -> void:
	"""Clean up system resources - override in derived classes"""
	print("%s: Cleaning up system" % system_name)
	disable_system()

func _exit_tree() -> void:
	"""Clean up when system is removed"""
	cleanup() 