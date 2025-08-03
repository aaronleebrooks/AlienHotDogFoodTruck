extends Resource
class_name BaseResource

## BaseResource
## 
## Base class for all game resources with common functionality.
## 
## This class provides standardized resource management including loading/unloading,
## metadata tracking, lifecycle management, and comprehensive validation. All game
## resources should extend this class to ensure consistent behavior and proper
## resource handling.
## 
## Features:
##   - Resource identification and versioning
##   - Metadata and tagging system
##   - Loading state tracking
##   - Access time monitoring
##   - Automatic resource ID generation
##   - Comprehensive validation system
##   - Data integrity checks
##   - Schema validation
##   - Validation rules and constraints
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

# Enhanced validation system
@export var validation_enabled: bool = true
@export var strict_validation: bool = false
@export var auto_validate_on_load: bool = true
@export var auto_validate_on_save: bool = true

# Validation state
var _validation_errors: Array[Dictionary] = []
var _validation_warnings: Array[Dictionary] = []
var _last_validation_time: float = 0.0
var _validation_schema: Dictionary = {}
var _validation_rules: Dictionary = {}

# Data integrity
var _data_hash: String = ""
var _last_modified: float = 0.0
var _is_dirty: bool = false

# Validation categories
enum ValidationCategory {
	DATA_INTEGRITY,
	SCHEMA_COMPLIANCE,
	BUSINESS_LOGIC,
	PERFORMANCE,
	SECURITY,
	ACCESSIBILITY
}

# Validation severity levels
enum ValidationSeverity {
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

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

## validation_completed
## 
## Emitted when validation is completed.
## 
## This signal indicates that validation has finished and provides
## information about any errors or warnings found.
## 
## Parameters:
##   errors (Array): Array of validation errors
##   warnings (Array): Array of validation warnings
##   is_valid (bool): Whether the resource passed validation
## 
## Example:
##   validation_completed.connect(_on_validation_completed)
##   func _on_validation_completed(errors: Array, warnings: Array, is_valid: bool):
##       if not is_valid:
##           handle_validation_errors(errors)
signal validation_completed(errors: Array, warnings: Array, is_valid: bool)

## data_integrity_changed
## 
## Emitted when data integrity status changes.
## 
## This signal indicates that the resource's data integrity has changed,
## either due to modifications or validation results.
## 
## Parameters:
##   is_valid (bool): Whether the data integrity is valid
##   hash (String): Current data hash
## 
## Example:
##   data_integrity_changed.connect(_on_data_integrity_changed)
##   func _on_data_integrity_changed(is_valid: bool, hash: String):
##       update_integrity_status(is_valid)
signal data_integrity_changed(is_valid: bool, hash: String)

func _init() -> void:
	"""Initialize the base resource"""
	_generate_resource_id()
	_initialize_validation_system()

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

## _initialize_validation_system
## 
## Initialize the validation system with default rules and schema.
## 
## @since: 1.0.0
func _initialize_validation_system() -> void:
	"""Initialize the validation system with default rules and schema"""
	# Set up default validation schema
	_validation_schema = {
		"resource_id": {
			"type": "string",
			"required": true,
			"min_length": 1,
			"max_length": 100
		},
		"custom_resource_name": {
			"type": "string",
			"required": true,
			"min_length": 1,
			"max_length": 50
		},
		"resource_version": {
			"type": "string",
			"required": true,
			"pattern": r"^\d+\.\d+\.\d+$"
		},
		"description": {
			"type": "string",
			"required": false,
			"max_length": 500
		},
		"tags": {
			"type": "array",
			"required": false,
			"max_items": 20
		}
	}
	
	# Set up default validation rules
	_validation_rules = {
		"resource_integrity": {
			"enabled": true,
			"severity": ValidationSeverity.ERROR,
			"category": ValidationCategory.DATA_INTEGRITY
		},
		"schema_compliance": {
			"enabled": true,
			"severity": ValidationSeverity.ERROR,
			"category": ValidationCategory.SCHEMA_COMPLIANCE
		},
		"business_logic": {
			"enabled": true,
			"severity": ValidationSeverity.WARNING,
			"category": ValidationCategory.BUSINESS_LOGIC
		}
	}

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
		
