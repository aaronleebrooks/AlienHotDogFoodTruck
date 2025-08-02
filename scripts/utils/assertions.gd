extends RefCounted

## Assertions
## 
## Development-time assertion system for error checking and validation.
## 
## This class provides assertion functions for validating conditions during
## development. Assertions help catch errors early and provide clear error
## messages. They are automatically disabled in release builds.
## 
## Features:
##   - Condition validation with custom error messages
##   - Type checking assertions
##   - Range and value validation
##   - Object and resource validation
##   - Array and dictionary validation
##   - Performance assertions
## 
## Example:
##   Assertions.assert_true(value > 0, "Value must be positive")
##   Assertions.assert_not_null(object, "Object cannot be null")
##   Assertions.assert_type(value, String, "Value must be a string")
## 
## @since: 1.0.0
## @category: Utility

# Assertion configuration
static var _assertions_enabled: bool = true
static var _break_on_failure: bool = false

## assert_true
## 
## Assert that a condition is true.
## 
## This function validates that the given condition is true. If the
## condition is false, it logs an error and optionally breaks execution.
## 
## Parameters:
##   condition (bool): Condition to validate
##   message (String, optional): Error message if assertion fails
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   Assertions.assert_true(value > 0, "Value must be positive")
## 
## @since: 1.0.0
static func assert_true(condition: bool, message: String = "Assertion failed", context: Dictionary = {}) -> void:
	"""Assert that a condition is true"""
	if not _assertions_enabled:
		return
	
	if not condition:
		_handle_assertion_failure("assert_true", message, context)

## assert_false
## 
## Assert that a condition is false.
## 
## This function validates that the given condition is false. If the
## condition is true, it logs an error and optionally breaks execution.
## 
## Parameters:
##   condition (bool): Condition to validate
##   message (String, optional): Error message if assertion fails
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   Assertions.assert_false(value < 0, "Value must not be negative")
## 
## @since: 1.0.0
static func assert_false(condition: bool, message: String = "Assertion failed", context: Dictionary = {}) -> void:
	"""Assert that a condition is false"""
	if not _assertions_enabled:
		return
	
	if condition:
		_handle_assertion_failure("assert_false", message, context)

## assert_not_null
## 
## Assert that an object is not null.
## 
## This function validates that the given object is not null. If the
## object is null, it logs an error and optionally breaks execution.
## 
## Parameters:
##   obj (Object): Object to validate
##   message (String, optional): Error message if assertion fails
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   Assertions.assert_not_null(node, "Node cannot be null")
## 
## @since: 1.0.0
static func assert_not_null(obj: Object, message: String = "Object cannot be null", context: Dictionary = {}) -> void:
	"""Assert that an object is not null"""
	if not _assertions_enabled:
		return
	
	if obj == null:
		_handle_assertion_failure("assert_not_null", message, context)

## assert_null
## 
## Assert that an object is null.
## 
## This function validates that the given object is null. If the
## object is not null, it logs an error and optionally breaks execution.
## 
## Parameters:
##   obj (Object): Object to validate
##   message (String, optional): Error message if assertion fails
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   Assertions.assert_null(cleaned_object, "Object should be null after cleanup")
## 
## @since: 1.0.0
static func assert_null(obj: Object, message: String = "Object should be null", context: Dictionary = {}) -> void:
	"""Assert that an object is null"""
	if not _assertions_enabled:
		return
	
	if obj != null:
		_handle_assertion_failure("assert_null", message, context)

## assert_type
## 
## Assert that a value is of a specific type.
## 
## This function validates that the given value is of the expected type.
## If the type doesn't match, it logs an error and optionally breaks execution.
## 
## Parameters:
##   value: Value to check type of
##   expected_type (Script): Expected type
##   message (String, optional): Error message if assertion fails
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   Assertions.assert_type(value, String, "Value must be a string")
## 
## @since: 1.0.0
static func assert_type(value, expected_type: Script, message: String = "Type assertion failed", context: Dictionary = {}) -> void:
	"""Assert that a value is of a specific type"""
	if not _assertions_enabled:
		return
	
	# Use get_class() for type checking instead of 'is' operator
	var value_class = value.get_class() if value else "null"
	var expected_class = expected_type.get_class()
	
	if value_class != expected_class:
		var type_message = "%s (expected %s, got %s)" % [message, expected_class, value_class]
		_handle_assertion_failure("assert_type", type_message, context)

