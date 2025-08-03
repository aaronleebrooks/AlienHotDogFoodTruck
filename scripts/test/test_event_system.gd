extends Node

## TestEventSystem
## 
## Comprehensive test script for the Event System.
## 
## This script tests all aspects of the EventBus and EventTypes including:
## - Event emission and listening
## - Event queuing and processing
## - Event data validation
## - Debug mode functionality
## - Event history and statistics
## 
## @since: 1.0.0
## @category: Test

# Test tracking
var _tests_passed: int = 0
var _tests_failed: int = 0
var _current_test: String = ""

# Event tracking for tests
var _received_events: Array[Dictionary] = []
var _test_listener_id: String = ""

# Event system references
var event_bus: Node
var event_types: Resource

func _ready():
	_safe_log("TestEventSystem: Starting Event System tests")
	
	# Get references
	event_bus = get_node("/root/EventBus")
	event_types = preload("res://scripts/resources/event_types.gd")
	
	_run_all_tests()

func _run_all_tests():
	"""Run all Event System tests"""
	_safe_log("TestEventSystem: ===== EVENT SYSTEM TESTS =====")
	
	_test_event_bus_initialization()
	_test_event_types_definition()
	_test_basic_event_emission()
	_test_event_listener_registration()
	_test_event_data_validation()
	_test_event_queuing()
	_test_debug_mode()
	_test_event_history()
	_test_event_statistics()
	_test_listener_cleanup()
	
	_safe_log("TestEventSystem: ===== TEST RESULTS =====")
	_safe_log("TestEventSystem: Tests passed: %d" % _tests_passed)
	_safe_log("TestEventSystem: Tests failed: %d" % _tests_failed)
	_safe_log("TestEventSystem: Total tests: %d" % (_tests_passed + _tests_failed))
	
	if _tests_failed == 0:
		_safe_log("TestEventSystem: ✅ ALL TESTS PASSED!")
	else:
		_safe_log("TestEventSystem: ❌ SOME TESTS FAILED!")

func _test_event_bus_initialization():
	"""Test EventBus initialization"""
	_current_test = "EventBus Initialization"
	
	if not event_bus:
		_test_failed("EventBus autoload not found")
		return
	
	_safe_log("TestEventSystem: Testing %s" % _current_test)
	_test_passed()

func _test_event_types_definition():
	"""Test EventTypes resource definition"""
	_current_test = "EventTypes Definition"
	
	if not event_types:
		_test_failed("EventTypes resource not found")
		return
	
	# Test that we can get all events
	var all_events = event_types.get_all_events()
	if all_events.size() == 0:
		_test_failed("No events defined in EventTypes")
		return
	
	# Test event categories
	var production_events = event_types.get_events_by_category(0)  # PRODUCTION = 0
	if production_events.size() == 0:
		_test_failed("No production events found")
		return
	
	# Test event definition structure
	var test_event = production_events[0]
	if not test_event.name or test_event.name.is_empty():
		_test_failed("Event definition missing name")
		return
	
	if not test_event.default_data:
		_test_failed("Event definition missing default data")
		return
	
	_safe_log("TestEventSystem: Found %d total events, %d production events" % [all_events.size(), production_events.size()])
	_test_passed()

func _test_basic_event_emission():
	"""Test basic event emission"""
	_current_test = "Basic Event Emission"
	
	# Clear any previous events
	_received_events.clear()
	
	# Register a test listener
	_test_listener_id = event_bus.register_listener("test_event", _on_test_event_received)
	
	# Emit a test event
	event_bus.emit_event("test_event", {"message": "Hello World"})
	
	# Wait multiple frames for processing
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Check if event was received
	if _received_events.size() == 0:
		_test_failed("Event was not received by listener")
		return
	
	var received_event = _received_events[0]
	if not received_event.has("message") or received_event["message"] != "Hello World":
		_test_failed("Event data was not received correctly")
		return
	
	_safe_log("TestEventSystem: Event emission and reception successful")
	_test_passed()

func _test_event_listener_registration():
	"""Test event listener registration and management"""
	_current_test = "Event Listener Registration"
	
	# Test registration
	var listener_id = event_bus.register_listener("registration_test", _on_test_event_received)
	if listener_id.is_empty():
		_test_failed("Failed to register listener")
		return
	
	# Test unregistration
	var unregister_success = event_bus.unregister_listener(listener_id)
	if not unregister_success:
		_test_failed("Failed to unregister listener")
		return
	
	# Test unregistering non-existent listener
	var fake_unregister = event_bus.unregister_listener("fake_id")
	if fake_unregister:
		_test_failed("Unregistering fake listener should return false")
		return
	
	_safe_log("TestEventSystem: Listener registration and unregistration successful")
	_test_passed()

func _test_event_data_validation():
	"""Test event data validation"""
	_current_test = "Event Data Validation"
	
	# Test with valid event type
	var money_event = event_types.EconomyEvent.MONEY_CHANGED
	var valid_data = money_event.create_data({
		"amount": 100.0,
		"change": 50.0,
		"reason": "sale"
	})
	
	if not money_event.validate_data(valid_data):
		_test_failed("Valid data failed validation")
		return
	
	# Test with invalid data (missing fields)
	var invalid_data = {
		"amount": 100.0
		# Missing "change" and "reason"
	}
	
	if money_event.validate_data(invalid_data):
		_test_failed("Invalid data passed validation")
		return
	
	_safe_log("TestEventSystem: Event data validation successful")
	_test_passed()

