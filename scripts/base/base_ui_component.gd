extends Control
class_name BaseUIComponent

## BaseUIComponent
## 
## Base class for all UI components with common functionality.
## 
## This class provides standardized UI component management including styling,
## animation support, focus handling, and interaction states. All UI components
## should extend this class to ensure consistent behavior and proper lifecycle.
## 
## Features:
##   - Component state management (interactive, focused)
##   - Custom styling and theme support
##   - Animation integration
##   - Standardized show/hide behavior
##   - Focus handling and accessibility
## 
## Example:
##   class_name MyUIComponent
##   extends BaseUIComponent
##   
##   func _ready():
##       component_name = "MyUIComponent"
##       super._ready()
## 
## @since: 1.0.0
## @category: UI

# Component identification
@export var component_name: String = "BaseUIComponent"
@export var component_version: String = "1.0.0"

# UI state
var is_interactive: bool = true
var is_focused: bool = false

# Styling
@export var custom_theme: Theme
@export var custom_styles: Dictionary = {}

# Animation
@export var use_animations: bool = true
@export var animation_duration: float = 0.2

# Signals
## component_initialized
## 
## Emitted when the component has been successfully initialized.
## 
## This signal indicates that the component is ready to use and all
## styling and connections have been set up. Listeners should wait for
## this signal before interacting with the component.
## 
## Example:
##   component_initialized.connect(_on_component_ready)
##   func _on_component_ready():
##       start_using_component()
signal component_initialized

## component_shown
## 
## Emitted when the component is shown.
## 
## This signal indicates that the component has become visible and
## is ready for user interaction. Listeners can start animations or
## enable interactions.
## 
## Example:
##   component_shown.connect(_on_component_shown)
##   func _on_component_shown():
##       start_entrance_animation()
signal component_shown

## component_hidden
## 
## Emitted when the component is hidden.
## 
## This signal indicates that the component has become invisible and
## should not receive user interaction. Listeners should pause
## animations or disable interactions.
## 
## Example:
##   component_hidden.connect(_on_component_hidden)
##   func _on_component_hidden():
##       pause_animations()
signal component_hidden

## component_focused
## 
## Emitted when the component receives focus.
## 
## This signal indicates that the component is now the active UI element
## and should respond to keyboard input. Listeners can update visual
## feedback or start focus-specific behaviors.
## 
## Example:
##   component_focused.connect(_on_component_focused)
##   func _on_component_focused():
##       highlight_component()
signal component_focused

## component_unfocused
## 
## Emitted when the component loses focus.
## 
## This signal indicates that the component is no longer the active
## UI element. Listeners should remove focus-specific visual feedback.
## 
## Example:
##   component_unfocused.connect(_on_component_unfocused)
##   func _on_component_unfocused():
##       remove_highlight()
signal component_unfocused

## component_error
## 
## Emitted when an error occurs in the component.
## 
## This signal provides error information when the component encounters
## a problem. Listeners should handle errors appropriately.
## 
## Parameters:
##   error_message (String): Description of the error that occurred
## 
## Example:
##   component_error.connect(_on_component_error)
##   func _on_component_error(error_message: String):
##       handle_component_error(error_message)
signal component_error(error_message: String)

func _ready() -> void:
	"""Initialize the base UI component"""
	_initialize_component()

## _initialize_component
## 
## Initialize the component - override in derived classes.
## 
## This function is called during component initialization and should be
## overridden by derived classes to perform their specific setup. The base
## implementation applies themes, styles, and connects focus signals.
## 
## Example:
##   func _initialize_component() -> void:
##       # Set up component-specific UI elements
##       setup_buttons()
##       # Call parent implementation
##       super._initialize_component()
## 
## @since: 1.0.0
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

## _apply_custom_styles
## 
## Apply custom styles to the component.
## 
## This function applies any custom StyleBox objects defined in the
## custom_styles dictionary to the component. It should be called
## during initialization or when styles are updated.
## 
## Example:
##   custom_styles["normal"] = my_style_box
##   _apply_custom_styles()
## 
## @since: 1.0.0
func _apply_custom_styles() -> void:
	"""Apply custom styles to the component"""
	for style_name in custom_styles:
		if custom_styles[style_name] is StyleBox:
			add_theme_stylebox_override(style_name, custom_styles[style_name])

## show_component
## 
## Show the component with optional animation.
## 
## This function makes the component visible and optionally animates
## the transition. It emits the component_shown signal when complete.
## 
## Example:
##   component.show_component()
##   # Component is now visible and ready for interaction
## 
## @since: 1.0.0
func show_component() -> void:
	"""Show the component with optional animation"""
	if not is_visible:
		visible = true
		
		if use_animations:
			_animate_show()
		else:
			modulate.a = 1.0
		
		print("%s: Component shown" % component_name)
		component_shown.emit()

