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
var gut_framework: Object
var test_results: Dictionary = {}

func _ready() -> void:
	"""Initialize the test runner"""
	print("TestRunner: Initializing test runner")
	
	# Load GUT framework
	gut_framework = preload("res://addons/gut/gut.gd").new()
	add_child(gut_framework)
	
	# Connect button signals
	run_all_tests_button.pressed.connect(_on_run_all_tests_pressed)
	run_economy_tests_button.pressed.connect(_on_run_economy_tests_pressed)
	run_production_tests_button.pressed.connect(_on_run_production_tests_pressed)
	clear_results_button.pressed.connect(_on_clear_results_pressed)
	
	# Connect GUT signals
	gut_framework.test_suite_started.connect(_on_test_suite_started)
	gut_framework.test_suite_completed.connect(_on_test_suite_completed)
	gut_framework.test_started.connect(_on_test_started)
	gut_framework.test_completed.connect(_on_test_completed)
	gut_framework.all_tests_completed.connect(_on_all_tests_completed)
	
	update_status("Ready to run tests")

func _on_run_all_tests_pressed() -> void:
	"""Handle run all tests button press"""
	print("TestRunner: Running all tests")
	update_status("Running all tests...")
	clear_results()
	
	# Run all tests
	test_results = gut_framework.run_all_tests()

func _on_run_economy_tests_pressed() -> void:
	"""Handle run economy tests button press"""
	print("TestRunner: Running economy tests")
	update_status("Running economy tests...")
	clear_results()
	
	# Run economy test suite
	test_results = gut_framework.run_test_suite("TestEconomySystemTests")

func _on_run_production_tests_pressed() -> void:
	"""Handle run production tests button press"""
	print("TestRunner: Running production tests")
	update_status("Running production tests...")
	clear_results()
	
	# Run production test suite
	test_results = gut_framework.run_test_suite("TestProductionSystemTests")

func _on_clear_results_pressed() -> void:
	"""Handle clear results button press"""
	print("TestRunner: Clearing results")
	clear_results()
	update_status("Results cleared")

func _on_test_suite_started(suite_name: String) -> void:
	"""Handle test suite started event"""
	print("TestRunner: Test suite started: %s" % suite_name)
	append_result("[color=yellow]Starting test suite: %s[/color]" % suite_name)

func _on_test_suite_completed(suite_name: String, results: Dictionary) -> void:
	"""Handle test suite completed event"""
	print("TestRunner: Test suite completed: %s" % suite_name)
	append_result("[color=blue]Completed test suite: %s[/color]" % suite_name)
	append_result("  - Total tests: %d" % results.total_tests)
	append_result("  - Passed: %d" % results.passed)
	append_result("  - Failed: %d" % results.failed)
	append_result("  - Skipped: %d" % results.skipped)

func _on_test_started(test_name: String) -> void:
	"""Handle test started event"""
	print("TestRunner: Test started: %s" % test_name)
	append_result("  [color=gray]Running: %s[/color]" % test_name)

func _on_test_completed(test_name: String, passed: bool, message: String) -> void:
	"""Handle test completed event"""
	print("TestRunner: Test completed: %s (%s)" % [test_name, "PASSED" if passed else "FAILED"])
	
	if passed:
		append_result("  [color=green]✅ %s PASSED[/color]" % test_name)
	else:
		append_result("  [color=red]❌ %s FAILED: %s[/color]" % [test_name, message])

func _on_all_tests_completed(results: Dictionary) -> void:
	"""Handle all tests completed event"""
	print("TestRunner: All tests completed")
	
	append_result("")
	append_result("[color=cyan]=== FINAL TEST RESULTS ===[/color]")
	append_result("Total Tests: %d" % results.total_tests)
	append_result("Passed: %d" % results.passed)
	append_result("Failed: %d" % results.failed)
	append_result("Skipped: %d" % results.skipped)
	
	var duration = (results.end_time - results.start_time) / 1000.0
	append_result("Duration: %.2f seconds" % duration)
	
	if results.failed == 0:
		append_result("[color=green]🎉 ALL TESTS PASSED![/color]")
		update_status("All tests passed!")
	else:
		append_result("[color=red]❌ SOME TESTS FAILED![/color]")
		update_status("Some tests failed!")

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