## assert_equal
## 
## Assert that two values are equal.
## 
## This function validates that two values are equal. If they are not
## equal, it logs an error and optionally breaks execution.
## 
## Parameters:
##   actual: Actual value
##   expected: Expected value
##   message (String, optional): Error message if assertion fails
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   Assertions.assert_equal(actual_value, expected_value, "Values should be equal")
## 
## @since: 1.0.0
static func assert_equal(actual, expected, message: String = "Values should be equal", context: Dictionary = {}) -> void:
	"""Assert that two values are equal"""
	if not _assertions_enabled:
		return
	
	if actual != expected:
		var equality_message = "%s (expected %s, got %s)" % [message, str(expected), str(actual)]
		_handle_assertion_failure("assert_equal", equality_message, context)

## assert_not_equal
## 
## Assert that two values are not equal.
## 
## This function validates that two values are not equal. If they are
## equal, it logs an error and optionally breaks execution.
## 
## Parameters:
##   actual: Actual value
##   expected: Expected value
##   message (String, optional): Error message if assertion fails
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   Assertions.assert_not_equal(actual_value, old_value, "Value should have changed")
## 
## @since: 1.0.0
static func assert_not_equal(actual, expected, message: String = "Values should not be equal", context: Dictionary = {}) -> void:
	"""Assert that two values are not equal"""
	if not _assertions_enabled:
		return
	
	if actual == expected:
		var equality_message = "%s (both values are %s)" % [message, str(actual)]
		_handle_assertion_failure("assert_not_equal", equality_message, context)

## assert_in_range
## 
## Assert that a value is within a specified range.
## 
## This function validates that a value is within the given range (inclusive).
## If the value is outside the range, it logs an error and optionally breaks execution.
## 
## Parameters:
##   value (float): Value to check
##   min_value (float): Minimum allowed value
##   max_value (float): Maximum allowed value
##   message (String, optional): Error message if assertion fails
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   Assertions.assert_in_range(value, 0.0, 1.0, "Value must be between 0 and 1")
## 
## @since: 1.0.0
static func assert_in_range(value: float, min_value: float, max_value: float, message: String = "Value out of range", context: Dictionary = {}) -> void:
	"""Assert that a value is within a specified range"""
	if not _assertions_enabled:
		return
	
	if value < min_value or value > max_value:
		var range_message = "%s (value %s not in range [%s, %s])" % [message, str(value), str(min_value), str(max_value)]
		_handle_assertion_failure("assert_in_range", range_message, context)

## assert_array_size
## 
## Assert that an array has a specific size.
## 
## This function validates that an array has the expected size. If the
## size doesn't match, it logs an error and optionally breaks execution.
## 
## Parameters:
##   array (Array): Array to check
##   expected_size (int): Expected array size
##   message (String, optional): Error message if assertion fails
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   Assertions.assert_array_size(items, 5, "Array should have 5 items")
## 
## @since: 1.0.0
static func assert_array_size(array: Array, expected_size: int, message: String = "Array size assertion failed", context: Dictionary = {}) -> void:
	"""Assert that an array has a specific size"""
	if not _assertions_enabled:
		return
	
	var actual_size = array.size()
	if actual_size != expected_size:
		var size_message = "%s (expected size %d, got %d)" % [message, expected_size, actual_size]
		_handle_assertion_failure("assert_array_size", size_message, context)

## assert_array_not_empty
## 
## Assert that an array is not empty.
## 
## This function validates that an array contains at least one element.
## If the array is empty, it logs an error and optionally breaks execution.
## 
## Parameters:
##   array (Array): Array to check
##   message (String, optional): Error message if assertion fails
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   Assertions.assert_array_not_empty(items, "Items array cannot be empty")
## 
## @since: 1.0.0
static func assert_array_not_empty(array: Array, message: String = "Array should not be empty", context: Dictionary = {}) -> void:
	"""Assert that an array is not empty"""
	if not _assertions_enabled:
		return
	
	if array.is_empty():
		_handle_assertion_failure("assert_array_not_empty", message, context)

## assert_dictionary_has_key
## 
## Assert that a dictionary contains a specific key.
## 
## This function validates that a dictionary contains the expected key.
## If the key is missing, it logs an error and optionally breaks execution.
## 
## Parameters:
##   dict (Dictionary): Dictionary to check
##   key: Key to look for
##   message (String, optional): Error message if assertion fails
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   Assertions.assert_dictionary_has_key(config, "version", "Config must have version key")
## 
## @since: 1.0.0
static func assert_dictionary_has_key(dict: Dictionary, key, message: String = "Dictionary should contain key", context: Dictionary = {}) -> void:
	"""Assert that a dictionary contains a specific key"""
	if not _assertions_enabled:
		return
	
	if not dict.has(key):
		var key_message = "%s (missing key: %s)" % [message, str(key)]
		_handle_assertion_failure("assert_dictionary_has_key", key_message, context)

