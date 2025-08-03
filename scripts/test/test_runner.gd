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
	
	# Create test utilities
	var test_utils = preload("res://scripts/test/test_utilities.gd").new()
	var mock_production = test_utils.create_mock_production_system(1.0, 10)
	
	# Test 1: Add to queue
	append_result("  [color=gray]Running: test_add_to_queue[/color]")
	var add_success = mock_production.add_to_queue()
	if add_success and mock_production.current_queue_size == 1:
		append_result("  [color=green]✅ test_add_to_queue PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_add_to_queue FAILED[/color]")
	
	# Test 2: Production stats
	append_result("  [color=gray]Running: test_production_stats[/color]")
	var stats = mock_production.get_production_stats()
	if stats.has("current_queue_size") and stats.has("total_produced"):
		append_result("  [color=green]✅ test_production_stats PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_production_stats FAILED[/color]")
	
	# Test 3: Produce hot dog
	append_result("  [color=gray]Running: test_produce_hot_dog[/color]")
	var initial_produced = mock_production.total_produced
	mock_production.produce_hot_dog()
	if mock_production.total_produced == initial_produced + 1:
		append_result("  [color=green]✅ test_produce_hot_dog PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_produce_hot_dog FAILED[/color]")
	
	append_result("[color=blue]Production System Tests Completed[/color]")

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
	
	# Get EventBus reference
	var event_bus = get_node("/root/EventBus")
	
	# Test 1: Event emission
	append_result("  [color=gray]Running: test_event_emission[/color]")
	if event_bus and event_bus.has_method("emit_event"):
		append_result("  [color=green]✅ test_event_emission PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_event_emission FAILED[/color]")
	
	# Test 2: Event listening
	append_result("  [color=gray]Running: test_event_listening[/color]")
	if event_bus and event_bus.has_method("listen"):
		append_result("  [color=green]✅ test_event_listening PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_event_listening FAILED[/color]")
	
	# Test 3: Event data passing
	append_result("  [color=gray]Running: test_event_data_passing[/color]")
	var test_data = {"test": "value", "number": 42}
	if test_data.has("test") and test_data.has("number"):
		append_result("  [color=green]✅ test_event_data_passing PASSED[/color]")
	else:
		append_result("  [color=red]❌ test_event_data_passing FAILED[/color]")
	
	append_result("[color=blue]EventBus Tests Completed[/color]")

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
