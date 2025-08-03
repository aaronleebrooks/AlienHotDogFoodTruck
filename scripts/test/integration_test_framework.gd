extends Node

## IntegrationTestFramework
## 
## Framework for testing system interactions and integration scenarios.
## 
## This framework provides tools for testing how different systems work together,
## including mock objects, test scenarios, and data management.
## 
## @since: 1.0.0
## @category: Testing

# Test tracking
var _tests_passed: int = 0
var _tests_failed: int = 0
var _current_test: String = ""

# Test scenarios
var _test_scenarios: Array[Dictionary] = []
var _mock_objects: Dictionary = {}

# Test data management
var _test_data: Dictionary = {}
var _test_data_templates: Dictionary = {}

func _ready() -> void:
	"""Initialize the integration test framework"""
	print("IntegrationTestFramework: Initialized")
	_setup_test_data_templates()

func _setup_test_data_templates() -> void:
	"""Set up default test data templates"""
	_test_data_templates = {
		"player_data": {
			"money": 1000.0,
			"level": 1,
			"experience": 0,
			"inventory": []
		},
		"production_data": {
			"queue_size": 5,
			"production_speed": 1.0,
			"quality": 0.8,
			"upgrades": []
		},
		"economy_data": {
			"hot_dog_price": 5.0,
			"cost_per_hot_dog": 2.0,
			"profit_margin": 0.6,
			"daily_sales": 0
		}
	}

## add_test_scenario
## 
## Add a test scenario to the framework.
## 
## Parameters:
##   scenario_name (String): Name of the test scenario
##   setup_func (Callable): Function to set up the test scenario
##   test_func (Callable): Function to run the test
##   cleanup_func (Callable, optional): Function to clean up after the test
## 
## Example:
##   framework.add_test_scenario("economy_production_integration", _setup_economy_test, _test_economy_production)
func add_test_scenario(scenario_name: String, setup_func: Callable, test_func: Callable, cleanup_func: Callable = Callable()):
	var scenario = {
		"name": scenario_name,
		"setup": setup_func,
		"test": test_func,
		"cleanup": cleanup_func
	}
	_test_scenarios.append(scenario)
	print("IntegrationTestFramework: Added test scenario: " + scenario_name)

## create_mock_object
## 
## Create a mock object for testing.
## 
## Parameters:
##   object_type (String): Type of object to mock
##   mock_data (Dictionary): Data for the mock object
## 
## Returns:
##   Dictionary: Mock object with test data
## 
## Example:
##   var mock_economy = framework.create_mock_object("economy", {"money": 1000.0})
func create_mock_object(object_type: String, mock_data: Dictionary = {}) -> Dictionary:
	var mock_object = {}
	
	# Add default mock data based on type
	if _test_data_templates.has(object_type):
		mock_object = _test_data_templates[object_type].duplicate(true)
	
	# Override with provided data
	for key in mock_data:
		mock_object[key] = mock_data[key]
	
	# Add mock methods
	mock_object["_mock_type"] = object_type
	mock_object["_mock_data"] = mock_object.duplicate(true)
	
	_mock_objects[object_type] = mock_object
	print("IntegrationTestFramework: Created mock object: " + object_type)
	return mock_object

## get_test_data
## 
## Get test data for a specific scenario.
## 
## Parameters:
##   data_key (String): Key for the test data
##   template_name (String, optional): Template to use as base
## 
## Returns:
##   Dictionary: Test data
## 
## Example:
##   var player_data = framework.get_test_data("player_level_5", "player_data")
func get_test_data(data_key: String, template_name: String = "") -> Dictionary:
	if _test_data.has(data_key):
		return _test_data[data_key].duplicate(true)
	
	if template_name and _test_data_templates.has(template_name):
		return _test_data_templates[template_name].duplicate(true)
	
	return {}

## set_test_data
## 
## Set test data for a specific scenario.
## 
## Parameters:
##   data_key (String): Key for the test data
##   data (Dictionary): Data to store
## 
## Example:
##   framework.set_test_data("high_level_player", {"level": 10, "money": 5000.0})
func set_test_data(data_key: String, data: Dictionary):
	_test_data[data_key] = data.duplicate(true)
	print("IntegrationTestFramework: Set test data: " + data_key)

