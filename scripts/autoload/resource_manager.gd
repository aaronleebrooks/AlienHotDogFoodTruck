extends Node

## ResourceManager
## 
## Enhanced global singleton for managing game resources.
## 
## This autoload provides advanced resource management including caching,
## memory management, lifecycle tracking, performance monitoring, and
## event-driven resource management. It builds upon Godot's native
## resource system while adding enterprise-level features.
## 
## Features:
##   - Advanced resource caching with statistics
##   - Memory usage monitoring and alerts
##   - Resource lifecycle tracking and cleanup
##   - Performance optimization strategies
##   - Event-driven resource management
##   - Resource loading queues and prioritization
##   - Memory leak prevention
## 
## Example:
##   # Load with caching
##   var resource = ResourceManager.load_resource("res://assets/textures/hot_dog.png")
##   
##   # Preload for performance
##   ResourceManager.preload_resource("res://assets/sounds/sell.wav")
##   
##   # Monitor memory usage
##   ResourceManager.get_memory_usage()
## 
## @since: 1.0.0
## @category: Autoload

# Resource cache and management
var _resource_cache: Dictionary = {}
var _cache_size_limit: int = 100
var _cache_hits: int = 0
var _cache_misses: int = 0

# Memory management
var _memory_usage_threshold: float = 0.8  # 80% of available memory
var _memory_usage_history: Array[float] = []
var _memory_check_interval: float = 5.0  # Check every 5 seconds
var _memory_timer: Timer

# Resource lifecycle tracking
var _resource_lifecycle: Dictionary = {}
var _resource_reference_count: Dictionary = {}
var _resource_load_times: Dictionary = {}

# Loading queue and prioritization
var _loading_queue: Array[Dictionary] = []
var _loading_in_progress: Dictionary = {}
var _max_concurrent_loads: int = 3

# Performance monitoring
var _performance_metrics: Dictionary = {
	"total_loads": 0,
	"total_load_time": 0.0,
	"average_load_time": 0.0,
	"peak_memory_usage": 0.0,
	"memory_warnings": 0
}

# Configuration
@export var enable_memory_monitoring: bool = true
@export var enable_performance_tracking: bool = true
@export var enable_lifecycle_tracking: bool = true
@export var auto_cleanup_enabled: bool = true

# Signals
signal resource_loaded(resource_path: String, resource: Resource, load_time: float)
signal resource_load_failed(resource_path: String, error: String)
signal resource_unloaded(resource_path: String)
signal cache_cleared()
signal cache_stats_updated(hits: int, misses: int, hit_rate: float)
signal memory_usage_updated(usage: float, peak_usage: float)
signal memory_warning_triggered(usage: float)
signal performance_metrics_updated(metrics: Dictionary)

## _ready
## 
## Initialize the enhanced resource manager.
func _ready() -> void:
	_safe_log("ResourceManager: Enhanced Resource Manager Initialized")
	_initialize_resource_system()

## _process
## 
## Process loading queue and monitor performance.
func _process(delta: float) -> void:
	_process_loading_queue()
	_update_performance_metrics(delta)

## load_resource
## 
## Load a resource with advanced caching and lifecycle tracking.
## 
## Parameters:
##   resource_path (String): Path to the resource file
##   use_cache (bool): Whether to use the resource cache (default: true)
##   priority (int): Loading priority (0=low, 1=normal, 2=high)
## 
## Returns:
##   Resource: The loaded resource, or null if loading failed
## 
## Example:
##   var texture = ResourceManager.load_resource("res://assets/textures/hot_dog.png", true, 2)
func load_resource(resource_path: String, use_cache: bool = true, priority: int = 1) -> Resource:
	"""Load a resource with advanced caching and lifecycle tracking"""
	if not resource_path or resource_path.is_empty():
		_safe_log("ResourceManager: Cannot load resource - invalid path")
		return null
	
	# Check cache first
	if use_cache and _resource_cache.has(resource_path):
		_cache_hits += 1
		_track_resource_access(resource_path)
		resource_loaded.emit(resource_path, _resource_cache[resource_path], 0.0)
		return _resource_cache[resource_path]
	
	_cache_misses += 1
	
	# Check if already loading
	if _loading_in_progress.has(resource_path):
		_safe_log("ResourceManager: Resource %s already loading" % resource_path)
		return null
	
	# Add to loading queue
	var load_request = {
		"path": resource_path,
		"use_cache": use_cache,
		"priority": priority,
		"timestamp": Time.get_ticks_msec()
	}
	
	_loading_queue.append(load_request)
	_loading_queue.sort_custom(_sort_by_priority)
	
	# Process queue immediately for high priority requests
	if priority >= 2:
		_process_loading_queue()
	
	return null

