extends Node

## TestProductionSystem
## 
## Comprehensive test suite for the production system.
## 
## This test script verifies all aspects of the production system including:
## - State management reliability
## - Queue management
## - Production automation
## - Upgrade system
## - Error handling
## - Save/load functionality
## 
## @since: 1.0.0
## @category: Testing

# Test state
var _tests_passed: int = 0
var _tests_failed: int = 0
var _current_test: String = ""
var _test_start_time: float = 0.0

# System references
@onready var production_system: Node = $ProductionSystem
@onready var production_ui: Node = $ProductionUI

# Test data
var _initial_queue_size: int = 0
var _initial_total_produced: int = 0
var _initial_money: float = 100.0

func _ready() -> void:
	"""Initialize and run all tests"""
	print("TestProductionSystem: Starting production system tests...")
	
	# Wait a frame for systems to initialize
	await get_tree().process_frame
	
	# Run all tests
	_run_all_tests()
	
	# Print results
	_print_test_results()

func _run_all_tests() -> void:
	"""Run all production system tests"""
	print("TestProductionSystem: Running production system tests...")
	
	# Basic functionality tests
	_test_production_system_initialization()
	_test_queue_management()
	_test_production_automation()
	_test_production_statistics()
	_test_upgrade_system()
	_test_state_persistence()
	_test_error_handling()
	_test_edge_cases()

func _test_production_system_initialization() -> void:
	"""Test production system initialization"""
	_current_test = "Production System Initialization"
	_test_start_time = Time.get_ticks_msec()
	
	# Test 1: System exists and is initialized
	if not production_system:
		_test_failed("Production system not found")
		return
	
	if not production_system.is_initialized:
		_test_failed("Production system not initialized")
		return
	
	# Test 2: Initial state is correct
	var initial_stats = production_system.get_production_statistics()
	if initial_stats["total_produced"] != 0:
		_test_failed("Initial total produced should be 0, got: " + str(initial_stats["total_produced"]))
		return
	
	var initial_queue = production_system.get_queue_status()
	if initial_queue["current_size"] != 0:
		_test_failed("Initial queue size should be 0, got: " + str(initial_queue["current_size"]))
		return
	
	_test_passed()

func _test_queue_management() -> void:
	"""Test queue management functionality"""
	_current_test = "Queue Management"
	_test_start_time = Time.get_ticks_msec()
	
	# Test 1: Add to queue
	var added = production_system.add_to_queue()
	if not added:
		_test_failed("Failed to add first hot dog to queue")
		return
	
	var queue_status = production_system.get_queue_status()
	if queue_status["current_size"] != 1:
		_test_failed("Queue size should be 1 after adding, got: " + str(queue_status["current_size"]))
		return
	
	# Test 2: Add multiple hot dogs
	for i in range(5):
		production_system.add_to_queue()
	
	queue_status = production_system.get_queue_status()
	if queue_status["current_size"] != 6:
		_test_failed("Queue size should be 6 after adding 6 hot dogs, got: " + str(queue_status["current_size"]))
		return
	
	# Test 3: Queue capacity limit
	var max_capacity = queue_status["max_size"]
	for i in range(max_capacity + 5):  # Try to add more than capacity
		production_system.add_to_queue()
	
	queue_status = production_system.get_queue_status()
	if queue_status["current_size"] > max_capacity:
		_test_failed("Queue should not exceed capacity, got: " + str(queue_status["current_size"]) + " > " + str(max_capacity))
		return
	
	_test_passed()

func _test_production_automation() -> void:
	"""Test production automation"""
	_current_test = "Production Automation"
	_test_start_time = Time.get_ticks_msec()
	
	# Clear queue first
	_clear_production_queue()
	
	# Test 1: Production starts automatically when first hot dog added
	var initial_stats = production_system.get_production_statistics()
	var initial_produced = initial_stats["total_produced"]
	
	production_system.add_to_queue()
	
	# Wait for production to complete
	await get_tree().create_timer(1.5).timeout
	
	var final_stats = production_system.get_production_statistics()
	var final_produced = final_stats["total_produced"]
	
	if final_produced <= initial_produced:
		_test_failed("Production should have increased, got: " + str(final_produced) + " <= " + str(initial_produced))
		return
	
	# Test 2: Production stops when queue is empty
	var queue_status = production_system.get_queue_status()
	if queue_status["current_size"] != 0:
		_test_failed("Queue should be empty after production, got: " + str(queue_status["current_size"]))
		return
	
	if final_stats["is_producing"]:
		_test_failed("Production should have stopped when queue empty")
		return
	
	_test_passed()

