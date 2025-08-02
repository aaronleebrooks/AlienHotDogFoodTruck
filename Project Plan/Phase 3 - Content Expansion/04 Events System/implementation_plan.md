# Events System - Implementation Plan

## Overview
This document provides a detailed step-by-step implementation plan for the Events System, which adds dynamic content and engagement through time-limited events and special challenges.

## Implementation Timeline
**Estimated Duration**: 3-4 days
**Sessions**: 6-8 coding sessions of 2-3 hours each

## Day 1: Core Events System Foundation

### Session 1: Event Data Structure (2-3 hours)

#### Step 1: Create Game Event Resource Class
```bash
# Create events system directory
mkdir -p scripts/systems
touch scripts/systems/events_manager.gd
mkdir -p resources
touch resources/game_event.gd
```

```gdscript
# resources/game_event.gd
class_name GameEvent
extends Resource

@export var event_id: String
@export var name: String
@export var description: String
@export var event_type: String  # "seasonal", "special", "challenge", "opportunity"
@export var duration: float = 0.0
@export var requirements: Dictionary = {}
@export var rewards: Dictionary = {}
@export var penalties: Dictionary = {}
@export var triggers: Array[String] = []
@export var start_time: Dictionary = {}
@export var end_time: Dictionary = {}
@export var is_active: bool = false
@export var progress: float = 0.0

func _init():
    event_id = _generate_event_id()

func _generate_event_id() -> String:
    return "event_" + str(randi() % 100000)

func check_requirements() -> bool:
    for requirement in requirements:
        if not _check_single_requirement(requirement, requirements[requirement]):
            return false
    return true

func _check_single_requirement(req_type: String, value) -> bool:
    match req_type:
        "money":
            return GameManager.player_money >= value
        "production_rate":
            return GameManager.hot_dog_production.production_rate >= value
        "staff_count":
            return GameManager.staff_manager.staff_members.size() >= value
        "location_count":
            return GameManager.location_manager.locations.size() >= value
        _:
            return true

func get_progress_percentage() -> float:
    return clamp(progress, 0.0, 1.0)

func is_completed() -> bool:
    return progress >= 1.0
```

