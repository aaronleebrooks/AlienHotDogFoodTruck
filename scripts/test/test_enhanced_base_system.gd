extends Node

## TestEnhancedBaseSystem
## 
## Test script for the enhanced BaseSystem functionality.
## 
## This script tests all the new features of the enhanced BaseSystem including:
## - Lifecycle management (initialize, pause, resume, shutdown)
## - Dependency tracking and validation
## - Performance monitoring and metrics
## - State management and transitions
## - Error handling and recovery
## 
## @since: 1.0.0
## @category: Test

# Test results tracking
var test_results: Dictionary = {}
var current_test: String = ""

# Test system instances
var test_system: Node
var dependency_system: Node

## _ready
## 
## Initialize and run all tests when the node is ready.
## 
## @since: 1.0.0
func _ready() -> void:
	"""Initialize and run all tests when the node is ready"""
	print("TestEnhancedBaseSystem: Starting enhanced BaseSystem tests...")
	
	# Run all tests
	await _test_lifecycle_management()
	await _test_dependency_management()
	await _test_performance_monitoring()
	await _test_state_management()
	await _test_error_handling()
	
	# Print results
	_print_test_results()

## _test_lifecycle_management
## 
## Test the lifecycle management functionality.
## 
## @since: 1.0.0
func _test_lifecycle_management() -> void:
	"""Test the lifecycle management functionality"""
	print("TestEnhancedBaseSystem: Testing lifecycle management...")
	
	# Create test system
	test_system = _create_test_system("TestSystem")
	
	# Test initialization
	current_test = "System Initialization"
	var init_success = test_system.initialize_system()
	_test_case("System should initialize successfully", init_success)
	_test_case("System should be in READY state", test_system.is_system_ready())
	
	# Test pause
	current_test = "System Pause"
	var pause_success = test_system.pause_system()
	_test_case("System should pause successfully", pause_success)
	_test_case("System should be in PAUSED state", test_system.is_system_paused())
	
	# Test resume
	current_test = "System Resume"
	var resume_success = test_system.resume_system()
	_test_case("System should resume successfully", resume_success)
	_test_case("System should be back in READY state", test_system.is_system_ready())
	
	# Test shutdown
	current_test = "System Shutdown"
	var shutdown_success = test_system.shutdown_system()
	_test_case("System should shutdown successfully", shutdown_success)
	
	# Cleanup
	test_system.queue_free()

## _test_dependency_management
## 
## Test the dependency management functionality.
## 
## @since: 1.0.0
func _test_dependency_management() -> void:
	"""Test the dependency management functionality"""
	print("TestEnhancedBaseSystem: Testing dependency management...")
	
	# Create dependency system first
	dependency_system = _create_test_system("DependencySystem")
	dependency_system.auto_initialize = false
	
	# Create dependent system
	test_system = _create_test_system("DependentSystem")
	test_system.auto_initialize = false
	test_system.add_dependency("DependencySystem")
	
	# Add to scene tree for dependency resolution
	get_tree().current_scene.add_child(dependency_system)
	get_tree().current_scene.add_child(test_system)
	
	# Test dependency tracking
	current_test = "Dependency Tracking"
	_test_case("System should have dependency listed", test_system.dependencies.has("DependencySystem"))
	_test_case("Dependency should not be ready initially", not test_system._are_all_dependencies_ready())
	
	# Initialize dependency
	dependency_system.initialize_system()
	await get_tree().process_frame
	
	# Test dependency notification
	current_test = "Dependency Notification"
	test_system.notify_dependency_ready("DependencySystem")
	await get_tree().process_frame
	_test_case("Dependency should be marked as ready", test_system.dependency_status.get("DependencySystem", false))
	
	# Test system initialization with dependency
	current_test = "Dependent System Initialization"
	var init_success = test_system.initialize_system()
	_test_case("Dependent system should initialize with ready dependency", init_success)
	
	# Cleanup
	dependency_system.queue_free()
	test_system.queue_free()

## _test_performance_monitoring
## 
## Test the performance monitoring functionality.
## 
## @since: 1.0.0
func _test_performance_monitoring() -> void:
	"""Test the performance monitoring functionality"""
	print("TestEnhancedBaseSystem: Testing performance monitoring...")
	
	# Create test system
	test_system = _create_test_system("PerformanceTestSystem")
	test_system.enable_performance_monitoring = true
	
	# Test performance tracking
	current_test = "Operation Tracking"
	var result = test_system.track_operation("test_operation", func(): 
		# Simulate some work
		var sum = 0
		for i in range(1000):
			sum += i
		return sum
	)
	_test_case("Operation should return correct result", result == 499500)
	_test_case("Performance metrics should be recorded", test_system.performance_metrics.operations_count > 0)
	
	# Test performance info
	current_test = "Performance Information"
	var info = test_system.get_system_info()
	_test_case("Performance info should include metrics", info.has("performance_metrics"))
	_test_case("Memory usage should be tracked", info.has("memory_usage"))
	
	# Cleanup
	test_system.queue_free()