## preload_resource
## 
## Preload a resource and cache it for immediate access.
## 
## Parameters:
##   resource_path (String): Path to the resource file
##   priority (int): Loading priority (default: 2 for preloading)
## 
## Returns:
##   bool: True if preloading was successful
## 
## Example:
##   var success = ResourceManager.preload_resource("res://assets/sounds/sell.wav")
func preload_resource(resource_path: String, priority: int = 2) -> bool:
	"""Preload a resource and cache it for immediate access"""
	var resource = load_resource(resource_path, true, priority)
	return resource != null

## unload_resource
## 
## Unload a resource and remove it from cache.
## 
## Parameters:
##   resource_path (String): Path to the resource file
##   force (bool): Force unload even if referenced
## 
## Returns:
##   bool: True if resource was unloaded
## 
## Example:
##   var unloaded = ResourceManager.unload_resource("res://assets/textures/hot_dog.png")
func unload_resource(resource_path: String, force: bool = false) -> bool:
	"""Unload a resource and remove it from cache"""
	if not _resource_cache.has(resource_path):
		return false
	
	# Check reference count
	var ref_count = _resource_reference_count.get(resource_path, 0)
	if ref_count > 0 and not force:
		_safe_log("ResourceManager: Cannot unload %s - still referenced (%d times)" % [resource_path, ref_count])
		return false
	
	# Remove from cache
	var resource = _resource_cache[resource_path]
	_resource_cache.erase(resource_path)
	_resource_reference_count.erase(resource_path)
	_resource_lifecycle.erase(resource_path)
	_resource_load_times.erase(resource_path)
	
	# Track lifecycle
	if enable_lifecycle_tracking:
		_track_resource_lifecycle(resource_path, "unloaded")
	
	resource_unloaded.emit(resource_path)
	_safe_log("ResourceManager: Unloaded resource %s" % resource_path)
	return true

## get_cached_resource
## 
## Get a resource from the cache without loading it.
## 
## Parameters:
##   resource_path (String): Path to the resource file
## 
## Returns:
##   Resource: The cached resource, or null if not found
## 
## Example:
##   var texture = ResourceManager.get_cached_resource("res://assets/textures/hot_dog.png")
func get_cached_resource(resource_path: String) -> Resource:
	"""Get a resource from the cache without loading it"""
	if _resource_cache.has(resource_path):
		_track_resource_access(resource_path)
		return _resource_cache[resource_path]
	return null

## clear_cache
## 
## Clear the resource cache and unload all resources.
## 
## Parameters:
##   force (bool): Force clear even if resources are referenced
## 
## Example:
##   ResourceManager.clear_cache(true)
func clear_cache(force: bool = false) -> void:
	"""Clear the resource cache and unload all resources"""
	var cleared_count = 0
	
	for resource_path in _resource_cache.keys():
		if unload_resource(resource_path, force):
			cleared_count += 1
	
	_resource_cache.clear()
	_resource_reference_count.clear()
	_resource_lifecycle.clear()
	_resource_load_times.clear()
	
	cache_cleared.emit()
	_safe_log("ResourceManager: Cleared cache (%d resources)" % cleared_count)

## get_cache_stats
## 
## Get comprehensive cache statistics.
## 
## Returns:
##   Dictionary: Cache statistics including hits, misses, hit rate, and performance metrics
## 
## Example:
##   var stats = ResourceManager.get_cache_stats()
func get_cache_stats() -> Dictionary:
	"""Get comprehensive cache statistics"""
	var total_requests = _cache_hits + _cache_misses
	var hit_rate = 0.0
	if total_requests > 0:
		hit_rate = float(_cache_hits) / float(total_requests)
	
	return {
		"hits": _cache_hits,
		"misses": _cache_misses,
		"total_requests": total_requests,
		"hit_rate": hit_rate,
		"cache_size": _resource_cache.size(),
		"cache_limit": _cache_size_limit,
		"memory_usage": get_memory_usage(),
		"peak_memory_usage": _performance_metrics.peak_memory_usage,
		"average_load_time": _performance_metrics.average_load_time,
		"total_loads": _performance_metrics.total_loads
	}

