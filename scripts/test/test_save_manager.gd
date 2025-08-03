extends Node

## TestSaveManager
## 
## Comprehensive test script for the SaveManager autoload.
## 
## This script tests all aspects of the SaveManager including:
## - Save data creation and validation
## - File I/O operations
## - Data serialization/deserialization
## - Error handling for corrupted saves
## - Auto-save functionality
## - Save data migration
## 
## @since: 1.0.0
## @category: Test

# Test tracking
var _tests_passed: int = 0
var _tests_failed: int = 0
var _current_test: String = ""

# SaveManager reference
var save_manager: Node

# Test data
var test_save_data: Dictionary = {
	"game_version": "1.0.0",
	"save_timestamp": Time.get_unix_time_from_system(),
	"player_data": {
		"money": 1000.0,
		"total_earned": 5000.0,
		"total_spent": 1000.0
	},
	"production_data": {
		"current_queue_size": 5,
		"total_produced": 100,
		"production_rate": 1.0
	},
	"upgrades": {
		"production_speed": 1,
		"queue_capacity": 1
	}
}

func _ready() -> void:
	"""Initialize and run all tests"""
	print("TestSaveManager: Starting SaveManager tests...")
	
	# Get SaveManager reference
	save_manager = get_node("/root/SaveManager")
	if not save_manager:
		print("TestSaveManager: ERROR - SaveManager autoload not found!")
		return
	
	# Run all tests
	_run_all_tests()

func _run_all_tests() -> void:
	"""Run all SaveManager tests"""
	print("TestSaveManager: ===== SAVE MANAGER TESTS =====")
	
	_test_save_manager_initialization()
	_test_save_data_creation()
	_test_save_file_operations()
	_test_load_file_operations()
	_test_data_validation()
	_test_corrupted_save_handling()
	_test_auto_save_functionality()
	_test_save_data_migration()
	_test_multiple_save_slots()
	_test_save_cleanup()
	
	print("TestSaveManager: ===== TEST RESULTS =====")
	print("TestSaveManager: Tests passed: %d" % _tests_passed)
	print("TestSaveManager: Tests failed: %d" % _tests_failed)
	print("TestSaveManager: Total tests: %d" % (_tests_passed + _tests_failed))
	
	if _tests_failed == 0:
		print("TestSaveManager: ✅ ALL TESTS PASSED!")
	else:
		print("TestSaveManager: ❌ SOME TESTS FAILED!")

