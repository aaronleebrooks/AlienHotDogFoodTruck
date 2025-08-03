extends Node

## BaseTestSuite
## 
## Base class for all test suites in the hot dog idle game.
## 
## This class provides common testing functionality including:
## - Test setup and teardown
## - Assertion methods
## - Mock object creation
## - Test utilities
## - Performance measurement
## 
## @since: 1.0.0
## @category: Testing

# Test configuration
@export var suite_name: String = "BaseTestSuite"
@export var auto_setup: bool = true
@export var auto_cleanup: bool = true

# Test state
var _test_start_time: int = 0
var _test_results: Array[Dictionary] = []
var _current_test_name: String = ""

# Mock objects
var _mock_objects: Dictionary = {}

# Test utilities
var _test_data: Dictionary = {}

## _ready
## 
## Initialize the test suite.
func _ready() -> void:
	"""Initialize the test suite"""
	if auto_setup:
		_setup()

## _setup
## 
## Setup the test suite environment.
## 
## Override this method in subclasses to perform suite-specific setup.
## 
## @since: 1.0.0
func _setup() -> void:
	"""Setup the test suite environment"""
	print("TestSuite: Setting up %s" % suite_name)

## _cleanup
## 
## Cleanup the test suite environment.
## 
## Override this method in subclasses to perform suite-specific cleanup.
## 
## @since: 1.0.0
func _cleanup() -> void:
	"""Cleanup the test suite environment"""
	print("TestSuite: Cleaning up %s" % suite_name)
	
	# Cleanup mock objects
	for mock_name in _mock_objects:
		var mock = _mock_objects[mock_name]
		if mock.has_method("cleanup"):
			mock.cleanup()
	_mock_objects.clear()

## _before_test
## 
## Setup before each individual test.
## 
## Override this method in subclasses to perform test-specific setup.
## 
## Parameters:
##   test_name (String): Name of the test being run
## 
## @since: 1.0.0
func _before_test(test_name: String) -> void:
	"""Setup before each individual test"""
	_current_test_name = test_name
	_test_start_time = Time.get_ticks_msec()
	print("TestSuite: Starting test: %s" % test_name)

## _after_test
## 
## Cleanup after each individual test.
## 
## Override this method in subclasses to perform test-specific cleanup.
## 
## Parameters:
##   test_name (String): Name of the test that was run
##   passed (bool): Whether the test passed
## 
## @since: 1.0.0
func _after_test(test_name: String, passed: bool) -> void:
	"""Cleanup after each individual test"""
	var duration = (Time.get_ticks_msec() - _test_start_time) / 1000.0
	var status = "PASSED" if passed else "FAILED"
	print("TestSuite: Test %s %s (%.2fms)" % [test_name, status, duration])

# Assertion methods

## assert_true
## 
## Assert that a condition is true.
## 
## Parameters:
##   condition (bool): The condition to check
##   message (String): Optional failure message
## 
## Returns:
##   bool: True if assertion passes, false otherwise
## 
## @since: 1.0.0
func assert_true(condition: bool, message: String = "") -> bool:
	"""Assert that a condition is true"""
	if not condition:
		var failure_msg = "Assertion failed: Expected true, got false"
		if message:
			failure_msg += " - " + message
		_record_test_failure(failure_msg)
		return false
	return true

## assert_false
## 
## Assert that a condition is false.
## 
## Parameters:
##   condition (bool): The condition to check
##   message (String): Optional failure message
## 
## Returns:
##   bool: True if assertion passes, false otherwise
## 
## @since: 1.0.0
func assert_false(condition: bool, message: String = "") -> bool:
	"""Assert that a condition is false"""
	if condition:
		var failure_msg = "Assertion failed: Expected false, got true"
		if message:
			failure_msg += " - " + message
		_record_test_failure(failure_msg)
		return false
	return true

## assert_equal
## 
## Assert that two values are equal.
## 
## Parameters:
##   expected: The expected value
##   actual: The actual value
##   message (String): Optional failure message
## 
## Returns:
##   bool: True if assertion passes, false otherwise
## 
## @since: 1.0.0
func assert_equal(expected, actual, message: String = "") -> bool:
	"""Assert that two values are equal"""
	if expected != actual:
		var failure_msg = "Assertion failed: Expected %s, got %s" % [str(expected), str(actual)]
		if message:
			failure_msg += " - " + message
		_record_test_failure(failure_msg)
		return false
	return true

## assert_not_equal
## 
## Assert that two values are not equal.
## 
## Parameters:
##   expected: The expected value
##   actual: The actual value
##   message (String): Optional failure message
## 
## Returns:
##   bool: True if assertion passes, false otherwise
## 
## @since: 1.0.0
func assert_not_equal(expected, actual, message: String = "") -> bool:
	"""Assert that two values are not equal"""
	if expected == actual:
		var failure_msg = "Assertion failed: Expected not equal to %s, got %s" % [str(expected), str(actual)]
		if message:
			failure_msg += " - " + message
		_record_test_failure(failure_msg)
		return false
	return true