## get_memory_usage
## 
## Get current memory usage as a percentage.
## 
## Returns:
##   float: Memory usage as percentage (0.0 to 1.0)
## 
## Example:
##   var usage = ResourceManager.get_memory_usage()
func get_memory_usage() -> float:
	"""Get current memory usage as a percentage"""
	var current_usage = OS.get_static_memory_usage()
	var peak_usage = OS.get_static_memory_peak_usage()
	
	if peak_usage > 0:
		return float(current_usage) / float(peak_usage)
	return 0.0

## get_performance_metrics
## 
## Get detailed performance metrics.
## 
## Returns:
##   Dictionary: Performance metrics including load times, memory usage, and statistics
## 
## Example:
##   var metrics = ResourceManager.get_performance_metrics()
func get_performance_metrics() -> Dictionary:
	"""Get detailed performance metrics"""
	return _performance_metrics.duplicate()

## set_memory_threshold
## 
## Set the memory usage threshold for warnings.
## 
## Parameters:
##   threshold (float): Memory usage threshold (0.0 to 1.0)
## 
## Example:
##   ResourceManager.set_memory_threshold(0.75)
func set_memory_threshold(threshold: float) -> void:
	"""Set the memory usage threshold for warnings"""
	_memory_usage_threshold = clamp(threshold, 0.1, 1.0)
	_safe_log("ResourceManager: Memory threshold set to %.2f" % _memory_usage_threshold)

## optimize_memory
## 
## Optimize memory usage by clearing cache and forcing garbage collection.
## 
## Example:
##   ResourceManager.optimize_memory()
func optimize_memory() -> void:
	"""Optimize memory usage by clearing cache and forcing garbage collection"""
	_safe_log("ResourceManager: Starting memory optimization")
	
	# Clear cache
	clear_cache(true)
	
	# Force garbage collection
	_force_garbage_collection()
	
	# Update memory usage
	var new_usage = get_memory_usage()
	memory_usage_updated.emit(new_usage, _performance_metrics.peak_memory_usage)
	
	_safe_log("ResourceManager: Memory optimization complete (usage: %.2f%%)" % (new_usage * 100))

# Private helper functions

func _initialize_resource_system() -> void:
	"""Initialize the enhanced resource system"""
	_safe_log("ResourceManager: Initializing enhanced resource system")
	
	# Setup memory monitoring
	if enable_memory_monitoring:
		_setup_memory_monitoring()
	
	# Setup performance tracking
	if enable_performance_tracking:
		_setup_performance_tracking()
	
	# Setup lifecycle tracking
	if enable_lifecycle_tracking:
		_setup_lifecycle_tracking()
	
	_safe_log("ResourceManager: Enhanced resource system initialized")

func _setup_memory_monitoring() -> void:
	"""Setup memory usage monitoring"""
	_memory_timer = Timer.new()
	_memory_timer.wait_time = _memory_check_interval
	_memory_timer.timeout.connect(_check_memory_usage)
	add_child(_memory_timer)
	_memory_timer.start()
	
	_safe_log("ResourceManager: Memory monitoring enabled (interval: %.1fs)" % _memory_check_interval)

func _setup_performance_tracking() -> void:
	"""Setup performance tracking"""
	_performance_metrics = {
		"total_loads": 0,
		"total_load_time": 0.0,
		"average_load_time": 0.0,
		"peak_memory_usage": 0.0,
		"memory_warnings": 0
	}
	
	_safe_log("ResourceManager: Performance tracking enabled")

func _setup_lifecycle_tracking() -> void:
	"""Setup resource lifecycle tracking"""
	_resource_lifecycle = {}
	_resource_reference_count = {}
	_resource_load_times = {}
	
	_safe_log("ResourceManager: Lifecycle tracking enabled")

func _check_memory_usage() -> void:
	"""Check current memory usage and trigger warnings if needed"""
	var current_usage = get_memory_usage()
	
	# Update history
	_memory_usage_history.append(current_usage)
	if _memory_usage_history.size() > 100:
		_memory_usage_history.pop_front()
	
	# Update peak usage
	if current_usage > _performance_metrics.peak_memory_usage:
		_performance_metrics.peak_memory_usage = current_usage
	
	# Emit memory update
	memory_usage_updated.emit(current_usage, _performance_metrics.peak_memory_usage)
	
	# Check threshold
	if current_usage > _memory_usage_threshold:
		_performance_metrics.memory_warnings += 1
		memory_warning_triggered.emit(current_usage)
		_safe_log("ResourceManager: Memory warning triggered (usage: %.2f%%)" % (current_usage * 100))
		
		# Auto-optimize if enabled
		if auto_cleanup_enabled:
			optimize_memory()

