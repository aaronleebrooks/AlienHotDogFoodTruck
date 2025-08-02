extends Resource
class_name BaseResource

## Base class for all game resources with common functionality

# Resource identification
@export var custom_resource_name: String = "BaseResource"
@export var resource_version: String = "1.0.0"
@export var resource_id: String = ""

# Resource metadata
@export var description: String = ""
@export var tags: Array[String] = []
@export var is_enabled: bool = true

# Resource state
var is_loaded: bool = false
var load_time: float = 0.0
var last_accessed: float = 0.0

# Signals
signal resource_loaded
signal resource_unloaded
signal resource_accessed
signal resource_error(error_message: String)

func _init() -> void:
	"""Initialize the base resource"""
	_generate_resource_id()

func _generate_resource_id() -> void:
	"""Generate a unique resource ID if not provided"""
	if resource_id.is_empty():
		resource_id = "%s_%s" % [custom_resource_name, str(randi()).substr(0, 8)]

func load_resource() -> bool:
	"""Load the resource - override in derived classes"""
	print("%s: Loading resource" % custom_resource_name)
	
	var start_time = Time.get_ticks_msec()
	var success = _load_resource_data()
	load_time = (Time.get_ticks_msec() - start_time) / 1000.0
	
	if success:
		is_loaded = true
		last_accessed = Time.get_ticks_msec()
		print("%s: Resource loaded successfully in %.3f seconds" % [custom_resource_name, load_time])
		resource_loaded.emit()
	else:
		log_error("Failed to load resource data")
	
	return success

func unload_resource() -> void:
	"""Unload the resource - override in derived classes"""
	print("%s: Unloading resource" % custom_resource_name)
	
	_unload_resource_data()
	is_loaded = false
	resource_unloaded.emit()

func access_resource() -> void:
	"""Mark resource as accessed"""
	last_accessed = Time.get_ticks_msec()
	resource_accessed.emit()

func is_resource_ready() -> bool:
	"""Check if the resource is ready to use"""
	return is_loaded and is_enabled

func get_resource_info() -> Dictionary:
	"""Get resource information"""
	return {
		"name": custom_resource_name,
		"version": resource_version,
		"id": resource_id,
		"description": description,
		"tags": tags,
		"enabled": is_enabled,
		"loaded": is_loaded,
		"load_time": load_time,
		"last_accessed": last_accessed
	}

func has_tag(tag: String) -> bool:
	"""Check if resource has a specific tag"""
	return tag in tags

func add_tag(tag: String) -> void:
	"""Add a tag to the resource"""
	if not has_tag(tag):
		tags.append(tag)

func remove_tag(tag: String) -> void:
	"""Remove a tag from the resource"""
	if has_tag(tag):
		tags.erase(tag)

func log_error(error_message: String) -> void:
	"""Log a resource error"""
	print("%s: ERROR - %s" % [custom_resource_name, error_message])
	resource_error.emit(error_message)

# Virtual methods to override in derived classes
func _load_resource_data() -> bool:
	"""Load resource data - override in derived classes"""
	return true

func _unload_resource_data() -> void:
	"""Unload resource data - override in derived classes"""
	pass

func validate_resource() -> bool:
	"""Validate resource data - override in derived classes"""
	return true 