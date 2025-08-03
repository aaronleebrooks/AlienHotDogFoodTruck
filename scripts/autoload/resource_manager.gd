extends Node

## ResourceManager
## 
## Global singleton for managing game resources.
## 
## This autoload handles loading, caching, and managing various game resources
## such as textures, sounds, configurations, and other assets.
## 
## @since: 1.0.0

# Resource cache
var _resource_cache: Dictionary = {}
var _cache_size_limit: int = 100
var _cache_hits: int = 0
var _cache_misses: int = 0

# Resource loading status
var _loading_resources: Dictionary = {}
var _resource_errors: Dictionary = {}

# Signals
signal resource_loaded(resource_path: String, resource: Resource)
signal resource_load_failed(resource_path: String, error: String)
signal cache_cleared()
signal cache_stats_updated(hits: int, misses: int, hit_rate: float)

## _ready
## 
## Initialize the resource manager.
## 
## @since: 1.0.0
func _ready() -> void:
	"""Initialize the resource manager"""
	print("ResourceManager: Initialized")

## load_resource
## 
## Load a resource from the given path.
## 
## Parameters:
##   resource_path (String): Path to the resource file
##   use_cache (bool): Whether to use the resource cache (default: true)
## 
## Returns:
##   Resource: The loaded resource, or null if loading failed
## 
## @since: 1.0.0
func load_resource(resource_path: String, use_cache: bool = true) -> Resource:
	"""Load a resource from the given path"""
	# Check cache first
	if use_cache and _resource_cache.has(resource_path):
		_cache_hits += 1
		resource_loaded.emit(resource_path, _resource_cache[resource_path])
		return _resource_cache[resource_path]
	
	_cache_misses += 1
	
	# Load the resource
	var resource = load(resource_path)
	if resource:
		# Cache the resource
		if use_cache:
			_cache_resource(resource_path, resource)
		
		resource_loaded.emit(resource_path, resource)
		return resource
	else:
		# Record the error
		_resource_errors[resource_path] = "Failed to load resource"
		resource_load_failed.emit(resource_path, "Failed to load resource")
		return null

## preload_resource
## 
## Preload a resource and cache it.
## 
## Parameters:
##   resource_path (String): Path to the resource file
## 
## Returns:
##   bool: True if preloading was successful
## 
## @since: 1.0.0
func preload_resource(resource_path: String) -> bool:
	"""Preload a resource and cache it"""
	var resource = load_resource(resource_path, true)
	return resource != null

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
## @since: 1.0.0
func get_cached_resource(resource_path: String) -> Resource:
	"""Get a resource from the cache without loading it"""
	return _resource_cache.get(resource_path, null)

## clear_cache
## 
## Clear the resource cache.
## 
## @since: 1.0.0
func clear_cache() -> void:
	"""Clear the resource cache"""
	_resource_cache.clear()
	cache_cleared.emit()

## get_cache_stats
## 
## Get cache statistics.
## 
## Returns:
##   Dictionary: Cache statistics including hits, misses, and hit rate
## 
## @since: 1.0.0
func get_cache_stats() -> Dictionary:
	"""Get cache statistics"""
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
		"cache_limit": _cache_size_limit
	}

## _cache_resource
## 
## Cache a resource, managing cache size.
## 
## Parameters:
##   resource_path (String): Path to the resource
##   resource (Resource): The resource to cache
## 
## @since: 1.0.0
func _cache_resource(resource_path: String, resource: Resource) -> void:
	"""Cache a resource, managing cache size"""
	# Remove oldest entries if cache is full
	if _resource_cache.size() >= _cache_size_limit:
		var oldest_key = _resource_cache.keys()[0]
		_resource_cache.erase(oldest_key)
	
	_resource_cache[resource_path] = resource
	cache_stats_updated.emit(_cache_hits, _cache_misses, get_cache_stats().hit_rate) 