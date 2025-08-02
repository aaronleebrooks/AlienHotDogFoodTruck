extends Control

## Modal Dialog Component with signal-based communication

signal dialog_closed
signal dialog_confirmed
signal dialog_cancelled

@export var dialog_title: String = ""
@export var dialog_content: String = ""
@export var show_confirm_button: bool = true
@export var show_cancel_button: bool = true

@onready var title_label: Label = $DialogPanel/VBoxContainer/TitleLabel
@onready var content_label: Label = $DialogPanel/VBoxContainer/ContentLabel
@onready var confirm_button: Button = $DialogPanel/VBoxContainer/ButtonContainer/ConfirmButton
@onready var cancel_button: Button = $DialogPanel/VBoxContainer/ButtonContainer/CancelButton

func _ready() -> void:
	"""Initialize the modal dialog"""
	connect_signals()
	update_display()
	hide_dialog()

func connect_signals() -> void:
	"""Connect button signals"""
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

func show_dialog(title: String = "", content: String = "") -> void:
	"""Show the dialog with optional title and content"""
	if title != "":
		dialog_title = title
	if content != "":
		dialog_content = content
	
	update_display()
	visible = true
	print("ModalDialog: Dialog shown - %s" % dialog_title)

func hide_dialog() -> void:
	"""Hide the dialog"""
	visible = false
	print("ModalDialog: Dialog hidden")

func update_display() -> void:
	"""Update dialog display with current title and content"""
	if title_label:
		title_label.text = dialog_title
	if content_label:
		content_label.text = dialog_content
	
	# Update button visibility
	if confirm_button:
		confirm_button.visible = show_confirm_button
	if cancel_button:
		cancel_button.visible = show_cancel_button

func _on_confirm_pressed() -> void:
	"""Handle confirm button press"""
	print("ModalDialog: Dialog confirmed - %s" % dialog_title)
	dialog_confirmed.emit()
	hide_dialog()
	dialog_closed.emit()

func _on_cancel_pressed() -> void:
	"""Handle cancel button press"""
	print("ModalDialog: Dialog cancelled - %s" % dialog_title)
	dialog_cancelled.emit()
	hide_dialog()
	dialog_closed.emit()

func set_dialog_title(title: String) -> void:
	"""Set dialog title"""
	dialog_title = title
	update_display()

func set_dialog_content(content: String) -> void:
	"""Set dialog content"""
	dialog_content = content
	update_display()

func set_button_visibility(show_confirm: bool, show_cancel: bool) -> void:
	"""Set button visibility"""
	show_confirm_button = show_confirm
	show_cancel_button = show_cancel
	update_display()

func _input(event: InputEvent) -> void:
	"""Handle input events"""
	if visible and event.is_action_pressed("ui_cancel"):
		# Close dialog on Escape key
		_on_cancel_pressed() 