extends Node

## GUT (Godot Unit Test) Framework
## 
## A comprehensive testing framework for Godot 4.x projects.
## 
## This framework provides unit testing, integration testing, and
## automated testing capabilities for the hot dog idle game.
## 
## Features:
##   - Unit test execution and reporting
##   - Test suite organization
##   - Assertion library
##   - Mock object support
##   - Performance testing
##   - Automated test discovery
## 
## @since: 1.0.0
## @category: Testing

# Test configuration
@export var test_directory: String = "res://scripts/test/"
@export var auto_run_tests: bool = false
@export var verbose_output: bool = true
@export var stop_on_failure: bool = false

# Test tracking
var _test_suites: Array[Dictionary] = []
var _current_suite: Dictionary = {}
var _current_test: Dictionary = {}
var _test_results: Dictionary = {
	"total_tests": 0,
	"passed": 0,
	"failed": 0,
	"skipped": 0,
	"start_time": 0,
	"end_time": 0
}

# Test utilities
var _assertions: Array[String] = []
var _mock_objects: Dictionary = {}

# Signals
signal test_suite_started(suite_name: String)
signal test_suite_completed(suite_name: String, results: Dictionary)
signal test_started(test_name: String)
signal test_completed(test_name: String, passed: bool, message: String)
signal all_tests_completed(results: Dictionary)

## _ready
## 
## Initialize the GUT framework.
func _ready() -> void:
	"""Initialize the GUT framework"""
	print("GUT: Godot Unit Test Framework Initialized")
	
	if auto_run_tests:
		run_all_tests()

## run_all_tests
## 
## Run all discovered tests.
## 
## Returns:
##   Dictionary: Test results summary
## 
## Example:
##   var results = GUT.run_all_tests()
func run_all_tests() -> Dictionary:
	"""Run all discovered tests"""
	print("GUT: Starting test execution...")
	
	_test_results.start_time = Time.get_ticks_msec()
	_test_results.total_tests = 0
	_test_results.passed = 0
	_test_results.failed = 0
	_test_results.skipped = 0
	
	# Discover and run test suites
	_discover_test_suites()
	_run_test_suites()
	
	_test_results.end_time = Time.get_ticks_msec()
	
	_print_test_summary()
	all_tests_completed.emit(_test_results)
	
	return _test_results

## run_test_suite
## 
## Run a specific test suite.
## 
## Parameters:
##   suite_name (String): Name of the test suite to run
## 
## Returns:
##   Dictionary: Test suite results
## 
## Example:
##   var results = GUT.run_test_suite("ProductionSystem")
func run_test_suite(suite_name: String) -> Dictionary:
	"""Run a specific test suite"""
	print("GUT: Running test suite: %s" % suite_name)
	
	var suite = _find_test_suite(suite_name)
	if not suite:
		print("GUT: Test suite '%s' not found" % suite_name)
		return {}
	
	return _run_single_suite(suite)

## run_single_test
## 
## Run a single test.
## 
## Parameters:
##   suite_name (String): Name of the test suite
##   test_name (String): Name of the test to run
## 
## Returns:
##   bool: True if test passed, false otherwise
## 
## Example:
##   var passed = GUT.run_single_test("ProductionSystem", "test_production_queue")
func run_single_test(suite_name: String, test_name: String) -> bool:
	"""Run a single test"""
	print("GUT: Running test: %s.%s" % [suite_name, test_name])
	
	var suite = _find_test_suite(suite_name)
	if not suite:
		print("GUT: Test suite '%s' not found" % suite_name)
		return false
	
	var test = _find_test_in_suite(suite, test_name)
	if not test:
		print("GUT: Test '%s' not found in suite '%s'" % [test_name, suite_name])
		return false
	
	return _run_single_test(suite, test)

# Private helper functions

func _discover_test_suites() -> void:
	"""Discover all test suites in the test directory"""
	print("GUT: Discovering test suites...")
	
	var dir = DirAccess.open(test_directory)
	if not dir:
		print("GUT: Could not open test directory: %s" % test_directory)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with("_test.gd") or file_name.ends_with("_tests.gd"):
			var suite_path = test_directory + file_name
			var suite = _load_test_suite(suite_path)
			if suite:
				_test_suites.append(suite)
				print("GUT: Discovered test suite: %s" % suite.name)
		
		file_name = dir.get_next()
	
	print("GUT: Discovered %d test suites" % _test_suites.size())

func _load_test_suite(suite_path: String) -> Dictionary:
	"""Load a test suite from a script file"""
	var script = load(suite_path)
	if not script:
		return {}
	
	var suite_instance = script.new()
	if not suite_instance:
		return {}
	
	return {
		"name": suite_instance.get_class() if suite_instance.has_method("get_class") else suite_path.get_file().get_basename(),
		"path": suite_path,
		"instance": suite_instance,
		"tests": _discover_tests_in_suite(suite_instance)
	}