func _test_production_statistics() -> void:
	"""Test production statistics tracking"""
	_current_test = "Production Statistics"
	_test_start_time = Time.get_ticks_msec()
	
	# Clear queue and add some hot dogs
	_clear_production_queue()
	
	var initial_stats = production_system.get_production_statistics()
	var initial_total = initial_stats["total_produced"]
	var initial_lifetime = initial_stats["lifetime_produced"]
	var initial_session = initial_stats["session_produced"]
	
	# Add and produce some hot dogs
	for i in range(3):
		production_system.add_to_queue()
	
	await get_tree().create_timer(3.5).timeout
	
	var final_stats = production_system.get_production_statistics()
	
	# Test 1: Total produced increased
	if final_stats["total_produced"] <= initial_total:
		_test_failed("Total produced should have increased")
		return
	
	# Test 2: Lifetime produced increased
	if final_stats["lifetime_produced"] <= initial_lifetime:
		_test_failed("Lifetime produced should have increased")
		return
	
	# Test 3: Session produced increased
	if final_stats["session_produced"] <= initial_session:
		_test_failed("Session produced should have increased")
		return
	
	# Test 4: Production rate is positive
	if final_stats["current_rate"] <= 0:
		_test_failed("Production rate should be positive, got: " + str(final_stats["current_rate"]))
		return
	
	_test_passed()

func _test_upgrade_system() -> void:
	"""Test upgrade system functionality"""
	_current_test = "Upgrade System"
	_test_start_time = Time.get_ticks_msec()
	
	var initial_stats = production_system.get_production_statistics()
	var initial_rate = initial_stats["current_rate"]
	var initial_rate_level = initial_stats["production_rate_level"]
	var initial_capacity_level = initial_stats["capacity_level"]
	var initial_efficiency_level = initial_stats["efficiency_level"]
	
	# Test 1: Production rate upgrade
	var upgraded = production_system.upgrade_production_rate()
	if not upgraded:
		_test_failed("Production rate upgrade failed")
		return
	
	var after_upgrade_stats = production_system.get_production_statistics()
	if after_upgrade_stats["production_rate_level"] <= initial_rate_level:
		_test_failed("Production rate level should have increased")
		return
	
	if after_upgrade_stats["current_rate"] <= initial_rate:
		_test_failed("Production rate should have increased after upgrade")
		return
	
	# Test 2: Capacity upgrade
	upgraded = production_system.upgrade_capacity()
	if not upgraded:
		_test_failed("Capacity upgrade failed")
		return
	
	after_upgrade_stats = production_system.get_production_statistics()
	if after_upgrade_stats["capacity_level"] <= initial_capacity_level:
		_test_failed("Capacity level should have increased")
		return
	
	var queue_status = production_system.get_queue_status()
	if queue_status["max_size"] <= 10:  # Initial capacity
		_test_failed("Max capacity should have increased after upgrade")
		return
	
	# Test 3: Efficiency upgrade
	upgraded = production_system.upgrade_efficiency()
	if not upgraded:
		_test_failed("Efficiency upgrade failed")
		return
	
	after_upgrade_stats = production_system.get_production_statistics()
	if after_upgrade_stats["efficiency_level"] <= initial_efficiency_level:
		_test_failed("Efficiency level should have increased")
		return
	
	_test_passed()

func _test_state_persistence() -> void:
	"""Test state persistence and recovery"""
	_current_test = "State Persistence"
	_test_start_time = Time.get_ticks_msec()
	
	# Set up some state
	_clear_production_queue()
	production_system.add_to_queue()
	production_system.add_to_queue()
	production_system.upgrade_production_rate()
	
	# Get current state
	var save_data = production_system.get_save_data()
	if save_data.is_empty():
		_test_failed("Save data should not be empty")
		return
	
	# Verify save data structure
	if not save_data.has("production_data"):
		_test_failed("Save data should contain production_data")
		return
	
	if not save_data.has("is_producing"):
		_test_failed("Save data should contain is_producing")
		return
	
	# Test loading (simulate by creating new system)
	var new_production_data = save_data["production_data"]
	if not new_production_data:
		_test_failed("Production data should not be null")
		return
	
	# Verify data integrity
	var stats = new_production_data.get_production_statistics()
	if stats["production_rate_level"] < 2:  # Should be upgraded
		_test_failed("Upgrade level should persist in save data")
		return
	
	_test_passed()

