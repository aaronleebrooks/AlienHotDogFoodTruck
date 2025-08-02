extends Control

## Menu UI controller for handling menu interactions

# Button references
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	"""Initialize the menu UI"""
	print("MenuUI: Initialized")
	
	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Update continue button state
	_update_continue_button()

func _update_continue_button() -> void:
	"""Update continue button visibility based on save file existence"""
	continue_button.visible = SaveManager.has_save_file()

func _on_start_pressed() -> void:
	"""Handle start game button press"""
	print("MenuUI: Start game pressed")
	GameManager.start_game()
	UIManager.show_screen("game")

func _on_continue_pressed() -> void:
	"""Handle continue game button press"""
	print("MenuUI: Continue game pressed")
	SaveManager.load_game()
	GameManager.start_game()
	UIManager.show_screen("game")

func _on_settings_pressed() -> void:
	"""Handle settings button press"""
	print("MenuUI: Settings pressed")
	UIManager.show_screen("settings")

func _on_quit_pressed() -> void:
	"""Handle quit button press"""
	print("MenuUI: Quit pressed")
	get_tree().quit() 