		# Update data integrity
		_update_data_integrity()
		
		# Auto-validate if enabled
		if auto_validate_on_load and validation_enabled:
			validate_resource()
		
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

## validate_resource
## 
## Validate the resource data and structure.
## 
## This function performs comprehensive validation of the resource
## including data integrity, schema compliance, and business logic.
## 
## Returns:
##   bool: True if validation passed, false otherwise
## 
## @since: 1.0.0
func validate_resource() -> bool:
	"""Validate the resource data and structure"""
	if not validation_enabled:
		return true
	
	print("%s: Starting resource validation" % custom_resource_name)
	
	# Clear previous validation results
	_validation_errors.clear()
	_validation_warnings.clear()
	
	# Perform validation checks
	_validate_data_integrity()
	_validate_schema_compliance()
	_validate_business_logic()
	_validate_custom_rules()
	
	# Update validation timestamp
	_last_validation_time = Time.get_ticks_msec()
	
	# Determine if validation passed
	var is_valid = _validation_errors.is_empty() or not strict_validation
	
	# Emit validation completed signal
	validation_completed.emit(_validation_errors.duplicate(), _validation_warnings.duplicate(), is_valid)
	
	print("%s: Validation completed - Valid: %s, Errors: %d, Warnings: %d" % [
		custom_resource_name, is_valid, _validation_errors.size(), _validation_warnings.size()
	])
	
	return is_valid

## _validate_data_integrity
## 
## Validate data integrity of the resource.
## 
## @since: 1.0.0
func _validate_data_integrity() -> void:
	"""Validate data integrity of the resource"""
	if not _validation_rules.resource_integrity.enabled:
		return
	
	# Check if data hash is valid
	var current_hash = _calculate_data_hash()
	if current_hash != _data_hash and not _data_hash.is_empty():
		_add_validation_error(
			"DATA_INTEGRITY_001",
			"Data integrity check failed",
			"Resource data has been modified since last validation",
			ValidationSeverity.ERROR,
			ValidationCategory.DATA_INTEGRITY
		)
	
	# Check for data corruption indicators
	_validate_data_corruption()

## _validate_schema_compliance
## 
## Validate schema compliance of the resource.
## 
## @since: 1.0.0
func _validate_schema_compliance() -> void:
	"""Validate schema compliance of the resource"""
	if not _validation_rules.schema_compliance.enabled:
		return
	
	# Validate required fields
	for field_name in _validation_schema:
		var field_schema = _validation_schema[field_name]
		var field_value = get(field_name)
		
		# Check if required field is present
		if field_schema.get("required", false) and (field_value == null or field_value == ""):
			_add_validation_error(
				"SCHEMA_001",
				"Required field missing",
				"Field '%s' is required but not present" % field_name,
				ValidationSeverity.ERROR,
				ValidationCategory.SCHEMA_COMPLIANCE
			)
			continue
		
		# Validate field type
		if field_value != null:
			_validate_field_type(field_name, field_value, field_schema)
			
			# Validate field constraints
			_validate_field_constraints(field_name, field_value, field_schema)

## _validate_business_logic
## 
## Validate business logic rules for the resource.
## 
## @since: 1.0.0
func _validate_business_logic() -> void:
	"""Validate business logic rules for the resource"""
	if not _validation_rules.business_logic.enabled:
		return
	
