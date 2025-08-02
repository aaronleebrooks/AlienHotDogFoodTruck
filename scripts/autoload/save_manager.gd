extends Node
class_name SaveManager

## Simple SaveManager autoload for basic save/load functionality

# Save file path
const SAVE_FILE_PATH = "user://save_data.json"

# Current save data
var save_data: Dictionary = {}

# Signals
signal save_completed
signal load_completed
signal save_failed
signal load_failed

func _ready() -> void:
	"""Initialize the SaveManager"""
	print("SaveManager: Initialized")

func save_game() -> void:
	"""Save the current game data"""
	print("SaveManager: Saving game...")
	
	# Create save data dictionary
	save_data = {
		"game_time": GameManager.get_game_time(),
		"is_game_running": GameManager.is_game_running,
		"save_timestamp": Time.get_unix_time_from_system()
	}
	
	# Save to file
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("SaveManager: Game saved successfully")
		save_completed.emit()
	else:
		print("SaveManager: Failed to save game")
		save_failed.emit()

func load_game() -> void:
	"""Load the saved game data"""
	print("SaveManager: Loading game...")
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			save_data = json.data
			print("SaveManager: Game loaded successfully")
			load_completed.emit()
		else:
			print("SaveManager: Failed to parse save data")
			load_failed.emit()
	else:
		print("SaveManager: No save file found")
		load_failed.emit()

func has_save_file() -> bool:
	"""Check if a save file exists"""
	return FileAccess.file_exists(SAVE_FILE_PATH)

func get_save_data() -> Dictionary:
	"""Get the current save data"""
	return save_data 