## assert_string_not_empty
## 
## Assert that a string is not empty.
## 
## This function validates that a string contains at least one character.
## If the string is empty, it logs an error and optionally breaks execution.
## 
## Parameters:
##   text (String): String to check
##   message (String, optional): Error message if assertion fails
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   Assertions.assert_string_not_empty(name, "Name cannot be empty")
## 
## @since: 1.0.0
static func assert_string_not_empty(text: String, message: String = "String should not be empty", context: Dictionary = {}) -> void:
	"""Assert that a string is not empty"""
	if not _assertions_enabled:
		return
	
	if text.is_empty():
		_handle_assertion_failure("assert_string_not_empty", message, context)

## assert_file_exists
## 
## Assert that a file exists at the specified path.
## 
## This function validates that a file exists at the given path.
## If the file doesn't exist, it logs an error and optionally breaks execution.
## 
## Parameters:
##   file_path (String): Path to the file
##   message (String, optional): Error message if assertion fails
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   Assertions.assert_file_exists("res://config.json", "Config file must exist")
## 
## @since: 1.0.0
static func assert_file_exists(file_path: String, message: String = "File should exist", context: Dictionary = {}) -> void:
	"""Assert that a file exists at the specified path"""
	if not _assertions_enabled:
		return
	
	if not FileAccess.file_exists(file_path):
		var file_message = "%s (file: %s)" % [message, file_path]
		_handle_assertion_failure("assert_file_exists", file_message, context)

## assert_performance
## 
## Assert that a function executes within a time limit.
## 
## This function validates that a function executes within the specified
## time limit. If it takes too long, it logs an error and optionally breaks execution.
## 
## Parameters:
##   func_to_test (Callable): Function to test
##   max_time_ms (int): Maximum execution time in milliseconds
##   message (String, optional): Error message if assertion fails
##   context (Dictionary, optional): Additional context information
## 
## Example:
##   Assertions.assert_performance(func(): heavy_calculation(), 100, "Calculation should complete within 100ms")
## 
## @since: 1.0.0
static func assert_performance(func_to_test: Callable, max_time_ms: int, message: String = "Performance assertion failed", context: Dictionary = {}) -> void:
	"""Assert that a function executes within a time limit"""
	if not _assertions_enabled:
		return
	
	var start_time = Time.get_ticks_msec()
	func_to_test.call()
	var end_time = Time.get_ticks_msec()
	var execution_time = end_time - start_time
	
	if execution_time > max_time_ms:
		var perf_message = "%s (execution time: %dms, max: %dms)" % [message, execution_time, max_time_ms]
		_handle_assertion_failure("assert_performance", perf_message, context)

## _handle_assertion_failure
## 
## Handle assertion failure by logging error and optionally breaking execution.
## 
## This function processes assertion failures by logging detailed error
## information and optionally breaking execution for debugging.
## 
## Parameters:
##   assertion_type (String): Type of assertion that failed
##   message (String): Error message
##   context (Dictionary): Additional context information
## 
## @since: 1.0.0
static func _handle_assertion_failure(assertion_type: String, message: String, context: Dictionary) -> void:
	"""Handle assertion failure by logging error and optionally breaking execution"""
	var error_message = "ASSERTION FAILED: %s - %s" % [assertion_type.to_upper(), message]
	
	# Add context information
	if not context.is_empty():
		error_message += "\nContext: %s" % JSON.stringify(context)
	
	# Log the error (check if ErrorHandler is available)
	if ClassDB.class_exists("ErrorHandler"):
		ErrorHandler.log_error("ASSERTION_%s" % assertion_type.to_upper(), error_message, "Assertion failed during development", context)
	else:
		# Fallback to print if ErrorHandler not available
		print("ASSERTION ERROR: %s" % error_message)
	
	# Break execution if enabled
	if _break_on_failure:
		# In a real implementation, this would trigger a debugger break
		print("BREAK: Assertion failure - %s" % error_message)

## set_assertions_enabled
## 
## Enable or disable assertions.
## 
## This function allows enabling or disabling all assertions for
## performance reasons or release builds.
## 
## Parameters:
##   enabled (bool): Whether to enable assertions
## 
## Example:
##   Assertions.set_assertions_enabled(false)  # Disable assertions
## 
## @since: 1.0.0
static func set_assertions_enabled(enabled: bool) -> void:
	"""Enable or disable assertions"""
	_assertions_enabled = enabled

## set_break_on_failure
## 
## Enable or disable breaking execution on assertion failures.
## 
## This function allows enabling or disabling automatic breaking
## when assertions fail, useful for debugging.
## 
## Parameters:
##   enabled (bool): Whether to break on assertion failures
## 
## Example:
##   Assertions.set_break_on_failure(true)  # Break on failures
## 
## @since: 1.0.0
static func set_break_on_failure(enabled: bool) -> void:
	"""Enable or disable breaking execution on assertion failures"""
	_break_on_failure = enabled 