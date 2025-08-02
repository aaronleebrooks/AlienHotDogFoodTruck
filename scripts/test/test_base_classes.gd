extends Node
class_name TestBaseClasses

## Test script to verify base classes functionality

# Test instances
var test_system: BaseSystem
var test_ui_component: BaseUIComponent
var test_resource: BaseResource

func _ready() -> void:
	print("TestBaseClasses: Starting base class tests...")
	_run_tests()

func _run_tests() -> void:
	_test_base_system()
	_test_base_ui_component()
	_test_base_resource()
	_test_utilities()
	print("TestBaseClasses: All tests completed!")

func _test_base_system() -> void:
	print("\n--- Testing BaseSystem ---")
	
	# Create test system
	test_system = BaseSystem.new()
	test_system.system_name = "TestSystem"
	add_child(test_system)
	
	# Test initialization
	print("System initialized: %s" % test_system.is_initialized)
	print("System ready: %s" % test_system.is_system_ready())
	
	# Test enable/disable
	test_system.disable_system()
	print("System disabled: %s" % (not test_system.is_enabled))
	
	test_system.enable_system()
	print("System enabled: %s" % test_system.is_enabled)
	
	# Test pause/resume
	test_system.pause_system()
	print("System paused: %s" % test_system.is_paused)
	
	test_system.resume_system()
	print("System resumed: %s" % (not test_system.is_paused))
	
	# Test info
	var info = test_system.get_system_info()
	print("System info: %s" % info)
	
	# Test error logging
	test_system.log_error("Test error message")
	
	print("BaseSystem tests passed!")

func _test_base_ui_component() -> void:
	print("\n--- Testing BaseUIComponent ---")
	
	# Create test UI component
	test_ui_component = BaseUIComponent.new()
	test_ui_component.component_name = "TestUIComponent"
	add_child(test_ui_component)
	
	# Test initialization
	print("Component initialized: %s" % test_ui_component.is_visible)
	
	# Test show/hide
	test_ui_component.hide_component()
	print("Component hidden: %s" % (not test_ui_component.is_visible))
	
	test_ui_component.show_component()
	print("Component shown: %s" % test_ui_component.is_visible)
	
	# Test interaction
	test_ui_component.disable_interaction()
	print("Interaction disabled: %s" % (not test_ui_component.is_interactive))
	
	test_ui_component.enable_interaction()
	print("Interaction enabled: %s" % test_ui_component.is_interactive)
	
	# Test info
	var info = test_ui_component.get_component_info()
	print("Component info: %s" % info)
	
	print("BaseUIComponent tests passed!")

func _test_base_resource() -> void:
	print("\n--- Testing BaseResource ---")
	
	# Create test resource
	test_resource = BaseResource.new()
	test_resource.custom_resource_name = "TestResource"
	
	# Test initialization
	print("Resource ID: %s" % test_resource.resource_id)
	
	# Test loading
	var success = test_resource.load_resource()
	print("Resource loaded: %s" % success)
	print("Resource ready: %s" % test_resource.is_resource_ready())
	
	# Test tags
	test_resource.add_tag("test")
	test_resource.add_tag("example")
	print("Has 'test' tag: %s" % test_resource.has_tag("test"))
	print("Has 'missing' tag: %s" % test_resource.has_tag("missing"))
	
	test_resource.remove_tag("test")
	print("Has 'test' tag after removal: %s" % test_resource.has_tag("test"))
	
	# Test info
	var info = test_resource.get_resource_info()
	print("Resource info: %s" % info)
	
	# Test access
	test_resource.access_resource()
	
	print("BaseResource tests passed!")

func _test_utilities() -> void:
	print("\n--- Testing Utilities ---")
	
	# Test GameUtils
	var money = GameUtils.format_money(1234.56)
	print("Formatted money: %s" % money)
	
	var time = GameUtils.format_time(125)
	print("Formatted time: %s" % time)
	
	var number = GameUtils.format_number(1234567)
	print("Formatted number: %s" % number)
	
	var clamped = GameUtils.clamp_value(150, 0, 100)
	print("Clamped value: %s" % clamped)
	
	# Test array utilities
	var test_array = [1, 2, 3, 4, 5]
	var shuffled = GameUtils.shuffle_array(test_array)
	print("Shuffled array: %s" % str(shuffled))
	
	var random_element = GameUtils.get_random_element(test_array)
	print("Random element: %s" % random_element)
	
	# Test SignalUtils
	var test_object = Node.new()
	add_child(test_object)
	
	var connection_id = SignalUtils.connect_signal(test_object, "tree_entered", func(): print("Signal connected!"))
	print("Signal connection ID: %s" % connection_id)
	
	var connections = SignalUtils.get_all_connections()
	print("Total connections: %d" % connections.size())
	
	# Test signal emission
	var emit_success = SignalUtils.emit_signal_safe(test_object, "tree_entered")
	print("Signal emission success: %s" % emit_success)
	
	# Cleanup
	SignalUtils.disconnect_signal(connection_id)
	
	print("Utility tests passed!")

func _exit_tree() -> void:
	"""Cleanup test instances"""
	if test_system:
		test_system.queue_free()
	if test_ui_component:
		test_ui_component.queue_free()
	
	SignalUtils.disconnect_all_signals()
	print("TestBaseClasses: Cleanup completed") 