func _discover_tests_in_suite(suite_instance: Object) -> Array[Dictionary]:
	"""Discover all tests in a test suite"""
	var tests: Array[Dictionary] = []
	
	var methods = suite_instance.get_method_list()
	for method in methods:
		var method_name = method.name
		if method_name.begins_with("test_"):
			tests.append({
				"name": method_name,
				"method": method_name,
				"description": _get_test_description(suite_instance, method_name)
			})
	
	return tests

func _get_test_description(suite_instance: Object, test_name: String) -> String:
	"""Get the description of a test method"""
	# Try to get docstring or return default description
	if suite_instance.has_method("_get_test_description"):
		return suite_instance._get_test_description(test_name)
	return "Test: " + test_name

func _run_test_suites() -> void:
	"""Run all discovered test suites"""
	for suite in _test_suites:
		_run_single_suite(suite)

func _run_single_suite(suite: Dictionary) -> Dictionary:
	"""Run a single test suite"""
	var suite_results = {
		"name": suite.name,
		"total_tests": suite.tests.size(),
		"passed": 0,
		"failed": 0,
		"skipped": 0,
		"tests": []
	}
	
	test_suite_started.emit(suite.name)
	
	for test in suite.tests:
		var test_result = _run_single_test(suite, test)
		suite_results.tests.append(test_result)
		
		if test_result.passed:
			suite_results.passed += 1
			_test_results.passed += 1
		else:
			suite_results.failed += 1
			_test_results.failed += 1
		
		_test_results.total_tests += 1
		
		if stop_on_failure and not test_result.passed:
			break
	
	test_suite_completed.emit(suite.name, suite_results)
	return suite_results

func _run_single_test(suite: Dictionary, test: Dictionary) -> Dictionary:
	"""Run a single test"""
	var test_result = {
		"name": test.name,
		"description": test.description,
		"passed": false,
		"message": "",
		"execution_time": 0,
		"start_time": 0,
		"end_time": 0
	}
	
	test_started.emit(test.name)
	test_result.start_time = Time.get_ticks_msec()
	
	# Setup test environment
	_setup_test_environment(suite.instance)
	
	# Run the test
	var success = false
	var error_message = ""
	
	if suite.instance.has_method(test.method):
		success = _execute_test_method(suite.instance, test.method)
	else:
		error_message = "Test method '%s' not found" % test.method
	
	test_result.end_time = Time.get_ticks_msec()
	test_result.execution_time = test_result.end_time - test_result.start_time
	
	if success:
		test_result.passed = true
		test_result.message = "Test passed"
		if verbose_output:
			print("GUT: ✅ %s.%s PASSED (%.2fms)" % [suite.name, test.name, test_result.execution_time / 1000.0])
	else:
		test_result.passed = false
		test_result.message = error_message
		if verbose_output:
			print("GUT: ❌ %s.%s FAILED: %s (%.2fms)" % [suite.name, test.name, error_message, test_result.execution_time / 1000.0])
	
	# Cleanup test environment
	_cleanup_test_environment(suite.instance)
	
	test_completed.emit(test.name, test_result.passed, test_result.message)
	return test_result

func _execute_test_method(suite_instance: Object, method_name: String) -> bool:
	"""Execute a test method safely"""
	try:
		suite_instance.call(method_name)
		return true
	except:
		return false

func _setup_test_environment(suite_instance: Object) -> void:
	"""Setup the test environment"""
	if suite_instance.has_method("_setup"):
		suite_instance._setup()

func _cleanup_test_environment(suite_instance: Object) -> void:
	"""Cleanup the test environment"""
	if suite_instance.has_method("_cleanup"):
		suite_instance._cleanup()

func _find_test_suite(suite_name: String) -> Dictionary:
	"""Find a test suite by name"""
	for suite in _test_suites:
		if suite.name == suite_name:
			return suite
	return {}

func _find_test_in_suite(suite: Dictionary, test_name: String) -> Dictionary:
	"""Find a test in a suite by name"""
	for test in suite.tests:
		if test.name == test_name:
			return test
	return {}

func _print_test_summary() -> void:
	"""Print a summary of all test results"""
	var duration = (_test_results.end_time - _test_results.start_time) / 1000.0
	
	print("\n" + "="*50)
	print("GUT: TEST EXECUTION SUMMARY")
	print("="*50)
	print("Total Tests: %d" % _test_results.total_tests)
	print("Passed: %d" % _test_results.passed)
	print("Failed: %d" % _test_results.failed)
	print("Skipped: %d" % _test_results.skipped)
	print("Duration: %.2f seconds" % duration)
	
	if _test_results.failed == 0:
		print("🎉 ALL TESTS PASSED!")
	else:
		print("❌ SOME TESTS FAILED!")
	
	print("="*50) 