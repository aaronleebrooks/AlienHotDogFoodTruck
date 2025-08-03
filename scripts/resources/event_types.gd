extends Resource
class_name EventTypes

## EventTypes
## 
## Centralized definition of all event types and their data structures.
## 
## This resource provides type-safe event definitions for the entire game.
## It ensures consistency in event naming and data structure across all
## systems and prevents errors from mismatched event data.
## 
## Features:
##   - Type-safe event definitions
##   - Structured event data validation
##   - Event category organization
##   - Documentation for each event type
##   - Default data templates
## 
## Example:
##   var event_data = EventTypes.PRODUCTION_COMPLETE.create_data({
##       "hot_dogs_produced": 10,
##       "production_time": 5.0
##   })
##   EventBus.emit_event(EventTypes.PRODUCTION_COMPLETE.name, event_data)
## 
## @since: 1.0.0
## @category: Resource

# Event Categories
enum EventCategory {
	PRODUCTION,
	ECONOMY,
	UI,
	SYSTEM,
	SAVE,
	UPGRADE,
	STAFF,
	LOCATION,
	EVENT,
	ANALYTICS
}

# Production Events
class ProductionEvent:
	extends Resource
	
	static var HOT_DOG_PRODUCED = EventDefinition.new(
		"hot_dog_produced",
		EventCategory.PRODUCTION,
		{
			"amount": 0,
			"production_time": 0.0,
			"quality": 1.0
		},
		"Emitted when hot dogs are produced"
	)
	
	static var PRODUCTION_STARTED = EventDefinition.new(
		"production_started",
		EventCategory.PRODUCTION,
		{
			"production_rate": 1.0,
			"queue_size": 0
		},
		"Emitted when production begins"
	)
	
	static var PRODUCTION_STOPPED = EventDefinition.new(
		"production_stopped",
		EventCategory.PRODUCTION,
		{
			"reason": "manual",
			"total_produced": 0
		},
		"Emitted when production stops"
	)
	
	static var PRODUCTION_QUEUE_UPDATED = EventDefinition.new(
		"production_queue_updated",
		EventCategory.PRODUCTION,
		{
			"queue_size": 0,
			"max_capacity": 100
		},
		"Emitted when production queue changes"
	)

# Economy Events
class EconomyEvent:
	extends Resource
	
	static var MONEY_CHANGED = EventDefinition.new(
		"money_changed",
		EventCategory.ECONOMY,
		{
			"amount": 0.0,
			"change": 0.0,
			"reason": "unknown"
		},
		"Emitted when money amount changes"
	)
	
	static var HOT_DOG_SOLD = EventDefinition.new(
		"hot_dog_sold",
		EventCategory.ECONOMY,
		{
			"amount": 1,
			"price": 5.0,
			"total_revenue": 0.0
		},
		"Emitted when hot dogs are sold"
	)
	
	static var UPGRADE_PURCHASED = EventDefinition.new(
		"upgrade_purchased",
		EventCategory.ECONOMY,
		{
			"upgrade_id": "",
			"cost": 0.0,
			"new_level": 1
		},
		"Emitted when an upgrade is purchased"
	)

# UI Events
class UIEvent:
	extends Resource
	
	static var UI_UPDATE_REQUESTED = EventDefinition.new(
		"ui_update_requested",
		EventCategory.UI,
		{
			"ui_component": "",
			"update_type": "full"
		},
		"Emitted when UI needs to be updated"
	)
	
	static var DIALOG_SHOWN = EventDefinition.new(
		"dialog_shown",
		EventCategory.UI,
		{
			"dialog_id": "",
			"dialog_type": "info"
		},
		"Emitted when a dialog is shown"
	)
	
	static var DIALOG_CLOSED = EventDefinition.new(
		"dialog_closed",
		EventCategory.UI,
		{
			"dialog_id": "",
			"result": "cancelled"
		},
		"Emitted when a dialog is closed"
	)
	
	static var SCREEN_CHANGED = EventDefinition.new(
		"screen_changed",
		EventCategory.UI,
		{
			"from_screen": "",
			"to_screen": "",
			"transition_type": "fade"
		},
		"Emitted when the active screen changes"
	)

