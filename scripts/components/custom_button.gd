extends BaseUIComponent

## Custom Button Component with consistent styling and signal-based communication

signal button_clicked(button_id: String)

@export var button_style: String = "default"
@export var hover_sound: AudioStream
@export var click_sound: AudioStream
@export var button_id: String = ""

# Button reference
@onready var button: Button = $Button

func _ready() -> void:
	"""Initialize the custom button"""
	# Set component name for BaseUIComponent
	component_name = "CustomButton"
	
	# Call parent initialization
	super._ready()
	
	setup_button()
	connect_signals()

func _initialize_component() -> void:
	"""Override BaseUIComponent initialization"""
	print("CustomButton: Initializing custom button component")
	# Call parent initialization
	super._initialize_component()

func setup_button() -> void:
	"""Apply consistent styling based on button style"""
	if not button:
		return
		
	match button_style:
		"default":
			button.add_theme_color_override("font_color", Color.WHITE)
			button.add_theme_font_size_override("font_size", 16)
		"primary":
			button.add_theme_color_override("font_color", Color.WHITE)
			button.add_theme_font_size_override("font_size", 18)
			button.add_theme_stylebox_override("normal", create_primary_stylebox())
		"secondary":
			button.add_theme_color_override("font_color", Color.BLACK)
			button.add_theme_font_size_override("font_size", 16)
			button.add_theme_stylebox_override("normal", create_secondary_stylebox())

func connect_signals() -> void:
	"""Connect button signals"""
	if button:
		button.pressed.connect(_on_pressed)
		button.mouse_entered.connect(_on_mouse_entered)

func _on_pressed() -> void:
	"""Handle button press"""
	if not is_interactive:
		return
		
	print("CustomButton: Button pressed - %s" % button_id)
	button_clicked.emit(button_id)
	
	# Play click sound if available
	if click_sound:
		# Note: AudioManager not implemented yet, will be added later
		print("CustomButton: Would play click sound")

func _on_mouse_entered() -> void:
	"""Handle mouse hover"""
	# Play hover sound if available
	if hover_sound:
		# Note: AudioManager not implemented yet, will be added later
		print("CustomButton: Would play hover sound")

func create_primary_stylebox() -> StyleBoxFlat:
	"""Create primary button style"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.6, 1.0)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	return style

func create_secondary_stylebox() -> StyleBoxFlat:
	"""Create secondary button style"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.9, 0.9, 0.9)
	style.border_color = Color(0.7, 0.7, 0.7)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style

func set_button_text(text: String) -> void:
	"""Set button text"""
	if button:
		button.text = text

func set_button_id(id: String) -> void:
	"""Set button ID"""
	button_id = id

func cleanup() -> void:
	"""Override BaseUIComponent cleanup"""
	print("CustomButton: Cleaning up custom button component")
	
	# Disconnect signals
	if button:
		button.pressed.disconnect(_on_pressed)
		button.mouse_entered.disconnect(_on_mouse_entered)
	
	# Call parent cleanup
	super.cleanup()

func _exit_tree() -> void:
	"""Clean up when component is removed"""
	cleanup() 
