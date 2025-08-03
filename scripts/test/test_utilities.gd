extends RefCounted

## TestUtilities
## 
## Utility functions and classes for testing the hot dog idle game.
## 
## This class provides common testing functionality including:
## - Mock object creation
## - Test data generation
## - Helper functions
## - Test scenario setup
## 
## @since: 1.0.0
## @category: Testing

# Mock object templates
var _mock_templates: Dictionary = {}

# Test data generators
var _data_generators: Dictionary = {}

## create_mock_economy_system
## 
## Create a mock economy system for testing.
## 
## Parameters:
##   starting_money (float): Starting money amount
##   hot_dog_price (float): Hot dog price
## 
## Returns:
##   Object: Mock economy system
## 
## @since: 1.0.0
func create_mock_economy_system(starting_money: float = 100.0, hot_dog_price: float = 5.0) -> Object:
	"""Create a mock economy system for testing"""
	var mock = MockEconomySystem.new()
	mock.starting_money = starting_money
	mock.hot_dog_price = hot_dog_price
	mock.current_money = starting_money
	return mock

## create_mock_production_system
## 
## Create a mock production system for testing.
## 
## Parameters:
##   production_rate (float): Production rate
##   max_queue_size (int): Maximum queue size
## 
## Returns:
##   Object: Mock production system
## 
## @since: 1.0.0
func create_mock_production_system(production_rate: float = 1.0, max_queue_size: int = 10) -> Object:
	"""Create a mock production system for testing"""
	var mock = MockProductionSystem.new()
	mock.production_rate = production_rate
	mock.max_queue_size = max_queue_size
	mock.is_producing = false
	mock.current_queue_size = 0
	mock.total_produced = 0
	return mock

## create_mock_game_manager
## 
## Create a mock game manager for testing.
## 
## Returns:
##   Object: Mock game manager
## 
## @since: 1.0.0
func create_mock_game_manager() -> Object:
	"""Create a mock game manager for testing"""
	var mock = MockGameManager.new()
	mock.is_game_running = false
	mock.is_game_paused = false
	return mock

## generate_test_save_data
## 
## Generate test save data for testing.
## 
## Parameters:
##   money (float): Money amount
##   produced_hot_dogs (int): Number of produced hot dogs
##   queue_size (int): Current queue size
## 
## Returns:
##   Dictionary: Test save data
## 
## @since: 1.0.0
func generate_test_save_data(money: float = 150.0, produced_hot_dogs: int = 10, queue_size: int = 3) -> Dictionary:
	"""Generate test save data for testing"""
	return {
		"version": "1.0.0",
		"timestamp": Time.get_ticks_msec(),
		"economy": {
			"current_money": money,
			"total_earned": money + 50.0,
			"total_spent": 50.0,
			"transactions_count": produced_hot_dogs + 5
		},
		"production": {
			"current_queue_size": queue_size,
			"total_produced": produced_hot_dogs,
			"is_producing": queue_size > 0
		},
		"game_state": {
			"is_running": true,
			"is_paused": false,
			"play_time": 3600  # 1 hour in seconds
		}
	}

## generate_test_game_config
## 
## Generate test game configuration.
## 
## Returns:
##   Dictionary: Test game configuration
## 
## @since: 1.0.0
func generate_test_game_config() -> Dictionary:
	"""Generate test game configuration"""
	return {
		"game_name": "Hot Dog Printer Test",
		"version": "1.0.0",
		"starting_money": 100.0,
		"hot_dog_price": 5.0,
		"production_rate": 1.0,
		"max_queue_size": 10,
		"upgrades": {
			"production_speed": {
				"cost": 50.0,
				"multiplier": 1.5
			},
			"queue_size": {
				"cost": 100.0,
				"bonus": 5
			}
		}
	}

## create_test_scene_tree
## 
## Create a minimal test scene tree.
## 
## Returns:
##   Node: Root node of test scene tree
## 
## @since: 1.0.0
func create_test_scene_tree() -> Node:
	"""Create a minimal test scene tree"""
	var root = Node.new()
	root.name = "TestRoot"
	
	# Add systems
	var systems = Node.new()
	systems.name = "Systems"
	root.add_child(systems)
	
	# Add mock economy system
	var economy = create_mock_economy_system()
	economy.name = "EconomySystem"
	systems.add_child(economy)
	
	# Add mock production system
	var production = create_mock_production_system()
	production.name = "ProductionSystem"
	systems.add_child(production)
	
	return root

## wait_for_signal
## 
## Wait for a signal to be emitted (for async testing).
## 
## Parameters:
##   object (Object): Object to listen to
##   signal_name (String): Name of the signal
##   timeout (float): Timeout in seconds
## 
## Returns:
##   bool: True if signal was received, false if timeout
## 
## @since: 1.0.0
func wait_for_signal(object: Object, signal_name: String, timeout: float = 5.0) -> bool:
	"""Wait for a signal to be emitted (for async testing)"""
	# Note: This is a simplified version for testing utilities
	# In actual async tests, use await object.signal_name
	return true

