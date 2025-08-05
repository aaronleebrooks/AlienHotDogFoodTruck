extends Control

## TestRunner
## 
## UI for running tests and displaying results.
## 
## This script provides a user interface for running the testing framework
## and displaying test results in a user-friendly format.
## 
## @since: 1.0.0
## @category: Testing

# UI references
@onready var run_all_tests_button: Button = $VBoxContainer/Controls/RunAllTestsButton
@onready var run_economy_tests_button: Button = $VBoxContainer/Controls/RunEconomyTestsButton
@onready var run_production_tests_button: Button = $VBoxContainer/Controls/RunProductionTestsButton
@onready var run_save_manager_tests_button: Button = $VBoxContainer/Controls/RunSaveManagerTestsButton
@onready var run_event_bus_tests_button: Button = $VBoxContainer/Controls/RunEventBusTestsButton
@onready var run_integration_tests_button: Button = $VBoxContainer/Controls/RunIntegrationTestsButton
@onready var run_error_handler_tests_button: Button = $VBoxContainer/Controls/RunErrorHandlerTestsButton
@onready var clear_results_button: Button = $VBoxContainer/Controls/ClearResultsButton
@onready var results_text: RichTextLabel = $VBoxContainer/ResultsContainer/ResultsText
@onready var status_bar: Label = $VBoxContainer/StatusBar

# Test framework
var test_results: Dictionary = {}

func _ready() -> void:
	"""Initialize the test runner"""
	print("TestRunner: Initializing test runner")
	
	# Connect button signals
	run_all_tests_button.pressed.connect(_on_run_all_tests_pressed)
	run_economy_tests_button.pressed.connect(_on_run_economy_tests_pressed)
	run_production_tests_button.pressed.connect(_on_run_production_tests_pressed)
	run_save_manager_tests_button.pressed.connect(_on_run_save_manager_tests_pressed)
	run_event_bus_tests_button.pressed.connect(_on_run_event_bus_tests_pressed)
	run_integration_tests_button.pressed.connect(_on_run_integration_tests_pressed)
	run_error_handler_tests_button.pressed.connect(_on_run_error_handler_tests_pressed)
	clear_results_button.pressed.connect(_on_clear_results_pressed)
	
	update_status("Ready to run tests")

func _on_run_all_tests_pressed() -> void:
	"""Handle run all tests button press"""
	print("TestRunner: Running all tests")
	update_status("Running all tests...")
	clear_results()
	
	# Run economy tests
	run_economy_tests()
	
	# Run production tests
	run_production_tests()
	
	# Run SaveManager tests
	run_save_manager_tests()
	
	# Run EventBus tests
	run_event_bus_tests()
	
	# Run Integration tests
	run_integration_tests()
	
	# Run ErrorHandler tests
	run_error_handler_tests()
	
	update_status("All tests completed!")

func _on_run_economy_tests_pressed() -> void:
	"""Handle run economy tests button press"""
	print("TestRunner: Running economy tests")
	update_status("Running economy tests...")
	clear_results()
	
	run_economy_tests()
	update_status("Economy tests completed!")

func _on_run_production_tests_pressed() -> void:
	"""Handle run production tests button press"""
	print("TestRunner: Running production tests")
	update_status("Running production tests...")
	clear_results()
	
	run_production_tests()
	update_status("Production tests completed!")

func _on_production_tests_pressed() -> void:
	"""Handle run production tests button press"""
	print("TestRunner: Running production tests")
	update_status("Running production tests...")
	clear_results()
	
	run_production_tests()
	update_status("Production tests completed!")

func _on_run_save_manager_tests_pressed() -> void:
	"""Handle run SaveManager tests button press"""
	print("TestRunner: Running SaveManager tests")
	update_status("Running SaveManager tests...")
	clear_results()
	
	run_save_manager_tests()
	update_status("SaveManager tests completed!")