func _test_error_handling() -> void:
	"""Test error handling and edge cases"""
	_current_test = "Error Handling"
	_test_start_time = Time.get_ticks_msec()
	
	# Test 1: Adding to queue when not initialized (should handle gracefully)
	# This is hard to test since we can't easily uninitialize the system
	
	# Test 2: Production with invalid data
	var stats = production_system.get_production_statistics()
	if stats.is_empty():
		_test_failed("get_production_statistics should not return empty dict when system is initialized")
		return
	
	# Test 3: Queue status with invalid data
	var queue_status = production_system.get_queue_status()
	if queue_status.is_empty():
		_test_failed("get_queue_status should not return empty dict when system is initialized")
		return
	
	# Test 4: Upgrade when already at max (if applicable)
	# This would require implementing max levels, which isn't done yet
	
	_test_passed()

func _test_edge_cases() -> void:
	"""Test edge cases and boundary conditions"""
	_current_test = "Edge Cases"
	_test_start_time = Time.get_ticks_msec()
	
	# Test 1: Rapid queue additions
	_clear_production_queue()
	
	for i in range(20):  # Add many hot dogs rapidly
		production_system.add_to_queue()
	
	var queue_status = production_system.get_queue_status()
	var max_capacity = queue_status["max_size"]
	
	if queue_status["current_size"] > max_capacity:
		_test_failed("Queue should respect capacity limit under rapid additions")
		return
	
	# Test 2: Production during rapid additions
	await get_tree().create_timer(2.0).timeout
	
	var stats = production_system.get_production_statistics()
	if stats["total_produced"] <= 0:
		_test_failed("Production should occur during rapid additions")
		return
	
	# Test 3: Multiple upgrades in sequence
	var initial_rate = stats["current_rate"]
	
	for i in range(3):
		production_system.upgrade_production_rate()
	
	var final_stats = production_system.get_production_statistics()
	if final_stats["current_rate"] <= initial_rate:
		_test_failed("Multiple upgrades should increase production rate")
		return
	
	_test_passed()

func _clear_production_queue() -> void:
	"""Helper function to clear the production queue"""
	# Wait for any ongoing production to complete
	await get_tree().create_timer(0.5).timeout
	
	# Add hot dogs and let them be produced to clear the queue
	for i in range(production_system.get_queue_status()["max_size"] + 5):
		production_system.add_to_queue()
	
	# Wait for production to complete
	await get_tree().create_timer(production_system.get_queue_status()["max_size"] + 2.0).timeout

func _test_passed() -> void:
	"""Mark current test as passed"""
	_tests_passed += 1
	var duration = (Time.get_ticks_msec() - _test_start_time) / 1000.0
	print("TestProductionSystem: ✅ " + _current_test + " PASSED (" + str(duration) + "s)")

func _test_failed(reason: String) -> void:
	"""Mark current test as failed"""
	_tests_failed += 1
	var duration = (Time.get_ticks_msec() - _test_start_time) / 1000.0
	print("TestProductionSystem: ❌ " + _current_test + " FAILED (" + str(duration) + "s) - " + reason)

func _print_test_results() -> void:
	"""Print final test results"""
	var total_tests = _tests_passed + _tests_failed
	print("\n" + "=".repeat(60))
	print("TestProductionSystem: TEST RESULTS")
	print("=".repeat(60))
	print("Total Tests: " + str(total_tests))
	print("Passed: " + str(_tests_passed))
	print("Failed: " + str(_tests_failed))
	print("Success Rate: " + str(float(_tests_passed) / float(total_tests) * 100.0) + "%")
	print("=".repeat(60))
	
	if _tests_failed == 0:
		print("🎉 All production system tests passed!")
	else:
		print("⚠️  Some tests failed. Check the output above for details.")
	
	# Clean up after tests
	queue_free() 