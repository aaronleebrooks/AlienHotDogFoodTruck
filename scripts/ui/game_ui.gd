extends Control

## Game UI controller for handling game interface interactions

# UI element references
@onready var money_label: Label = $TopBar/MoneyLabel
@onready var time_label: Label = $TopBar/TimeLabel
@onready var menu_button: Button = $TopBar/MenuButton
@onready var status_label: Label = $GameArea/VBoxContainer/StatusLabel
@onready var pause_button: Button = $GameArea/VBoxContainer/PauseButton
@onready var save_button: Button = $GameArea/VBoxContainer/SaveButton
@onready var add_hot_dog_button: Button = $GameArea/VBoxContainer/AddHotDogButton
@onready var upgrade_rate_button: Button = $GameArea/VBoxContainer/UpgradeSection/UpgradeRateButton
@onready var upgrade_capacity_button: Button = $GameArea/VBoxContainer/UpgradeSection/UpgradeCapacityButton
@onready var upgrade_efficiency_button: Button = $GameArea/VBoxContainer/UpgradeSection/UpgradeEfficiencyButton

# Signals - UI emits these, main scene listens
signal add_hot_dog_requested
signal pause_game_requested
signal save_game_requested
signal menu_requested
signal upgrade_rate_requested
signal upgrade_capacity_requested
signal upgrade_efficiency_requested

# Signal connection tracking
var signal_connections: Array[String] = []

func _ready() -> void:
	"""Initialize the game UI"""
	print("GameUI: Initialized")
	
	# Set up signal connections using SignalUtils
	setup_signal_connections()

func setup_signal_connections() -> void:
	"""Set up all signal connections using SignalUtils"""
	print("GameUI: Setting up signal connections...")
	
	# Connect button signals
	signal_connections.append(SignalUtils.connect_signal(menu_button, "pressed", _on_menu_pressed))
	signal_connections.append(SignalUtils.connect_signal(pause_button, "pressed", _on_pause_pressed))
	signal_connections.append(SignalUtils.connect_signal(save_button, "pressed", _on_save_pressed))
	signal_connections.append(SignalUtils.connect_signal(add_hot_dog_button, "pressed", _on_add_hot_dog_pressed))
	signal_connections.append(SignalUtils.connect_signal(upgrade_rate_button, "pressed", _on_upgrade_rate_pressed))
	signal_connections.append(SignalUtils.connect_signal(upgrade_capacity_button, "pressed", _on_upgrade_capacity_pressed))
	signal_connections.append(SignalUtils.connect_signal(upgrade_efficiency_button, "pressed", _on_upgrade_efficiency_pressed))
	
	# Connect GameManager signals
	signal_connections.append(SignalUtils.connect_signal(GameManager, "game_started", _on_game_started))
	signal_connections.append(SignalUtils.connect_signal(GameManager, "game_paused", _on_game_paused))
	signal_connections.append(SignalUtils.connect_signal(GameManager, "game_resumed", _on_game_resumed))
	
	# Connect SaveManager signals
	signal_connections.append(SignalUtils.connect_signal(SaveManager, "save_completed", _on_save_completed))
	signal_connections.append(SignalUtils.connect_signal(SaveManager, "save_failed", _on_save_failed))
	
	# Connect EconomySystem signals (accessed through main scene)
	# Use call_deferred to ensure systems are ready
	call_deferred("_connect_to_systems")
	
	print("GameUI: Signal connections set up. Total connections: %d" % signal_connections.size())

func _process(_delta: float) -> void:
	"""Update UI elements"""
	time_label.text = "Time: %.1fs" % GameManager.get_game_time()

func _on_menu_pressed() -> void:
	"""Handle menu button press"""
	print("GameUI: Menu pressed")
	menu_requested.emit()

func _on_pause_pressed() -> void:
	"""Handle pause button press"""
	print("GameUI: Pause pressed")
	pause_game_requested.emit()

func _on_save_pressed() -> void:
	"""Handle save button press"""
	print("GameUI: Save pressed")
	save_game_requested.emit()

func _on_add_hot_dog_pressed() -> void:
	"""Handle add hot dog button press"""
	print("GameUI: Add hot dog pressed")
	add_hot_dog_requested.emit()

func _on_upgrade_rate_pressed() -> void:
	"""Handle upgrade rate button press"""
	print("GameUI: Upgrade rate pressed")
	upgrade_rate_requested.emit()

func _on_upgrade_capacity_pressed() -> void:
	"""Handle upgrade capacity button press"""
	print("GameUI: Upgrade capacity pressed")
	upgrade_capacity_requested.emit()