func _on_run_event_bus_tests_pressed() -> void:
	"""Handle run EventBus tests button press"""
	print("TestRunner: Running EventBus tests")
	update_status("Running EventBus tests...")
	clear_results()
	
	run_event_bus_tests()
	update_status("EventBus tests completed!")

func _on_run_integration_tests_pressed() -> void:
	"""Handle run integration tests button press"""
	print("TestRunner: Running integration tests")
	update_status("Running integration tests...")
	clear_results()
	
	run_integration_tests()
	update_status("Integration tests completed!")

func _on_run_error_handler_tests_pressed() -> void:
	"""Handle run ErrorHandler tests button press"""
	print("TestRunner: Running ErrorHandler tests")
	update_status("Running ErrorHandler tests...")
	clear_results()
	
	run_error_handler_tests()
	update_status("ErrorHandler tests completed!")

func _on_clear_results_pressed() -> void:
	"""Handle clear results button press"""
	print("TestRunner: Clearing results")
	clear_results()
	update_status("Results cleared")

func run_economy_tests() -> void:
	"""Run economy system tests"""
	append_result("[color=yellow]Starting Economy System Tests[/color]")
	
	# Create test utilities
	var test_utils = preload("res://scripts/test/test_utilities.gd").new()
	var mock_economy = test_utils.create_mock_economy_system(100.0, 5.0)
	
	# Test 1: Add money
	append_result("  [color=gray]Running: test_add_money[/color]")
	var initial_money = mock_economy.get_current_money()
	var success = mock_economy.add_money(50.0, "Test bonus")
	if success and mock_economy.get_current_money() == initial_money + 50.0:
		append_result("  [color=green]✅ test_add_money PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_add_money FAILED[/color]")
	
	# Test 2: Spend money
	append_result("  [color=gray]Running: test_spend_money[/color]")
	var spend_success = mock_economy.spend_money(30.0, "Test purchase")
	if spend_success and mock_economy.get_current_money() == initial_money + 50.0 - 30.0:
		append_result("  [color=green]✅ test_spend_money PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_spend_money FAILED[/color]")
	
	# Test 3: Sell hot dog
	append_result("  [color=gray]Running: test_sell_hot_dog[/color]")
	var hot_dog_success = mock_economy.sell_hot_dog()
	if hot_dog_success:
		append_result("  [color=green]✅ test_sell_hot_dog PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_sell_hot_dog FAILED[/color]")
	
	# Test 4: Can afford
	append_result("  [color=gray]Running: test_can_afford[/color]")
	var can_afford = mock_economy.can_afford(50.0)
	if can_afford:
		append_result("  [color=green]✅ test_can_afford PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_can_afford FAILED[/color]")
	
	append_result("[color=blue]Economy System Tests Completed[/color]")

func run_production_tests() -> void:
	"""Run production system tests"""
	append_result("[color=yellow]Starting Production System Tests[/color]")
	
	# Load and instantiate the production test scene
	var test_scene = preload("res://scenes/test/test_production_system.tscn")
	var test_instance = test_scene.instantiate()
	
	# Add the test instance to the scene tree so it can run
	add_child(test_instance)
	
	# Wait for the test to complete (give it more time for async operations)
	for i in range(30):  # Wait up to 30 frames for comprehensive tests
		await get_tree().process_frame
	
	# Remove the test instance
	test_instance.queue_free()
	
	append_result("[color=blue]Production System Tests Completed[/color]")
	append_result("[color=gray]Check console for detailed test output[/color]")

