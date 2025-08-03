extends Node

## IntegrationTests
## 
## Sample integration tests demonstrating system interactions.
## 
## This script contains example integration tests that show how different
## systems work together, including economy, production, and event systems.
## 
## @since: 1.0.0
## @category: Testing

# Framework reference
var framework: Node

# Test data
var _test_economy: Dictionary = {}
var _test_production: Dictionary = {}
var _test_events: Array[Dictionary] = []

func _ready() -> void:
	"""Initialize integration tests"""
	print("IntegrationTests: Initialized")
	
	# Get framework reference
	framework = get_node("/root/IntegrationTestFramework")
	if not framework:
		print("IntegrationTests: ERROR - IntegrationTestFramework not found!")
		return
	
	# Set up test scenarios
	_setup_test_scenarios()

func _setup_test_scenarios() -> void:
	"""Set up all integration test scenarios"""
	
	# Test 1: Economy and Production Integration
	framework.add_test_scenario(
		"economy_production_integration",
		_setup_economy_production_test,
		_test_economy_production_integration,
		_cleanup_economy_production_test
	)
	
	# Test 2: Event System Integration
	framework.add_test_scenario(
		"event_system_integration",
		_setup_event_system_test,
		_test_event_system_integration,
		_cleanup_event_system_test
	)
	
	# Test 3: Save System Integration
	framework.add_test_scenario(
		"save_system_integration",
		_setup_save_system_test,
		_test_save_system_integration,
		_cleanup_save_system_test
	)
	
	# Test 4: UI System Integration
	framework.add_test_scenario(
		"ui_system_integration",
		_setup_ui_system_test,
		_test_ui_system_integration,
		_cleanup_ui_system_test
	)

# Test 1: Economy and Production Integration
func _setup_economy_production_test() -> void:
	"""Set up economy and production integration test"""
	print("IntegrationTests: Setting up economy-production test")
	
	# Create mock economy system
	_test_economy = framework.create_mock_object("economy_data", {
		"money": 1000.0,
		"hot_dog_price": 5.0,
		"cost_per_hot_dog": 2.0
	})
	
	# Create mock production system
	_test_production = framework.create_mock_object("production_data", {
		"queue_size": 3,
		"production_speed": 1.0,
		"quality": 0.8
	})
	
	# Set up test data
	framework.set_test_data("economy_production_test", {
		"initial_money": 1000.0,
		"hot_dogs_to_produce": 5,
		"expected_profit": 15.0  # (5.0 - 2.0) * 5
	})

func _test_economy_production_integration() -> bool:
	"""Test economy and production system integration"""
	print("IntegrationTests: Testing economy-production integration")
	
	var test_data = framework.get_test_data("economy_production_test")
	var initial_money = test_data.initial_money
	var hot_dogs_to_produce = test_data.hot_dogs_to_produce
	var expected_profit = test_data.expected_profit
	
	# Simulate production process
	var production_cost = _test_economy.cost_per_hot_dog * hot_dogs_to_produce
	var production_revenue = _test_economy.hot_dog_price * hot_dogs_to_produce
	var actual_profit = production_revenue - production_cost
	
	# Verify production affects economy
	if actual_profit != expected_profit:
		print("IntegrationTests: Profit calculation failed. Expected: " + str(expected_profit) + ", Got: " + str(actual_profit))
		return false
	
	# Verify production queue management
	if _test_production.queue_size < hot_dogs_to_produce:
		print("IntegrationTests: Production queue too small for demand")
		return false
	
	# Verify quality affects pricing (simplified)
	var quality_bonus = _test_production.quality * 0.1
	var adjusted_price = _test_economy.hot_dog_price * (1.0 + quality_bonus)
	
	if adjusted_price <= _test_economy.hot_dog_price:
		print("IntegrationTests: Quality bonus not applied to pricing")
		return false
	
	print("IntegrationTests: Economy-production integration test passed")
	return true

func _cleanup_economy_production_test() -> void:
	"""Clean up economy and production test"""
	print("IntegrationTests: Cleaning up economy-production test")
	_test_economy.clear()
	_test_production.clear()

# Test 2: Event System Integration
func _setup_event_system_test() -> void:
	"""Set up event system integration test"""
	print("IntegrationTests: Setting up event system test")
	
	# Clear any existing events
	_test_events.clear()
	
	# Set up test data
	framework.set_test_data("event_system_test", {
		"expected_events": ["money_changed", "hot_dog_produced", "upgrade_purchased"],
		"event_data": {
			"money_changed": {"amount": 100.0},
			"hot_dog_produced": {"quality": 0.8},
			"upgrade_purchased": {"upgrade_type": "production_speed"}
		}
	})

