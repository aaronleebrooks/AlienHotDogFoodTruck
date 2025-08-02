extends Control

## Test script for component scenes

@onready var test_button: Button = $VBoxContainer/TestButton
@onready var test_panel: Button = $VBoxContainer/TestPanel
@onready var test_dialog: Button = $VBoxContainer/TestDialog
@onready var test_hud: Button = $VBoxContainer/TestHUD
@onready var back_button: Button = $VBoxContainer/BackButton

var custom_button_instance: Node
var custom_panel_instance: Node
var modal_dialog_instance: Node
var hud_instance: Node

func _ready() -> void:
	"""Initialize the test scene"""
	connect_signals()
	print("TestComponents: Initialized")

func connect_signals() -> void:
	"""Connect button signals"""
	test_button.pressed.connect(_on_test_button_pressed)
	test_panel.pressed.connect(_on_test_panel_pressed)
	test_dialog.pressed.connect(_on_test_dialog_pressed)
	test_hud.pressed.connect(_on_test_hud_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

func _on_test_button_pressed() -> void:
	"""Test custom button component"""
	print("TestComponents: Testing Custom Button")
	
	# Load and instantiate custom button
	var custom_button_scene = load("res://scenes/components/custom_button.tscn")
	if custom_button_scene:
		custom_button_instance = custom_button_scene.instantiate()
		if custom_button_instance:
			custom_button_instance.button_id = "test_button"
			custom_button_instance.text = "Test Custom Button"
			custom_button_instance.button_clicked.connect(_on_custom_button_clicked)
			add_child(custom_button_instance)
			print("TestComponents: Custom button instantiated successfully")
		else:
			print("TestComponents: Error - Failed to instantiate custom button")
	else:
		print("TestComponents: Error - Failed to load custom button scene")

func _on_test_panel_pressed() -> void:
	"""Test custom panel component"""
	print("TestComponents: Testing Custom Panel")
	
	# Load and instantiate custom panel
	var custom_panel_scene = load("res://scenes/components/custom_panel.tscn")
	if custom_panel_scene:
		custom_panel_instance = custom_panel_scene.instantiate()
		if custom_panel_instance:
			custom_panel_instance.panel_title = "Test Panel"
			custom_panel_instance.panel_opened.connect(_on_custom_panel_opened)
			custom_panel_instance.panel_closed.connect(_on_custom_panel_closed)
			add_child(custom_panel_instance)
			
			# Check if the method exists before calling
			if custom_panel_instance.has_method("show_panel"):
				custom_panel_instance.show_panel()
				print("TestComponents: Custom panel instantiated and shown successfully")
			else:
				print("TestComponents: Error - show_panel method not found")
		else:
			print("TestComponents: Error - Failed to instantiate custom panel")
	else:
		print("TestComponents: Error - Failed to load custom panel scene")

func _on_test_dialog_pressed() -> void:
	"""Test modal dialog component"""
	print("TestComponents: Testing Modal Dialog")
	
	# Load and instantiate modal dialog
	var modal_dialog_scene = load("res://scenes/components/modal_dialog.tscn")
	if modal_dialog_scene:
		modal_dialog_instance = modal_dialog_scene.instantiate()
		if modal_dialog_instance:
			modal_dialog_instance.dialog_confirmed.connect(_on_dialog_confirmed)
			modal_dialog_instance.dialog_cancelled.connect(_on_dialog_cancelled)
			add_child(modal_dialog_instance)
			modal_dialog_instance.show_dialog("Test Dialog", "This is a test dialog message.")
			print("TestComponents: Modal dialog instantiated successfully")
		else:
			print("TestComponents: Error - Failed to instantiate modal dialog")
	else:
		print("TestComponents: Error - Failed to load modal dialog scene")

func _on_test_hud_pressed() -> void:
	"""Test HUD component"""
	print("TestComponents: Testing HUD")
	
	# Load and instantiate HUD
	var hud_scene = load("res://scenes/components/hud.tscn")
	if hud_scene:
		hud_instance = hud_scene.instantiate()
		if hud_instance:
			hud_instance.hud_element_clicked.connect(_on_hud_element_clicked)
			add_child(hud_instance)
			hud_instance.update_money_display(150.50)
			hud_instance.update_status_display("Testing")
			hud_instance.update_production_info(5)
			hud_instance.update_queue_info(3, 10)
			print("TestComponents: HUD instantiated successfully")
		else:
			print("TestComponents: Error - Failed to instantiate HUD")
	else:
		print("TestComponents: Error - Failed to load HUD scene")

func _on_back_button_pressed() -> void:
	"""Return to main scene"""
	print("TestComponents: Returning to main scene")
	get_tree().change_scene_to_file("res://scenes/main/main_scene.tscn")

# Component signal handlers
func _on_custom_button_clicked(button_id: String) -> void:
	print("TestComponents: Custom button clicked - %s" % button_id)
	if custom_button_instance:
		custom_button_instance.queue_free()
		custom_button_instance = null

func _on_custom_panel_opened() -> void:
	print("TestComponents: Custom panel opened")
	# Auto-close after 2 seconds
	await get_tree().create_timer(2.0).timeout
	if custom_panel_instance and custom_panel_instance.has_method("hide_panel"):
		custom_panel_instance.hide_panel()

func _on_custom_panel_closed() -> void:
	print("TestComponents: Custom panel closed")
	if custom_panel_instance:
		custom_panel_instance.queue_free()
		custom_panel_instance = null

func _on_dialog_confirmed() -> void:
	print("TestComponents: Dialog confirmed")
	if modal_dialog_instance:
		modal_dialog_instance.queue_free()
		modal_dialog_instance = null

func _on_dialog_cancelled() -> void:
	print("TestComponents: Dialog cancelled")
	if modal_dialog_instance:
		modal_dialog_instance.queue_free()
		modal_dialog_instance = null

func _on_hud_element_clicked(element_id: String) -> void:
	print("TestComponents: HUD element clicked - %s" % element_id)
	if hud_instance:
		hud_instance.queue_free()
		hud_instance = null 