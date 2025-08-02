extends Panel

## Custom Panel Component with title and content management

signal panel_opened
signal panel_closed

@export var panel_title: String = ""
@export var auto_show: bool = false

@onready var title_label: Label = $TitleLabel
@onready var content_container: VBoxContainer = $ContentContainer

func _ready() -> void:
	"""Initialize the custom panel"""
	update_display()
	
	# Only auto-hide if explicitly set to false and not auto-show
	if not auto_show:
		# Don't automatically hide - let the parent control visibility
		pass

func update_display() -> void:
	"""Update panel display with current title"""
	if title_label:
		title_label.text = panel_title

func show_panel() -> void:
	"""Show the panel"""
	visible = true
	print("CustomPanel: Panel opened - %s" % panel_title)
	panel_opened.emit()

func hide_panel() -> void:
	"""Hide the panel"""
	visible = false
	print("CustomPanel: Panel closed - %s" % panel_title)
	panel_closed.emit()

func set_panel_title(title: String) -> void:
	"""Set panel title"""
	panel_title = title
	update_display()

func add_content(node: Node) -> void:
	"""Add content to the panel"""
	if content_container:
		content_container.add_child(node)

func remove_content(node: Node) -> void:
	"""Remove content from the panel"""
	if content_container and node.get_parent() == content_container:
		content_container.remove_child(node)

func clear_content() -> void:
	"""Clear all content from the panel"""
	if content_container:
		for child in content_container.get_children():
			content_container.remove_child(child)

func get_content_container() -> VBoxContainer:
	"""Get the content container for direct manipulation"""
	return content_container 