## hide_component
## 
## Hide the component with optional animation.
## 
## This function makes the component invisible and optionally animates
## the transition. It emits the component_hidden signal when complete.
## 
## Example:
##   component.hide_component()
##   # Component is now hidden and not interactive
## 
## @since: 1.0.0
func hide_component() -> void:
	"""Hide the component with optional animation"""
	if is_visible:
		visible = false
		
		if use_animations:
			_animate_hide()
		else:
			visible = false
		
		print("%s: Component hidden" % component_name)
		component_hidden.emit()

## enable_interaction
## 
## Enable interaction with the component.
## 
## This function allows the component to receive user input and
## respond to interactions. It sets the is_interactive flag to true.
## 
## Example:
##   component.enable_interaction()
##   # Component can now receive user input
## 
## @since: 1.0.0
func enable_interaction() -> void:
	"""Enable interaction with the component"""
	if not is_interactive:
		is_interactive = true
		mouse_filter = Control.MOUSE_FILTER_STOP
		print("%s: Interaction enabled" % component_name)

## disable_interaction
## 
## Disable interaction with the component.
## 
## This function prevents the component from receiving user input.
## It sets the is_interactive flag to false and ignores mouse events.
## 
## Example:
##   component.disable_interaction()
##   # Component no longer responds to user input
## 
## @since: 1.0.0
func disable_interaction() -> void:
	"""Disable interaction with the component"""
	if is_interactive:
		is_interactive = false
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		print("%s: Interaction disabled" % component_name)

## _on_focus_entered
## 
## Handle focus entered event.
## 
## This function is called when the component receives focus. It updates
## the focus state and emits the component_focused signal.
## 
## Example:
##   # Override in derived classes for custom focus behavior
##   func _on_focus_entered():
##       super._on_focus_entered()
##       custom_focus_behavior()
## 
## @since: 1.0.0
func _on_focus_entered() -> void:
	"""Handle focus entered event"""
	is_focused = true
	component_focused.emit()

## _on_focus_exited
## 
## Handle focus exited event.
## 
## This function is called when the component loses focus. It updates
## the focus state and emits the component_unfocused signal.
## 
## Example:
##   # Override in derived classes for custom focus behavior
##   func _on_focus_exited():
##       super._on_focus_exited()
##       custom_unfocus_behavior()
## 
## @since: 1.0.0
func _on_focus_exited() -> void:
	"""Handle focus exited event"""
	is_focused = false
	component_unfocused.emit()

## _animate_show
## 
## Animate the component showing.
## 
## This function provides a default fade-in animation when the component
## is shown. It can be overridden by derived classes for custom animations.
## 
## Example:
##   # Override for custom show animation
##   func _animate_show():
##       # Custom slide-in animation
##       var tween = create_tween()
##       tween.tween_property(self, "position", Vector2.ZERO, 0.3)
## 
## @since: 1.0.0
func _animate_show() -> void:
	"""Animate the component showing"""
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, animation_duration)

## _animate_hide
## 
## Animate the component hiding.
## 
## This function provides a default fade-out animation when the component
## is hidden. It can be overridden by derived classes for custom animations.
## 
## Example:
##   # Override for custom hide animation
##   func _animate_hide():
##       # Custom slide-out animation
##       var tween = create_tween()
##       tween.tween_property(self, "position", Vector2(0, -100), 0.3)
## 
## @since: 1.0.0
func _animate_hide() -> void:
	"""Animate the component hiding"""
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, animation_duration)

## get_component_info
## 
## Get component information.
## 
## This function returns a dictionary containing comprehensive information
## about the component's current state and configuration.
## 
## Returns:
##   Dictionary: Component information including name, version, state, and settings
## 
## Example:
##   var info = component.get_component_info()
##   print("Component: %s, Version: %s, Interactive: %s" % [info.name, info.version, info.interactive])
## 
## @since: 1.0.0
func get_component_info() -> Dictionary:
	"""Get component information"""
	return {
		"name": component_name,
		"version": component_version,
		"interactive": is_interactive,
		"focused": is_focused,
		"visible": is_visible,
		"use_animations": use_animations,
		"animation_duration": animation_duration
	}

## log_error
## 
## Log a component error.
## 
## This function logs an error message and emits the component_error signal.
## It should be used by derived classes to report errors consistently.
## 
## Parameters:
##   error_message (String): The error message to log
## 
## Example:
##   if not validate_input():
##       log_error("Invalid input format")
## 
## @since: 1.0.0
func log_error(error_message: String) -> void:
	"""Log a component error"""
	print("%s: ERROR - %s" % [component_name, error_message])
	component_error.emit(error_message)

## cleanup
## 
## Clean up component resources - override in derived classes.
## 
## This function should be overridden by derived classes to perform
## their specific cleanup operations. The base implementation disables
## interaction and hides the component.
## 
## Example:
##   func cleanup() -> void:
##       # Clean up component-specific resources
##       disconnect_signals()
##       clear_animations()
##       # Call parent implementation
##       super.cleanup()
## 
## @since: 1.0.0
func cleanup() -> void:
	"""Clean up component resources - override in derived classes"""
	print("%s: Cleaning up component" % component_name)
	disable_interaction()
	hide_component()

func _exit_tree() -> void:
	"""Clean up when component is removed"""
	cleanup() 
