extends Control

## ProductionUI
## 
## User interface for the hot dog production system.
## 
## This UI provides controls for managing production and displays
## current production status, queue information, and upgrade options.
## 
## @since: 1.0.0
## @category: UI

# UI references
@onready var status_label: Label = $VBoxContainer/ProductionStatus/StatusLabel
@onready var queue_label: Label = $VBoxContainer/ProductionStatus/QueueLabel
@onready var rate_label: Label = $VBoxContainer/ProductionStatus/RateLabel
@onready var total_label: Label = $VBoxContainer/ProductionStatus/TotalLabel

@onready var add_to_queue_button: Button = $VBoxContainer/Controls/AddToQueueButton
@onready var start_production_button: Button = $VBoxContainer/Controls/StartProductionButton
@onready var stop_production_button: Button = $VBoxContainer/Controls/StopProductionButton

@onready var upgrade_rate_button: Button = $VBoxContainer/Upgrades/UpgradeRateButton
@onready var upgrade_capacity_button: Button = $VBoxContainer/Upgrades/UpgradeCapacityButton
@onready var upgrade_efficiency_button: Button = $VBoxContainer/Upgrades/UpgradeEfficiencyButton

# System references
var production_system: Node

func _ready() -> void:
	"""Initialize the production UI"""
	print("ProductionUI: Initializing...")
	
	# Get production system reference
	production_system = get_node("/root/ProductionSystem")
	if not production_system:
		print("ProductionUI: ERROR - ProductionSystem not found!")
		return
	
	# Connect button signals
	_connect_button_signals()
	
	# Connect to production system signals
	_connect_production_signals()
	
	# Initial UI update
	_update_ui()
	
	print("ProductionUI: Initialized successfully")

func _connect_button_signals() -> void:
	"""Connect button signals to handlers"""
	add_to_queue_button.pressed.connect(_on_add_to_queue_pressed)
	start_production_button.pressed.connect(_on_start_production_pressed)
	stop_production_button.pressed.connect(_on_stop_production_pressed)
	
	upgrade_rate_button.pressed.connect(_on_upgrade_rate_pressed)
	upgrade_capacity_button.pressed.connect(_on_upgrade_capacity_pressed)
	upgrade_efficiency_button.pressed.connect(_on_upgrade_efficiency_pressed)

func _connect_production_signals() -> void:
	"""Connect to production system signals"""
	if production_system:
		production_system.production_started.connect(_on_production_started)
		production_system.production_stopped.connect(_on_production_stopped)
		production_system.hot_dog_produced.connect(_on_hot_dog_produced)
		production_system.queue_updated.connect(_on_queue_updated)
		production_system.production_rate_changed.connect(_on_production_rate_changed)
		production_system.capacity_changed.connect(_on_capacity_changed)

func _update_ui() -> void:
	"""Update the UI with current production status"""
	if not production_system:
		return
	
	var queue_status = production_system.get_queue_status()
	var stats = production_system.get_production_statistics()
	
	# Update status labels
	if production_system.is_producing():
		status_label.text = "Status: Producing"
		status_label.modulate = Color.GREEN
	else:
		status_label.text = "Status: Not Producing"
		status_label.modulate = Color.WHITE
	
	queue_label.text = "Queue: %d/%d" % [queue_status.current_size, queue_status.max_size]
	rate_label.text = "Rate: %.1f hot dogs/sec" % stats.current_rate
	total_label.text = "Total Produced: %d" % stats.total_produced
	
	# Update upgrade buttons with costs
	_update_upgrade_buttons()
	
	# Update button states
	_update_button_states()