func _test_event_queuing():
	"""Test event queuing functionality"""
	_current_test = "Event Queuing"
	
	# Enable queuing
	event_bus.enable_event_queuing = true
	
	# Clear received events
	_received_events.clear()
	
	# Register listener
	var listener_id = event_bus.register_listener("queue_test", _on_test_event_received)
	
	# Emit queued event
	event_bus.emit_event("queue_test", {"queued": true}, false)  # Don't process immediately
	
	# Check that event is not immediately received
	if _received_events.size() > 0:
		_test_failed("Queued event was processed immediately")
		return
	
	# Wait multiple frames for queue processing
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Check that event was processed
	if _received_events.size() == 0:
		_test_failed("Queued event was not processed")
		return
	
	# Clean up
	event_bus.unregister_listener(listener_id)
	
	_safe_log("TestEventSystem: Event queuing successful")
	_test_passed()

func _test_debug_mode():
	"""Test debug mode functionality"""
	_current_test = "Debug Mode"
	
	# Enable debug mode
	event_bus.set_debug_mode(true)
	
	# Get debug info
	var debug_info = event_bus.get_debug_info()
	if not debug_info.has("debug_mode") or not debug_info["debug_mode"]:
		_test_failed("Debug mode not properly enabled")
		return
	
	# Emit an event to test debug logging
	event_bus.emit_event("debug_test", {"test": true})
	
	# Disable debug mode
	event_bus.set_debug_mode(false)
	
	# Verify debug mode is disabled
	debug_info = event_bus.get_debug_info()
	if debug_info["debug_mode"]:
		_test_failed("Debug mode not properly disabled")
		return
	
	_safe_log("TestEventSystem: Debug mode functionality successful")
	_test_passed()

func _test_event_history():
	"""Test event history functionality"""
	_current_test = "Event History"
	
	# Clear history
	event_bus.clear_event_history()
	
	# Emit some events
	event_bus.emit_event("history_test_1", {"id": 1})
	event_bus.emit_event("history_test_2", {"id": 2})
	event_bus.emit_event("history_test_3", {"id": 3})
	
	# Get history
	var history = event_bus.get_event_history()
	if history.size() != 3:
		_test_failed("Event history size incorrect: %d" % history.size())
		return
	
	# Check history structure
	for event in history:
		if not event.has("event_name") or not event.has("event_data") or not event.has("timestamp"):
			_test_failed("Event history entry missing required fields")
			return
	
	_safe_log("TestEventSystem: Event history functionality successful")
	_test_passed()

func _test_event_statistics():
	"""Test event statistics"""
	_current_test = "Event Statistics"
	
	# Get stats
	var stats = event_bus.get_event_stats()
	
	# Check required stat fields
	var required_fields = ["events_emitted", "events_processed", "active_listeners", "event_types", "queue_size", "history_size"]
	for field in required_fields:
		if not stats.has(field):
			_test_failed("Statistics missing field: %s" % field)
			return
	
	# Verify stats are reasonable
	if stats["events_emitted"] < 0:
		_test_failed("Events emitted count is negative")
		return
	
	if stats["events_processed"] < 0:
		_test_failed("Events processed count is negative")
		return
	
	_safe_log("TestEventSystem: Event statistics successful")
	_test_passed()

func _test_listener_cleanup():
	"""Test listener cleanup"""
	_current_test = "Listener Cleanup"
	
	# Register multiple listeners
	var listener1 = event_bus.register_listener("cleanup_test", _on_test_event_received)
	var listener2 = event_bus.register_listener("cleanup_test", _on_test_event_received)
	
	# Test unregistering all listeners for specific event
	event_bus.unregister_all_listeners("cleanup_test")
	
	# Verify listeners are removed
	var stats = event_bus.get_event_stats()
	if stats["active_listeners"] > 0:
		# Check if our test listeners are still there
		var debug_info = event_bus.get_debug_info()
		for listener_id in debug_info["debug_listeners"]:
			if debug_info["debug_listeners"][listener_id]["event_name"] == "cleanup_test":
				_test_failed("Listeners not properly cleaned up")
				return
	
	# Test unregistering all listeners
	event_bus.unregister_all_listeners()
	
	# Verify all listeners are removed
	stats = event_bus.get_event_stats()
	if stats["active_listeners"] != 0:
		_test_failed("Not all listeners were cleaned up")
		return
	
	_safe_log("TestEventSystem: Listener cleanup successful")
	_test_passed()

# Event handler for tests
func _on_test_event_received(event_data):
	"""Handle test events"""
	_received_events.append(event_data)

# Test helper functions
func _test_passed():
	"""Mark current test as passed"""
	_tests_passed += 1
	_safe_log("TestEventSystem: ✅ %s PASSED" % _current_test)

func _test_failed(message: String):
	"""Mark current test as failed"""
	_tests_failed += 1
	_safe_log("TestEventSystem: ❌ %s FAILED: %s" % [_current_test, message])

func _safe_log(message: String):
	"""Safely log messages"""
	if ClassDB.class_exists("ErrorHandler"):
		ErrorHandler.log_info("TEST_INFO", message)
	else:
		print(message)

## _exit_tree
## 
## Clean up test listeners.
func _exit_tree():
	if not _test_listener_id.is_empty():
		event_bus.unregister_listener(_test_listener_id)
	_safe_log("TestEventSystem: Cleaned up test listeners") 