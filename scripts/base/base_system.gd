extends Node
class_name BaseSystem

## Base class for all game systems with common functionality

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
signal system_initialized
signal system_enabled
signal system_disabled
signal system_paused
signal system_resumed
signal system_error(error_message: String)

func _ready() -> void:
	"""Initialize the base system"""
	_initialize_system()

func _initialize_system() -> void:
	"""Initialize the system - override in derived classes"""
	print("%s: Initializing system" % system_name)
	is_initialized = true
	system_initialized.emit()

func enable_system() -> void:
	"""Enable the system"""
	if not is_enabled:
		is_enabled = true
		print("%s: System enabled" % system_name)
		system_enabled.emit()

func disable_system() -> void:
	"""Disable the system"""
	if is_enabled:
		is_enabled = false
		print("%s: System disabled" % system_name)
		system_disabled.emit()

func pause_system() -> void:
	"""Pause the system"""
	if not is_paused:
		is_paused = true
		print("%s: System paused" % system_name)
		system_paused.emit()

func resume_system() -> void:
	"""Resume the system"""
	if is_paused:
		is_paused = false
		print("%s: System resumed" % system_name)
		system_resumed.emit()

func is_system_ready() -> bool:
	"""Check if the system is ready to operate"""
	return is_initialized and is_enabled and not is_paused

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

func log_error(error_message: String) -> void:
	"""Log a system error"""
	print("%s: ERROR - %s" % [system_name, error_message])
	system_error.emit(error_message)

func cleanup() -> void:
	"""Clean up system resources - override in derived classes"""
	print("%s: Cleaning up system" % system_name)
	disable_system()

func _exit_tree() -> void:
	"""Clean up when system is removed"""
	cleanup() 