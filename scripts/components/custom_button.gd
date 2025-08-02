extends Button

## Custom Button Component with consistent styling and signal-based communication

signal button_clicked(button_id: String)

@export var button_style: String = "default"
@export var hover_sound: AudioStream
@export var click_sound: AudioStream
@export var button_id: String = ""

func _ready() -> void:
	"""Initialize the custom button"""
	setup_button()
	connect_signals()

func setup_button() -> void:
	"""Apply consistent styling based on button style"""
	match button_style:
		"default":
			add_theme_color_override("font_color", Color.WHITE)
			add_theme_font_size_override("font_size", 16)
		"primary":
			add_theme_color_override("font_color", Color.WHITE)
			add_theme_font_size_override("font_size", 18)
			add_theme_stylebox_override("normal", create_primary_stylebox())
		"secondary":
			add_theme_color_override("font_color", Color.BLACK)
			add_theme_font_size_override("font_size", 16)
			add_theme_stylebox_override("normal", create_secondary_stylebox())

func connect_signals() -> void:
	"""Connect button signals"""
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)

func _on_pressed() -> void:
	"""Handle button press"""
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
	text = text

func set_button_id(id: String) -> void:
	"""Set button ID"""
	button_id = id 