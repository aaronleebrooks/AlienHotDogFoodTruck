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

func _ready() -> void:
	"""Initialize the game UI"""
	print("GameUI: Initialized")
	
	# Connect button signals
	menu_button.pressed.connect(_on_menu_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	save_button.pressed.connect(_on_save_pressed)
	add_hot_dog_button.pressed.connect(_on_add_hot_dog_pressed)
	
	# Connect GameManager signals
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_resumed.connect(_on_game_resumed)
	
	# Connect SaveManager signals
	SaveManager.save_completed.connect(_on_save_completed)
	SaveManager.save_failed.connect(_on_save_failed)
	
	# Connect EconomySystem signals (accessed through main scene)
	# Use call_deferred to ensure systems are ready
	call_deferred("_connect_to_systems")

func _process(_delta: float) -> void:
	"""Update UI elements"""
	time_label.text = "Time: %.1fs" % GameManager.get_game_time()

func _on_menu_pressed() -> void:
	"""Handle menu button press"""
	print("GameUI: Menu pressed")
	UIManager.show_screen("menu")

func _on_pause_pressed() -> void:
	"""Handle pause button press"""
	print("GameUI: Pause pressed")
	if GameManager.is_game_running:
		GameManager.pause_game()
	else:
		GameManager.resume_game()

func _on_save_pressed() -> void:
	"""Handle save button press"""
	print("GameUI: Save pressed")
	SaveManager.save_game()

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

func _connect_to_systems() -> void:
	"""Connect to systems after they're ready"""
	var economy_system = %EconomySystem
	if economy_system:
		economy_system.money_changed.connect(_on_money_changed)
		print("GameUI: Connected to EconomySystem")
	else:
		print("GameUI: Warning - EconomySystem not found")

func _on_add_hot_dog_pressed() -> void:
	"""Handle add hot dog button press"""
	print("GameUI: Add hot dog pressed")
	print("GameUI: Current node path: %s" % get_path())
	print("GameUI: Parent path: %s" % get_parent().get_path())
	print("GameUI: Parent's parent path: %s" % get_parent().get_parent().get_path())
	
	# Try different approaches to find main scene
	var main_scene = %MainScene
	if main_scene:
		print("GameUI: Found MainScene via %MainScene")
		main_scene.add_hot_dog_to_queue_requested.emit()
	else:
		print("GameUI: Warning - Main scene not found via %MainScene")
		# Fallback to parent approach
		var parent_scene = get_parent().get_parent()
		if parent_scene and parent_scene.has_method("add_hot_dog_to_queue_requested"):
			print("GameUI: Using fallback parent approach")
			parent_scene.add_hot_dog_to_queue_requested.emit()
		else:
			print("GameUI: Error - No valid main scene found") 
