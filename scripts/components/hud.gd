extends Control

## HUD Component with signal-based communication for game information display

signal hud_element_clicked(element_id: String)
signal menu_requested
signal pause_requested
signal save_requested
signal add_hot_dog_requested

@onready var money_label: Label = $TopBar/MoneyLabel
@onready var time_label: Label = $TopBar/TimeLabel
@onready var status_label: Label = $TopBar/StatusLabel
@onready var production_info: Label = $CenterArea/GameInfo/ProductionInfo
@onready var queue_info: Label = $CenterArea/GameInfo/QueueInfo
@onready var menu_button: Button = $BottomBar/MenuButton
@onready var pause_button: Button = $BottomBar/PauseButton
@onready var save_button: Button = $BottomBar/SaveButton
@onready var add_hot_dog_button: Button = $CenterArea/AddHotDogButton

func _ready() -> void:
	"""Initialize the HUD"""
	connect_signals()
	print("HUD: Initialized")

func connect_signals() -> void:
	"""Connect button signals"""
	menu_button.pressed.connect(_on_menu_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	save_button.pressed.connect(_on_save_pressed)
	add_hot_dog_button.pressed.connect(_on_add_hot_dog_pressed)

func _process(_delta: float) -> void:
	"""Update time display"""
	time_label.text = "Time: %.1fs" % GameManager.get_game_time()

func _on_menu_pressed() -> void:
	"""Handle menu button press"""
	print("HUD: Menu requested")
	hud_element_clicked.emit("menu")
	menu_requested.emit()

func _on_pause_pressed() -> void:
	"""Handle pause button press"""
	print("HUD: Pause requested")
	hud_element_clicked.emit("pause")
	pause_requested.emit()

func _on_save_pressed() -> void:
	"""Handle save button press"""
	print("HUD: Save requested")
	hud_element_clicked.emit("save")
	save_requested.emit()

func _on_add_hot_dog_pressed() -> void:
	"""Handle add hot dog button press"""
	print("HUD: Add hot dog requested")
	hud_element_clicked.emit("add_hot_dog")
	add_hot_dog_requested.emit()

func update_money_display(amount: float) -> void:
	"""Update money display"""
	money_label.text = "Money: $%.2f" % amount

func update_status_display(status: String) -> void:
	"""Update status display"""
	status_label.text = "Status: %s" % status

func update_production_info(produced: int) -> void:
	"""Update production information"""
	production_info.text = "Production: %d hot dogs" % produced

func update_queue_info(current: int, max_size: int) -> void:
	"""Update queue information"""
	queue_info.text = "Queue: %d/%d" % [current, max_size]

func set_pause_button_text(text: String) -> void:
	"""Set pause button text"""
	pause_button.text = text

func show_element(element_name: String) -> void:
	"""Show a specific HUD element"""
	var element = get_node_or_null(element_name)
	if element:
		element.visible = true

func hide_element(element_name: String) -> void:
	"""Hide a specific HUD element"""
	var element = get_node_or_null(element_name)
	if element:
		element.visible = false

func get_element(element_name: String) -> Node:
	"""Get a specific HUD element"""
	return get_node_or_null(element_name) 