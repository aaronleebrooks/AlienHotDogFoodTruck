extends Resource
class_name BaseResource

## BaseResource
## 
## Base class for all game resources with common functionality.
## 
## This class provides standardized resource management including loading/unloading,
## metadata tracking, and lifecycle management. All game resources should extend
## this class to ensure consistent behavior and proper resource handling.
## 
## Features:
##   - Resource identification and versioning
##   - Metadata and tagging system
##   - Loading state tracking
##   - Access time monitoring
##   - Automatic resource ID generation
## 
## Example:
##   class_name MyResource
##   extends BaseResource
##   
##   func _init():
##       custom_resource_name = "MyResource"
##       super._init()
## 
## @since: 1.0.0
## @category: Resource

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
## resource_loaded
## 
## Emitted when the resource has been successfully loaded.
## 
## This signal indicates that the resource is ready to use and all
## data has been loaded from storage. Listeners should wait for this
## signal before accessing resource data.
## 
## Example:
##   resource_loaded.connect(_on_resource_loaded)
##   func _on_resource_loaded():
##       start_using_resource()
signal resource_loaded

## resource_unloaded
## 
## Emitted when the resource has been unloaded.
## 
## This signal indicates that the resource has been freed from memory
## and is no longer available for use. Listeners should stop accessing
## the resource data.
## 
## Example:
##   resource_unloaded.connect(_on_resource_unloaded)
##   func _on_resource_unloaded():
##       stop_using_resource()
signal resource_unloaded

## resource_accessed
## 
## Emitted when the resource is accessed.
## 
## This signal indicates that the resource data has been read or modified.
## It can be used for tracking usage patterns or implementing caching logic.
## 
## Example:
##   resource_accessed.connect(_on_resource_accessed)
##   func _on_resource_accessed():
##       update_access_timestamp()
signal resource_accessed

## resource_error
## 
## Emitted when an error occurs with the resource.
## 
## This signal provides error information when the resource encounters
## a problem during loading, saving, or other operations.
## 
## Parameters:
##   error_message (String): Description of the error that occurred
## 
## Example:
##   resource_error.connect(_on_resource_error)
##   func _on_resource_error(error_message: String):
##       handle_resource_error(error_message)
signal resource_error(error_message: String)

func _init() -> void:
	"""Initialize the base resource"""
	_generate_resource_id()

## _generate_resource_id
## 
## Generate a unique resource ID if not provided.
## 
## This function creates a unique identifier for the resource using
## the resource name and a random number. It should be called during
## initialization if no resource_id is provided.
## 
## Example:
##   # Called automatically during _init()
##   # Generates ID like "MyResource_12345678"
## 
## @since: 1.0.0
func _generate_resource_id() -> void:
	"""Generate a unique resource ID if not provided"""
	if resource_id.is_empty():
		resource_id = "%s_%s" % [custom_resource_name, str(randi()).substr(0, 8)]

## load_resource
## 
## Load the resource - override in derived classes.
## 
## This function loads the resource data and should be overridden by
## derived classes to perform their specific loading operations. The
## base implementation tracks loading time and state.
## 
## Returns:
##   bool: True if loading was successful, false otherwise
## 
## Example:
##   var success = resource.load_resource()
##   if success:
##       print("Resource loaded successfully")
## 
## @since: 1.0.0
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

## unload_resource
## 
## Unload the resource - override in derived classes.
## 
## This function frees the resource data and should be overridden by
## derived classes to perform their specific cleanup operations. The
## base implementation tracks unloading state.
## 
## Example:
##   resource.unload_resource()
##   # Resource is now freed from memory
## 
## @since: 1.0.0
func unload_resource() -> void:
	"""Unload the resource - override in derived classes"""
	print("%s: Unloading resource" % custom_resource_name)
	
	_unload_resource_data()
	is_loaded = false
	resource_unloaded.emit()

## access_resource
## 
## Mark resource as accessed.
## 
## This function updates the last access time and emits the
## resource_accessed signal. It should be called whenever the
## resource data is read or modified.
## 
## Example:
##   resource.access_resource()
##   var data = resource.get_data()
## 
## @since: 1.0.0
func access_resource() -> void:
	"""Mark resource as accessed"""
	last_accessed = Time.get_ticks_msec()
	resource_accessed.emit()

