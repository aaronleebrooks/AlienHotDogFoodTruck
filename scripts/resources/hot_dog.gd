extends BaseResource

## Hot Dog resource for representing hot dog items in the game

# Hot dog properties
@export var hot_dog_name: String = "Classic Hot Dog"
@export var price: float = 5.0
@export var quality: float = 1.0  # 0.0 to 1.0
@export var cooking_time: float = 2.0  # seconds
@export var ingredients: Array[String] = ["bun", "sausage", "mustard", "ketchup"]

# Visual properties
@export var texture: Texture2D
@export var color: Color = Color.WHITE
@export var size: Vector2 = Vector2(64, 64)

# Gameplay properties
@export var satisfaction_bonus: float = 1.0
@export var energy_value: float = 100.0
@export var is_premium: bool = false
@export var unlock_level: int = 1

# Statistics
var times_produced: int = 0
var times_sold: int = 0
var total_revenue: float = 0.0
var average_rating: float = 0.0

func _init() -> void:
	"""Initialize the hot dog resource"""
	custom_resource_name = "HotDog"
	description = "A delicious hot dog for customers to enjoy"
	add_tag("food")
	add_tag("hot_dog")
	add_tag("consumable")

func _load_resource_data() -> bool:
	"""Load hot dog data"""
	print("HotDog: Loading hot dog data for %s" % hot_dog_name)
	
	# Validate hot dog properties
	if not validate_hot_dog():
		log_error("Invalid hot dog properties")
		return false
	
	print("HotDog: Hot dog data loaded successfully")
	return true

func validate_hot_dog() -> bool:
	"""Validate hot dog properties"""
	if hot_dog_name.is_empty():
		log_error("Hot dog name cannot be empty")
		return false
	
	if price < 0:
		log_error("Price cannot be negative")
		return false
	
	if quality < 0 or quality > 1:
		log_error("Quality must be between 0 and 1")
		return false
	
	if cooking_time <= 0:
		log_error("Cooking time must be positive")
		return false
	
	if ingredients.is_empty():
		log_error("Hot dog must have at least one ingredient")
		return false
	
	return true

func get_hot_dog_info() -> Dictionary:
	"""Get hot dog information"""
	return {
		"name": hot_dog_name,
		"price": price,
		"quality": quality,
		"cooking_time": cooking_time,
		"ingredients": ingredients,
		"is_premium": is_premium,
		"unlock_level": unlock_level,
		"times_produced": times_produced,
		"times_sold": times_sold,
		"total_revenue": total_revenue,
		"average_rating": average_rating
	}

func produce() -> void:
	"""Mark hot dog as produced"""
	times_produced += 1
	access_resource()
	print("HotDog: Produced %s (Total: %d)" % [hot_dog_name, times_produced])

func sell() -> float:
	"""Mark hot dog as sold and return revenue"""
	times_sold += 1
	total_revenue += price
	access_resource()
	print("HotDog: Sold %s for $%.2f (Total sold: %d)" % [hot_dog_name, price, times_sold])
	return price

func add_rating(rating: float) -> void:
	"""Add a customer rating"""
	if rating < 0 or rating > 5:
		log_error("Rating must be between 0 and 5")
		return
	
	# Calculate new average rating
	var total_ratings = times_sold
	if total_ratings > 0:
		average_rating = ((average_rating * (total_ratings - 1)) + rating) / total_ratings
	else:
		average_rating = rating
	
	print("HotDog: Added rating %.1f for %s (Average: %.2f)" % [rating, hot_dog_name, average_rating])

func calculate_satisfaction() -> float:
	"""Calculate customer satisfaction based on quality and other factors"""
	var satisfaction = quality * satisfaction_bonus
	
	# Premium hot dogs get a bonus
	if is_premium:
		satisfaction *= 1.2
	
	# Factor in average rating
	if average_rating > 0:
		satisfaction *= (average_rating / 5.0)
	
	return satisfaction

func is_unlocked(player_level: int) -> bool:
	"""Check if hot dog is unlocked for player level"""
	return player_level >= unlock_level

func get_production_cost() -> float:
	"""Calculate production cost based on ingredients and quality"""
	var base_cost = 1.0  # Base cost for basic ingredients
	
	# Add cost for each ingredient
	for ingredient in ingredients:
		match ingredient:
			"bun":
				base_cost += 0.5
			"sausage":
				base_cost += 1.0
			"mustard", "ketchup":
				base_cost += 0.2
			"cheese":
				base_cost += 0.8
			"bacon":
				base_cost += 1.5
			_:
				base_cost += 0.3  # Default ingredient cost
	
	# Quality affects cost
	base_cost *= (1.0 + quality)
	
	return base_cost

func get_profit_margin() -> float:
	"""Calculate profit margin"""
	var cost = get_production_cost()
	return price - cost 