	# Override in derived classes to implement specific business logic validation
	pass

## _validate_custom_rules
## 
## Validate custom validation rules.
## 
## @since: 1.0.0
func _validate_custom_rules() -> void:
	"""Validate custom validation rules"""
	# Override in derived classes to implement custom validation rules
	pass

## _validate_data_corruption
## 
## Check for data corruption indicators.
## 
## @since: 1.0.0
func _validate_data_corruption() -> void:
	"""Check for data corruption indicators"""
	# Override in derived classes to implement specific corruption checks
	pass

## _validate_field_type
## 
## Validate field type according to schema.
## 
## Parameters:
##   field_name (String): Name of the field to validate
##   field_value: Value of the field
##   field_schema (Dictionary): Schema definition for the field
## 
## @since: 1.0.0
func _validate_field_type(field_name: String, field_value, field_schema: Dictionary) -> void:
	"""Validate field type according to schema"""
	var expected_type = field_schema.get("type", "any")
	
	match expected_type:
		"string":
			if not field_value is String:
				_add_validation_error(
					"SCHEMA_002",
					"Invalid field type",
					"Field '%s' should be a string, got %s" % [field_name, typeof(field_value)],
					ValidationSeverity.ERROR,
					ValidationCategory.SCHEMA_COMPLIANCE
				)
		"array":
			if not field_value is Array:
				_add_validation_error(
					"SCHEMA_003",
					"Invalid field type",
					"Field '%s' should be an array, got %s" % [field_name, typeof(field_value)],
					ValidationSeverity.ERROR,
					ValidationCategory.SCHEMA_COMPLIANCE
				)
		"int":
			if not field_value is int:
				_add_validation_error(
					"SCHEMA_004",
					"Invalid field type",
					"Field '%s' should be an integer, got %s" % [field_name, typeof(field_value)],
					ValidationSeverity.ERROR,
					ValidationCategory.SCHEMA_COMPLIANCE
				)
		"float":
			if not field_value is float:
				_add_validation_error(
					"SCHEMA_005",
					"Invalid field type",
					"Field '%s' should be a float, got %s" % [field_name, typeof(field_value)],
					ValidationSeverity.ERROR,
					ValidationCategory.SCHEMA_COMPLIANCE
				)
		"bool":
			if not field_value is bool:
				_add_validation_error(
					"SCHEMA_006",
					"Invalid field type",
					"Field '%s' should be a boolean, got %s" % [field_name, typeof(field_value)],
					ValidationSeverity.ERROR,
					ValidationCategory.SCHEMA_COMPLIANCE
				)

## _validate_field_constraints
## 
## Validate field constraints according to schema.
## 
## Parameters:
##   field_name (String): Name of the field to validate
##   field_value: Value of the field
##   field_schema (Dictionary): Schema definition for the field
## 
## @since: 1.0.0
func _validate_field_constraints(field_name: String, field_value, field_schema: Dictionary) -> void:
	"""Validate field constraints according to schema"""
	if field_value is String:
		var string_value = field_value as String
		
		# Check minimum length
		if field_schema.has("min_length") and string_value.length() < field_schema.min_length:
			_add_validation_error(
				"SCHEMA_007",
				"Field too short",
				"Field '%s' must be at least %d characters long" % [field_name, field_schema.min_length],
				ValidationSeverity.ERROR,
				ValidationCategory.SCHEMA_COMPLIANCE
			)
		
		# Check maximum length
		if field_schema.has("max_length") and string_value.length() > field_schema.max_length:
			_add_validation_error(
				"SCHEMA_008",
				"Field too long",
				"Field '%s' must be at most %d characters long" % [field_name, field_schema.max_length],
				ValidationSeverity.ERROR,
				ValidationCategory.SCHEMA_COMPLIANCE
			)
		
		# Check pattern
		if field_schema.has("pattern"):
			var regex = RegEx.new()
			regex.compile(field_schema.pattern)
			if not regex.search(string_value):
				_add_validation_error(
					"SCHEMA_009",
					"Invalid field format",
					"Field '%s' does not match required pattern" % field_name,
					ValidationSeverity.ERROR,
					ValidationCategory.SCHEMA_COMPLIANCE
				)
	
	elif field_value is Array:
		var array_value = field_value as Array
		