func _update_upgrade_buttons() -> void:
	"""Update upgrade buttons with costs and availability"""
	if not production_system:
		return
	
	# Get upgrade costs
	var upgrade_costs = production_system.get_upgrade_costs()
	
	# Update rate upgrade button
	var rate_cost = upgrade_costs.get("rate", 0.0)
	var can_afford_rate = production_system.can_afford_upgrade("rate")
	upgrade_rate_button.text = "Upgrade Production Rate ($%.0f)" % rate_cost
	upgrade_rate_button.disabled = not can_afford_rate
	upgrade_rate_button.modulate = Color.GREEN if can_afford_rate else Color.GRAY
	
	# Update capacity upgrade button
	var capacity_cost = upgrade_costs.get("capacity", 0.0)
	var can_afford_capacity = production_system.can_afford_upgrade("capacity")
	upgrade_capacity_button.text = "Upgrade Capacity ($%.0f)" % capacity_cost
	upgrade_capacity_button.disabled = not can_afford_capacity
	upgrade_capacity_button.modulate = Color.GREEN if can_afford_capacity else Color.GRAY
	
	# Update efficiency upgrade button
	var efficiency_cost = upgrade_costs.get("efficiency", 0.0)
	var can_afford_efficiency = production_system.can_afford_upgrade("efficiency")
	upgrade_efficiency_button.text = "Upgrade Efficiency ($%.0f)" % efficiency_cost
	upgrade_efficiency_button.disabled = not can_afford_efficiency
	upgrade_efficiency_button.modulate = Color.GREEN if can_afford_efficiency else Color.GRAY

func _update_button_states() -> void:
	"""Update button enabled/disabled states"""
	if not production_system:
		return
	
	var queue_status = production_system.get_queue_status()
	
	# Add to queue button
	add_to_queue_button.disabled = queue_status.is_full
	
	# Start/stop production buttons
	start_production_button.disabled = production_system.is_producing() or queue_status.is_empty
	stop_production_button.disabled = not production_system.is_producing()

# Button event handlers
func _on_add_to_queue_pressed() -> void:
	"""Handle add to queue button press"""
	if production_system:
		production_system.add_to_queue()
		_update_ui()

func _on_start_production_pressed() -> void:
	"""Handle start production button press"""
	if production_system:
		production_system.start_production()
		_update_ui()

func _on_stop_production_pressed() -> void:
	"""Handle stop production button press"""
	if production_system:
		production_system.stop_production()
		_update_ui()

func _on_upgrade_rate_pressed() -> void:
	"""Handle upgrade rate button press"""
	if production_system:
		production_system.upgrade_production_rate()
		_update_ui()

func _on_upgrade_capacity_pressed() -> void:
	"""Handle upgrade capacity button press"""
	if production_system:
		production_system.upgrade_capacity()
		_update_ui()

func _on_upgrade_efficiency_pressed() -> void:
	"""Handle upgrade efficiency button press"""
	if production_system:
		production_system.upgrade_efficiency()
		_update_ui()

# Production system signal handlers
func _on_production_started() -> void:
	"""Handle production started signal"""
	print("ProductionUI: Production started")
	_update_ui()

func _on_production_stopped() -> void:
	"""Handle production stopped signal"""
	print("ProductionUI: Production stopped")
	_update_ui()

func _on_hot_dog_produced() -> void:
	"""Handle hot dog produced signal"""
	print("ProductionUI: Hot dog produced!")
	_update_ui()

func _on_queue_updated(current_size: int, max_size: int) -> void:
	"""Handle queue updated signal"""
	print("ProductionUI: Queue updated - %d/%d" % [current_size, max_size])
	_update_ui()

func _on_production_rate_changed(new_rate: float) -> void:
	"""Handle production rate changed signal"""
	print("ProductionUI: Production rate changed to %.2f" % new_rate)
	_update_ui()

func _on_capacity_changed(new_capacity: int) -> void:
	"""Handle capacity changed signal"""
	print("ProductionUI: Capacity changed to %d" % new_capacity)
	_update_ui()

# Periodic UI updates
func _process(_delta: float) -> void:
	"""Update UI periodically"""
	# Update UI every few frames to keep it responsive
	if Engine.get_process_frames() % 30 == 0:  # Every 30 frames (about 0.5 seconds at 60 FPS)
		_update_ui() 