## assert_null
## 
## Assert that a value is null.
## 
## Parameters:
##   value: The value to check
##   message (String): Optional failure message
## 
## Returns:
##   bool: True if assertion passes, false otherwise
## 
## @since: 1.0.0
func assert_null(value, message: String = "") -> bool:
	"""Assert that a value is null"""
	if value != null:
		var failure_msg = "Assertion failed: Expected null, got %s" % str(value)
		if message:
			failure_msg += " - " + message
		_record_test_failure(failure_msg)
		return false
	return true

## assert_not_null
## 
## Assert that a value is not null.
## 
## Parameters:
##   value: The value to check
##   message (String): Optional failure message
## 
## Returns:
##   bool: True if assertion passes, false otherwise
## 
## @since: 1.0.0
func assert_not_null(value, message: String = "") -> bool:
	"""Assert that a value is not null"""
	if value == null:
		var failure_msg = "Assertion failed: Expected not null, got null"
		if message:
			failure_msg += " - " + message
		_record_test_failure(failure_msg)
		return false
	return true

## assert_almost_equal
## 
## Assert that two float values are almost equal (within tolerance).
## 
## Parameters:
##   expected (float): The expected value
##   actual (float): The actual value
##   tolerance (float): The tolerance for comparison
##   message (String): Optional failure message
## 
## Returns:
##   bool: True if assertion passes, false otherwise
## 
## @since: 1.0.0
func assert_almost_equal(expected: float, actual: float, tolerance: float = 0.001, message: String = "") -> bool:
	"""Assert that two float values are almost equal"""
	if abs(expected - actual) > tolerance:
		var failure_msg = "Assertion failed: Expected %.6f ± %.6f, got %.6f" % [expected, tolerance, actual]
		if message:
			failure_msg += " - " + message
		_record_test_failure(failure_msg)
		return false
	return true

# Mock object methods

## create_mock
## 
## Create a mock object for testing.
## 
## Parameters:
##   mock_name (String): Name for the mock object
##   mock_class (GDScript): Class to mock
## 
## Returns:
##   Object: The created mock object
## 
## @since: 1.0.0
func create_mock(mock_name: String, mock_class: GDScript) -> Object:
	"""Create a mock object for testing"""
	var mock = mock_class.new()
	_mock_objects[mock_name] = mock
	return mock

## get_mock
## 
## Get a mock object by name.
## 
## Parameters:
##   mock_name (String): Name of the mock object
## 
## Returns:
##   Object: The mock object, or null if not found
## 
## @since: 1.0.0
func get_mock(mock_name: String) -> Object:
	"""Get a mock object by name"""
	return _mock_objects.get(mock_name, null)

# Test utility methods

## set_test_data
## 
## Set test data for use in tests.
## 
## Parameters:
##   key (String): Data key
##   value: Data value
## 
## @since: 1.0.0
func set_test_data(key: String, value) -> void:
	"""Set test data for use in tests"""
	_test_data[key] = value

## get_test_data
## 
## Get test data by key.
## 
## Parameters:
##   key (String): Data key
##   default: Default value if key not found
## 
## Returns:
##   The data value, or default if not found
## 
## @since: 1.0.0
func get_test_data(key: String, default = null):
	"""Get test data by key"""
	return _test_data.get(key, default)

## clear_test_data
## 
## Clear all test data.
## 
## @since: 1.0.0
func clear_test_data() -> void:
	"""Clear all test data"""
	_test_data.clear()

## measure_performance
## 
## Measure the performance of a function.
## 
## Parameters:
##   func_name (String): Name of the function to measure
##   func_ref (Callable): Reference to the function
##   iterations (int): Number of iterations to run
## 
## Returns:
##   Dictionary: Performance metrics
## 
## @since: 1.0.0
func measure_performance(func_name: String, func_ref: Callable, iterations: int = 1000) -> Dictionary:
	"""Measure the performance of a function"""
	var start_time = Time.get_ticks_msec()
	
	for i in range(iterations):
		func_ref.call()
	
	var end_time = Time.get_ticks_msec()
	var total_time = end_time - start_time
	var avg_time = float(total_time) / float(iterations)
	
	return {
		"function": func_name,
		"iterations": iterations,
		"total_time_ms": total_time,
		"average_time_ms": avg_time,
		"iterations_per_second": float(iterations) / (float(total_time) / 1000.0)
	}

# Private helper methods

func _record_test_failure(message: String) -> void:
	"""Record a test failure"""
	var failure = {
		"test": _current_test_name,
		"message": message,
		"timestamp": Time.get_ticks_msec()
	}
	_test_results.append(failure)
	print("TestSuite: ❌ %s FAILED: %s" % [_current_test_name, message])

## _exit_tree
## 
## Cleanup when the test suite is removed.
func _exit_tree() -> void:
	"""Cleanup when the test suite is removed"""
	if auto_cleanup:
		_cleanup() 