func _on_upgrade_efficiency_pressed() -> void:
	"""Handle upgrade efficiency button press"""
	print("GameUI: Upgrade efficiency pressed")
	upgrade_efficiency_requested.emit()

func _on_game_started() -> void:
	"""Handle game started signal"""
	print("GameUI: Game started")
	status_label.text = "Game Running"
	pause_button.text = "Pause"

func _on_game_paused() -> void:
	"""Handle game paused signal"""
	print("GameUI: Game paused")
	status_label.text = "Game Paused"
	pause_button.text = "Resume"

func _on_game_resumed() -> void:
	"""Handle game resumed signal"""
	print("GameUI: Game resumed")
	status_label.text = "Game Running"
	pause_button.text = "Pause"

func _on_save_completed() -> void:
	"""Handle save completed signal"""
	print("GameUI: Save completed")

func _on_save_failed() -> void:
	"""Handle save failed signal"""
	print("GameUI: Save failed")

func _on_money_changed(new_amount: float, change: float) -> void:
	"""Handle money changes"""
	print("GameUI: Money changed by $%.2f. New total: $%.2f" % [change, new_amount])
	money_label.text = "Money: $%.2f" % new_amount
	
	# Update upgrade buttons when money changes
	_update_upgrade_buttons_from_main_scene()

func update_money_display(amount: float) -> void:
	"""Update money display (for save/load)"""
	money_label.text = "Money: $%.2f" % amount
	print("GameUI: Money display updated to $%.2f" % amount)

func update_production_info(produced: int) -> void:
	"""Update production information display"""
	# Note: This would need a production info label in the UI
	print("GameUI: Production info updated - Total produced: %d" % produced)

func update_queue_info(current: int, max_size: int) -> void:
	"""Update queue information display"""
	# Note: This would need a queue info label in the UI
	print("GameUI: Queue info updated - Current: %d/%d" % [current, max_size])

func update_upgrade_buttons(upgrade_costs: Dictionary, can_afford: Dictionary) -> void:
	"""Update upgrade buttons with costs and availability"""
	# Update rate upgrade button
	var rate_cost = upgrade_costs.get("rate", 0.0)
	var can_afford_rate = can_afford.get("rate", false)
	upgrade_rate_button.text = "Upgrade Production Rate ($%.0f)" % rate_cost
	upgrade_rate_button.disabled = not can_afford_rate
	upgrade_rate_button.modulate = Color.GREEN if can_afford_rate else Color.GRAY
	
	# Update capacity upgrade button
	var capacity_cost = upgrade_costs.get("capacity", 0.0)
	var can_afford_capacity = can_afford.get("capacity", false)
	upgrade_capacity_button.text = "Upgrade Capacity ($%.0f)" % capacity_cost
	upgrade_capacity_button.disabled = not can_afford_capacity
	upgrade_capacity_button.modulate = Color.GREEN if can_afford_capacity else Color.GRAY
	
	# Update efficiency upgrade button
	var efficiency_cost = upgrade_costs.get("efficiency", 0.0)
	var can_afford_efficiency = can_afford.get("efficiency", false)
	upgrade_efficiency_button.text = "Upgrade Efficiency ($%.0f)" % efficiency_cost
	upgrade_efficiency_button.disabled = not can_afford_efficiency
	upgrade_efficiency_button.modulate = Color.GREEN if can_afford_efficiency else Color.GRAY

func _connect_to_systems() -> void:
	"""Connect to system signals"""
	# Get references to systems through the main scene
	var main_scene = get_parent().get_parent()
	if main_scene and main_scene.has_method("get_economy_system"):
		var economy_system = main_scene.get_economy_system()
		if economy_system:
			signal_connections.append(SignalUtils.connect_signal(economy_system, "money_changed", _on_money_changed))
			print("GameUI: Connected to EconomySystem")
		else:
			print("GameUI: EconomySystem not found")
	else:
		print("GameUI: Main scene or get_economy_system method not found")

func _exit_tree() -> void:
	"""Clean up when UI is removed"""
	print("GameUI: Cleaning up signal connections...")
	
	# Disconnect all tracked signals
	for connection_id in signal_connections:
		SignalUtils.disconnect_signal(connection_id)
	
	signal_connections.clear()
	print("GameUI: Signal cleanup completed")

func _update_upgrade_buttons_from_main_scene() -> void:
	"""Request upgrade button update from main scene"""
	# Get reference to main scene and ask it to update upgrade buttons
	var main_scene = get_parent().get_parent()
	if main_scene and main_scene.has_method("_update_upgrade_buttons"):
		main_scene._update_upgrade_buttons() 