## _test_state_management
## 
## Test the state management functionality.
## 
## @since: 1.0.0
func _test_state_management() -> void:
	"""Test the state management functionality"""
	print("TestEnhancedBaseSystem: Testing state management...")
	
	# Create test system
	test_system = _create_test_system("StateTestSystem")
	
	# Test initial state
	current_test = "Initial State"
	_test_case("System should start in UNINITIALIZED state", test_system.system_state == test_system.SystemState.UNINITIALIZED)
	
	# Test state transitions
	current_test = "State Transitions"
	test_system.initialize_system()
	_test_case("System should transition to READY state", test_system.system_state == test_system.SystemState.READY)
	
	test_system.pause_system()
	_test_case("System should transition to PAUSED state", test_system.system_state == test_system.SystemState.PAUSED)
	
	test_system.resume_system()
	_test_case("System should transition back to READY state", test_system.system_state == test_system.SystemState.READY)
	
	# Test state change tracking
	current_test = "State Change Tracking"
	_test_case("Previous state should be tracked", test_system.previous_state == test_system.SystemState.PAUSED)
	_test_case("State change time should be recorded", test_system.state_change_time > 0)
	
	# Cleanup
	test_system.queue_free()

## _test_error_handling
## 
## Test the error handling functionality.
## 
## @since: 1.0.0
func _test_error_handling() -> void:
	"""Test the error handling functionality"""
	print("TestEnhancedBaseSystem: Testing error handling...")
	
	# Create test system
	test_system = _create_test_system("ErrorTestSystem")
	
	# Test error logging
	current_test = "Error Logging"
	var initial_error_count = test_system.error_count
	test_system.log_error("TEST_ERROR_001", "Test error message", "Test error details")
	_test_case("Error count should increase", test_system.error_count > initial_error_count)
	_test_case("Last error should be recorded", test_system.last_error.has("code"))
	_test_case("Error should be in history", test_system.error_history.size() > 0)
	
	# Test error state
	current_test = "Error State"
	_test_case("System should transition to ERROR state", test_system.is_system_error())
	
	# Test error info
	current_test = "Error Information"
	var info = test_system.get_system_info()
	_test_case("Error info should include error count", info.has("error_count"))
	_test_case("Error info should include last error", info.has("last_error"))
	_test_case("Error info should include error history", info.has("error_history"))
	
	# Cleanup
	test_system.queue_free()

## _create_test_system
## 
## Create a test system instance for testing.
## 
## Parameters:
##   system_name (String): Name for the test system
## 
## Returns:
##   Node: The created test system node
## 
## @since: 1.0.0
func _create_test_system(system_name: String) -> Node:
	"""Create a test system instance for testing"""
	var system = Node.new()
	system.set_script(load("res://scripts/base/base_system.gd"))
	system.system_name = system_name
	return system

## _test_case
## 
## Run a single test case and record the result.
## 
## Parameters:
##   description (String): Description of the test case
##   condition (bool): The condition to test
## 
## @since: 1.0.0
func _test_case(description: String, condition: bool) -> void:
	"""Run a single test case and record the result"""
	if not test_results.has(current_test):
		test_results[current_test] = []
	
	var result = {
		"description": description,
		"passed": condition,
		"timestamp": Time.get_ticks_msec()
	}
	
	test_results[current_test].append(result)
	
	var status = "PASS" if condition else "FAIL"
	print("TestEnhancedBaseSystem: [%s] %s - %s" % [status, current_test, description])

## _print_test_results
## 
## Print a summary of all test results.
## 
## @since: 1.0.0
func _print_test_results() -> void:
	"""Print a summary of all test results"""
	print("\n" + "=".repeat(60))
	print("TestEnhancedBaseSystem: TEST RESULTS SUMMARY")
	print("=".repeat(60))
	
	var total_tests = 0
	var passed_tests = 0
	
	for test_category in test_results:
		var category_tests = test_results[test_category]
		var category_passed = 0
		
		print("\n%s:" % test_category)
		for test in category_tests:
			total_tests += 1
			if test.passed:
				category_passed += 1
				passed_tests += 1
			
			var status = "✓" if test.passed else "✗"
			print("  %s %s" % [status, test.description])
		
		print("  %d/%d tests passed" % [category_passed, category_tests.size()])
	
	print("\n" + "=".repeat(60))
	print("OVERALL: %d/%d tests passed (%.1f%%)" % [passed_tests, total_tests, (passed_tests * 100.0 / total_tests)])
	print("=".repeat(60))
	
	if passed_tests == total_tests:
		print("🎉 All tests passed! Enhanced BaseSystem is working correctly.")
	else:
		print("❌ Some tests failed. Please review the implementation.")

## _exit_tree
## 
## Clean up test resources when the node is removed.
## 
## @since: 1.0.0
func _exit_tree() -> void:
	"""Clean up test resources when the node is removed"""
	if test_system and is_instance_valid(test_system):
		test_system.queue_free()
	
	if dependency_system and is_instance_valid(dependency_system):
		dependency_system.queue_free() 