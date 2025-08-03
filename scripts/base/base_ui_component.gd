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
##   - Advanced styling and theme support with presets
##   - Responsive design and layout management
##   - Animation integration with easing
##   - Visual state management (normal, hover, pressed, disabled)
##   - Accessibility support
##   - Standardized show/hide behavior
##   - Focus handling and keyboard navigation
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
var is_hovered: bool = false
var is_pressed: bool = false
var is_disabled: bool = false

# Enhanced styling system
@export var custom_theme: Theme
@export var custom_styles: Dictionary = {}
@export var style_preset: String = "default"
@export var responsive_enabled: bool = true
@export var accessibility_enabled: bool = true

# Style presets
var _style_presets: Dictionary = {
	"default": {
		"colors": {
			"normal": Color.WHITE,
			"hover": Color.LIGHT_GRAY,
			"pressed": Color.GRAY,
			"disabled": Color.DARK_GRAY,
			"focused": Color.CYAN
		},
		"fonts": {
			"normal": null,
			"bold": null,
			"italic": null
		},
		"spacing": {
			"margin": Vector2(5, 5),
			"padding": Vector2(10, 10),
			"border": 2
		},
		"animation": {
			"duration": 0.2,
			"easing": Tween.EASE_OUT
		}
	},
	"modern": {
		"colors": {
			"normal": Color(0.2, 0.2, 0.2, 0.9),
			"hover": Color(0.3, 0.3, 0.3, 0.9),
			"pressed": Color(0.1, 0.1, 0.1, 0.9),
			"disabled": Color(0.1, 0.1, 0.1, 0.5),
			"focused": Color(0.4, 0.6, 1.0, 0.9)
		},
		"fonts": {
			"normal": null,
			"bold": null,
			"italic": null
		},
		"spacing": {
			"margin": Vector2(8, 8),
			"padding": Vector2(15, 15),
			"border": 3
		},
		"animation": {
			"duration": 0.15,
			"easing": Tween.EASE_OUT
		}
	},
	"minimal": {
		"colors": {
			"normal": Color.TRANSPARENT,
			"hover": Color(1, 1, 1, 0.1),
			"pressed": Color(1, 1, 1, 0.2),
			"disabled": Color(1, 1, 1, 0.05),
			"focused": Color(1, 1, 1, 0.15)
		},
		"fonts": {
			"normal": null,
			"bold": null,
			"italic": null
		},
		"spacing": {
			"margin": Vector2(2, 2),
			"padding": Vector2(5, 5),
			"border": 1
		},
		"animation": {
			"duration": 0.1,
			"easing": Tween.EASE_OUT
		}
	}
}

# Visual state management
var _current_visual_state: String = "normal"
var _visual_states: Dictionary = {}
var _state_transitions: Dictionary = {}

# Animation
@export var use_animations: bool = true
@export var animation_duration: float = 0.2
@export var animation_easing: Tween.EaseType = Tween.EASE_OUT

# Responsive design
var _screen_size: Vector2
var _breakpoints: Dictionary = {
	"mobile": Vector2(480, 800),
	"tablet": Vector2(768, 1024),
	"desktop": Vector2(1024, 768),
	"large": Vector2(1920, 1080)
}

# Accessibility
var _accessibility_label: String = ""
var _accessibility_description: String = ""
var _accessibility_hint: String = ""

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

## visual_state_changed
## 
## Emitted when the visual state of the component changes.
## 
## This signal indicates that the component's visual appearance has
## changed (e.g., from normal to hover state). Listeners can respond
## to visual state changes.
## 
## Parameters:
##   new_state (String): The new visual state
##   previous_state (String): The previous visual state
## 
## Example:
##   visual_state_changed.connect(_on_visual_state_changed)
##   func _on_visual_state_changed(new_state: String, previous_state: String):
##       update_visual_feedback(new_state)
signal visual_state_changed(new_state: String, previous_state: String)

## style_preset_changed
## 
## Emitted when the style preset is changed.
## 
## This signal indicates that the component's styling preset has been
## updated. Listeners can respond to style changes.
## 
## Parameters:
##   new_preset (String): The new style preset name
## 
## Example:
##   style_preset_changed.connect(_on_style_preset_changed)
##   func _on_style_preset_changed(new_preset: String):
##       apply_new_theme(new_preset)
signal style_preset_changed(new_preset: String)

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
	
	# Initialize responsive design
	_screen_size = get_viewport().get_visible_rect().size
	
	# Apply custom theme if provided
	if custom_theme:
		theme = custom_theme
	
	# Initialize styling system
	_initialize_styling_system()
	
	# Apply current style preset
	apply_style_preset(style_preset)
	
	# Set up visual states
	_setup_visual_states()
	
	# Connect signals
	_connect_component_signals()
	
	# Apply responsive design if enabled
	if responsive_enabled:
		_apply_responsive_design()
	
	# Set up accessibility if enabled
	if accessibility_enabled:
		_setup_accessibility()
	
	component_initialized.emit()

