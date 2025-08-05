extends Node

## SaveManager autoload for comprehensive save/load functionality

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
	
	# Get references to systems (accessed through main scene)
	var main_scene = get_tree().current_scene
	var production_system = main_scene.get_node_or_null("Systems/ProductionSystem")
	var economy_system = main_scene.get_node_or_null("Systems/EconomySystem")
	
	# Create comprehensive save data dictionary
	save_data = {
		"game_time": GameManager.get_game_time(),
		"is_game_running": GameManager.is_game_running,
		"save_timestamp": Time.get_unix_time_from_system(),
		"economy": {
			"current_money": economy_system.get_current_money() if economy_system else 100.0,
			"total_earned": economy_system.get_economy_stats()["total_earned"] if economy_system else 0.0,
			"total_spent": economy_system.get_economy_stats()["total_spent"] if economy_system else 0.0,
			"transactions_count": economy_system.get_economy_stats()["transactions_count"] if economy_system else 0
		},
		"production": {
			"is_producing": production_system.get_production_statistics()["is_producing"] if production_system else false,
			"current_queue_size": production_system.get_production_statistics()["current_size"] if production_system else 0,
			"total_produced": production_system.get_production_statistics()["total_produced"] if production_system else 0,
			"production_rate": production_system.get_production_statistics()["current_rate"] if production_system else 1.0
		}
	}
	
	# Save to file
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("SaveManager: Game saved successfully")
		print("SaveManager: Saved data: %s" % save_data)
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
			print("SaveManager: Loaded data: %s" % save_data)
			load_completed.emit()
		else:
			print("SaveManager: Failed to parse save data")
			load_failed.emit()
	else:
		print("SaveManager: No save file found")
		load_failed.emit()

func restore_game_state() -> void:
	"""Restore the loaded game state to all systems"""
	print("SaveManager: Restoring game state...")
	
	if save_data.is_empty():
		print("SaveManager: No save data to restore")
		return
	
	# Get references to systems
	var main_scene = get_tree().current_scene
	var production_system = main_scene.get_node_or_null("Systems/ProductionSystem")
	var economy_system = main_scene.get_node_or_null("Systems/EconomySystem")
	
	# Restore GameManager state
	if "game_time" in save_data:
		# Note: GameManager doesn't have a set_game_time method, so we'll start fresh
		# but keep track of the saved time for display purposes
		pass
	
	# Restore Economy state
	if economy_system and "economy" in save_data:
		var economy_data = save_data["economy"]
		# Set money directly (we'll need to add a method to EconomySystem)
		if "current_money" in economy_data:
			economy_system.set_current_money(economy_data["current_money"])
			print("SaveManager: Restored money: $%.2f" % economy_data["current_money"])
	
	# Restore Production state
	if production_system and "production" in save_data:
		var production_data = save_data["production"]
		if "current_queue_size" in production_data:
			# Add items to queue to restore production state
			var queue_size = production_data["current_queue_size"]
			for i in range(queue_size):
				production_system.add_to_queue()
			print("SaveManager: Restored production queue: %d items" % queue_size)
	
	print("SaveManager: Game state restored successfully")

func has_save_file() -> bool:
	"""Check if a save file exists"""
	return FileAccess.file_exists(SAVE_FILE_PATH)

func get_save_data() -> Dictionary:
	"""Get the current save data"""
	return save_data

func get_save_info() -> Dictionary:
	"""Get save file information for display"""
	if has_save_file():
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var data = json.data
				return {
					"exists": true,
					"timestamp": data.get("save_timestamp", 0),
					"game_time": data.get("game_time", 0.0),
					"money": data.get("economy", {}).get("current_money", 0.0)
				}
	
	return {"exists": false} 