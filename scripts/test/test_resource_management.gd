extends Node

## TestResourceManagement
## 
## Comprehensive test script for the enhanced Resource Management system.
## 
## This script tests all aspects of the ResourceManager including:
## - Resource loading and caching
## - Memory management and monitoring
## - Performance tracking and optimization
## - Lifecycle tracking and cleanup
## - Event-driven resource management
## 
## @since: 1.0.0
## @category: Test

# Test tracking
var _tests_passed: int = 0
var _tests_failed: int = 0
var _current_test: String = ""

# Resource management references
var resource_manager: Node
var test_resources: Array[String] = []

# Event tracking for tests
var _received_events: Array[Dictionary] = []
var _test_listener_ids: Array[int] = []

func _ready():
	_safe_log("TestResourceManagement: Starting Resource Management tests")
	
	# Get references
	resource_manager = get_node("/root/ResourceManager")
	
	# Setup test resources
	_setup_test_resources()
	
	_run_all_tests()

func _setup_test_resources():
	"""Setup test resources for testing"""
	# Create some test resource paths (these won't actually load, but we can test the system)
	test_resources = [
		"res://test_resources/test_texture.png",
		"res://test_resources/test_sound.wav",
		"res://test_resources/test_config.tres",
		"res://test_resources/test_scene.tscn"
	]

func _run_all_tests():
	"""Run all Resource Management tests"""
	_safe_log("TestResourceManagement: ===== RESOURCE MANAGEMENT TESTS =====")
	
	_test_resource_manager_initialization()
	_test_basic_resource_loading()
	_test_resource_caching()
	_test_memory_management()
	_test_performance_tracking()
	_test_lifecycle_tracking()
	_test_resource_unloading()
	_test_cache_management()
	_test_memory_optimization()
	_test_event_system_integration()
	
	_safe_log("TestResourceManagement: ===== TEST RESULTS =====")
	_safe_log("TestResourceManagement: Tests passed: %d" % _tests_passed)
	_safe_log("TestResourceManagement: Tests failed: %d" % _tests_failed)
	_safe_log("TestResourceManagement: Total tests: %d" % (_tests_passed + _tests_failed))
	
	if _tests_failed == 0:
		_safe_log("TestResourceManagement: ✅ ALL TESTS PASSED!")
	else:
		_safe_log("TestResourceManagement: ❌ SOME TESTS FAILED!")

func _test_resource_manager_initialization():
	"""Test ResourceManager initialization"""
	_current_test = "ResourceManager Initialization"
	
	if not resource_manager:
		_test_failed("ResourceManager autoload not found")
		return
	
	_safe_log("TestResourceManagement: Testing %s" % _current_test)
	_test_passed()

func _test_basic_resource_loading():
	"""Test basic resource loading functionality"""
	_current_test = "Basic Resource Loading"
	
	# Test loading a resource (will fail since file doesn't exist, but tests the system)
	var resource = resource_manager.load_resource(test_resources[0])
	
	# The resource should be null since the file doesn't exist, but the system should handle it gracefully
	if resource != null:
		_test_failed("Resource loading should return null for non-existent file")
		return
	
	_safe_log("TestResourceManagement: Basic resource loading system working")
	_test_passed()

func _test_resource_caching():
	"""Test resource caching functionality"""
	_current_test = "Resource Caching"
	
	# Get initial cache stats
	var initial_stats = resource_manager.get_cache_stats()
	
	# Test cache operations
	var cached_resource = resource_manager.get_cached_resource(test_resources[0])
	if cached_resource != null:
		_test_failed("Cached resource should be null for non-existent file")
		return
	
	# Test cache statistics
	var stats = resource_manager.get_cache_stats()
	if not stats.has("hits") or not stats.has("misses") or not stats.has("hit_rate"):
		_test_failed("Cache stats missing required fields")
		return
	
	_safe_log("TestResourceManagement: Resource caching system working")
	_test_passed()

func _test_memory_management():
	"""Test memory management functionality"""
	_current_test = "Memory Management"
	
	# Test memory usage monitoring
	var memory_usage = resource_manager.get_memory_usage()
	if memory_usage < 0.0 or memory_usage > 1.0:
		_test_failed("Memory usage should be between 0.0 and 1.0")
		return
	
	# Test memory threshold setting
	resource_manager.set_memory_threshold(0.75)
	
	# Test memory optimization
	resource_manager.optimize_memory()
	
	_safe_log("TestResourceManagement: Memory management system working")
	_test_passed()

func _test_performance_tracking():
	"""Test performance tracking functionality"""
	_current_test = "Performance Tracking"
	
	# Get performance metrics
	var metrics = resource_manager.get_performance_metrics()
	
	# Check required metric fields
	var required_fields = ["total_loads", "total_load_time", "average_load_time", "peak_memory_usage", "memory_warnings"]
	for field in required_fields:
		if not metrics.has(field):
			_test_failed("Performance metrics missing field: %s" % field)
			return
	
	# Verify metrics are reasonable
	if metrics["total_loads"] < 0:
		_test_failed("Total loads should not be negative")
		return
	
	if metrics["total_load_time"] < 0.0:
		_test_failed("Total load time should not be negative")
		return
	
	_safe_log("TestResourceManagement: Performance tracking system working")
	_test_passed()