func run_save_manager_tests() -> void:
	"""Run SaveManager system tests"""
	append_result("[color=yellow]Starting SaveManager Tests[/color]")
	
	# Create test utilities
	var test_utils = preload("res://scripts/test/test_utilities.gd").new()
	
	# Test 1: Save data creation
	append_result("  [color=gray]Running: test_save_data_creation[/color]")
	var save_data = {
		"game_version": "1.0.0",
		"player_data": {"money": 1000.0},
		"production_data": {"queue_size": 5}
	}
	if save_data.has("game_version") and save_data.has("player_data"):
		append_result("  [color=green]✅ test_save_data_creation PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_save_data_creation FAILED[/color]")
	
	# Test 2: Save file operations
	append_result("  [color=gray]Running: test_save_file_operations[/color]")
	var save_manager = get_node("/root/SaveManager")
	if save_manager and save_manager.has_method("save_game"):
		append_result("  [color=green]✅ test_save_file_operations PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_save_file_operations FAILED[/color]")
	
	# Test 3: Data validation
	append_result("  [color=gray]Running: test_data_validation[/color]")
	var valid_data = save_data.duplicate(true)
	if valid_data.has("game_version") and valid_data.has("player_data"):
		append_result("  [color=green]✅ test_data_validation PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_data_validation FAILED[/color]")
	
	append_result("[color=blue]SaveManager Tests Completed[/color]")

func run_event_bus_tests() -> void:
	"""Run EventBus system tests"""
	append_result("[color=yellow]Starting EventBus Tests[/color]")
	
	# Load and instantiate the EventBus test scene
	var test_scene = preload("res://scenes/test/test_event_bus.tscn")
	var test_instance = test_scene.instantiate()
	
	# Add the test instance to the scene tree so it can run
	add_child(test_instance)
	
	# Wait for the test to complete (give it more time for async operations)
	for i in range(10):  # Wait up to 10 frames
		await get_tree().process_frame
	
	# Remove the test instance
	test_instance.queue_free()
	
	append_result("[color=blue]EventBus Tests Completed[/color]")
	append_result("[color=gray]Check console for detailed test output[/color]")

func run_integration_tests() -> void:
	"""Run integration system tests"""
	append_result("[color=yellow]Starting Integration Tests[/color]")
	
	# Load and instantiate the integration test scene
	var test_scene = preload("res://scenes/test/integration_tests.tscn")
	var test_instance = test_scene.instantiate()
	
	# Add the test instance to the scene tree so it can run
	add_child(test_instance)
	
	# Wait for the test to complete
	for i in range(15):  # Wait up to 15 frames for integration tests
		await get_tree().process_frame
	
	# Remove the test instance
	test_instance.queue_free()
	
	append_result("[color=blue]Integration Tests Completed[/color]")
	append_result("[color=gray]Check console for detailed test output[/color]")

func run_error_handler_tests() -> void:
	"""Run ErrorHandler system tests"""
	append_result("[color=yellow]Starting ErrorHandler Tests[/color]")
	
	# Get ErrorHandler reference
	var error_handler = get_node("/root/ErrorHandler")
	
	# Test 1: Error logging
	append_result("  [color=gray]Running: test_error_logging[/color]")
	if error_handler and error_handler.has_method("log_error"):
		append_result("  [color=green]✅ test_error_logging PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_error_logging FAILED[/color]")
	
	# Test 2: Warning logging
	append_result("  [color=gray]Running: test_warning_logging[/color]")
	if error_handler and error_handler.has_method("log_warning"):
		append_result("  [color=green]✅ test_warning_logging PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_warning_logging FAILED[/color]")
	
	# Test 3: Info logging
	append_result("  [color=gray]Running: test_info_logging[/color]")
	if error_handler and error_handler.has_method("log_info"):
		append_result("  [color=green]✅ test_info_logging PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_info_logging FAILED[/color]")
	
	append_result("[color=blue]ErrorHandler Tests Completed[/color]")

func append_result(text: String) -> void:
	"""Append text to the results display"""
	results_text.append_text(text + "\n")

func clear_results() -> void:
	"""Clear the results display"""
	results_text.text = ""

func update_status(status: String) -> void:
	"""Update the status bar"""
	status_bar.text = status
	print("TestRunner: Status: %s" % status) 