#### Step 2: Create Events Manager System
```gdscript
# scripts/systems/events_manager.gd
class_name EventsManager
extends Node

signal event_started(event: GameEvent)
signal event_completed(event: GameEvent)
signal event_failed(event: GameEvent)
signal special_offer_available(offer: Dictionary)

var active_events: Array[GameEvent] = []
var event_history: Array[GameEvent] = []
var special_offers: Array[Dictionary] = []
var event_schedule: Dictionary = {}

func _ready():
    print("EventsManager initialized")
    _setup_event_types()
    _schedule_initial_events()

func _setup_event_types():
    # Define event types and their configurations
    pass

func _schedule_initial_events():
    # Schedule initial events
    _schedule_seasonal_events()
    _schedule_special_events()

func _schedule_seasonal_events():
    # Schedule seasonal events based on real time
    var current_time = Time.get_time_dict_from_system()
    var month = current_time["month"]
    
    match month:
        6, 7, 8:  # Summer
            _schedule_event("summer_festival", 86400.0)  # 24 hours
        12:  # December
            _schedule_event("holiday_special", 604800.0)  # 1 week
        _:
            pass

func _schedule_event(event_type: String, delay: float):
    var event = _create_event(event_type)
    if event:
        event_schedule[event.event_id] = {
            "event": event,
            "start_time": Time.get_time_dict_from_system(),
            "delay": delay
        }

func _create_event(event_type: String) -> GameEvent:
    var event_data = _get_event_data(event_type)
    if not event_data:
        return null
    
    var event = GameEvent.new()
    event.event_id = event_data.id
    event.name = event_data.name
    event.description = event_data.description
    event.event_type = event_data.type
    event.duration = event_data.duration
    event.requirements = event_data.requirements
    event.rewards = event_data.rewards
    
    return event

func _get_event_data(event_type: String) -> Dictionary:
    var event_database = {
        "summer_festival": {
            "id": "summer_festival",
            "name": "Summer Festival",
            "description": "A special summer festival with increased customer demand!",
            "type": "seasonal",
            "duration": 86400.0,
            "requirements": {"money": 1000.0},
            "rewards": {"money_multiplier": 2.0, "customer_satisfaction": 0.5}
        },
        "holiday_special": {
            "id": "holiday_special",
            "name": "Holiday Special",
            "description": "Celebrate the holidays with special bonuses!",
            "type": "seasonal",
            "duration": 604800.0,
            "requirements": {"location_count": 2},
            "rewards": {"money_multiplier": 1.5, "staff_happiness": 0.3}
        }
    }
    
    return event_database.get(event_type, {})

func _process(delta: float):
    _update_event_schedule(delta)
    _update_active_events(delta)

func _update_event_schedule(delta: float):
    var current_time = Time.get_time_dict_from_system()
    var events_to_start = []
    
    for event_id in event_schedule:
        var schedule_info = event_schedule[event_id]
        var elapsed_time = _get_elapsed_time(schedule_info.start_time)
        
        if elapsed_time >= schedule_info.delay:
            events_to_start.append(event_id)
    
    for event_id in events_to_start:
        _start_scheduled_event(event_id)

func _start_scheduled_event(event_id: String):
    var schedule_info = event_schedule[event_id]
    var event = schedule_info.event
    
    if event.check_requirements():
        _start_event(event)
    else:
        event_schedule.erase(event_id)

func _start_event(event: GameEvent):
    event.is_active = true
    event.start_time = Time.get_time_dict_from_system()
    active_events.append(event)
    
    event_started.emit(event)
    EventManager.emit_event("event_started", {"event": event.name})

func _update_active_events(delta: float):
    var completed_events = []
    
    for event in active_events:
        if event.is_active:
            _update_event_progress(event, delta)
            
            if event.is_completed():
                _complete_event(event)
                completed_events.append(event)
            elif _is_event_expired(event):
                _fail_event(event)
                completed_events.append(event)
    
    for event in completed_events:
        active_events.erase(event)

func _update_event_progress(event: GameEvent, delta: float):
    # Update event progress based on player actions
    var progress_increment = _calculate_progress_increment(event, delta)
    event.progress += progress_increment

func _calculate_progress_increment(event: GameEvent, delta: float) -> float:
    # Calculate progress based on event type and player performance
    match event.event_type:
        "seasonal":
            return delta / event.duration  # Time-based progress
        "challenge":
            return _calculate_challenge_progress(event, delta)
        _:
            return 0.0

func _calculate_challenge_progress(event: GameEvent, delta: float) -> float:
    # Calculate progress for challenge events
    var base_progress = 0.0
    
    # Add progress based on hot dogs sold
    base_progress += GameManager.sales_system.total_sales * 0.001
    
    # Add progress based on money earned
    base_progress += GameManager.player_money * 0.0001
    
    return base_progress * delta

func _complete_event(event: GameEvent):
    _apply_event_rewards(event)
    event_history.append(event)
    
    event_completed.emit(event)
    EventManager.emit_event("event_completed", {"event": event.name})

func _fail_event(event: GameEvent):
    _apply_event_penalties(event)
    event_history.append(event)
    
    event_failed.emit(event)
    EventManager.emit_event("event_failed", {"event": event.name})

func _apply_event_rewards(event: GameEvent):
    for reward_type in event.rewards:
        match reward_type:
            "money_multiplier":
                GameManager.sales_system.revenue_multiplier *= event.rewards[reward_type]
            "customer_satisfaction":
                GameManager.sales_system.customer_satisfaction += event.rewards[reward_type]
            "staff_happiness":
                for staff_member in GameManager.staff_manager.staff_members:
                    staff_member.happiness += event.rewards[reward_type]

func _apply_event_penalties(event: GameEvent):
    for penalty_type in event.penalties:
        match penalty_type:
            "money_penalty":
                GameManager.player_money -= event.penalties[penalty_type]
            "customer_satisfaction_penalty":
                GameManager.sales_system.customer_satisfaction -= event.penalties[penalty_type]

func _is_event_expired(event: GameEvent) -> bool:
    var elapsed_time = _get_elapsed_time(event.start_time)
    return elapsed_time >= event.duration

func _get_elapsed_time(start_time: Dictionary) -> float:
    var current_time = Time.get_time_dict_from_system()
    # Calculate elapsed time in seconds
    return 0.0  # Placeholder
```

#### Step 3: Integrate with Game Manager
```gdscript
# Add to scripts/autoload/game_manager.gd
var events_manager: EventsManager

func _ready():
    events_manager = EventsManager.new()
    add_child(events_manager)
    
    events_manager.event_started.connect(_on_event_started)
    events_manager.event_completed.connect(_on_event_completed)
    events_manager.event_failed.connect(_on_event_failed)
```

