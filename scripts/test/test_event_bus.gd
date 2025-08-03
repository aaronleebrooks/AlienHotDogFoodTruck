extends Node

## TestEventBus
## 
## Comprehensive test script for the EventBus autoload.
## 
## This script tests all aspects of the EventBus including:
## - Event emission and listening
## - Event queuing and processing
## - Event data validation
## - Debug mode functionality
## - Event history and statistics
## - Listener management and cleanup
## 
## @since: 1.0.0
## @category: Test

# Test tracking
var _tests_passed: int = 0
var _tests_failed: int = 0
var _current_test: String = ""

# EventBus reference
var event_bus: Node

# Event tracking for tests
var _received_events: Array[Dictionary] = []
var _test_listener_ids: Array[int] = []

# Test event types
var test_event_types: Dictionary = {
	"GAME_STARTED": "game_started",
	"MONEY_CHANGED": "money_changed",
	"HOT_DOG_PRODUCED": "hot_dog_produced",
	"UPGRADE_PURCHASED": "upgrade_purchased",
	"ERROR_OCCURRED": "error_occurred"
}

func _ready() -> void:
	"""Initialize and run all tests"""
	print("TestEventBus: Starting EventBus tests...")
	
	# Get EventBus reference
	event_bus = get_node("/root/EventBus")
	if not event_bus:
		print("TestEventBus: ERROR - EventBus autoload not found!")
		return
	
	# Run all tests
	_run_all_tests()

func _run_all_tests() -> void:
	"""Run all EventBus tests"""
	print("TestEventBus: ===== EVENT BUS TESTS =====")
	print("TestEventBus: Starting comprehensive test suite...")
	print("TestEventBus: EventBus reference: %s" % event_bus)
	print("TestEventBus: EventBus methods: %s" % event_bus.get_method_list() if event_bus else "No EventBus")
	
	_test_event_bus_initialization()
	_test_event_emission()
	_test_event_listening()
	_test_event_data_passing()
	_test_multiple_listeners()
	_test_event_queuing()
	_test_debug_mode()
	_test_event_history()
	_test_listener_cleanup()
	_test_error_handling()
	
	print("TestEventBus: ===== TEST RESULTS =====")
	print("TestEventBus: Tests passed: %d" % _tests_passed)
	print("TestEventBus: Tests failed: %d" % _tests_failed)
	print("TestEventBus: Total tests: %d" % (_tests_passed + _tests_failed))
	
	if _tests_failed == 0:
		print("TestEventBus: ✅ ALL TESTS PASSED!")
	else:
		print("TestEventBus: ❌ SOME TESTS FAILED!")