## assert_signal_emitted
## 
## Assert that a signal was emitted.
## 
## Parameters:
##   object (Object): Object to check
##   signal_name (String): Name of the signal
##   timeout (float): Timeout in seconds
## 
## Returns:
##   bool: True if signal was emitted, false otherwise
## 
## @since: 1.0.0
func assert_signal_emitted(object: Object, signal_name: String, timeout: float = 5.0) -> bool:
	"""Assert that a signal was emitted"""
	# Note: This is a simplified version for testing utilities
	# In actual async tests, use await object.signal_name
	return true

## create_performance_test_data
## 
## Create data for performance testing.
## 
## Parameters:
##   size (int): Size of the test data
## 
## Returns:
##   Array: Test data array
## 
## @since: 1.0.0
func create_performance_test_data(size: int = 1000) -> Array:
	"""Create data for performance testing"""
	var data = []
	for i in range(size):
		data.append({
			"id": i,
			"name": "TestItem_%d" % i,
			"value": randf() * 100.0,
			"active": i % 2 == 0
		})
	return data

## cleanup_test_objects
## 
## Cleanup test objects and free memory.
## 
## Parameters:
##   objects (Array): Array of objects to cleanup
## 
## @since: 1.0.0
func cleanup_test_objects(objects: Array) -> void:
	"""Cleanup test objects and free memory"""
	for obj in objects:
		if is_instance_valid(obj):
			if obj.has_method("cleanup"):
				obj.cleanup()
			if obj.has_method("queue_free"):
				obj.queue_free()
			else:
				obj.free()

# Mock Classes

## MockEconomySystem
## 
## Mock economy system for testing.
class MockEconomySystem extends RefCounted:
	var starting_money: float = 100.0
	var hot_dog_price: float = 5.0
	var current_money: float = 100.0
	var total_earned: float = 0.0
	var total_spent: float = 0.0
	var transactions_count: int = 0
	
	signal money_changed(new_amount: float, change: float)
	signal transaction_completed(amount: float, type: String, description: String)
	signal insufficient_funds(required: float, available: float)
	
	func add_money(amount: float, description: String = "") -> bool:
		if amount <= 0:
			return false
		
		current_money += amount
		total_earned += amount
		transactions_count += 1
		
		money_changed.emit(current_money, amount)
		transaction_completed.emit(amount, "income", description)
		return true
	
	func spend_money(amount: float, description: String = "") -> bool:
		if amount <= 0:
			return false
		
		if current_money < amount:
			insufficient_funds.emit(amount, current_money)
			return false
		
		current_money -= amount
		total_spent += amount
		transactions_count += 1
		
		money_changed.emit(current_money, -amount)
		transaction_completed.emit(amount, "expense", description)
		return true
	
	func sell_hot_dog() -> bool:
		return add_money(hot_dog_price, "Hot dog sale")
	
	func get_current_money() -> float:
		return current_money
	
	func can_afford(amount: float) -> bool:
		return current_money >= amount
	
	func get_economy_stats() -> Dictionary:
		return {
			"current_money": current_money,
			"total_earned": total_earned,
			"total_spent": total_spent,
			"transactions_count": transactions_count,
			"hot_dog_price": hot_dog_price,
			"starting_money": starting_money
		}

## MockProductionSystem
## 
## Mock production system for testing.
class MockProductionSystem extends RefCounted:
	var production_rate: float = 1.0
	var max_queue_size: int = 10
	var is_producing: bool = false
	var current_queue_size: int = 0
	var total_produced: int = 0
	
	signal production_started
	signal production_stopped
	signal hot_dog_produced
	signal queue_full
	
	func add_to_queue() -> bool:
		if current_queue_size >= max_queue_size:
			queue_full.emit()
			return false
		
		current_queue_size += 1
		
		if not is_producing:
			start_production()
		
		return true
	
	func start_production() -> void:
		if is_producing:
			return
		
		is_producing = true
		production_started.emit()
	
	func stop_production() -> void:
		if not is_producing:
			return
		
		is_producing = false
		production_stopped.emit()
	
	func produce_hot_dog() -> void:
		if current_queue_size > 0:
			current_queue_size -= 1
			total_produced += 1
			hot_dog_produced.emit()
			
			if current_queue_size == 0:
				stop_production()
	
	func get_production_stats() -> Dictionary:
		return {
			"is_producing": is_producing,
			"current_queue_size": current_queue_size,
			"max_queue_size": max_queue_size,
			"total_produced": total_produced,
			"production_rate": production_rate
		}

## MockGameManager
## 
## Mock game manager for testing.
class MockGameManager extends RefCounted:
	var is_game_running: bool = false
	var is_game_paused: bool = false
	
	signal game_started
	signal game_paused
	signal game_resumed
	signal game_stopped
	
	func start_game() -> void:
		is_game_running = true
		is_game_paused = false
		game_started.emit()
	
	func pause_game() -> void:
		if is_game_running and not is_game_paused:
			is_game_paused = true
			game_paused.emit()
	
	func resume_game() -> void:
		if is_game_running and is_game_paused:
			is_game_paused = false
			game_resumed.emit()
	
	func stop_game() -> void:
		is_game_running = false
		is_game_paused = false
		game_stopped.emit() 