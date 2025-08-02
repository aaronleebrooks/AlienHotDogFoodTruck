extends Control

## Main scene controller for managing UI transitions and game state

# UI references
@onready var ui_container: Control = $UI
@onready var game_ui: Control = $UI/GameUI
@onready var menu_ui: Control = $UI/MenuUI
@onready var settings_ui: Control = $UI/SettingsUI
@onready var loading_ui: Control = $UI/LoadingUI

# System references
@onready var production_system: Node = $Systems/ProductionSystem
@onready var economy_system: Node = $Systems/EconomySystem

# Current active UI
var current_ui: Control

func _ready() -> void:
	"""Initialize the main scene"""
	print("MainScene: Initialized")
	
	# Connect UIManager signals
	UIManager.screen_changed.connect(_on_screen_changed)
	
	# Connect system signals
	production_system.hot_dog_produced.connect(_on_hot_dog_produced)
	economy_system.money_changed.connect(_on_money_changed)
	
	# Show initial UI (menu)
	show_ui("menu")

func show_ui(ui_name: String) -> void:
	"""Show a specific UI screen"""
	# Hide current UI
	if current_ui:
		current_ui.visible = false
	
	# Show new UI
	match ui_name:
		"menu":
			current_ui = menu_ui
		"game":
			current_ui = game_ui
		"settings":
			current_ui = settings_ui
		"loading":
			current_ui = loading_ui
		_:
			print("MainScene: Unknown UI: %s" % ui_name)
			return
	
	current_ui.visible = true
	print("MainScene: Showing UI: %s" % ui_name)

func _on_screen_changed(new_screen: String, old_screen: String) -> void:
	"""Handle screen changes from UIManager"""
	print("MainScene: Screen changed from '%s' to '%s'" % [old_screen, new_screen])
	show_ui(new_screen)

func _on_hot_dog_produced() -> void:
	"""Handle hot dog production"""
	print("MainScene: Hot dog produced")
	economy_system.sell_hot_dog()

func _on_money_changed(new_amount: float, change: float) -> void:
	"""Handle money changes"""
	print("MainScene: Money changed by $%.2f. New total: $%.2f" % [change, new_amount]) 