## _initialize_styling_system
## 
## Initialize the styling system with presets and state management.
## 
## @since: 1.0.0
func _initialize_styling_system() -> void:
	"""Initialize the styling system with presets and state management"""
	# Initialize visual states
	_visual_states = {
		"normal": {},
		"hover": {},
		"pressed": {},
		"disabled": {},
		"focused": {}
	}
	
	# Set up state transitions
	_state_transitions = {
		"normal": ["hover", "focused", "disabled"],
		"hover": ["normal", "pressed", "focused", "disabled"],
		"pressed": ["normal", "hover", "focused", "disabled"],
		"focused": ["normal", "hover", "pressed", "disabled"],
		"disabled": ["normal"]
	}

## _setup_visual_states
## 
## Set up visual states for the component.
## 
## @since: 1.0.0
func _setup_visual_states() -> void:
	"""Set up visual states for the component"""
	# Override in derived classes to set up specific visual states
	pass

## _connect_component_signals
## 
## Connect all component signals.
## 
## @since: 1.0.0
func _connect_component_signals() -> void:
	"""Connect all component signals"""
	# Connect focus signals
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	
	# Connect mouse signals for hover detection
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Connect input signals
	gui_input.connect(_on_gui_input)

## _setup_accessibility
## 
## Set up accessibility features for the component.
## 
## @since: 1.0.0
func _setup_accessibility() -> void:
	"""Set up accessibility features for the component"""
	# Set default accessibility properties
	if _accessibility_label.is_empty():
		_accessibility_label = component_name
	
	# Override in derived classes for specific accessibility setup
	pass

## apply_style_preset
## 
## Apply a style preset to the component.
## 
## Parameters:
##   preset_name (String): Name of the preset to apply
## 
## @since: 1.0.0
func apply_style_preset(preset_name: String) -> void:
	"""Apply a style preset to the component"""
	if not _style_presets.has(preset_name):
		log_error("Style preset '%s' not found" % preset_name)
		return
	
	var preset = _style_presets[preset_name]
	style_preset = preset_name
	
	# Apply colors
	_apply_preset_colors(preset.colors)
	
	# Apply fonts
	_apply_preset_fonts(preset.fonts)
	
	# Apply spacing
	_apply_preset_spacing(preset.spacing)
	
	# Apply animation settings
	_apply_preset_animation(preset.animation)
	
	# Apply custom styles
	_apply_custom_styles()
	
	style_preset_changed.emit(preset_name)
	print("%s: Applied style preset '%s'" % [component_name, preset_name])

## _apply_preset_colors
## 
## Apply color settings from a preset.
## 
## Parameters:
##   colors (Dictionary): Color settings to apply
## 
## @since: 1.0.0
func _apply_preset_colors(colors: Dictionary) -> void:
	"""Apply color settings from a preset"""
	# Override in derived classes to apply specific color settings
	pass

## _apply_preset_fonts
## 
## Apply font settings from a preset.
## 
## Parameters:
##   fonts (Dictionary): Font settings to apply
## 
## @since: 1.0.0
func _apply_preset_fonts(fonts: Dictionary) -> void:
	"""Apply font settings from a preset"""
	# Override in derived classes to apply specific font settings
	pass

## _apply_preset_spacing
## 
## Apply spacing settings from a preset.
## 
## Parameters:
##   spacing (Dictionary): Spacing settings to apply
## 
## @since: 1.0.0
func _apply_preset_spacing(spacing: Dictionary) -> void:
	"""Apply spacing settings from a preset"""
	# Override in derived classes to apply specific spacing settings
	pass

## _apply_preset_animation
## 
## Apply animation settings from a preset.
## 
## Parameters:
##   animation (Dictionary): Animation settings to apply
## 
## @since: 1.0.0
func _apply_preset_animation(animation: Dictionary) -> void:
	"""Apply animation settings from a preset"""
	animation_duration = animation.get("duration", 0.2)
	animation_easing = animation.get("easing", Tween.EASE_OUT)

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

