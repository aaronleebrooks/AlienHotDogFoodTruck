extends Control

## Comprehensive test script for all autoloads

# GameManager UI elements
@onready var game_time_label: Label = $VBoxContainer/GameManagerSection/GameTimeLabel
@onready var start_button: Button = $VBoxContainer/GameManagerSection/GameButtons/StartButton
@onready var pause_button: Button = $VBoxContainer/GameManagerSection/GameButtons/PauseButton
@onready var resume_button: Button = $VBoxContainer/GameManagerSection/GameButtons/ResumeButton

# SaveManager UI elements
@onready var save_status_label: Label = $VBoxContainer/SaveManagerSection/SaveStatusLabel
@onready var save_button: Button = $VBoxContainer/SaveManagerSection/SaveButtons/SaveButton
@onready var load_button: Button = $VBoxContainer/SaveManagerSection/SaveButtons/LoadButton

# UIManager UI elements
@onready var current_screen_label: Label = $VBoxContainer/UIManagerSection/CurrentScreenLabel
@onready var menu_button: Button = $VBoxContainer/UIManagerSection/UIButtons/MenuButton
@onready var game_button: Button = $VBoxContainer/UIManagerSection/UIButtons/GameButton
@onready var settings_button: Button = $VBoxContainer/UIManagerSection/UIButtons/SettingsButton
@onready var back_button: Button = $VBoxContainer/UIManagerSection/UIButtons/BackButton

func _ready() -> void:
	"""Setup test UI and connect signals"""
	print("TestAllAutoloads: Setting up test UI...")
	
	# Connect GameManager buttons
	start_button.pressed.connect(_on_start_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	
	# Connect SaveManager buttons
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	
	# Connect UIManager buttons
	menu_button.pressed.connect(_on_menu_pressed)
	game_button.pressed.connect(_on_game_screen_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Connect autoload signals
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_resumed.connect(_on_game_resumed)
	
	SaveManager.save_completed.connect(_on_save_completed)
	SaveManager.load_completed.connect(_on_load_completed)
	SaveManager.save_failed.connect(_on_save_failed)
	SaveManager.load_failed.connect(_on_load_failed)
	
	UIManager.screen_changed.connect(_on_screen_changed)
	
	# Update initial UI state
	_update_save_status()
	_update_screen_display()
	
	print("TestAllAutoloads: Test UI setup complete")

func _process(_delta: float) -> void:
	"""Update time display"""
	game_time_label.text = "Time: %.1fs" % GameManager.get_game_time()

func _update_save_status() -> void:
	"""Update save status display"""
	if SaveManager.has_save_file():
		save_status_label.text = "Status: Save file exists"
	else:
		save_status_label.text = "Status: No save file"

func _update_screen_display() -> void:
	"""Update current screen display"""
	var screen = UIManager.get_current_screen()
	if screen.is_empty():
		current_screen_label.text = "Screen: None"
	else:
		current_screen_label.text = "Screen: %s" % screen

# GameManager button handlers
func _on_start_pressed() -> void:
	GameManager.start_game()

func _on_pause_pressed() -> void:
	GameManager.pause_game()

func _on_resume_pressed() -> void:
	GameManager.resume_game()

# SaveManager button handlers
func _on_save_pressed() -> void:
	SaveManager.save_game()

func _on_load_pressed() -> void:
	SaveManager.load_game()

# UIManager button handlers
func _on_menu_pressed() -> void:
	UIManager.show_screen("menu")

func _on_game_screen_pressed() -> void:
	UIManager.show_screen("game")

func _on_settings_pressed() -> void:
	UIManager.show_screen("settings")

func _on_back_pressed() -> void:
	UIManager.go_back()

# GameManager signal handlers
func _on_game_started() -> void:
	print("Test: Game started")

func _on_game_paused() -> void:
	print("Test: Game paused")

func _on_game_resumed() -> void:
	print("Test: Game resumed")

# SaveManager signal handlers
func _on_save_completed() -> void:
	print("Test: Save completed")
	_update_save_status()

func _on_load_completed() -> void:
	print("Test: Load completed")
	_update_save_status()

func _on_save_failed() -> void:
	print("Test: Save failed")

func _on_load_failed() -> void:
	print("Test: Load failed")

# UIManager signal handlers
func _on_screen_changed(new_screen: String, old_screen: String) -> void:
	print("Test: Screen changed from '%s' to '%s'" % [old_screen, new_screen])
	_update_screen_display() 