func _test_event_bus_initialization() -> void:
	"""Test EventBus initialization"""
	_current_test = "EventBus Initialization"
	
	print("TestEventBus: Testing EventBus initialization...")
	
	if not event_bus:
		_test_failed("EventBus autoload not found")
		return
	
	print("TestEventBus: EventBus found: %s" % event_bus)
	
	# Test basic properties
	if not event_bus.has_method("emit_event"):
		_test_failed("EventBus missing emit_event method")
		return
	
	if not event_bus.has_method("register_listener"):
		_test_failed("EventBus missing register_listener method")
		return
	
	if not event_bus.has_method("unregister_listener"):
		_test_failed("EventBus missing unregister_listener method")
		return
	
	# Test basic functionality
	print("TestEventBus: Testing basic EventBus functionality...")
	
	# Try to emit a test event
	event_bus.emit_event("test_initialization", {"test": true})
	
	# Check if EventBus has any stats
	if event_bus.has_method("get_event_stats"):
		var stats = event_bus.get_event_stats()
		print("TestEventBus: EventBus stats: %s" % stats)
	
	print("TestEventBus: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_event_emission() -> void:
	"""Test basic event emission"""
	_current_test = "Event Emission"
	
	# Clear any previous events
	_received_events.clear()
	
	# Register a test listener
	var listener_id = event_bus.register_listener(test_event_types.GAME_STARTED, _on_test_event_received)
	_test_listener_ids.append(listener_id)
	
	# Emit an event
	var event_data = {"player_name": "TestPlayer", "difficulty": "normal"}
	event_bus.emit_event(test_event_types.GAME_STARTED, event_data)
	
	# Wait a frame for event processing
	await get_tree().process_frame
	
	# Check if event was received
	if _received_events.size() == 0:
		_test_failed("Event was not received")
		return
	
	var received_event = _received_events[0]
	if received_event.data.player_name != "TestPlayer":
		_test_failed("Event data not passed correctly")
		return
	
	print("TestEventBus: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_event_listening() -> void:
	"""Test event listening functionality"""
	_current_test = "Event Listening"
	
	print("TestEventBus: ===== STARTING EVENT LISTENING TEST =====")
	
	# Clear any previous events
	_received_events.clear()
	print("TestEventBus: Cleared previous events. Current count: %d" % _received_events.size())
	
	print("TestEventBus: Starting Event Listening test...")
	print("TestEventBus: EventBus available: %s" % (event_bus != null))
	print("TestEventBus: EventBus methods: %s" % event_bus.get_method_list() if event_bus else "No EventBus")
	
	# Register multiple listeners for the same event
	print("TestEventBus: Registering listeners for event: %s" % test_event_types.MONEY_CHANGED)
	var listener1_id = event_bus.register_listener(test_event_types.MONEY_CHANGED, _on_test_event_received)
	var listener2_id = event_bus.register_listener(test_event_types.MONEY_CHANGED, _on_test_event_received)
	
	print("TestEventBus: Registered listeners - ID1: %s, ID2: %s" % [listener1_id, listener2_id])
	print("TestEventBus: Listener IDs valid: %s, %s" % [listener1_id != "", listener2_id != ""])
	
	_test_listener_ids.append(listener1_id)
	_test_listener_ids.append(listener2_id)
	
	# Emit an event
	var event_data = {"amount": 100.0, "reason": "hot_dog_sale"}
	print("TestEventBus: Emitting event with data: %s" % event_data)
	print("TestEventBus: Event type: %s" % test_event_types.MONEY_CHANGED)
	event_bus.emit_event(test_event_types.MONEY_CHANGED, event_data)
	
	# Wait a frame for event processing
	print("TestEventBus: Waiting for event processing...")
	await get_tree().process_frame
	
	print("TestEventBus: Received %d events" % _received_events.size())
	print("TestEventBus: Events received: %s" % _received_events)
	
	# Check if both listeners received the event
	if _received_events.size() != 2:
		_test_failed("Expected 2 events, got %d. Events received: %s" % [_received_events.size(), _received_events])
		return
	
	# Check that both events have the expected data
	for i in range(_received_events.size()):
		var event = _received_events[i]
		print("TestEventBus: Checking event %d: %s" % [i, event])
		
		# Check if the event data is the expected dictionary
		if not event.data is Dictionary:
			_test_failed("Event %d data is not a Dictionary. Event data: %s" % [i, event.data])
			return
		
		if not event.data.has("amount"):
			_test_failed("Event %d missing 'amount' field. Event data: %s" % [i, event.data])
			return
		
		if event.data.amount != 100.0:
			_test_failed("Event %d has wrong amount. Expected 100.0, got %s" % [i, event.data.amount])
			return
	
	print("TestEventBus: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_event_data_passing() -> void:
	"""Test event data passing and validation"""
	_current_test = "Event Data Passing"
	
	# Clear any previous events
	_received_events.clear()
	
	# Register a test listener
	var listener_id = event_bus.register_listener(test_event_types.HOT_DOG_PRODUCED, _on_test_event_received)
	_test_listener_ids.append(listener_id)
	
	# Emit an event with complex data
	var complex_data = {
		"hot_dog_id": 123,
		"ingredients": ["bun", "sausage", "mustard"],
		"quality": 0.95,
		"production_time": 2.5
	}
	event_bus.emit_event(test_event_types.HOT_DOG_PRODUCED, complex_data)
	
	# Wait a frame for event processing
	await get_tree().process_frame
	
	# Check if event data was passed correctly
	if _received_events.size() == 0:
		_test_failed("Event was not received")
		return
	
	var received_event = _received_events[0]
	if received_event.data.hot_dog_id != 123:
		_test_failed("Complex data not passed correctly")
		return
	
	if received_event.data.ingredients.size() != 3:
		_test_failed("Array data not passed correctly")
		return
	
	print("TestEventBus: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_multiple_listeners() -> void:
	"""Test multiple listeners for different events"""
	_current_test = "Multiple Listeners"
	
	# Clear any previous events
	_received_events.clear()
	
	# Register listeners for different events
	var money_listener = event_bus.register_listener(test_event_types.MONEY_CHANGED, _on_test_event_received)
	var upgrade_listener = event_bus.register_listener(test_event_types.UPGRADE_PURCHASED, _on_test_event_received)
	_test_listener_ids.append(money_listener)
	_test_listener_ids.append(upgrade_listener)
	
	# Emit different events
	event_bus.emit_event(test_event_types.MONEY_CHANGED, {"amount": 50.0})
	event_bus.emit_event(test_event_types.UPGRADE_PURCHASED, {"upgrade_type": "production_speed"})
	
	# Wait a frame for event processing
	await get_tree().process_frame
	
	# Check if both events were received
	if _received_events.size() != 2:
		_test_failed("Not all events were received")
		return
	
	# Check that we have both types of data
	var has_money_event = false
	var has_upgrade_event = false
	
	for event in _received_events:
		if event.data.has("amount") and event.data.amount == 50.0:
			has_money_event = true
		if event.data.has("upgrade_type") and event.data.upgrade_type == "production_speed":
			has_upgrade_event = true
	
	if not has_money_event:
		_test_failed("Money changed event not received")
		return
	
	if not has_upgrade_event:
		_test_failed("Upgrade purchased event not received")
		return
	
	print("TestEventBus: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_event_queuing() -> void:
	"""Test event queuing functionality"""
	_current_test = "Event Queuing"
	
	# Clear any previous events
	_received_events.clear()
	
	# Register a test listener
	var listener_id = event_bus.register_listener(test_event_types.GAME_STARTED, _on_test_event_received)
	_test_listener_ids.append(listener_id)
	
	# Emit multiple events rapidly
	for i in range(5):
		event_bus.emit_event(test_event_types.GAME_STARTED, {"level": i})
	
	# Wait a frame for event processing
	await get_tree().process_frame
	
	# Check if all events were processed
	if _received_events.size() != 5:
		_test_failed("Not all queued events were processed")
		return
	
	# Check if events were processed in order
	for i in range(_received_events.size()):
		if _received_events[i].data.level != i:
			_test_failed("Events not processed in order")
			return
	
	print("TestEventBus: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_debug_mode() -> void:
	"""Test debug mode functionality"""
	_current_test = "Debug Mode"
	
	# Test debug mode toggle
	var original_debug_mode = event_bus.enable_debug_mode
	event_bus.enable_debug_mode = true
	
	if not event_bus.enable_debug_mode:
		_test_failed("Debug mode not enabled")
		return
	
	# Test debug mode functionality
	event_bus.emit_event(test_event_types.ERROR_OCCURRED, {"message": "Test error"})
	
	# Restore original debug mode
	event_bus.enable_debug_mode = original_debug_mode
	
	print("TestEventBus: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_event_history() -> void:
	"""Test event history tracking"""
	_current_test = "Event History"
	
	# Clear any previous events
	_received_events.clear()
	
	# Emit some test events
	event_bus.emit_event(test_event_types.MONEY_CHANGED, {"amount": 25.0})
	event_bus.emit_event(test_event_types.HOT_DOG_PRODUCED, {"quality": 0.9})
	
	# Wait a frame for event processing
	await get_tree().process_frame
	
	# Check if event history is being tracked
	if event_bus.has_method("get_event_history"):
		var history = event_bus.get_event_history()
		if history.size() < 2:
			_test_failed("Event history not being tracked")
			return
	
	print("TestEventBus: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_listener_cleanup() -> void:
	"""Test listener cleanup and management"""
	_current_test = "Listener Cleanup"
	
	# Register a test listener
	var listener_id = event_bus.register_listener(test_event_types.GAME_STARTED, _on_test_event_received)
	
	# Stop listening
	var stop_result = event_bus.unregister_listener(listener_id)
	if not stop_result:
		_test_failed("Failed to stop listening")
		return
	
	# Clear any previous events
	_received_events.clear()
	
	# Emit an event (should not be received)
	event_bus.emit_event(test_event_types.GAME_STARTED, {"test": "data"})
	
	# Wait a frame for event processing
	await get_tree().process_frame
	
	# Check that no events were received
	if _received_events.size() > 0:
		_test_failed("Listener still receiving events after cleanup")
		return
	
	print("TestEventBus: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_error_handling() -> void:
	"""Test error handling in event system"""
	_current_test = "Error Handling"
	
	# Test invalid event type
	event_bus.emit_event("INVALID_EVENT_TYPE", {})
	
	# Test null data
	event_bus.emit_event(test_event_types.MONEY_CHANGED, null)
	
	# Test invalid listener registration
	var invalid_listener_id = event_bus.register_listener("INVALID_EVENT_TYPE", _on_test_event_received)
	if invalid_listener_id != "":
		_test_listener_ids.append(invalid_listener_id)
	
	# If we get here without errors, the system handled invalid inputs gracefully
	print("TestEventBus: ✅ %s PASSED" % _current_test)
	_test_passed()

# Event handler for tests
func _on_test_event_received(event_data) -> void:
	"""Handle test events"""
	print("TestEventBus: ===== EVENT CALLBACK TRIGGERED =====")
	print("TestEventBus: Event callback called with data: %s" % event_data)
	print("TestEventBus: Event data type: %s" % typeof(event_data))
	print("TestEventBus: Event data is Dictionary: %s" % (event_data is Dictionary))
	
	if event_data is Dictionary:
		print("TestEventBus: Event data keys: %s" % event_data.keys())
		if event_data.has("amount"):
			print("TestEventBus: Amount value: %s" % event_data.amount)
	
	_received_events.append({
		"data": event_data,
		"timestamp": Time.get_unix_time_from_system()
	})
	
	print("TestEventBus: Total events received: %d" % _received_events.size())
	print("TestEventBus: All received events: %s" % _received_events)
	print("TestEventBus: ===== EVENT CALLBACK COMPLETE =====")

func _test_passed() -> void:
	"""Record a passed test"""
	_tests_passed += 1

func _test_failed(message: String) -> void:
	"""Record a failed test with detailed error information"""
	_tests_failed += 1
	
	# Get stack trace
	var stack_trace = get_stack()
	var stack_info = ""
	for i in range(stack_trace.size()):
		var frame = stack_trace[i]
		stack_info += "  %d: %s:%d in %s()\n" % [i, frame.source, frame.line, frame.function]
	
	# Print detailed error information
	print("TestEventBus: ❌ %s FAILED" % _current_test)
	print("TestEventBus: Error: %s" % message)
	print("TestEventBus: Stack trace:")
	print(stack_info)
	
	# Print current state information
	print("TestEventBus: Current state:")
	print("  - Tests passed: %d" % _tests_passed)
	print("  - Tests failed: %d" % _tests_failed)
	print("  - Received events: %s" % _received_events)
	print("  - Listener IDs: %s" % _test_listener_ids)
	
	if event_bus:
		print("  - EventBus methods: %s" % event_bus.get_method_list())
		if event_bus.has_method("get_event_stats"):
			print("  - Event stats: %s" % event_bus.get_event_stats())

func _exit_tree() -> void:
	"""Clean up test listeners"""
	for listener_id in _test_listener_ids:
		if event_bus and event_bus.has_method("unregister_listener"):
			event_bus.unregister_listener(listener_id) 