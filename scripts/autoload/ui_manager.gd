extends Node
class_name UIManager

## Simple UIManager autoload for basic UI management

# Current UI state
var current_screen: String = ""
var ui_stack: Array[String] = []

# Signals
signal screen_changed(new_screen: String, old_screen: String)
signal ui_ready

func _ready() -> void:
	"""Initialize the UIManager"""
	print("UIManager: Initialized")
	ui_ready.emit()

func show_screen(screen_name: String) -> void:
	"""Show a specific screen"""
	var old_screen = current_screen
	current_screen = screen_name
	ui_stack.append(screen_name)
	
	print("UIManager: Showing screen: %s" % screen_name)
	screen_changed.emit(screen_name, old_screen)

func go_back() -> void:
	"""Go back to the previous screen"""
	if ui_stack.size() > 1:
		ui_stack.pop_back()  # Remove current screen
		var new_screen = ui_stack.back()
		var old_screen = current_screen
		current_screen = new_screen
		
		print("UIManager: Going back to: %s" % new_screen)
		screen_changed.emit(new_screen, old_screen)

func get_current_screen() -> String:
	"""Get the current screen name"""
	return current_screen

func clear_stack() -> void:
	"""Clear the UI stack"""
	ui_stack.clear()
	current_screen = ""
	print("UIManager: UI stack cleared") 