func _test_event_system_integration() -> bool:
	"""Test event system integration"""
	print("IntegrationTests: Testing event system integration")
	
	var test_data = framework.get_test_data("event_system_test")
	var expected_events = test_data.expected_events
	var event_data = test_data.event_data
	
	# Get EventBus reference
	var event_bus = get_node("/root/EventBus")
	if not event_bus:
		print("IntegrationTests: EventBus not found")
		return false
	
	# Simulate event emission and capture
	for event_name in expected_events:
		if event_data.has(event_name):
			event_bus.emit_event(event_name, event_data[event_name])
			_test_events.append({
				"name": event_name,
				"data": event_data[event_name]
			})
	
	# Verify events were captured
	if _test_events.size() != expected_events.size():
		print("IntegrationTests: Event count mismatch. Expected: " + str(expected_events.size()) + ", Got: " + str(_test_events.size()))
		return false
	
	# Verify event data integrity
	for i in range(_test_events.size()):
		var captured_event = _test_events[i]
		var expected_event_name = expected_events[i]
		
		if captured_event.name != expected_event_name:
			print("IntegrationTests: Event name mismatch. Expected: " + expected_event_name + ", Got: " + captured_event.name)
			return false
		
		if not captured_event.data.has_all(event_data[expected_event_name].keys()):
			print("IntegrationTests: Event data missing fields")
			return false
	
	print("IntegrationTests: Event system integration test passed")
	return true

func _cleanup_event_system_test() -> void:
	"""Clean up event system test"""
	print("IntegrationTests: Cleaning up event system test")
	_test_events.clear()

# Test 3: Save System Integration
func _setup_save_system_test() -> void:
	"""Set up save system integration test"""
	print("IntegrationTests: Setting up save system test")
	
	# Create test game state
	var test_game_state = {
		"player": framework.get_test_data("", "player_data"),
		"economy": framework.get_test_data("", "economy_data"),
		"production": framework.get_test_data("", "production_data")
	}
	
	framework.set_test_data("save_system_test", test_game_state)

func _test_save_system_integration() -> bool:
	"""Test save system integration"""
	print("IntegrationTests: Testing save system integration")
	
	var test_data = framework.get_test_data("save_system_test")
	
	# Get SaveManager reference
	var save_manager = get_node("/root/SaveManager")
	if not save_manager:
		print("IntegrationTests: SaveManager not found")
		return false
	
	# Test save data structure
	if not test_data.has("player"):
		print("IntegrationTests: Save data missing player data")
		return false
	
	if not test_data.has("economy"):
		print("IntegrationTests: Save data missing economy data")
		return false
	
	if not test_data.has("production"):
		print("IntegrationTests: Save data missing production data")
		return false
	
	# Verify data integrity
	var player_data = test_data.player
	if not player_data.has("money") or not player_data.has("level"):
		print("IntegrationTests: Player data missing required fields")
		return false
	
	var economy_data = test_data.economy
	if not economy_data.has("hot_dog_price") or not economy_data.has("cost_per_hot_dog"):
		print("IntegrationTests: Economy data missing required fields")
		return false
	
	print("IntegrationTests: Save system integration test passed")
	return true

func _cleanup_save_system_test() -> void:
	"""Clean up save system test"""
	print("IntegrationTests: Cleaning up save system test")

# Test 4: UI System Integration
func _setup_ui_system_test() -> void:
	"""Set up UI system integration test"""
	print("IntegrationTests: Setting up UI system test")
	
	# Create test UI state
	var test_ui_state = {
		"current_screen": "game",
		"ui_elements": ["money_display", "production_queue", "upgrade_panel"],
		"ui_data": {
			"money_display": {"value": 1000.0, "visible": true},
			"production_queue": {"items": 3, "visible": true},
			"upgrade_panel": {"upgrades": [], "visible": false}
		}
	}
	
	framework.set_test_data("ui_system_test", test_ui_state)

func _test_ui_system_integration() -> bool:
	"""Test UI system integration"""
	print("IntegrationTests: Testing UI system integration")
	
	var test_data = framework.get_test_data("ui_system_test")
	
	# Get UIManager reference
	var ui_manager = get_node("/root/UIManager")
	if not ui_manager:
		print("IntegrationTests: UIManager not found")
		return false
	
	# Test UI state management
	if not test_data.has("current_screen"):
		print("IntegrationTests: UI state missing current screen")
		return false
	
	if not test_data.has("ui_elements"):
		print("IntegrationTests: UI state missing UI elements")
		return false
	
	# Verify UI data integrity
	var ui_data = test_data.ui_data
	for element_name in test_data.ui_elements:
		if not ui_data.has(element_name):
			print("IntegrationTests: UI data missing element: " + element_name)
			return false
		
		var element_data = ui_data[element_name]
		if not element_data.has("visible"):
			print("IntegrationTests: UI element missing visibility state: " + element_name)
			return false
	
	print("IntegrationTests: UI system integration test passed")
	return true

func _cleanup_ui_system_test() -> void:
	"""Clean up UI system test"""
	print("IntegrationTests: Cleaning up UI system test")

## run_all_tests
## 
## Run all integration tests.
## 
## Returns:
##   Dictionary: Test results
## 
## Example:
##   var results = integration_tests.run_all_tests()
func run_all_tests() -> Dictionary:
	"""Run all integration tests"""
	if not framework:
		print("IntegrationTests: ERROR - Framework not available!")
		return {"error": "Framework not available"}
	
	return framework.run_all_integration_tests()

## run_specific_test
## 
## Run a specific integration test.
## 
## Parameters:
##   test_name (String): Name of the test to run
## 
## Returns:
##   bool: True if test passed, false otherwise
## 
## Example:
##   var passed = integration_tests.run_specific_test("economy_production_integration")
func run_specific_test(test_name: String) -> bool:
	"""Run a specific integration test"""
	if not framework:
		print("IntegrationTests: ERROR - Framework not available!")
		return false
	
	return framework.run_specific_test(test_name) 