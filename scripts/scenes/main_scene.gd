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

# Signal connection tracking
var signal_connections: Array[String] = []

func _ready() -> void:
	"""Initialize the main scene"""
	print("MainScene: Initialized")
	print("MainScene: ProductionSystem reference: %s" % production_system)
	print("MainScene: EconomySystem reference: %s" % economy_system)
	
	# Print scene tree for debugging
	print("MainScene: Scene tree structure:")
	_print_scene_tree(self, 0)
	
	# Set up signal connections using SignalUtils
	setup_signal_connections()
	
	# Show initial UI (menu)
	show_ui("menu")

func setup_signal_connections() -> void:
	"""Set up all signal connections using SignalUtils"""
	print("MainScene: Setting up signal connections...")
	
	# Connect UIManager signals
	signal_connections.append(SignalUtils.connect_signal(UIManager, "screen_changed", _on_screen_changed))
	
	# Connect SaveManager signals
	signal_connections.append(SignalUtils.connect_signal(SaveManager, "load_completed", _on_save_load_completed))
	signal_connections.append(SignalUtils.connect_signal(SaveManager, "load_failed", _on_save_load_failed))
	
	# Connect system signals
	if production_system:
		signal_connections.append(SignalUtils.connect_signal(production_system, "hot_dog_produced", _on_hot_dog_produced))
	else:
		print("MainScene: WARNING - ProductionSystem not found for signal connection!")
	
	if economy_system:
		signal_connections.append(SignalUtils.connect_signal(economy_system, "money_changed", _on_money_changed))
	else:
		print("MainScene: WARNING - EconomySystem not found for signal connection!")
	
	# Connect to EventBus for upgrade button updates
	EventBus.register_listener("upgrade_buttons_update_requested", _on_upgrade_buttons_update_requested)
	
	# Connect GameUI signals
	signal_connections.append(SignalUtils.connect_signal(game_ui, "add_hot_dog_requested", _on_add_hot_dog_requested))
	signal_connections.append(SignalUtils.connect_signal(game_ui, "pause_game_requested", _on_pause_game_requested))
	signal_connections.append(SignalUtils.connect_signal(game_ui, "save_game_requested", _on_save_game_requested))
	signal_connections.append(SignalUtils.connect_signal(game_ui, "menu_requested", _on_menu_requested))
	signal_connections.append(SignalUtils.connect_signal(game_ui, "upgrade_rate_requested", _on_upgrade_rate_requested))
	signal_connections.append(SignalUtils.connect_signal(game_ui, "upgrade_capacity_requested", _on_upgrade_capacity_requested))
	signal_connections.append(SignalUtils.connect_signal(game_ui, "upgrade_efficiency_requested", _on_upgrade_efficiency_requested))
	
	# Connect MenuUI signals
	signal_connections.append(SignalUtils.connect_signal(menu_ui, "start_game_requested", _on_start_game_requested))
	signal_connections.append(SignalUtils.connect_signal(menu_ui, "continue_game_requested", _on_continue_game_requested))
	signal_connections.append(SignalUtils.connect_signal(menu_ui, "settings_requested", _on_settings_requested))
	signal_connections.append(SignalUtils.connect_signal(menu_ui, "quit_game_requested", _on_quit_game_requested))
	
	print("MainScene: Signal connections set up. Total connections: %d" % signal_connections.size())

func _exit_tree() -> void:
	"""Clean up when scene is removed"""
	print("MainScene: Cleaning up signal connections...")
	
	# Disconnect all tracked signals
	for connection_id in signal_connections:
		SignalUtils.disconnect_signal(connection_id)
	
	signal_connections.clear()
	
	# Unregister EventBus listeners
	EventBus.unregister_listener("upgrade_buttons_update_requested")
	
	print("MainScene: Signal cleanup and EventBus cleanup completed")

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

# Helper methods for UI components to access systems
func get_economy_system() -> Node:
	"""Get reference to EconomySystem"""
	return economy_system

func get_production_system() -> Node:
	"""Get reference to ProductionSystem"""
	return production_system

func _on_screen_changed(new_screen: String, old_screen: String) -> void:
	"""Handle screen changes from UIManager"""
	print("MainScene: Screen changed from '%s' to '%s'" % [old_screen, new_screen])
	show_ui(new_screen)

func _on_hot_dog_produced() -> void:
	"""Handle hot dog production"""
	print("MainScene: Hot dog produced")
	
	# Add money for the sold hot dog
	if economy_system:
		var hot_dog_price = economy_system.hot_dog_price
		economy_system.add_money(hot_dog_price, "Hot dog sold")
		print("MainScene: Added $%.2f for hot dog sale" % hot_dog_price)
		# Note: Upgrade buttons will update automatically via event when money_changed is emitted
	else:
		print("MainScene: WARNING - EconomySystem not found!")

func _on_money_changed(new_amount: float, change: float) -> void:
	"""Handle money changes"""
	print("MainScene: Money changed by $%.2f. New total: $%.2f" % [change, new_amount])