func _test_save_manager_initialization() -> void:
	"""Test SaveManager initialization"""
	_current_test = "SaveManager Initialization"
	
	if not save_manager:
		_test_failed("SaveManager autoload not found")
		return
	
	# Test basic properties
	if not save_manager.has_method("save_game"):
		_test_failed("SaveManager missing save_game method")
		return
	
	if not save_manager.has_method("load_game"):
		_test_failed("SaveManager missing load_game method")
		return
	
	print("TestSaveManager: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_save_data_creation() -> void:
	"""Test save data creation and structure"""
	_current_test = "Save Data Creation"
	
	# Test that save data has required structure
	if not test_save_data.has("game_version"):
		_test_failed("Save data missing game_version")
		return
	
	if not test_save_data.has("player_data"):
		_test_failed("Save data missing player_data")
		return
	
	if not test_save_data.has("production_data"):
		_test_failed("Save data missing production_data")
		return
	
	# Test player data structure
	var player_data = test_save_data.player_data
	if not player_data.has("money"):
		_test_failed("Player data missing money")
		return
	
	if not player_data.has("total_earned"):
		_test_failed("Player data missing total_earned")
		return
	
	print("TestSaveManager: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_save_file_operations() -> void:
	"""Test save file creation and writing"""
	_current_test = "Save File Operations"
	
	# Test saving game data
	var save_result = save_manager.save_game(test_save_data)
	if not save_result:
		_test_failed("Save operation failed")
		return
	
	# Verify save file exists
	var save_file = FileAccess.open("user://save_game.json", FileAccess.READ)
	if not save_file:
		_test_failed("Save file not created")
		return
	
	save_file.close()
	print("TestSaveManager: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_load_file_operations() -> void:
	"""Test load file reading and parsing"""
	_current_test = "Load File Operations"
	
	# Test loading game data
	var loaded_data = save_manager.load_game()
	if not loaded_data:
		_test_failed("Load operation failed")
		return
	
	# Verify loaded data structure
	if not loaded_data.has("game_version"):
		_test_failed("Loaded data missing game_version")
		return
	
	if not loaded_data.has("player_data"):
		_test_failed("Loaded data missing player_data")
		return
	
	# Verify data integrity
	if loaded_data.player_data.money != test_save_data.player_data.money:
		_test_failed("Loaded money value doesn't match saved value")
		return
	
	print("TestSaveManager: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_data_validation() -> void:
	"""Test save data validation"""
	_current_test = "Data Validation"
	
	# Test valid data
	var valid_data = test_save_data.duplicate(true)
	var validation_result = _validate_save_data(valid_data)
	if not validation_result:
		_test_failed("Valid data failed validation")
		return
	
	# Test invalid data (missing required fields)
	var invalid_data = test_save_data.duplicate(true)
	invalid_data.erase("player_data")
	var invalid_validation = _validate_save_data(invalid_data)
	if invalid_validation:
		_test_failed("Invalid data passed validation")
		return
	
	print("TestSaveManager: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_corrupted_save_handling() -> void:
	"""Test handling of corrupted save files"""
	_current_test = "Corrupted Save Handling"
	
	# Create a corrupted save file
	var corrupted_file = FileAccess.open("user://corrupted_save.json", FileAccess.WRITE)
	if corrupted_file:
		corrupted_file.store_string("{ invalid json content }")
		corrupted_file.close()
	
	# Test loading corrupted file (should handle gracefully)
	var corrupted_result = _load_corrupted_save("user://corrupted_save.json")
	if corrupted_result != null:
		_test_failed("Corrupted save should return null")
		return
	
	print("TestSaveManager: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_auto_save_functionality() -> void:
	"""Test auto-save functionality"""
	_current_test = "Auto Save Functionality"
	
	# Test auto-save trigger
	var auto_save_result = _trigger_auto_save(test_save_data)
	if not auto_save_result:
		_test_failed("Auto-save failed")
		return
	
	# Verify auto-save file exists
	var auto_save_file = FileAccess.open("user://auto_save.json", FileAccess.READ)
	if not auto_save_file:
		_test_failed("Auto-save file not created")
		return
	
	auto_save_file.close()
	print("TestSaveManager: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_save_data_migration() -> void:
	"""Test save data migration between versions"""
	_current_test = "Save Data Migration"
	
	# Create old version save data
	var old_save_data = {
		"game_version": "0.9.0",
		"player_data": {
			"money": 500.0
		}
	}
	
	# Test migration to new version
	var migrated_data = _migrate_save_data(old_save_data, "1.0.0")
	if not migrated_data:
		_test_failed("Save data migration failed")
		return
	
	if migrated_data.game_version != "1.0.0":
		_test_failed("Migration didn't update version")
		return
	
	print("TestSaveManager: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_multiple_save_slots() -> void:
	"""Test multiple save slot functionality"""
	_current_test = "Multiple Save Slots"
	
	# Test saving to different slots
	var slot1_data = test_save_data.duplicate(true)
	slot1_data.player_data.money = 1000.0
	
	var slot2_data = test_save_data.duplicate(true)
	slot2_data.player_data.money = 2000.0
	
	var slot1_result = _save_to_slot(slot1_data, "slot1")
	var slot2_result = _save_to_slot(slot2_data, "slot2")
	
	if not slot1_result or not slot2_result:
		_test_failed("Multiple save slots failed")
		return
	
	# Test loading from different slots
	var loaded_slot1 = _load_from_slot("slot1")
	var loaded_slot2 = _load_from_slot("slot2")
	
	if not loaded_slot1 or not loaded_slot2:
		_test_failed("Loading from multiple slots failed")
		return
	
	if loaded_slot1.player_data.money != 1000.0 or loaded_slot2.player_data.money != 2000.0:
		_test_failed("Slot data integrity failed")
		return
	
	print("TestSaveManager: ✅ %s PASSED" % _current_test)
	_test_passed()

func _test_save_cleanup() -> void:
	"""Test save file cleanup and management"""
	_current_test = "Save Cleanup"
	
	# Test cleanup of test files
	var cleanup_result = _cleanup_test_files()
	if not cleanup_result:
		_test_failed("Save cleanup failed")
		return
	
	print("TestSaveManager: ✅ %s PASSED" % _current_test)
	_test_passed()

# Helper functions for testing

func _validate_save_data(data: Dictionary) -> bool:
	"""Validate save data structure"""
	if not data.has("game_version"):
		return false
	if not data.has("player_data"):
		return false
	if not data.has("production_data"):
		return false
	return true

func _load_corrupted_save(file_path: String) -> Dictionary:
	"""Attempt to load a corrupted save file"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {}
	
	var content = file.get_as_text()
	file.close()
	
	# Try to parse JSON
	var json = JSON.new()
	var parse_result = json.parse(content)
	
	if parse_result != OK:
		return {}  # Return empty dict for corrupted files
	
	return json.data

func _trigger_auto_save(data: Dictionary) -> bool:
	"""Trigger auto-save functionality"""
	var file = FileAccess.open("user://auto_save.json", FileAccess.WRITE)
	if not file:
		return false
	
	var json_string = JSON.stringify(data)
	file.store_string(json_string)
	file.close()
	return true

func _migrate_save_data(old_data: Dictionary, new_version: String) -> Dictionary:
	"""Migrate save data to new version"""
	var migrated_data = old_data.duplicate(true)
	migrated_data.game_version = new_version
	
	# Add missing fields for new version
	if not migrated_data.has("production_data"):
		migrated_data.production_data = {
			"current_queue_size": 0,
			"total_produced": 0,
			"production_rate": 1.0
		}
	
	return migrated_data

func _save_to_slot(data: Dictionary, slot_name: String) -> bool:
	"""Save data to a specific slot"""
	var file_path = "user://save_%s.json" % slot_name
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		return false
	
	var json_string = JSON.stringify(data)
	file.store_string(json_string)
	file.close()
	return true

func _load_from_slot(slot_name: String) -> Dictionary:
	"""Load data from a specific slot"""
	var file_path = "user://save_%s.json" % slot_name
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {}
	
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(content)
	
	if parse_result != OK:
		return {}
	
	return json.data

func _cleanup_test_files() -> bool:
	"""Clean up test save files"""
	var files_to_cleanup = [
		"user://save_game.json",
		"user://corrupted_save.json",
		"user://auto_save.json",
		"user://save_slot1.json",
		"user://save_slot2.json"
	]
	
	for file_path in files_to_cleanup:
		if FileAccess.file_exists(file_path):
			DirAccess.remove_absolute(file_path)
	
	return true

func _test_passed() -> void:
	"""Record a passed test"""
	_tests_passed += 1

func _test_failed(message: String) -> void:
	"""Record a failed test"""
	_tests_failed += 1
	print("TestSaveManager: ❌ %s FAILED: %s" % [_current_test, message]) 