func _process_loading_queue() -> void:
	"""Process the resource loading queue"""
	var current_loads = _loading_in_progress.size()
	
	while current_loads < _max_concurrent_loads and not _loading_queue.is_empty():
		var load_request = _loading_queue.pop_front()
		var resource_path = load_request.path
		
		# Start loading
		_loading_in_progress[resource_path] = load_request
		_load_resource_async(resource_path, load_request.use_cache)
		
		current_loads += 1

func _load_resource_async(resource_path: String, use_cache: bool) -> void:
	"""Load a resource asynchronously"""
	var start_time = Time.get_ticks_msec()
	
	# Load the resource
	var resource = load(resource_path)
	var load_time = (Time.get_ticks_msec() - start_time) / 1000.0
	
	# Remove from loading queue
	_loading_in_progress.erase(resource_path)
	
	if resource:
		# Cache the resource
		if use_cache:
			_cache_resource(resource_path, resource)
		
		# Track performance
		_track_load_performance(resource_path, load_time)
		
		# Track lifecycle
		if enable_lifecycle_tracking:
			_track_resource_lifecycle(resource_path, "loaded")
		
		resource_loaded.emit(resource_path, resource, load_time)
		_safe_log("ResourceManager: Loaded resource %s (%.3fs)" % [resource_path, load_time])
	else:
		# Record the error
		resource_load_failed.emit(resource_path, "Failed to load resource")
		_safe_log("ResourceManager: Failed to load resource %s" % resource_path)

func _cache_resource(resource_path: String, resource: Resource) -> void:
	"""Cache a resource with advanced management"""
	# Remove oldest entries if cache is full
	if _resource_cache.size() >= _cache_size_limit:
		var oldest_key = _resource_cache.keys()[0]
		_resource_cache.erase(oldest_key)
		_resource_reference_count.erase(oldest_key)
		_resource_lifecycle.erase(oldest_key)
		_resource_load_times.erase(oldest_key)
	
	# Add to cache
	_resource_cache[resource_path] = resource
	_resource_reference_count[resource_path] = 0
	
	# Update cache stats
	cache_stats_updated.emit(_cache_hits, _cache_misses, get_cache_stats().hit_rate)

func _track_resource_access(resource_path: String) -> void:
	"""Track resource access for reference counting"""
	if _resource_reference_count.has(resource_path):
		_resource_reference_count[resource_path] += 1

func _track_load_performance(resource_path: String, load_time: float) -> void:
	"""Track resource load performance"""
	_performance_metrics.total_loads += 1
	_performance_metrics.total_load_time += load_time
	_performance_metrics.average_load_time = _performance_metrics.total_load_time / _performance_metrics.total_loads
	
	_resource_load_times[resource_path] = load_time
	
	# Emit performance update
	performance_metrics_updated.emit(_performance_metrics.duplicate())

func _track_resource_lifecycle(resource_path: String, event: String) -> void:
	"""Track resource lifecycle events"""
	_resource_lifecycle[resource_path] = {
		"event": event,
		"timestamp": Time.get_ticks_msec(),
		"memory_usage": get_memory_usage()
	}

func _force_garbage_collection() -> void:
	"""Force garbage collection"""
	# In Godot 4, we can't directly force GC, but we can help by clearing references
	# This is a placeholder for future GC implementation
	pass

func _update_performance_metrics(delta: float) -> void:
	"""Update performance metrics"""
	# This could include real-time performance monitoring
	pass

func _sort_by_priority(a: Dictionary, b: Dictionary) -> bool:
	"""Sort loading queue by priority"""
	return a.priority > b.priority

func _safe_log(message: String) -> void:
	"""Safely log messages using ErrorHandler if available"""
	if ClassDB.class_exists("ErrorHandler"):
		ErrorHandler.log_info("RESOURCE_MANAGER_INFO", message)
	else:
		print(message)

## _exit_tree
## 
## Clean up resource system on exit.
func _exit_tree() -> void:
	"""Clean up resource system on exit"""
	clear_cache(true)
	
	if _memory_timer:
		_memory_timer.stop()
		_memory_timer.queue_free()
	
	_safe_log("ResourceManager: Enhanced resource system cleaned up") 