## set_visual_state
## 
## Set the visual state of the component.
## 
## Parameters:
##   new_state (String): The new visual state to set
## 
## @since: 1.0.0
func set_visual_state(new_state: String) -> void:
	"""Set the visual state of the component"""
	if not _visual_states.has(new_state):
		log_error("Visual state '%s' not found" % new_state)
		return
	
	var previous_state = _current_visual_state
	_current_visual_state = new_state
	
	# Apply the visual state
	_apply_visual_state(new_state)
	
	# Emit signal
	visual_state_changed.emit(new_state, previous_state)

## _apply_visual_state
## 
## Apply a visual state to the component.
## 
## Parameters:
##   state (String): The visual state to apply
## 
## @since: 1.0.0
func _apply_visual_state(state: String) -> void:
	"""Apply a visual state to the component"""
	# Override in derived classes to apply specific visual states
	pass

## _apply_responsive_design
## 
## Apply responsive design based on screen size.
## 
## @since: 1.0.0
func _apply_responsive_design() -> void:
	"""Apply responsive design based on screen size"""
	var current_breakpoint = _get_current_breakpoint()
	_apply_breakpoint_design(current_breakpoint)

## _get_current_breakpoint
## 
## Get the current breakpoint based on screen size.
## 
## Returns:
##   String: The current breakpoint name
## 
## @since: 1.0.0
func _get_current_breakpoint() -> String:
	"""Get the current breakpoint based on screen size"""
	var width = _screen_size.x
	
	if width <= _breakpoints.mobile.x:
		return "mobile"
	elif width <= _breakpoints.tablet.x:
		return "tablet"
	elif width <= _breakpoints.desktop.x:
		return "desktop"
	else:
		return "large"

## _apply_breakpoint_design
## 
## Apply design for a specific breakpoint.
## 
## Parameters:
##   breakpoint (String): The breakpoint to apply
## 
## @since: 1.0.0
func _apply_breakpoint_design(breakpoint: String) -> void:
	"""Apply design for a specific breakpoint"""
	# Override in derived classes to apply specific breakpoint designs
	pass

## set_accessibility_info
## 
## Set accessibility information for the component.
## 
## Parameters:
##   label (String): Accessibility label
##   description (String): Accessibility description
##   hint (String): Accessibility hint
## 
## @since: 1.0.0
func set_accessibility_info(label: String, description: String = "", hint: String = "") -> void:
	"""Set accessibility information for the component"""
	_accessibility_label = label
	_accessibility_description = description
	_accessibility_hint = hint

## get_accessibility_info
## 
## Get accessibility information for the component.
## 
## Returns:
##   Dictionary: Accessibility information
## 
## @since: 1.0.0
func get_accessibility_info() -> Dictionary:
	"""Get accessibility information for the component"""
	return {
		"label": _accessibility_label,
		"description": _accessibility_description,
		"hint": _accessibility_hint,
		"enabled": accessibility_enabled
	}

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
		set_visual_state("normal")
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
		set_visual_state("disabled")
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
	set_visual_state("focused")
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
	set_visual_state("normal")
	component_unfocused.emit()

## _on_mouse_entered
## 
## Handle mouse entered event.
## 
## @since: 1.0.0
func _on_mouse_entered() -> void:
	"""Handle mouse entered event"""
	is_hovered = true
	if is_interactive and not is_focused:
		set_visual_state("hover")

## _on_mouse_exited
## 
## Handle mouse exited event.
## 
## @since: 1.0.0
func _on_mouse_exited() -> void:
	"""Handle mouse exited event"""
	is_hovered = false
	is_pressed = false
	if is_interactive and not is_focused:
		set_visual_state("normal")

## _on_gui_input
## 
## Handle GUI input events.
## 
## Parameters:
##   event (InputEvent): The input event to handle
## 
## @since: 1.0.0
func _on_gui_input(event: InputEvent) -> void:
	"""Handle GUI input events"""
	if not is_interactive:
		return
	
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				is_pressed = true
				set_visual_state("pressed")
			else:
				is_pressed = false
				if is_hovered:
					set_visual_state("hover")
				else:
					set_visual_state("normal")

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
	tween.set_ease(animation_easing)
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
	tween.set_ease(animation_easing)
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
		"hovered": is_hovered,
		"pressed": is_pressed,
		"disabled": is_disabled,
		"visible": is_visible,
		"visual_state": _current_visual_state,
		"style_preset": style_preset,
		"use_animations": use_animations,
		"animation_duration": animation_duration,
		"responsive_enabled": responsive_enabled,
		"accessibility_enabled": accessibility_enabled
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