# System Events
class SystemEvent:
	extends Resource
	
	static var GAME_STARTED = EventDefinition.new(
		"game_started",
		EventCategory.SYSTEM,
		{
			"game_mode": "new",
			"timestamp": 0
		},
		"Emitted when the game starts"
	)
	
	static var GAME_PAUSED = EventDefinition.new(
		"game_paused",
		EventCategory.SYSTEM,
		{
			"pause_reason": "user"
		},
		"Emitted when the game is paused"
	)
	
	static var GAME_RESUMED = EventDefinition.new(
		"game_resumed",
		EventCategory.SYSTEM,
		{
			"resume_reason": "user"
		},
		"Emitted when the game is resumed"
	)
	
	static var SYSTEM_ERROR = EventDefinition.new(
		"system_error",
		EventCategory.SYSTEM,
		{
			"error_code": "",
			"error_message": "",
			"system_name": ""
		},
		"Emitted when a system error occurs"
	)

# Save Events
class SaveEvent:
	extends Resource
	
	static var GAME_SAVED = EventDefinition.new(
		"game_saved",
		EventCategory.SAVE,
		{
			"save_slot": 1,
			"save_time": 0,
			"game_time": 0.0
		},
		"Emitted when the game is saved"
	)
	
	static var GAME_LOADED = EventDefinition.new(
		"game_loaded",
		EventCategory.SAVE,
		{
			"save_slot": 1,
			"load_time": 0,
			"game_time": 0.0
		},
		"Emitted when the game is loaded"
	)

# Upgrade Events
class UpgradeEvent:
	extends Resource
	
	static var UPGRADE_AVAILABLE = EventDefinition.new(
		"upgrade_available",
		EventCategory.UPGRADE,
		{
			"upgrade_id": "",
			"upgrade_name": "",
			"cost": 0.0
		},
		"Emitted when an upgrade becomes available"
	)
	
	static var UPGRADE_COMPLETED = EventDefinition.new(
		"upgrade_completed",
		EventCategory.UPGRADE,
		{
			"upgrade_id": "",
			"new_level": 1,
			"effects": {}
		},
		"Emitted when an upgrade is completed"
	)

# Staff Events
class StaffEvent:
	extends Resource
	
	static var STAFF_HIRED = EventDefinition.new(
		"staff_hired",
		EventCategory.STAFF,
		{
			"staff_id": "",
			"staff_name": "",
			"position": "",
			"salary": 0.0
		},
		"Emitted when staff is hired"
	)
	
	static var STAFF_FIRED = EventDefinition.new(
		"staff_fired",
		EventCategory.STAFF,
		{
			"staff_id": "",
			"reason": "performance"
		},
		"Emitted when staff is fired"
	)
	
	static var STAFF_PROMOTED = EventDefinition.new(
		"staff_promoted",
		EventCategory.STAFF,
		{
			"staff_id": "",
			"new_position": "",
			"new_salary": 0.0
		},
		"Emitted when staff is promoted"
	)

# Location Events
class LocationEvent:
	extends Resource
	
	static var LOCATION_UNLOCKED = EventDefinition.new(
		"location_unlocked",
		EventCategory.LOCATION,
		{
			"location_id": "",
			"location_name": "",
			"unlock_cost": 0.0
		},
		"Emitted when a new location is unlocked"
	)
	
	static var LOCATION_ACTIVATED = EventDefinition.new(
		"location_activated",
		EventCategory.LOCATION,
		{
			"location_id": "",
			"activation_cost": 0.0
		},
		"Emitted when a location is activated"
	)

# Event System Events
class GameEvent:
	extends Resource
	
	static var SPECIAL_EVENT_STARTED = EventDefinition.new(
		"special_event_started",
		EventCategory.EVENT,
		{
			"event_id": "",
			"event_name": "",
			"duration": 0.0
		},
		"Emitted when a special event starts"
	)
	
	static var SPECIAL_EVENT_ENDED = EventDefinition.new(
		"special_event_ended",
		EventCategory.EVENT,
		{
			"event_id": "",
			"rewards": {}
		},
		"Emitted when a special event ends"
	)

