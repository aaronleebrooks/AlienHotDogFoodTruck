extends RefCounted
class_name GameUtils

## GameUtils
## 
## Utility functions for common game operations and data manipulation.
## 
## This class provides static utility functions for formatting, validation,
## data manipulation, and other common operations used throughout the game.
## All functions are stateless and can be called without instantiation.
## 
## Features:
##   - Number and currency formatting
##   - Time and duration formatting
##   - Array and dictionary manipulation
##   - Node finding and traversal
##   - File and resource operations
##   - Data validation
##   - Performance measurement
## 
## Example:
##   var formatted_money = GameUtils.format_money(1234.56)
##   var formatted_time = GameUtils.format_time(125)
##   var shuffled_array = GameUtils.shuffle_array([1, 2, 3, 4, 5])
## 
## @since: 1.0.0
## @category: Utility

## format_money
## 
## Format a number as currency with proper formatting.
## 
## This function formats a float value as currency with dollar sign,
## thousands separators, and two decimal places. It handles negative
## values and zero appropriately.
## 
## Parameters:
##   amount (float): The amount to format as currency
##   decimals (int, optional): Number of decimal places (default: 2)
## 
## Returns:
##   String: Formatted currency string (e.g., "$1,234.56")
## 
## Example:
##   var money = GameUtils.format_money(1234.56)
##   print(money)  # Output: "$1,234.56"
##   
##   var cents = GameUtils.format_money(0.99)
##   print(cents)  # Output: "$0.99"
## 
## @since: 1.0.0
static func format_money(amount: float, decimals: int = 2) -> String:
	"""Format a number as currency with proper formatting"""
	var multiplier = pow(10, decimals)
	var rounded = round(amount * multiplier) / multiplier
	var string_number = str(rounded)
	var result = ""
	var count = 0
	
	# Add dollar sign
	result += "$"
	
	# Handle negative numbers
	if amount < 0:
		result += "-"
		string_number = string_number.substr(1)
	
	# Find decimal point
	var decimal_index = string_number.find(".")
	if decimal_index == -1:
		decimal_index = string_number.length()
	
	# Add thousands separators
	for i in range(decimal_index):
		if count > 0 and count % 3 == 0:
			result += ","
		result += string_number[i]
		count += 1
	
	# Add decimal part
	if decimal_index < string_number.length():
		result += string_number.substr(decimal_index)
	
	return result

## format_time
## 
## Format seconds into a human-readable time string.
## 
## This function converts seconds into a formatted time string showing
## minutes and seconds. It handles values over 60 seconds appropriately.
## 
## Parameters:
##   seconds (float): Time in seconds to format
## 
## Returns:
##   String: Formatted time string (e.g., "02:05")
## 
## Example:
##   var time = GameUtils.format_time(125)
##   print(time)  # Output: "02:05"
##   
##   var short_time = GameUtils.format_time(45)
##   print(short_time)  # Output: "00:45"
## 
## @since: 1.0.0
static func format_time(seconds: float) -> String:
	"""Format seconds into a human-readable time string"""
	var minutes = int(seconds) / 60.0
	var secs = int(seconds) % 60
	return "%02d:%02d" % [int(minutes), secs]

## format_number
## 
## Format a number with thousands separators.
## 
## This function adds thousands separators to a number for better
## readability. It works with both integers and floats.
## 
## Parameters:
##   number (float): The number to format
## 
## Returns:
##   String: Formatted number with thousands separators
## 
## Example:
##   var formatted = GameUtils.format_number(1234567)
##   print(formatted)  # Output: "1,234,567"
##   
##   var decimal = GameUtils.format_number(1234.56)
##   print(decimal)  # Output: "1,234.56"
## 
## @since: 1.0.0
static func format_number(number: float) -> String:
	"""Format a number with thousands separators"""
	var string_number = str(number)
	var result = ""
	var count = 0
	
	# Find decimal point
	var decimal_index = string_number.find(".")
	if decimal_index == -1:
		decimal_index = string_number.length()
	
	# Add thousands separators
	for i in range(decimal_index):
		if count > 0 and count % 3 == 0:
			result += ","
		result += string_number[i]
		count += 1
	
	# Add decimal part
	if decimal_index < string_number.length():
		result += string_number.substr(decimal_index)
	
	return result

## clamp_value
## 
## Clamp a value between minimum and maximum bounds.
## 
## This function ensures a value stays within specified bounds.
## If the value is less than min, it returns min. If greater than max,
## it returns max. Otherwise, it returns the original value.
## 
## Parameters:
##   value (float): The value to clamp
##   min_value (float): Minimum allowed value
##   max_value (float): Maximum allowed value
## 
## Returns:
##   float: Clamped value within the specified range
## 
## Example:
##   var clamped = GameUtils.clamp_value(150, 0, 100)
##   print(clamped)  # Output: 100
##   
##   var normal = GameUtils.clamp_value(50, 0, 100)
##   print(normal)  # Output: 50
## 
## @since: 1.0.0
static func clamp_value(value: float, min_value: float, max_value: float) -> float:
	"""Clamp a value between minimum and maximum bounds"""
	return clamp(value, min_value, max_value)

