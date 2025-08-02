extends RefCounted
class_name GameUtils

## Utility functions for common game operations

# Math utilities
static func clamp_value(value: float, min_value: float, max_value: float) -> float:
	"""Clamp a value between min and max"""
	return clamp(value, min_value, max_value)

static func lerp_value(current: float, target: float, weight: float) -> float:
	"""Lerp between current and target value"""
	return lerp(current, target, weight)

static func round_to_decimals(value: float, decimals: int) -> float:
	"""Round a float to specified number of decimals"""
	var multiplier = pow(10, decimals)
	return round(value * multiplier) / multiplier

# String utilities
static func format_money(amount: float) -> String:
	"""Format money amount with proper currency formatting"""
	return "$%.2f" % amount

static func format_time(seconds: float) -> String:
	"""Format time in seconds to readable format"""
	var minutes = int(seconds) / 60.0
	var secs = int(seconds) % 60
	return "%02d:%02d" % [int(minutes), secs]

static func format_number(number: int) -> String:
	"""Format large numbers with commas"""
	var string_number = str(number)
	var result = ""
	var count = 0
	
	for i in range(string_number.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = string_number[i] + result
		count += 1
	
	return result

# Array utilities
static func shuffle_array(array: Array) -> Array:
	"""Shuffle an array in place"""
	var shuffled = array.duplicate()
	shuffled.shuffle()
	return shuffled

static func get_random_element(array: Array):
	"""Get a random element from an array"""
	if array.is_empty():
		return null
	return array[randi() % array.size()]

static func remove_duplicates(array: Array) -> Array:
	"""Remove duplicate elements from an array"""
	var seen = {}
	var result = []
	
	for item in array:
		if not seen.has(item):
			seen[item] = true
			result.append(item)
	
	return result

# Dictionary utilities
static func merge_dictionaries(dict1: Dictionary, dict2: Dictionary) -> Dictionary:
	"""Merge two dictionaries, dict2 overwrites dict1"""
	var result = dict1.duplicate()
	for key in dict2:
		result[key] = dict2[key]
	return result

static func filter_dictionary(dict: Dictionary, predicate: Callable) -> Dictionary:
	"""Filter dictionary based on predicate function"""
	var result = {}
	for key in dict:
		if predicate.call(key, dict[key]):
			result[key] = dict[key]
	return result

# Node utilities
static func find_node_by_type(parent: Node, type: String) -> Node:
	"""Find first node of specified type in the tree"""
	if parent.get_class() == type:
		return parent
	
	for child in parent.get_children():
		var result = find_node_by_type(child, type)
		if result:
			return result
	
	return null

static func find_all_nodes_by_type(parent: Node, type: String) -> Array[Node]:
	"""Find all nodes of specified type in the tree"""
	var result: Array[Node] = []
	
	if parent.get_class() == type:
		result.append(parent)
	
	for child in parent.get_children():
		result.append_array(find_all_nodes_by_type(child, type))
	
	return result

static func safe_connect(signal_obj: Object, signal_name: String, callable: Callable) -> bool:
	"""Safely connect a signal, returns true if successful"""
	if signal_obj and signal_obj.has_signal(signal_name):
		signal_obj.connect(signal_name, callable)
		return true
	return false

static func safe_disconnect(signal_obj: Object, signal_name: String, callable: Callable) -> bool:
	"""Safely disconnect a signal, returns true if successful"""
	if signal_obj and signal_obj.has_signal(signal_name):
		signal_obj.disconnect(signal_name, callable)
		return true
	return false

# Resource utilities
static func load_resource_safe(path: String) -> Resource:
	"""Safely load a resource, returns null if failed"""
	if not FileAccess.file_exists(path):
		print("GameUtils: Resource not found: %s" % path)
		return null
	
	var resource = load(path)
	if not resource:
		print("GameUtils: Failed to load resource: %s" % path)
		return null
	
	return resource

static func save_resource_safe(resource: Resource, path: String) -> bool:
	"""Safely save a resource, returns true if successful"""
	var dir = DirAccess.open("res://")
	if not dir:
		print("GameUtils: Cannot access directory")
		return false
	
	# Ensure directory exists
	var dir_path = path.get_base_dir()
	if not dir.dir_exists(dir_path):
		dir.make_dir_recursive(dir_path)
	
	var result = ResourceSaver.save(resource, path)
	if result != OK:
		print("GameUtils: Failed to save resource: %s" % path)
		return false
	
	return true

# Validation utilities
static func is_valid_email(email: String) -> bool:
	"""Check if email format is valid"""
	var email_regex = RegEx.new()
	email_regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	return email_regex.search(email) != null

static func is_valid_filename(filename: String) -> bool:
	"""Check if filename is valid"""
	var invalid_chars = ["<", ">", ":", "\"", "|", "?", "*", "\\", "/"]
	for invalid_char in invalid_chars:
		if invalid_char in filename:
			return false
	return true

# Performance utilities
static func measure_time(func_name: String, func_to_call: Callable) -> float:
	"""Measure execution time of a function"""
	var start_time = Time.get_ticks_msec()
	func_to_call.call()
	var end_time = Time.get_ticks_msec()
	var duration = (end_time - start_time) / 1000.0
	print("GameUtils: %s took %.3f seconds" % [func_name, duration])
	return duration 