# Analytics Events
class AnalyticsEvent:
	extends Resource
	
	static var ACHIEVEMENT_UNLOCKED = EventDefinition.new(
		"achievement_unlocked",
		EventCategory.ANALYTICS,
		{
			"achievement_id": "",
			"achievement_name": "",
			"progress": 100.0
		},
		"Emitted when an achievement is unlocked"
	)
	
	static var MILESTONE_REACHED = EventDefinition.new(
		"milestone_reached",
		EventCategory.ANALYTICS,
		{
			"milestone_id": "",
			"milestone_name": "",
			"value": 0.0
		},
		"Emitted when a milestone is reached"
	)

# Event Definition Class
class EventDefinition:
	extends Resource
	
	var name: String
	var category: EventCategory
	var default_data: Dictionary
	var description: String
	
	func _init(event_name: String, event_category: EventCategory, data: Dictionary, desc: String):
		name = event_name
		category = event_category
		default_data = data
		description = desc
	
	func create_data(custom_data: Dictionary = {}) -> Dictionary:
		"""Create event data with custom values merged with defaults"""
		var data = default_data.duplicate()
		for key in custom_data:
			if data.has(key):
				data[key] = custom_data[key]
		return data
	
	func validate_data(data: Dictionary) -> bool:
		"""Validate that data contains all required fields"""
		for key in default_data:
			if not data.has(key):
				return false
		return true

# Utility functions
static func get_all_events() -> Array[EventDefinition]:
	"""Get all defined events"""
	var events: Array[EventDefinition] = []
	
	# Production events
	events.append(ProductionEvent.HOT_DOG_PRODUCED)
	events.append(ProductionEvent.PRODUCTION_STARTED)
	events.append(ProductionEvent.PRODUCTION_STOPPED)
	events.append(ProductionEvent.PRODUCTION_QUEUE_UPDATED)
	
	# Economy events
	events.append(EconomyEvent.MONEY_CHANGED)
	events.append(EconomyEvent.HOT_DOG_SOLD)
	events.append(EconomyEvent.UPGRADE_PURCHASED)
	
	# UI events
	events.append(UIEvent.UI_UPDATE_REQUESTED)
	events.append(UIEvent.DIALOG_SHOWN)
	events.append(UIEvent.DIALOG_CLOSED)
	events.append(UIEvent.SCREEN_CHANGED)
	
	# System events
	events.append(SystemEvent.GAME_STARTED)
	events.append(SystemEvent.GAME_PAUSED)
	events.append(SystemEvent.GAME_RESUMED)
	events.append(SystemEvent.SYSTEM_ERROR)
	
	# Save events
	events.append(SaveEvent.GAME_SAVED)
	events.append(SaveEvent.GAME_LOADED)
	
	# Upgrade events
	events.append(UpgradeEvent.UPGRADE_AVAILABLE)
	events.append(UpgradeEvent.UPGRADE_COMPLETED)
	
	# Staff events
	events.append(StaffEvent.STAFF_HIRED)
	events.append(StaffEvent.STAFF_FIRED)
	events.append(StaffEvent.STAFF_PROMOTED)
	
	# Location events
	events.append(LocationEvent.LOCATION_UNLOCKED)
	events.append(LocationEvent.LOCATION_ACTIVATED)
	
	# Game events
	events.append(GameEvent.SPECIAL_EVENT_STARTED)
	events.append(GameEvent.SPECIAL_EVENT_ENDED)
	
	# Analytics events
	events.append(AnalyticsEvent.ACHIEVEMENT_UNLOCKED)
	events.append(AnalyticsEvent.MILESTONE_REACHED)
	
	return events

static func get_events_by_category(category: EventCategory) -> Array[EventDefinition]:
	"""Get all events for a specific category"""
	var events = get_all_events()
	var filtered_events: Array[EventDefinition] = []
	
	for event in events:
		if event.category == category:
			filtered_events.append(event)
	
	return filtered_events

static func find_event_by_name(event_name: String) -> EventDefinition:
	"""Find an event definition by name"""
	var events = get_all_events()
	
	for event in events:
		if event.name == event_name:
			return event
	
	return null 