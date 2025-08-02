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

# Signals
signal add_hot_dog_to_queue_requested

func _ready() -> void:
	"""Initialize the main scene"""
	print("MainScene: Initialized")
	print("MainScene: ProductionSystem reference: %s" % production_system)
	print("MainScene: EconomySystem reference: %s" % economy_system)
	
	# Print scene tree for debugging
	print("MainScene: Scene tree structure:")
	_print_scene_tree(self, 0)
	
	# Connect UIManager signals
	UIManager.screen_changed.connect(_on_screen_changed)
	
	# Connect system signals
	production_system.hot_dog_produced.connect(_on_hot_dog_produced)
	economy_system.money_changed.connect(_on_money_changed)
	
	# Connect UI signals
	add_hot_dog_to_queue_requested.connect(_on_add_hot_dog_requested)
	
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

func get_production_system() -> Node:
	"""Get reference to production system"""
	if production_system:
		return production_system
	else:
		print("MainScene: Warning - ProductionSystem not found")
		return null

func get_economy_system() -> Node:
	"""Get reference to economy system"""
	if economy_system:
		return economy_system
	else:
		print("MainScene: Warning - EconomySystem not found")
		return null

func _print_scene_tree(node: Node, depth: int) -> void:
	"""Print the scene tree structure for debugging"""
	var indent = "  ".repeat(depth)
	var node_info = "%s%s (%s)" % [indent, node.name, node.get_class()]
	if node.has_method("get_script") and node.get_script():
		node_info += " [Script: %s]" % node.get_script().resource_path.get_file()
	print(node_info)
	
	for child in node.get_children():
		_print_scene_tree(child, depth + 1)

func _on_add_hot_dog_requested() -> void:
	"""Handle add hot dog request from UI"""
	print("MainScene: Add hot dog requested")
	production_system.add_to_queue() 