### Session 2: Event UI Components (2-3 hours)

#### Step 1: Create Event Management Interface
```gdscript
# scenes/ui/events_management.gd
extends Control

@onready var active_events_panel = $ActiveEventsPanel
@onready var event_history_panel = $EventHistoryPanel
@onready var event_calendar = $EventCalendar

func _ready():
    GameManager.events_manager.event_started.connect(_on_event_started)
    GameManager.events_manager.event_completed.connect(_on_event_completed)
    GameManager.events_manager.event_failed.connect(_on_event_failed)
    
    _update_active_events()
    _update_event_history()

func _on_event_started(event: GameEvent):
    _update_active_events()
    _show_event_notification(event, "started")

func _on_event_completed(event: GameEvent):
    _update_active_events()
    _update_event_history()
    _show_event_notification(event, "completed")

func _on_event_failed(event: GameEvent):
    _update_active_events()
    _update_event_history()
    _show_event_notification(event, "failed")

func _update_active_events():
    active_events_panel.clear_events()
    
    for event in GameManager.events_manager.active_events:
        active_events_panel.add_event(event)

func _update_event_history():
    event_history_panel.clear_events()
    
    for event in GameManager.events_manager.event_history:
        event_history_panel.add_event(event)

func _show_event_notification(event: GameEvent, status: String):
    var notification = preload("res://scenes/ui/event_notification.tscn").instantiate()
    notification.setup(event, status)
    add_child(notification)
```

## Day 2: Event Types and Special Features

### Session 3: Seasonal and Special Events (2-3 hours)

#### Step 1: Implement Seasonal Events
```gdscript
# Add to scripts/systems/events_manager.gd
func _setup_seasonal_events():
    var seasonal_events = {
        "spring_festival": {
            "name": "Spring Festival",
            "description": "Welcome spring with fresh ingredients and happy customers!",
            "duration": 604800.0,  # 1 week
            "requirements": {"money": 500.0},
            "rewards": {"production_efficiency": 0.2, "customer_satisfaction": 0.3}
        },
        "summer_bbq": {
            "name": "Summer BBQ",
            "description": "Hot dogs are perfect for summer BBQs!",
            "duration": 1209600.0,  # 2 weeks
            "requirements": {"location_count": 1},
            "rewards": {"sales_rate": 0.3, "money_multiplier": 1.5}
        },
        "fall_fair": {
            "name": "Fall Fair",
            "description": "The fall fair brings hungry crowds!",
            "duration": 604800.0,
            "requirements": {"staff_count": 2},
            "rewards": {"customer_satisfaction": 0.4, "staff_happiness": 0.2}
        },
        "winter_warmth": {
            "name": "Winter Warmth",
            "description": "Warm up with hot dogs in winter!",
            "duration": 1209600.0,
            "requirements": {"money": 1000.0},
            "rewards": {"production_rate": 0.2, "money_multiplier": 1.3}
        }
    }
    
    return seasonal_events
```

#### Step 2: Create Special Event Mechanics
```gdscript
# Add to scripts/systems/events_manager.gd
func create_special_offer(offer_type: String, duration: float) -> Dictionary:
    var offer = {
        "type": offer_type,
        "duration": duration,
        "start_time": Time.get_time_dict_from_system(),
        "discount": 0.0,
        "bonus": 0.0
    }
    
    match offer_type:
        "upgrade_discount":
            offer.discount = 0.5  # 50% off upgrades
        "research_boost":
            offer.bonus = 2.0  # 2x research points
        "staff_bonus":
            offer.bonus = 0.3  # 30% staff productivity bonus
    
    special_offers.append(offer)
    special_offer_available.emit(offer)
    
    return offer
```

### Session 4: Event Challenges and Goals (2-3 hours)

