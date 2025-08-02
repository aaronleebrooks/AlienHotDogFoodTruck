extends Control
class_name BaseUIComponent

## Base class for all UI components with common functionality

# Component identification
@export var component_name: String = "BaseUIComponent"
@export var component_version: String = "1.0.0"

# UI state
var is_component_visible: bool = true
var is_interactive: bool = true
var is_focused: bool = false

# Styling
@export var custom_theme: Theme
@export var custom_styles: Dictionary = {}

# Animation
@export var use_animations: bool = true
@export var animation_duration: float = 0.2

# Signals
signal component_initialized
signal component_shown
signal component_hidden
signal component_focused
signal component_unfocused
signal component_error(error_message: String)

func _ready() -> void:
	"""Initialize the base UI component"""
	_initialize_component()

func _initialize_component() -> void:
	"""Initialize the component - override in derived classes"""
	print("%s: Initializing UI component" % component_name)
	
	# Apply custom theme if provided
	if custom_theme:
		theme = custom_theme
	
	# Apply custom styles
	_apply_custom_styles()
	
	# Connect focus signals
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	
	component_initialized.emit()

func _apply_custom_styles() -> void:
	"""Apply custom styles to the component"""
	for style_name in custom_styles:
		if custom_styles[style_name] is StyleBox:
			add_theme_stylebox_override(style_name, custom_styles[style_name])

func show_component() -> void:
	"""Show the component with optional animation"""
	if not is_component_visible:
		is_component_visible = true
		visible = true
		
		if use_animations:
			_animate_show()
		else:
			modulate.a = 1.0
		
		print("%s: Component shown" % component_name)
		component_shown.emit()

func hide_component() -> void:
	"""Hide the component with optional animation"""
	if is_component_visible:
		is_component_visible = false
		
		if use_animations:
			_animate_hide()
		else:
			visible = false
		
		print("%s: Component hidden" % component_name)
		component_hidden.emit()

func enable_interaction() -> void:
	"""Enable component interaction"""
	is_interactive = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	print("%s: Interaction enabled" % component_name)

func disable_interaction() -> void:
	"""Disable component interaction"""
	is_interactive = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	print("%s: Interaction disabled" % component_name)

func focus_component() -> void:
	"""Focus the component"""
	grab_focus()

func _on_focus_entered() -> void:
	"""Handle focus entered"""
	is_focused = true
	print("%s: Component focused" % component_name)
	component_focused.emit()

func _on_focus_exited() -> void:
	"""Handle focus exited"""
	is_focused = false
	print("%s: Component unfocused" % component_name)
	component_unfocused.emit()

func _animate_show() -> void:
	"""Animate component showing - override in derived classes"""
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, animation_duration)

func _animate_hide() -> void:
	"""Animate component hiding - override in derived classes"""
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, animation_duration)
	tween.tween_callback(func(): visible = false)

func get_component_info() -> Dictionary:
	"""Get component information"""
	return {
		"name": component_name,
		"version": component_version,
		"visible": is_component_visible,
		"interactive": is_interactive,
		"focused": is_focused
	}

func log_error(error_message: String) -> void:
	"""Log a component error"""
	print("%s: ERROR - %s" % [component_name, error_message])
	component_error.emit(error_message)

func cleanup() -> void:
	"""Clean up component resources - override in derived classes"""
	print("%s: Cleaning up UI component" % component_name)
	hide_component()

func _exit_tree() -> void:
	"""Clean up when component is removed"""
	cleanup() 