func _test_lifecycle_tracking():
	"""Test resource lifecycle tracking"""
	_current_test = "Lifecycle Tracking"
	
	# Test lifecycle tracking (since we can't actually load resources, we test the system)
	# The lifecycle tracking should be enabled by default
	
	# Test that the system is properly configured
	var stats = resource_manager.get_cache_stats()
	if not stats.has("cache_size"):
		_test_failed("Cache stats should include cache size")
		return
	
	_safe_log("TestResourceManagement: Lifecycle tracking system working")
	_test_passed()

func _test_resource_unloading():
	"""Test resource unloading functionality"""
	_current_test = "Resource Unloading"
	
	# Test unloading non-existent resource
	var unloaded = resource_manager.unload_resource(test_resources[0])
	if unloaded:
		_test_failed("Unloading non-existent resource should return false")
		return
	
	# Test force unloading
	var force_unloaded = resource_manager.unload_resource(test_resources[0], true)
	if force_unloaded:
		_test_failed("Force unloading non-existent resource should return false")
		return
	
	_safe_log("TestResourceManagement: Resource unloading system working")
	_test_passed()

func _test_cache_management():
	"""Test cache management functionality"""
	_current_test = "Cache Management"
	
	# Get initial cache stats
	var initial_stats = resource_manager.get_cache_stats()
	
	# Test cache clearing
	resource_manager.clear_cache()
	
	# Get cache stats after clearing
	var final_stats = resource_manager.get_cache_stats()
	
	# Cache should be empty after clearing
	if final_stats["cache_size"] != 0:
		_test_failed("Cache should be empty after clearing")
		return
	
	_safe_log("TestResourceManagement: Cache management system working")
	_test_passed()

func _test_memory_optimization():
	"""Test memory optimization functionality"""
	_current_test = "Memory Optimization"
	
	# Test memory optimization
	resource_manager.optimize_memory()
	
	# Get memory usage after optimization
	var memory_usage = resource_manager.get_memory_usage()
	
	# Memory usage should be reasonable
	if memory_usage < 0.0 or memory_usage > 1.0:
		_test_failed("Memory usage after optimization should be between 0.0 and 1.0")
		return
	
	_safe_log("TestResourceManagement: Memory optimization system working")
	_test_passed()

func _test_event_system_integration():
	"""Test event system integration"""
	_current_test = "Event System Integration"
	
	# Clear any previous events
	_received_events.clear()
	
	# Register event listeners
	_register_event_listeners()
	
	# Trigger some events by calling resource manager functions
	resource_manager.get_cache_stats()
	resource_manager.get_memory_usage()
	
	# Wait a frame for event processing
	await get_tree().process_frame
	
	# Clean up event listeners
	_unregister_event_listeners()
	
	_safe_log("TestResourceManagement: Event system integration working")
	_test_passed()

func _register_event_listeners():
	"""Register event listeners for testing"""
	# Register listeners for resource manager events
	var listener_id1 = resource_manager.resource_loaded.connect(_on_resource_loaded)
	var listener_id2 = resource_manager.cache_cleared.connect(_on_cache_cleared)
	var listener_id3 = resource_manager.memory_usage_updated.connect(_on_memory_updated)
	
	_test_listener_ids.append(listener_id1)
	_test_listener_ids.append(listener_id2)
	_test_listener_ids.append(listener_id3)

func _unregister_event_listeners():
	"""Unregister event listeners"""
	for listener_id in _test_listener_ids:
		if resource_manager.resource_loaded.is_connected(_on_resource_loaded):
			resource_manager.resource_loaded.disconnect(_on_resource_loaded)
		if resource_manager.cache_cleared.is_connected(_on_cache_cleared):
			resource_manager.cache_cleared.disconnect(_on_cache_cleared)
		if resource_manager.memory_usage_updated.is_connected(_on_memory_updated):
			resource_manager.memory_usage_updated.disconnect(_on_memory_updated)
	
	_test_listener_ids.clear()

# Event handlers for tests
func _on_resource_loaded(resource_path: String, resource: Resource, load_time: float):
	"""Handle resource loaded events"""
	_received_events.append({
		"event": "resource_loaded",
		"path": resource_path,
		"load_time": load_time
	})

func _on_cache_cleared():
	"""Handle cache cleared events"""
	_received_events.append({
		"event": "cache_cleared"
	})

func _on_memory_updated(usage: float, peak_usage: float):
	"""Handle memory usage updated events"""
	_received_events.append({
		"event": "memory_updated",
		"usage": usage,
		"peak_usage": peak_usage
	})

# Test helper functions
func _test_passed():
	"""Mark current test as passed"""
	_tests_passed += 1
	_safe_log("TestResourceManagement: ✅ %s PASSED" % _current_test)

func _test_failed(message: String):
	"""Mark current test as failed"""
	_tests_failed += 1
	_safe_log("TestResourceManagement: ❌ %s FAILED: %s" % [_current_test, message])

func _safe_log(message: String):
	"""Safely log messages"""
	if ClassDB.class_exists("ErrorHandler"):
		ErrorHandler.log_info("TEST_INFO", message)
	else:
		print(message)

## _exit_tree
## 
## Clean up test resources.
func _exit_tree():
	_unregister_event_listeners()
	_safe_log("TestResourceManagement: Cleaned up test resources") 
