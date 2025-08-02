extends BaseResource

## Game configuration resource for storing game settings and parameters

# Game settings
@export var game_name: String = "Hot Dog Printer"
@export var game_version: String = "1.0.0"
@export var starting_money: float = 100.0
@export var hot_dog_price: float = 5.0

# Production settings
@export var base_production_rate: float = 1.0  # Hot dogs per second
@export var max_queue_size: int = 10
@export var production_upgrade_cost: float = 50.0

# Economy settings
@export var money_multiplier: float = 1.0
@export var price_inflation_rate: float = 0.1
@export var max_money: float = 999999.0

# UI settings
@export var ui_scale: float = 1.0
@export var show_debug_info: bool = false
@export var auto_save_interval: float = 30.0  # seconds

# Audio settings
@export var master_volume: float = 1.0
@export var music_volume: float = 0.7
@export var sfx_volume: float = 0.8
@export var enable_sound: bool = true

func _init() -> void:
	"""Initialize the game config resource"""
	custom_resource_name = "GameConfig"
	description = "Configuration settings for the Hot Dog Printer game"
	add_tag("config")
	add_tag("game_settings")

func _load_resource_data() -> bool:
	"""Load game configuration data"""
	print("GameConfig: Loading game configuration...")
	
	# Validate configuration values
	if not validate_config():
		log_error("Invalid configuration values")
		return false
	
	print("GameConfig: Configuration loaded successfully")
	return true

func validate_config() -> bool:
	"""Validate configuration values"""
	if starting_money < 0:
		log_error("Starting money cannot be negative")
		return false
	
	if hot_dog_price <= 0:
		log_error("Hot dog price must be positive")
		return false
	
	if base_production_rate <= 0:
		log_error("Production rate must be positive")
		return false
	
	if max_queue_size <= 0:
		log_error("Max queue size must be positive")
		return false
	
	if ui_scale <= 0:
		log_error("UI scale must be positive")
		return false
	
	if master_volume < 0 or master_volume > 1:
		log_error("Master volume must be between 0 and 1")
		return false
	
	return true

func get_config_info() -> Dictionary:
	"""Get configuration information"""
	return {
		"game_name": game_name,
		"game_version": game_version,
		"starting_money": starting_money,
		"hot_dog_price": hot_dog_price,
		"base_production_rate": base_production_rate,
		"max_queue_size": max_queue_size,
		"ui_scale": ui_scale,
		"master_volume": master_volume
	}

func save_config() -> bool:
	"""Save configuration to file"""
	var config_path = "user://game_config.tres"
	return GameUtils.save_resource_safe(self, config_path)

func load_config() -> bool:
	"""Load configuration from file"""
	var config_path = "user://game_config.tres"
	var loaded_config = GameUtils.load_resource_safe(config_path)
	if loaded_config:
		# Copy values from loaded config
		game_name = loaded_config.game_name
		game_version = loaded_config.game_version
		starting_money = loaded_config.starting_money
		hot_dog_price = loaded_config.hot_dog_price
		base_production_rate = loaded_config.base_production_rate
		max_queue_size = loaded_config.max_queue_size
		production_upgrade_cost = loaded_config.production_upgrade_cost
		money_multiplier = loaded_config.money_multiplier
		price_inflation_rate = loaded_config.price_inflation_rate
		max_money = loaded_config.max_money
		ui_scale = loaded_config.ui_scale
		show_debug_info = loaded_config.show_debug_info
		auto_save_interval = loaded_config.auto_save_interval
		master_volume = loaded_config.master_volume
		music_volume = loaded_config.music_volume
		sfx_volume = loaded_config.sfx_volume
		enable_sound = loaded_config.enable_sound
		return true
	return false 