## is_resource_ready
## 
## Check if the resource is ready to use.
## 
## This function returns true if the resource is loaded and enabled.
## It should be checked before accessing resource data.
## 
## Returns:
##   bool: True if the resource is ready to use, false otherwise
## 
## Example:
##   if resource.is_resource_ready():
##       var data = resource.get_data()
##   else:
##       print("Resource not ready")
## 
## @since: 1.0.0
func is_resource_ready() -> bool:
	"""Check if the resource is ready to use"""
	return is_loaded and is_enabled

## get_resource_info
## 
## Get resource information.
## 
## This function returns a dictionary containing comprehensive information
## about the resource's current state and metadata.
## 
## Returns:
##   Dictionary: Resource information including ID, version, state, and metadata
## 
## Example:
##   var info = resource.get_resource_info()
##   print("Resource: %s, Version: %s, Loaded: %s" % [info.id, info.version, info.loaded])
## 
## @since: 1.0.0
func get_resource_info() -> Dictionary:
	"""Get resource information"""
	return {
		"id": resource_id,
		"name": custom_resource_name,
		"version": resource_version,
		"description": description,
		"loaded": is_loaded,
		"enabled": is_enabled,
		"load_time": load_time,
		"last_accessed": last_accessed,
		"tags": tags.duplicate()
	}

## add_tag
## 
## Add a tag to the resource.
## 
## This function adds a tag to the resource's tag list. Tags can be
## used for categorization, filtering, and organization.
## 
## Parameters:
##   tag (String): The tag to add to the resource
## 
## Example:
##   resource.add_tag("config")
##   resource.add_tag("game_settings")
## 
## @since: 1.0.0
func add_tag(tag: String) -> void:
	"""Add a tag to the resource"""
	if not tags.has(tag):
		tags.append(tag)

## remove_tag
## 
## Remove a tag from the resource.
## 
## This function removes a tag from the resource's tag list.
## 
## Parameters:
##   tag (String): The tag to remove from the resource
## 
## Example:
##   resource.remove_tag("obsolete")
## 
## @since: 1.0.0
func remove_tag(tag: String) -> void:
	"""Remove a tag from the resource"""
	tags.erase(tag)

## has_tag
## 
## Check if the resource has a specific tag.
## 
## This function returns true if the resource has the specified tag.
## 
## Parameters:
##   tag (String): The tag to check for
## 
## Returns:
##   bool: True if the resource has the tag, false otherwise
## 
## Example:
##   if resource.has_tag("config"):
##       print("This is a configuration resource")
## 
## @since: 1.0.0
func has_tag(tag: String) -> bool:
	"""Check if the resource has a specific tag"""
	return tags.has(tag)

## _load_resource_data
## 
## Load resource data - override in derived classes.
## 
## This function should be overridden by derived classes to perform
## their specific data loading operations. The base implementation
## returns true by default.
## 
## Returns:
##   bool: True if loading was successful, false otherwise
## 
## Example:
##   func _load_resource_data() -> bool:
##       # Load data from file or other source
##       var file = FileAccess.open("res://data.txt", FileAccess.READ)
##       if file:
##           data = file.get_as_text()
##           file.close()
##           return true
##       return false
## 
## @since: 1.0.0
func _load_resource_data() -> bool:
	"""Load resource data - override in derived classes"""
	return true

## _unload_resource_data
## 
## Unload resource data - override in derived classes.
## 
## This function should be overridden by derived classes to perform
## their specific data cleanup operations. The base implementation
## does nothing by default.
## 
## Example:
##   func _unload_resource_data() -> void:
##       # Clear loaded data
##       data.clear()
##       # Free any allocated memory
##       free_allocated_resources()
## 
## @since: 1.0.0
func _unload_resource_data() -> void:
	"""Unload resource data - override in derived classes"""
	pass

## log_error
## 
## Log a resource error.
## 
## This function logs an error message and emits the resource_error signal.
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
	"""Log a resource error"""
	print("%s: ERROR - %s" % [custom_resource_name, error_message])
	resource_error.emit(error_message) 