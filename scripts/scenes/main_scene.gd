extends Control

## Main scene controller for managing UI transitions and game state

# UI references
@onready var ui_container: Control = $UI
@onready var game_ui: Control = $UI/GameUI
@onready var menu_ui: Control = $UI/MenuUI
@onready var settings_ui: Control = $UI/SettingsUI
@onready var loading_ui: Control = $UI/LoadingUI

# Current active UI
var current_ui: Control

func _ready() -> void:
	"""Initialize the main scene"""
	print("MainScene: Initialized")
	
	# Connect UIManager signals
	UIManager.screen_changed.connect(_on_screen_changed)
	
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