# Save/Load signal handlers
func _on_save_load_completed() -> void:
	"""Handle save/load completion"""
	print("MainScene: Save/load completed successfully")
	SaveManager.restore_game_state()
	GameManager.start_game()
	UIManager.show_screen("game")
	
	# Refresh UI to show restored state
	_refresh_ui_after_load()

func _refresh_ui_after_load() -> void:
	"""Refresh UI elements to show restored game state"""
	print("MainScene: Refreshing UI after load")
	
	# Update money display
	if economy_system:
		var current_money = economy_system.get_current_money()
		game_ui.update_money_display(current_money)
		print("MainScene: Updated money display to $%.2f" % current_money)
	else:
		print("MainScene: WARNING - EconomySystem not found!")
	
	# Update production display
	if production_system:
		var production_stats = production_system.get_production_statistics()
		var queue_status = production_system.get_queue_status()
		game_ui.update_production_info(production_stats["total_produced"])
		game_ui.update_queue_info(queue_status["current_size"], queue_status["max_size"])
		print("MainScene: Updated production display - Produced: " + str(production_stats["total_produced"]) + ", Queue: " + str(queue_status["current_size"]) + "/" + str(queue_status["max_size"]))
		
		# Update upgrade buttons
		_update_upgrade_buttons()
	else:
		print("MainScene: WARNING - ProductionSystem not found!")

func _on_save_load_failed() -> void:
	"""Handle save/load failure"""
	print("MainScene: Save/load failed")

# Signal handlers for MenuUI
func _on_start_game_requested() -> void:
	"""Handle start game request from menu"""
	print("MainScene: Start game requested")
	GameManager.start_game()
	UIManager.show_screen("game")
	
	# Refresh UI to show initial game state
	_refresh_ui_after_load()

func _on_continue_game_requested() -> void:
	"""Handle continue game request from menu"""
	print("MainScene: Continue game requested")
	SaveManager.load_game()
	# Game will be started after load completion in _on_save_load_completed

func _on_settings_requested() -> void:
	"""Handle settings request from menu"""
	print("MainScene: Settings requested")
	UIManager.show_screen("settings")

func _on_quit_game_requested() -> void:
	"""Handle quit game request from menu"""
	print("MainScene: Quit game requested")
	get_tree().quit()

# Signal handlers for GameUI
func _on_add_hot_dog_requested() -> void:
	"""Handle add hot dog request from UI"""
	print("MainScene: Add hot dog requested")
	if production_system:
		production_system.add_to_queue()
	else:
		print("MainScene: ERROR - ProductionSystem not found!")

func _on_pause_game_requested() -> void:
	"""Handle pause game request from UI"""
	print("MainScene: Pause game requested")
	if GameManager.is_game_running:
		GameManager.pause_game()
	else:
		GameManager.resume_game()

func _on_save_game_requested() -> void:
	"""Handle save game request from UI"""
	print("MainScene: Save game requested")
	SaveManager.save_game()

func _on_menu_requested() -> void:
	"""Handle menu request from UI"""
	print("MainScene: Menu requested")
	UIManager.show_screen("menu")

func _on_upgrade_rate_requested() -> void:
	"""Handle upgrade rate request from UI"""
	print("MainScene: Upgrade rate requested")
	if production_system:
		production_system.upgrade_production_rate()
		_update_upgrade_buttons()
	else:
		print("MainScene: ERROR - ProductionSystem not found!")

func _on_upgrade_capacity_requested() -> void:
	"""Handle upgrade capacity request from UI"""
	print("MainScene: Upgrade capacity requested")
	if production_system:
		production_system.upgrade_capacity()
		_update_upgrade_buttons()
	else:
		print("MainScene: ERROR - ProductionSystem not found!")

func _on_upgrade_efficiency_requested() -> void:
	"""Handle upgrade efficiency request from UI"""
	print("MainScene: Upgrade efficiency requested")
	if production_system:
		production_system.upgrade_efficiency()
		_update_upgrade_buttons()
	else:
		print("MainScene: ERROR - ProductionSystem not found!")

func _update_upgrade_buttons() -> void:
	"""Update upgrade buttons with current costs and affordability"""
	if not production_system or not game_ui:
		return
	
	var upgrade_costs = production_system.get_upgrade_costs()
	var can_afford = {
		"rate": production_system.can_afford_upgrade("rate"),
		"capacity": production_system.can_afford_upgrade("capacity"),
		"efficiency": production_system.can_afford_upgrade("efficiency")
	}
	
	game_ui.update_upgrade_buttons(upgrade_costs, can_afford)

func _on_upgrade_buttons_update_requested(event_data: Dictionary) -> void:
	"""Handle event-driven upgrade button update requests"""
	print("MainScene: Received upgrade button update request (event-driven)")
	_update_upgrade_buttons()

func _print_scene_tree(node: Node, depth: int) -> void:
	"""Print the scene tree structure for debugging"""
	var indent = "  ".repeat(depth)
	var node_info = "%s%s (%s)" % [indent, node.name, node.get_class()]
	if node.has_method("get_script") and node.get_script():
		node_info += " [Script: %s]" % node.get_script().resource_path.get_file()
	print(node_info)
	
	for child in node.get_children():
		_print_scene_tree(child, depth + 1)

 