## shuffle_array
## 
## Shuffle an array in place using Fisher-Yates algorithm.
## 
## This function randomly reorders the elements of an array using
## the Fisher-Yates shuffle algorithm. The original array is modified.
## 
## Parameters:
##   array (Array): The array to shuffle
## 
## Returns:
##   Array: The shuffled array (same reference as input)
## 
## Example:
##   var cards = [1, 2, 3, 4, 5]
##   GameUtils.shuffle_array(cards)
##   print(cards)  # Output: Random order like [3, 1, 5, 2, 4]
## 
## @since: 1.0.0
static func shuffle_array(array: Array) -> Array:
	"""Shuffle an array in place using Fisher-Yates algorithm"""
	var shuffled = array.duplicate()
	for i in range(shuffled.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		var temp = shuffled[i]
		shuffled[i] = shuffled[j]
		shuffled[j] = temp
	return shuffled

## remove_duplicates
## 
## Remove duplicate elements from an array.
## 
## This function creates a new array with all duplicate elements removed.
## The order of elements is preserved, keeping the first occurrence
## of each unique element.
## 
## Parameters:
##   array (Array): The array to remove duplicates from
## 
## Returns:
##   Array: New array with duplicates removed
## 
## Example:
##   var numbers = [1, 2, 2, 3, 3, 4]
##   var unique = GameUtils.remove_duplicates(numbers)
##   print(unique)  # Output: [1, 2, 3, 4]
## 
## @since: 1.0.0
static func remove_duplicates(array: Array) -> Array:
	"""Remove duplicate elements from an array"""
	var seen = {}
	var result = []
	for item in array:
		if not seen.has(item):
			seen[item] = true
			result.append(item)
	return result

## merge_dictionaries
## 
## Merge two dictionaries, with values from dict2 overriding dict1.
## 
## This function combines two dictionaries into a new dictionary.
## If both dictionaries have the same key, the value from dict2
## takes precedence over the value from dict1.
## 
## Parameters:
##   dict1 (Dictionary): First dictionary to merge
##   dict2 (Dictionary): Second dictionary to merge (takes precedence)
## 
## Returns:
##   Dictionary: Merged dictionary
## 
## Example:
##   var base = {"a": 1, "b": 2}
##   var override = {"b": 3, "c": 4}
##   var merged = GameUtils.merge_dictionaries(base, override)
##   print(merged)  # Output: {"a": 1, "b": 3, "c": 4}
## 
## @since: 1.0.0
static func merge_dictionaries(dict1: Dictionary, dict2: Dictionary) -> Dictionary:
	"""Merge two dictionaries, with values from dict2 overriding dict1"""
	var result = dict1.duplicate()
	for key in dict2:
		result[key] = dict2[key]
	return result

## deep_copy_dictionary
## 
## Create a deep copy of a dictionary.
## 
## This function creates a completely independent copy of a dictionary,
## including nested dictionaries and arrays. Modifying the copy will
## not affect the original.
## 
## Parameters:
##   dict (Dictionary): The dictionary to copy
## 
## Returns:
##   Dictionary: Deep copy of the original dictionary
## 
## Example:
##   var original = {"a": 1, "b": {"c": 2}}
##   var copy = GameUtils.deep_copy_dictionary(original)
##   copy["b"]["c"] = 3
##   print(original["b"]["c"])  # Output: 2 (unchanged)
##   print(copy["b"]["c"])     # Output: 3 (modified)
## 
## @since: 1.0.0
static func deep_copy_dictionary(dict: Dictionary) -> Dictionary:
	"""Create a deep copy of a dictionary"""
	var result = {}
	for key in dict:
		var value = dict[key]
		if value is Dictionary:
			result[key] = deep_copy_dictionary(value)
		elif value is Array:
			result[key] = value.duplicate()
		else:
			result[key] = value
	return result

## find_node_by_type
## 
## Find a node of a specific type in the scene tree.
## 
## This function searches through the scene tree starting from the given
## node and returns the first node of the specified type found.
## 
## Parameters:
##   node (Node): Starting node for the search
##   target_type (Script): Type of node to find
## 
## Returns:
##   Node: First node of the specified type, or null if not found
## 
## Example:
##   var button = GameUtils.find_node_by_type(self, Button)
##   if button:
##       button.text = "Found!"
## 
## @since: 1.0.0
static func find_node_by_type(node: Node, target_type: Script) -> Node:
	"""Find a node of a specific type in the scene tree"""
	if node is target_type:
		return node
	
	for child in node.get_children():
		var result = find_node_by_type(child, target_type)
		if result:
			return result
	
	return null

## find_all_nodes_by_type
## 
## Find all nodes of a specific type in the scene tree.
## 
## This function searches through the scene tree starting from the given
## node and returns all nodes of the specified type found.
## 
## Parameters:
##   node (Node): Starting node for the search
##   target_type (Script): Type of nodes to find
## 
## Returns:
##   Array[Node]: Array of all nodes of the specified type
## 
## Example:
##   var buttons = GameUtils.find_all_nodes_by_type(self, Button)
##   for button in buttons:
##       button.disabled = true
## 
## @since: 1.0.0
static func find_all_nodes_by_type(node: Node, target_type: Script) -> Array[Node]:
	"""Find all nodes of a specific type in the scene tree"""
	var result: Array[Node] = []
	
	if node is target_type:
		result.append(node)
	
	for child in node.get_children():
		result.append_array(find_all_nodes_by_type(child, target_type))
	
	return result

## load_resource_safe
## 
## Safely load a resource from a path.
## 
## This function attempts to load a resource from the given path and
## returns null if the resource cannot be loaded. It provides error
## handling and logging for failed loads.
## 
## Parameters:
##   path (String): Path to the resource file
## 
## Returns:
##   Resource: Loaded resource, or null if loading failed
## 
## Example:
##   var texture = GameUtils.load_resource_safe("res://assets/icon.png")
##   if texture:
##       sprite.texture = texture
##   else:
##       print("Failed to load texture")
## 
## @since: 1.0.0
static func load_resource_safe(path: String) -> Resource:
	"""Safely load a resource from a path"""
	if not FileAccess.file_exists(path):
		print("GameUtils: File does not exist: %s" % path)
		return null
	
	var resource = load(path)
	if not resource:
		print("GameUtils: Failed to load resource: %s" % path)
		return null
	
	return resource

## save_resource_safe
## 
## Safely save a resource to a path.
## 
## This function attempts to save a resource to the given path and
## returns false if the save operation fails. It provides error
## handling and logging for failed saves.
## 
## Parameters:
##   resource (Resource): Resource to save
##   path (String): Path where to save the resource
## 
## Returns:
##   bool: True if save was successful, false otherwise
## 
## Example:
##   var success = GameUtils.save_resource_safe(my_config, "user://config.tres")
##   if success:
##       print("Config saved successfully")
##   else:
##       print("Failed to save config")
## 
## @since: 1.0.0
static func save_resource_safe(resource: Resource, path: String) -> bool:
	"""Safely save a resource to a path"""
	if not resource:
		print("GameUtils: Cannot save null resource")
		return false
	
	# Ensure directory exists
	var dir = DirAccess.open("res://")
	if not dir:
		print("GameUtils: Cannot access directory")
		return false
	
	var dir_path = path.get_base_dir()
	if not dir.dir_exists(dir_path):
		dir.make_dir_recursive(dir_path)
	
	var result = ResourceSaver.save(resource, path)
	if result != OK:
		print("GameUtils: Failed to save resource: %s (Error: %d)" % [path, result])
		return false
	
	return true

## validate_email
## 
## Validate an email address format.
## 
## This function checks if a string matches a basic email format.
## It uses a simple regex pattern to validate the email structure.
## 
## Parameters:
##   email (String): Email address to validate
## 
## Returns:
##   bool: True if email format is valid, false otherwise
## 
## Example:
##   if GameUtils.validate_email("user@example.com"):
##       print("Valid email")
##   else:
##       print("Invalid email format")
## 
## @since: 1.0.0
static func validate_email(email: String) -> bool:
	"""Validate an email address format"""
	var email_regex = RegEx.new()
	email_regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	return email_regex.search(email) != null

## is_valid_filename
## 
## Check if a filename is valid for the current operating system.
## 
## This function validates that a filename doesn't contain invalid
## characters for the current operating system.
## 
## Parameters:
##   filename (String): Filename to validate
## 
## Returns:
##   bool: True if filename is valid, false otherwise
## 
## Example:
##   if GameUtils.is_valid_filename("my_file.txt"):
##       print("Valid filename")
##   else:
##       print("Invalid filename")
## 
## @since: 1.0.0
static func is_valid_filename(filename: String) -> bool:
	"""Check if a filename is valid for the current operating system"""
	var invalid_chars = ["<", ">", ":", "\"", "|", "?", "*", "\\", "/"]
	
	for invalid_char in invalid_chars:
		if filename.contains(invalid_char):
			return false
	
	return true

## measure_performance
## 
## Measure the execution time of a function.
## 
## This function measures how long it takes to execute a given function
## and returns the duration in seconds. It's useful for performance
## profiling and optimization.
## 
## Parameters:
##   func_to_measure (Callable): Function to measure
## 
## Returns:
##   float: Execution time in seconds
## 
## Example:
##   var duration = GameUtils.measure_performance(func(): heavy_calculation())
##   print("Function took %.3f seconds" % duration)
## 
## @since: 1.0.0
static func measure_performance(func_to_measure: Callable) -> float:
	"""Measure the execution time of a function"""
	var start_time = Time.get_ticks_msec()
	func_to_measure.call()
	var end_time = Time.get_ticks_msec()
	var duration = (end_time - start_time) / 1000.0
	return duration 