#### Step 1: Implement Challenge Events
```gdscript
# Add to scripts/systems/events_manager.gd
func create_challenge_event(challenge_type: String) -> GameEvent:
    var challenge_data = _get_challenge_data(challenge_type)
    if not challenge_data:
        return null
    
    var event = GameEvent.new()
    event.event_id = challenge_data.id
    event.name = challenge_data.name
    event.description = challenge_data.description
    event.event_type = "challenge"
    event.duration = challenge_data.duration
    event.requirements = challenge_data.requirements
    event.rewards = challenge_data.rewards
    
    return event

func _get_challenge_data(challenge_type: String) -> Dictionary:
    var challenges = {
        "speed_challenge": {
            "id": "speed_challenge",
            "name": "Speed Challenge",
            "description": "Produce 1000 hot dogs in 1 hour!",
            "duration": 3600.0,  # 1 hour
            "requirements": {"production_rate": 5.0},
            "rewards": {"money": 5000.0, "upgrade_discount": 0.25}
        },
        "quality_challenge": {
            "id": "quality_challenge",
            "name": "Quality Challenge",
            "description": "Maintain 90% customer satisfaction for 24 hours!",
            "duration": 86400.0,  # 24 hours
            "requirements": {"customer_satisfaction": 0.9},
            "rewards": {"customer_loyalty": 0.5, "reputation": 1.0}
        }
    }
    
    return challenges.get(challenge_type, {})
```

## Day 3: Event Integration and Polish

### Session 5: Event Integration with Other Systems (2-3 hours)

#### Step 1: Integrate Events with Game Systems
```gdscript
# Add to scripts/autoload/game_manager.gd
func _on_event_started(event: GameEvent):
    # Apply event effects to game systems
    _apply_event_effects(event, true)

func _on_event_completed(event: GameEvent):
    # Remove event effects
    _apply_event_effects(event, false)

func _apply_event_effects(event: GameEvent, is_starting: bool):
    var multiplier = 1.0 if is_starting else -1.0
    
    for effect_type in event.rewards:
        match effect_type:
            "production_efficiency":
                hot_dog_production.production_efficiency += event.rewards[effect_type] * multiplier
            "sales_rate":
                sales_system.sales_rate += event.rewards[effect_type] * multiplier
            "customer_satisfaction":
                sales_system.customer_satisfaction += event.rewards[effect_type] * multiplier
            "staff_happiness":
                for staff_member in staff_manager.staff_members:
                    staff_member.happiness += event.rewards[effect_type] * multiplier
```

### Session 6: Event Analytics and Testing (2-3 hours)

#### Step 1: Create Event Analytics
```gdscript
# Add to scripts/systems/events_manager.gd
func get_event_statistics() -> Dictionary:
    var stats = {
        "total_events_completed": 0,
        "total_events_failed": 0,
        "average_event_duration": 0.0,
        "most_popular_event": "",
        "event_completion_rate": 0.0
    }
    
    var total_events = event_history.size()
    if total_events > 0:
        stats.total_events_completed = event_history.filter(func(e): return e.is_completed()).size()
        stats.total_events_failed = total_events - stats.total_events_completed
        stats.event_completion_rate = float(stats.total_events_completed) / total_events
    
    return stats
```

#### Step 2: Create Comprehensive Tests
```gdscript
# scripts/tests/events_system_test.gd
extends GutTest

func test_event_creation():
    var events_manager = EventsManager.new()
    add_child_autofree(events_manager)
    
    var event = events_manager._create_event("summer_festival")
    assert_not_null(event)
    assert_eq(event.name, "Summer Festival")

func test_event_requirements():
    var events_manager = EventsManager.new()
    add_child_autofree(events_manager)
    
    var event = events_manager._create_event("summer_festival")
    GameManager.player_money = 500.0
    
    assert_false(event.check_requirements())
    
    GameManager.player_money = 1500.0
    assert_true(event.check_requirements())
```

## Success Criteria Checklist

- [ ] Events system triggers and manages events correctly
- [ ] Seasonal events occur at appropriate times
- [ ] Challenge events provide engaging goals
- [ ] Event rewards and penalties work properly
- [ ] Event UI provides clear feedback and information
- [ ] Events integrate with other game systems
- [ ] Event analytics provide useful insights
- [ ] Event system supports save/load functionality
- [ ] Events provide engaging long-term content
- [ ] Event balance provides fair and fun gameplay

## Risk Mitigation

1. **System Complexity**: Implement modular design with clear interfaces
2. **Performance Issues**: Use efficient algorithms and batch updates
3. **Balance Problems**: Extensive testing and balance configuration
4. **UI Complexity**: Create intuitive, hierarchical interface design

## Next Steps

After completing the Events System:
1. Move to Enhanced Progression implementation
2. Integrate with achievement system for event milestones
3. Connect to prestige system for event bonuses
4. Implement event-specific achievements and progression 