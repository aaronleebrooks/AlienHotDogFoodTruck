extends Node
class_name TestResources

## Test script to verify resource classes functionality

# Test instances
var test_config: GameConfig
var test_hot_dog: HotDog

func _ready() -> void:
	print("TestResources: Starting resource tests...")
	_run_tests()

func _run_tests() -> void:
	_test_game_config()
	_test_hot_dog()
	print("TestResources: All resource tests completed!")

func _test_game_config() -> void:
	print("\n--- Testing GameConfig ---")
	
	# Create test config
	test_config = GameConfig.new()
	test_config.game_name = "Test Hot Dog Game"
	test_config.starting_money = 200.0
	test_config.hot_dog_price = 7.5
	test_config.base_production_rate = 2.0
	test_config.max_queue_size = 15
	
	# Test loading
	var success = test_config.load_resource()
	print("Config loaded: %s" % success)
	print("Config ready: %s" % test_config.is_resource_ready())
	
	# Test validation
	var valid = test_config.validate_config()
	print("Config valid: %s" % valid)
	
	# Test info
	var info = test_config.get_config_info()
	print("Config info: %s" % info)
	
	# Test tags
	print("Has 'config' tag: %s" % test_config.has_tag("config"))
	print("Has 'game_settings' tag: %s" % test_config.has_tag("game_settings"))
	
	# Test save/load
	var save_success = test_config.save_config()
	print("Config saved: %s" % save_success)
	
	print("GameConfig tests passed!")

func _test_hot_dog() -> void:
	print("\n--- Testing HotDog ---")
	
	# Create test hot dog
	test_hot_dog = HotDog.new()
	test_hot_dog.hot_dog_name = "Premium Bacon Dog"
	test_hot_dog.price = 8.0
	test_hot_dog.quality = 0.9
	test_hot_dog.cooking_time = 3.0
	test_hot_dog.ingredients = ["bun", "sausage", "bacon", "cheese", "mustard"]
	test_hot_dog.is_premium = true
	test_hot_dog.unlock_level = 5
	
	# Test loading
	var success = test_hot_dog.load_resource()
	print("Hot dog loaded: %s" % success)
	print("Hot dog ready: %s" % test_hot_dog.is_resource_ready())
	
	# Test validation
	var valid = test_hot_dog.validate_hot_dog()
	print("Hot dog valid: %s" % valid)
	
	# Test info
	var info = test_hot_dog.get_hot_dog_info()
	print("Hot dog info: %s" % info)
	
	# Test production and sales
	test_hot_dog.produce()
	test_hot_dog.produce()
	test_hot_dog.produce()
	
	var revenue = test_hot_dog.sell()
	print("Sold hot dog for: $%.2f" % revenue)
	
	# Test ratings
	test_hot_dog.add_rating(4.5)
	test_hot_dog.add_rating(5.0)
	test_hot_dog.add_rating(4.0)
	
	# Test calculations
	var satisfaction = test_hot_dog.calculate_satisfaction()
	print("Customer satisfaction: %.2f" % satisfaction)
	
	var cost = test_hot_dog.get_production_cost()
	print("Production cost: $%.2f" % cost)
	
	var profit = test_hot_dog.get_profit_margin()
	print("Profit margin: $%.2f" % profit)
	
	# Test unlock system
	print("Unlocked at level 3: %s" % test_hot_dog.is_unlocked(3))
	print("Unlocked at level 5: %s" % test_hot_dog.is_unlocked(5))
	print("Unlocked at level 7: %s" % test_hot_dog.is_unlocked(7))
	
	# Test tags
	print("Has 'food' tag: %s" % test_hot_dog.has_tag("food"))
	print("Has 'hot_dog' tag: %s" % test_hot_dog.has_tag("hot_dog"))
	print("Has 'consumable' tag: %s" % test_hot_dog.has_tag("consumable"))
	
	print("HotDog tests passed!")

func _exit_tree() -> void:
	"""Cleanup test instances"""
	if test_config:
		test_config.queue_free()
	if test_hot_dog:
		test_hot_dog.queue_free()
	print("TestResources: Cleanup completed") 