		# Check maximum items
		if field_schema.has("max_items") and array_value.size() > field_schema.max_items:
			_add_validation_error(
				"SCHEMA_010",
				"Too many items",
				"Field '%s' must have at most %d items" % [field_name, field_schema.max_items],
				ValidationSeverity.ERROR,
				ValidationCategory.SCHEMA_COMPLIANCE
			)

## _add_validation_error
## 
## Add a validation error to the error list.
## 
## Parameters:
##   code (String): Error code
##   title (String): Error title
##   message (String): Error message
##   severity (ValidationSeverity): Error severity
##   category (ValidationCategory): Error category
## 
## @since: 1.0.0
func _add_validation_error(code: String, title: String, message: String, severity: ValidationSeverity, category: ValidationCategory) -> void:
	"""Add a validation error to the error list"""
	var error = {
		"code": code,
		"title": title,
		"message": message,
		"severity": severity,
		"category": category,
		"timestamp": Time.get_ticks_msec(),
		"resource_id": resource_id
	}
	
	if severity == ValidationSeverity.ERROR or severity == ValidationSeverity.CRITICAL:
		_validation_errors.append(error)
	else:
		_validation_warnings.append(error)

## _calculate_data_hash
## 
## Calculate a hash of the resource data for integrity checking.
## 
## Returns:
##   String: Hash of the resource data
## 
## @since: 1.0.0
func _calculate_data_hash() -> String:
	"""Calculate a hash of the resource data for integrity checking"""
	# Override in derived classes to implement specific hash calculation
	return ""

## _update_data_integrity
## 
## Update data integrity information.
## 
## @since: 1.0.0
func _update_data_integrity() -> void:
	"""Update data integrity information"""
	var new_hash = _calculate_data_hash()
	var old_hash = _data_hash
	_data_hash = new_hash
	_last_modified = Time.get_ticks_msec()
	
	if old_hash != new_hash and not old_hash.is_empty():
		_is_dirty = true
		data_integrity_changed.emit(true, new_hash)

## get_validation_results
## 
## Get the current validation results.
## 
## Returns:
##   Dictionary: Validation results including errors and warnings
## 
## @since: 1.0.0
func get_validation_results() -> Dictionary:
	"""Get the current validation results"""
	return {
		"errors": _validation_errors.duplicate(),
		"warnings": _validation_warnings.duplicate(),
		"last_validation_time": _last_validation_time,
		"is_valid": _validation_errors.is_empty() or not strict_validation
	}

## clear_validation_results
## 
## Clear all validation results.
## 
## @since: 1.0.0
func clear_validation_results() -> void:
	"""Clear all validation results"""
	_validation_errors.clear()
	_validation_warnings.clear()

## add_validation_rule
## 
## Add a custom validation rule.
## 
## Parameters:
##   rule_name (String): Name of the validation rule
##   rule_config (Dictionary): Rule configuration
## 
## @since: 1.0.0
func add_validation_rule(rule_name: String, rule_config: Dictionary) -> void:
	"""Add a custom validation rule"""
	_validation_rules[rule_name] = rule_config

## set_validation_schema
## 
## Set the validation schema for the resource.
## 
## Parameters:
##   schema (Dictionary): Validation schema definition
## 
## @since: 1.0.0
func set_validation_schema(schema: Dictionary) -> void:
	"""Set the validation schema for the resource"""
	_validation_schema = schema

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
	var validation_results = get_validation_results()
	
	return {
		"id": resource_id,
		"name": custom_resource_name,
		"version": resource_version,
		"description": description,
		"loaded": is_loaded,
		"enabled": is_enabled,
		"load_time": load_time,
		"last_accessed": last_accessed,
		"tags": tags.duplicate(),
		"validation_enabled": validation_enabled,
		"validation_results": validation_results,
		"data_integrity": {
			"hash": _data_hash,
			"last_modified": _last_modified,
			"is_dirty": _is_dirty
		}
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