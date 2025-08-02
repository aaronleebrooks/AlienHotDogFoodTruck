extends Node

## SceneManager autoload for managing scene dependencies and transitions

# Scene registry
var scene_registry: Dictionary = {}
var current_scene: Node
var scene_stack: Array[String] = []

# Signals
signal scene_changed(new_scene: String, old_scene: String)
signal scene_loaded(scene_name: String)
signal scene_unloaded(scene_name: String)
signal scene_transition_started(from_scene: String, to_scene: String)
signal scene_transition_completed(to_scene: String)

func _ready() -> void:
	"""Initialize the SceneManager"""
	print("SceneManager: Initialized")
	register_default_scenes()

func register_default_scenes() -> void:
	"""Register default scenes"""
	register_scene("main", "res://scenes/main/main_scene.tscn")
	register_scene("menu", "res://scenes/ui/menu_ui.tscn")
	register_scene("game", "res://scenes/ui/game_ui.tscn")
	register_scene("hud", "res://scenes/components/hud.tscn")
	register_scene("modal_dialog", "res://scenes/components/modal_dialog.tscn")
	register_scene("custom_button", "res://scenes/components/custom_button.tscn")
	register_scene("custom_panel", "res://scenes/components/custom_panel.tscn")

func register_scene(scene_name: String, scene_path: String) -> void:
	"""Register a scene with its dependencies"""
	scene_registry[scene_name] = {
		"path": scene_path,
		"dependencies": [],
		"loaded": false
	}
	print("SceneManager: Registered scene '%s' at '%s'" % [scene_name, scene_path])

func add_scene_dependency(scene_name: String, dependency_name: String) -> void:
	"""Add a dependency to a scene"""
	if scene_name in scene_registry:
		if dependency_name not in scene_registry[scene_name]["dependencies"]:
			scene_registry[scene_name]["dependencies"].append(dependency_name)
			print("SceneManager: Added dependency '%s' to scene '%s'" % [dependency_name, scene_name])

func load_scene(scene_name: String) -> Node:
	"""Load a scene and its dependencies"""
	if scene_name not in scene_registry:
		print("SceneManager: Error - Scene '%s' not registered" % scene_name)
		return null
	
	var scene_info = scene_registry[scene_name]
	var scene_path = scene_info["path"]
	
	# Load dependencies first
	for dependency in scene_info["dependencies"]:
		if not scene_registry[dependency]["loaded"]:
			load_scene(dependency)
	
	# Load the scene
	var scene_resource = load(scene_path)
	if scene_resource:
		var scene_instance = scene_resource.instantiate()
		scene_registry[scene_name]["loaded"] = true
		scene_loaded.emit(scene_name)
		print("SceneManager: Loaded scene '%s'" % scene_name)
		return scene_instance
	else:
		print("SceneManager: Error - Failed to load scene '%s' from '%s'" % [scene_name, scene_path])
		return null

func unload_scene(scene_name: String) -> void:
	"""Unload a scene"""
	if scene_name in scene_registry:
		scene_registry[scene_name]["loaded"] = false
		scene_unloaded.emit(scene_name)
		print("SceneManager: Unloaded scene '%s'" % scene_name)

func change_scene(scene_name: String) -> void:
	"""Change to a new scene"""
	var old_scene_name = ""
	if current_scene:
		old_scene_name = current_scene.name
	
	scene_transition_started.emit(old_scene_name, scene_name)
	
	# Load new scene
	var new_scene = load_scene(scene_name)
	if new_scene:
		# Unload current scene if it exists
		if current_scene:
			current_scene.queue_free()
		
		# Set new scene
		current_scene = new_scene
		get_tree().current_scene.add_child(new_scene)
		
		scene_changed.emit(scene_name, old_scene_name)
		scene_transition_completed.emit(scene_name)
		print("SceneManager: Changed to scene '%s'" % scene_name)

func push_scene(scene_name: String) -> void:
	"""Push a scene onto the stack"""
	scene_stack.append(scene_name)
	change_scene(scene_name)

func pop_scene() -> void:
	"""Pop the top scene from the stack"""
	if scene_stack.size() > 1:
		scene_stack.pop_back()
		var previous_scene = scene_stack.back()
		change_scene(previous_scene)

func get_scene_info(scene_name: String) -> Dictionary:
	"""Get information about a scene"""
	if scene_name in scene_registry:
		return scene_registry[scene_name].duplicate()
	return {}

func is_scene_loaded(scene_name: String) -> bool:
	"""Check if a scene is loaded"""
	if scene_name in scene_registry:
		return scene_registry[scene_name]["loaded"]
	return false

func get_current_scene_name() -> String:
	"""Get the name of the current scene"""
	if current_scene:
		return current_scene.name
	return ""

func get_scene_stack() -> Array[String]:
	"""Get the current scene stack"""
	return scene_stack.duplicate() 