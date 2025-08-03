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
	clear_results_button.pressed.connect(_on_clear_results_pressed)
	
	update_status("Ready to run tests")

func _on_run_all_tests_pressed() -> void:
	"""Handle run all tests button press"""
	print("TestRunner: Running all tests")
	update_status("Running all tests...")
	clear_results()
	
	# Run economy tests
	run_economy_tests()
	
	# Run production tests (placeholder)
	run_production_tests()
	
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