## run_all_integration_tests
## 
## Run all integration test scenarios.
## 
## Returns:
##   Dictionary: Test results
## 
## Example:
##   var results = framework.run_all_integration_tests()
func run_all_integration_tests() -> Dictionary:
	print("IntegrationTestFramework: ===== RUNNING INTEGRATION TESTS =====")
	
	_tests_passed = 0
	_tests_failed = 0
	
	for scenario in _test_scenarios:
		_run_test_scenario(scenario)
	
	var results = {
		"total_tests": _tests_passed + _tests_failed,
		"passed": _tests_passed,
		"failed": _tests_failed,
		"success_rate": float(_tests_passed) / float(_tests_passed + _tests_failed) if (_tests_passed + _tests_failed) > 0 else 0.0
	}
	
	print("IntegrationTestFramework: ===== INTEGRATION TEST RESULTS =====")
	print("IntegrationTestFramework: Total tests: " + str(results.total_tests))
	print("IntegrationTestFramework: Passed: " + str(results.passed))
	print("IntegrationTestFramework: Failed: " + str(results.failed))
	print("IntegrationTestFramework: Success rate: " + str(results.success_rate * 100) + "%")
	
	if results.failed == 0:
		print("IntegrationTestFramework: ✅ ALL INTEGRATION TESTS PASSED!")
	else:
		print("IntegrationTestFramework: ❌ SOME INTEGRATION TESTS FAILED!")
	
	return results

## run_specific_test
## 
## Run a specific integration test scenario.
## 
## Parameters:
##   scenario_name (String): Name of the test scenario to run
## 
## Returns:
##   bool: True if test passed, false otherwise
## 
## Example:
##   var passed = framework.run_specific_test("economy_production_integration")
func run_specific_test(scenario_name: String) -> bool:
	for scenario in _test_scenarios:
		if scenario.name == scenario_name:
			return _run_test_scenario(scenario)
	
	print("IntegrationTestFramework: Test scenario not found: " + scenario_name)
	return false

func _run_test_scenario(scenario: Dictionary) -> bool:
	"""Run a single test scenario"""
	_current_test = scenario.name
	print("IntegrationTestFramework: Running test: " + _current_test)
	
	# Set up the test
	if scenario.setup.is_valid():
		scenario.setup.call()
	
	# Run the test
	var test_passed = false
	if scenario.test.is_valid():
		test_passed = scenario.test.call()
	else:
		print("IntegrationTestFramework: Invalid test function for: " + _current_test)
		test_passed = false
	
	# Clean up
	if scenario.cleanup.is_valid():
		scenario.cleanup.call()
	
	# Record results
	if test_passed:
		_tests_passed += 1
		print("IntegrationTestFramework: ✅ " + _current_test + " PASSED")
	else:
		_tests_failed += 1
		print("IntegrationTestFramework: ❌ " + _current_test + " FAILED")
	
	return test_passed

## clear_test_data
## 
## Clear all test data and mock objects.
## 
## Example:
##   framework.clear_test_data()
func clear_test_data():
	_test_data.clear()
	_mock_objects.clear()
	print("IntegrationTestFramework: Cleared all test data")

## get_mock_object
## 
## Get a mock object by type.
## 
## Parameters:
##   object_type (String): Type of mock object to retrieve
## 
## Returns:
##   Dictionary: Mock object or empty dictionary if not found
## 
## Example:
##   var mock_economy = framework.get_mock_object("economy")
func get_mock_object(object_type: String) -> Dictionary:
	if _mock_objects.has(object_type):
		return _mock_objects[object_type].duplicate(true)
	return {}

## get_test_results
## 
## Get current test results.
## 
## Returns:
##   Dictionary: Current test statistics
## 
## Example:
##   var results = framework.get_test_results()
func get_test_results() -> Dictionary:
	return {
		"passed": _tests_passed,
		"failed": _tests_failed,
		"total": _tests_passed + _tests_failed
	} 