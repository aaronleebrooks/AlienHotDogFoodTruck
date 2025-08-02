# Staff Management System - Implementation Plan

## Overview
This document provides a detailed step-by-step implementation plan for the Staff Management System, which adds strategic depth and human resource management to the hot dog idle game.

## Implementation Timeline
**Estimated Duration**: 4-5 days
**Sessions**: 8-10 coding sessions of 2-3 hours each

## Day 1: Core Staff System Foundation

### Session 1: Staff Data Structure (2-3 hours)

#### Step 1: Create Staff Member Resource Class
```bash
# Create staff system directory
mkdir -p scripts/systems
touch scripts/systems/staff_manager.gd
mkdir -p resources
touch resources/staff_member.gd
```

```gdscript
# resources/staff_member.gd
class_name StaffMember
extends Resource

@export var staff_id: String
@export var name: String
@export var staff_type: String  # "cook", "cashier", "manager", "marketer"
@export var skills: Dictionary = {}
@export var experience: float = 0.0
@export var salary: float = 0.0
@export var happiness: float = 1.0
@export var productivity: float = 1.0
@export var training_level: int = 0
@export var assigned_location: String = ""
@export var hire_date: Dictionary = {}
@export var performance_rating: float = 1.0

func _init():
    staff_id = _generate_staff_id()
    name = _generate_random_name()
    hire_date = Time.get_time_dict_from_system()

func _generate_staff_id() -> String:
    return "staff_" + str(randi() % 100000)

func _generate_random_name() -> String:
    var first_names = ["Alex", "Sam", "Jordan", "Casey", "Taylor", "Morgan", "Riley", "Quinn"]
    var last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller"]
    return first_names[randi() % first_names.size()] + " " + last_names[randi() % last_names.size()]

func get_skill_level(skill_name: String) -> float:
    return skills.get(skill_name, 0.0)

func improve_skill(skill_name: String, amount: float):
    skills[skill_name] = get_skill_level(skill_name) + amount
    _recalculate_productivity()

func add_experience(amount: float):
    experience += amount
    _recalculate_productivity()

func _recalculate_productivity():
    var base_productivity = 1.0
    var skill_bonus = 0.0
    var happiness_bonus = happiness * 0.2
    var experience_bonus = experience * 0.1
    var training_bonus = training_level * 0.05
    
    for skill_level in skills.values():
        skill_bonus += skill_level * 0.1
    
    productivity = base_productivity + skill_bonus + happiness_bonus + experience_bonus + training_bonus
    productivity = max(productivity, 0.1)  # Minimum productivity
```

#### Step 2: Create Staff Manager System
```gdscript
# scripts/systems/staff_manager.gd
class_name StaffManager
extends Node

signal staff_hired(staff_member: StaffMember)
signal staff_fired(staff_member: StaffMember)
signal staff_promoted(staff_member: StaffMember)
signal staff_trained(staff_member: StaffMember)
signal staff_assigned(staff_member: StaffMember, location_id: String)

var staff_members: Array[StaffMember] = []
var available_positions: Dictionary = {}
var training_programs: Dictionary = {}
var salary_budget: float = 0.0
var total_salary_expenses: float = 0.0

func _ready():
    print("StaffManager initialized")
    _setup_staff_types()
    _setup_training_programs()

func _setup_staff_types():
    available_positions = {
        "cook": {
            "base_salary": 15.0,
            "skills": ["cooking", "efficiency", "quality"],
            "production_bonus": 0.1
        },
        "cashier": {
            "base_salary": 12.0,
            "skills": ["customer_service", "speed", "accuracy"],
            "sales_bonus": 0.1
        },
        "manager": {
            "base_salary": 25.0,
            "skills": ["leadership", "organization", "motivation"],
            "overall_bonus": 0.05
        },
        "marketer": {
            "base_salary": 20.0,
            "skills": ["marketing", "creativity", "communication"],
            "marketing_bonus": 0.15
        }
    }

func _setup_training_programs():
    training_programs = {
        "basic_cooking": {
            "cost": 50.0,
            "duration": 300.0,  # 5 minutes
            "skills": {"cooking": 1.0},
            "prerequisites": []
        },
        "advanced_cooking": {
            "cost": 100.0,
            "duration": 600.0,  # 10 minutes
            "skills": {"cooking": 2.0, "efficiency": 1.0},
            "prerequisites": ["basic_cooking"]
        },
        "customer_service": {
            "cost": 30.0,
            "duration": 180.0,  # 3 minutes
            "skills": {"customer_service": 1.0},
            "prerequisites": []
        }
    }

func hire_staff(staff_type: String, location_id: String) -> StaffMember:
    if not available_positions.has(staff_type):
        print("Error: Unknown staff type: %s" % staff_type)
        return null
    
    var position_data = available_positions[staff_type]
    var new_staff = StaffMember.new()
    new_staff.staff_type = staff_type
    new_staff.salary = position_data.base_salary
    
    # Initialize skills based on staff type
    for skill in position_data.skills:
        new_staff.skills[skill] = 0.0
    
    staff_members.append(new_staff)
    total_salary_expenses += new_staff.salary
    
    staff_hired.emit(new_staff)
    EventManager.emit_event("staff_hired", {"type": staff_type, "name": new_staff.name})
    
    return new_staff

func fire_staff(staff_member: StaffMember):
    if staff_member in staff_members:
        staff_members.erase(staff_member)
        total_salary_expenses -= staff_member.salary
        staff_fired.emit(staff_member)
        EventManager.emit_event("staff_fired", {"name": staff_member.name})
```

#### Step 3: Integrate with Game Manager
```gdscript
# Add to scripts/autoload/game_manager.gd
var staff_manager: StaffManager

func _ready():
    staff_manager = StaffManager.new()
    add_child(staff_manager)
    
    staff_manager.staff_hired.connect(_on_staff_hired)
    staff_manager.staff_fired.connect(_on_staff_fired)
    staff_manager.staff_trained.connect(_on_staff_trained)
```

### Session 2: Staff Hiring and Assignment (2-3 hours)

#### Step 1: Create Staff Hiring Interface
```bash
# Create staff UI scenes
mkdir -p scenes/ui
touch scenes/ui/staff_management.tscn
touch scenes/ui/staff_management.gd
touch scenes/ui/staff_hiring_panel.tscn
touch scenes/ui/staff_hiring_panel.gd
```

```gdscript
# scenes/ui/staff_management.gd
extends Control

@onready var staff_list = $StaffList
@onready var hiring_panel = $HiringPanel
@onready var staff_details = $StaffDetails
@onready var total_staff_label = $TotalStaffLabel
@onready var total_salary_label = $TotalSalaryLabel

func _ready():
    GameManager.staff_manager.staff_hired.connect(_on_staff_hired)
    GameManager.staff_manager.staff_fired.connect(_on_staff_fired)
    _populate_staff_list()
    _update_summary()

func _populate_staff_list():
    # Clear existing staff items
    for child in staff_list.get_children():
        child.queue_free()
    
    # Add staff members to list
    for staff_member in GameManager.staff_manager.staff_members:
        var staff_item = preload("res://scenes/ui/staff_list_item.tscn").instantiate()
        staff_item.setup(staff_member)
        staff_item.staff_selected.connect(_on_staff_selected)
        staff_list.add_child(staff_item)

func _on_staff_hired(staff_member: StaffMember):
    _populate_staff_list()
    _update_summary()

func _on_staff_fired(staff_member: StaffMember):
    _populate_staff_list()
    _update_summary()

func _on_staff_selected(staff_member: StaffMember):
    staff_details.show_staff_details(staff_member)

func _update_summary():
    total_staff_label.text = "Total Staff: %d" % GameManager.staff_manager.staff_members.size()
    total_salary_label.text = "Total Salary: $%.1f/hr" % GameManager.staff_manager.total_salary_expenses
```

#### Step 2: Create Staff Hiring Panel
```gdscript
# scenes/ui/staff_hiring_panel.gd
extends Control

@onready var staff_type_container = $StaffTypeContainer
@onready var hire_button = $HireButton
@onready var cancel_button = $CancelButton

var selected_staff_type: String = ""
var target_location: String = ""

func _ready():
    hire_button.pressed.connect(_on_hire_pressed)
    cancel_button.pressed.connect(_on_cancel_pressed)
    _populate_staff_types()

func _populate_staff_types():
    for staff_type in GameManager.staff_manager.available_positions:
        var position_data = GameManager.staff_manager.available_positions[staff_type]
        var staff_type_button = preload("res://scenes/ui/staff_type_button.tscn").instantiate()
        staff_type_button.setup(staff_type, position_data)
        staff_type_button.staff_type_selected.connect(_on_staff_type_selected)
        staff_type_container.add_child(staff_type_button)

func _on_staff_type_selected(staff_type: String):
    selected_staff_type = staff_type
    hire_button.disabled = false

func _on_hire_pressed():
    if selected_staff_type != "":
        var new_staff = GameManager.staff_manager.hire_staff(selected_staff_type, target_location)
        if new_staff:
            hide()
            EventManager.emit_event("staff_hiring_completed", {"type": selected_staff_type})

func _on_cancel_pressed():
    hide()
```

## Day 2: Staff Training and Development

### Session 3: Training System Implementation (2-3 hours)

#### Step 1: Implement Training Mechanics
```gdscript
# Add to scripts/systems/staff_manager.gd
var active_training: Dictionary = {}

func train_staff(staff_member: StaffMember, training_type: String):
    if not training_programs.has(training_type):
        print("Error: Unknown training program: %s" % training_type)
        return false
    
    var training_data = training_programs[training_type]
    
    # Check prerequisites
    for prereq in training_data.prerequisites:
        if not _has_completed_training(staff_member, prereq):
            print("Error: Prerequisite not met: %s" % prereq)
            return false
    
    # Check if staff member can afford training
    if GameManager.player_money < training_data.cost:
        print("Error: Not enough money for training")
        return false
    
    # Start training
    GameManager.player_money -= training_data.cost
    active_training[staff_member.staff_id] = {
        "training_type": training_type,
        "start_time": Time.get_time_dict_from_system(),
        "duration": training_data.duration,
        "training_data": training_data
    }
    
    EventManager.emit_event("staff_training_started", {"staff_name": staff_member.name, "training": training_type})
    return true

func _process(delta: float):
    _update_training_progress(delta)

func _update_training_progress(delta: float):
    var completed_training = []
    
    for staff_id in active_training:
        var training_info = active_training[staff_id]
        var elapsed_time = _get_elapsed_time(training_info.start_time)
        
        if elapsed_time >= training_info.duration:
            _complete_training(staff_id, training_info)
            completed_training.append(staff_id)
    
    for staff_id in completed_training:
        active_training.erase(staff_id)

func _complete_training(staff_id: String, training_info: Dictionary):
    var staff_member = _get_staff_by_id(staff_id)
    if not staff_member:
        return
    
    var training_data = training_info.training_data
    
    # Apply training effects
    for skill_name in training_data.skills:
        staff_member.improve_skill(skill_name, training_data.skills[skill_name])
    
    staff_member.training_level += 1
    staff_member.add_experience(1.0)
    
    staff_trained.emit(staff_member)
    EventManager.emit_event("staff_training_completed", {"staff_name": staff_member.name, "training": training_info.training_type})

func _get_staff_by_id(staff_id: String) -> StaffMember:
    for staff_member in staff_members:
        if staff_member.staff_id == staff_id:
            return staff_member
    return null

func _has_completed_training(staff_member: StaffMember, training_type: String) -> bool:
    # Check if staff member has completed this training
    # This would be stored in staff member data
    return false  # Placeholder
```

#### Step 2: Create Training UI
```gdscript
# scenes/ui/staff_training_panel.gd
extends Control

@onready var training_programs_list = $TrainingProgramsList
@onready var start_training_button = $StartTrainingButton
@onready var training_progress = $TrainingProgress

var selected_staff: StaffMember
var selected_training: String = ""

func _ready():
    start_training_button.pressed.connect(_on_start_training_pressed)
    _populate_training_programs()

func setup(staff_member: StaffMember):
    selected_staff = staff_member
    _update_training_programs()

func _populate_training_programs():
    for training_type in GameManager.staff_manager.training_programs:
        var training_data = GameManager.staff_manager.training_programs[training_type]
        var training_item = preload("res://scenes/ui/training_program_item.tscn").instantiate()
        training_item.setup(training_type, training_data)
        training_item.training_selected.connect(_on_training_selected)
        training_programs_list.add_child(training_item)

func _on_training_selected(training_type: String):
    selected_training = training_type
    start_training_button.disabled = false

func _on_start_training_pressed():
    if selected_staff and selected_training != "":
        var success = GameManager.staff_manager.train_staff(selected_staff, selected_training)
        if success:
            hide()
            EventManager.emit_event("training_started", {"staff": selected_staff.name, "training": selected_training})
```

### Session 4: Staff Performance and Analytics (2-3 hours)

#### Step 1: Implement Performance Tracking
```gdscript
# Add to scripts/systems/staff_manager.gd
var staff_performance_history: Dictionary = {}

func update_staff_performance():
    for staff_member in staff_members:
        var performance_data = _calculate_staff_performance(staff_member)
        staff_performance_history[staff_member.staff_id] = performance_data
        
        # Update staff member's performance rating
        staff_member.performance_rating = performance_data.overall_rating

func _calculate_staff_performance(staff_member: StaffMember) -> Dictionary:
    var performance = {
        "productivity": staff_member.productivity,
        "happiness": staff_member.happiness,
        "experience": staff_member.experience,
        "training_level": staff_member.training_level,
        "overall_rating": 0.0
    }
    
    # Calculate overall rating
    var productivity_weight = 0.4
    var happiness_weight = 0.2
    var experience_weight = 0.2
    var training_weight = 0.2
    
    performance.overall_rating = (
        performance.productivity * productivity_weight +
        performance.happiness * happiness_weight +
        min(performance.experience / 10.0, 1.0) * experience_weight +
        min(performance.training_level / 5.0, 1.0) * training_weight
    )
    
    return performance

func get_staff_statistics() -> Dictionary:
    var stats = {
        "total_staff": staff_members.size(),
        "average_productivity": 0.0,
        "average_happiness": 0.0,
        "total_salary": total_salary_expenses,
        "staff_by_type": {},
        "performance_distribution": {}
    }
    
    if staff_members.size() > 0:
        var total_productivity = 0.0
        var total_happiness = 0.0
        
        for staff_member in staff_members:
            total_productivity += staff_member.productivity
            total_happiness += staff_member.happiness
            
            # Count by type
            if not stats.staff_by_type.has(staff_member.staff_type):
                stats.staff_by_type[staff_member.staff_type] = 0
            stats.staff_by_type[staff_member.staff_type] += 1
        
        stats.average_productivity = total_productivity / staff_members.size()
        stats.average_happiness = total_happiness / staff_members.size()
    
    return stats
```

#### Step 2: Create Performance Analytics UI
```gdscript
# scenes/ui/staff_analytics.gd
extends Control

@onready var total_staff_label = $TotalStaffLabel
@onready var average_productivity_label = $AverageProductivityLabel
@onready var average_happiness_label = $AverageHappinessLabel
@onready var total_salary_label = $TotalSalaryLabel
@onready var staff_type_chart = $StaffTypeChart
@onready var performance_chart = $PerformanceChart

func _ready():
    # Update analytics every 5 seconds
    var timer = Timer.new()
    timer.wait_time = 5.0
    timer.timeout.connect(_update_analytics)
    add_child(timer)
    timer.start()
    
    _update_analytics()

func _update_analytics():
    var stats = GameManager.staff_manager.get_staff_statistics()
    
    total_staff_label.text = "Total Staff: %d" % stats.total_staff
    average_productivity_label.text = "Avg Productivity: %.2f" % stats.average_productivity
    average_happiness_label.text = "Avg Happiness: %.2f" % stats.average_happiness
    total_salary_label.text = "Total Salary: $%.1f/hr" % stats.total_salary
    
    _update_staff_type_chart(stats.staff_by_type)
    _update_performance_chart(stats.performance_distribution)

func _update_staff_type_chart(staff_by_type: Dictionary):
    # Update pie chart showing staff distribution by type
    staff_type_chart.clear()
    for staff_type in staff_by_type:
        staff_type_chart.add_slice(staff_by_type[staff_type], staff_type)
```

## Day 3: Staff Happiness and Morale

### Session 5: Happiness System Implementation (2-3 hours)

#### Step 1: Implement Happiness Mechanics
```gdscript
# Add to scripts/systems/staff_manager.gd
var happiness_factors: Dictionary = {
    "salary_satisfaction": 0.3,
    "workload": 0.2,
    "training_opportunities": 0.15,
    "work_environment": 0.15,
    "recognition": 0.1,
    "career_growth": 0.1
}

func _ready():
    # Start happiness update timer
    var timer = Timer.new()
    timer.wait_time = 60.0  # Update every minute
    timer.timeout.connect(_update_staff_happiness)
    add_child(timer)
    timer.start()

func _update_staff_happiness():
    for staff_member in staff_members:
        var new_happiness = _calculate_happiness(staff_member)
        staff_member.happiness = lerp(staff_member.happiness, new_happiness, 0.1)
        staff_member._recalculate_productivity()

func _calculate_happiness(staff_member: StaffMember) -> float:
    var happiness = 0.0
    
    # Salary satisfaction
    var expected_salary = _get_expected_salary(staff_member)
    var salary_ratio = staff_member.salary / expected_salary if expected_salary > 0 else 1.0
    happiness += salary_ratio * happiness_factors.salary_satisfaction
    
    # Workload (inverse relationship)
    var workload = _calculate_workload(staff_member)
    var workload_satisfaction = 1.0 - (workload * 0.5)  # Less workload = more happiness
    happiness += workload_satisfaction * happiness_factors.workload
    
    # Training opportunities
    var training_satisfaction = min(staff_member.training_level / 5.0, 1.0)
    happiness += training_satisfaction * happiness_factors.training_opportunities
    
    # Work environment (based on location)
    var environment_satisfaction = _calculate_environment_satisfaction(staff_member)
    happiness += environment_satisfaction * happiness_factors.work_environment
    
    # Recognition (based on performance)
    var recognition_satisfaction = staff_member.performance_rating
    happiness += recognition_satisfaction * happiness_factors.recognition
    
    # Career growth (based on experience and promotions)
    var growth_satisfaction = min(staff_member.experience / 20.0, 1.0)
    happiness += growth_satisfaction * happiness_factors.career_growth
    
    return clamp(happiness, 0.0, 1.0)

func _get_expected_salary(staff_member: StaffMember) -> float:
    var base_salary = available_positions[staff_member.staff_type].base_salary
    var experience_bonus = staff_member.experience * 0.5
    var training_bonus = staff_member.training_level * 2.0
    return base_salary + experience_bonus + training_bonus

func _calculate_workload(staff_member: StaffMember) -> float:
    # Calculate workload based on location capacity and staff count
    var location = GameManager.location_manager.get_location(staff_member.assigned_location)
    if not location:
        return 0.5  # Default moderate workload
    
    var staff_at_location = _get_staff_at_location(location.location_id)
    var workload_ratio = staff_at_location.size() / location.staff_capacity
    return clamp(workload_ratio, 0.0, 2.0)  # Cap at 200% workload

func _calculate_environment_satisfaction(staff_member: StaffMember) -> float:
    var location = GameManager.location_manager.get_location(staff_member.assigned_location)
    if not location:
        return 0.5  # Default moderate satisfaction
    
    # Base satisfaction from location type
    var base_satisfaction = 0.7
    
    # Facility bonuses
    var facility_bonus = 0.0
    for facility in location.facilities:
        facility_bonus += 0.05
    
    return clamp(base_satisfaction + facility_bonus, 0.0, 1.0)
```

#### Step 2: Create Happiness Management UI
```gdscript
# scenes/ui/staff_happiness_panel.gd
extends Control

@onready var happiness_bar = $HappinessBar
@onready var happiness_factors_list = $HappinessFactorsList
@onready var improve_happiness_button = $ImproveHappinessButton

var selected_staff: StaffMember

func setup(staff_member: StaffMember):
    selected_staff = staff_member
    _update_happiness_display()

func _update_happiness_display():
    happiness_bar.value = selected_staff.happiness * 100
    _update_happiness_factors()

func _update_happiness_factors():
    # Clear existing factors
    for child in happiness_factors_list.get_children():
        child.queue_free()
    
    # Add happiness factor breakdown
    var factors = GameManager.staff_manager._calculate_happiness_factors(selected_staff)
    for factor_name in factors:
        var factor_item = preload("res://scenes/ui/happiness_factor_item.tscn").instantiate()
        factor_item.setup(factor_name, factors[factor_name])
        happiness_factors_list.add_child(factor_item)

func _on_improve_happiness_pressed():
    # Show options to improve happiness
    var happiness_options = preload("res://scenes/ui/happiness_improvement_dialog.tscn").instantiate()
    happiness_options.setup(selected_staff)
    add_child(happiness_options)
```

### Session 6: Staff Scheduling and Workload (2-3 hours)

#### Step 1: Implement Scheduling System
```gdscript
# Add to scripts/systems/staff_manager.gd
var staff_schedules: Dictionary = {}
var shift_types: Dictionary = {
    "morning": {"start": 6, "end": 14, "bonus": 1.0},
    "afternoon": {"start": 14, "end": 22, "bonus": 1.0},
    "night": {"start": 22, "end": 6, "bonus": 1.2},
    "overtime": {"start": 0, "end": 0, "bonus": 1.5}
}

func assign_shift(staff_member: StaffMember, shift_type: String, day: int):
    if not shift_types.has(shift_type):
        print("Error: Unknown shift type: %s" % shift_type)
        return false
    
    if not staff_schedules.has(staff_member.staff_id):
        staff_schedules[staff_member.staff_id] = {}
    
    staff_schedules[staff_member.staff_id][day] = shift_type
    EventManager.emit_event("staff_shift_assigned", {"staff": staff_member.name, "shift": shift_type, "day": day})
    return true

func get_staff_schedule(staff_member: StaffMember) -> Dictionary:
    return staff_schedules.get(staff_member.staff_id, {})

func calculate_workload(staff_member: StaffMember) -> float:
    var schedule = get_staff_schedule(staff_member)
    var total_hours = 0.0
    
    for day in schedule:
        var shift_type = schedule[day]
        var shift_data = shift_types[shift_type]
        var shift_hours = (shift_data.end - shift_data.start) % 24
        total_hours += shift_hours
    
    return total_hours / 7.0  # Average daily hours

func optimize_schedule():
    # Simple scheduling algorithm
    var available_staff = staff_members.duplicate()
    var schedule_requirements = _get_schedule_requirements()
    
    for day in range(7):
        for shift_type in schedule_requirements[day]:
            var required_staff = schedule_requirements[day][shift_type]
            
            for i in range(required_staff):
                if available_staff.size() > 0:
                    var staff_member = available_staff.pop_front()
                    assign_shift(staff_member, shift_type, day)

func _get_schedule_requirements() -> Dictionary:
    # Return staffing requirements for each day and shift
    var requirements = {}
    for day in range(7):
        requirements[day] = {
            "morning": 2,
            "afternoon": 3,
            "night": 1
        }
    return requirements
```

#### Step 2: Create Scheduling UI
```gdscript
# scenes/ui/staff_scheduling.gd
extends Control

@onready var schedule_grid = $ScheduleGrid
@onready var staff_list = $StaffList
@onready var optimize_button = $OptimizeButton

func _ready():
    optimize_button.pressed.connect(_on_optimize_pressed)
    _populate_schedule_grid()
    _populate_staff_list()

func _populate_schedule_grid():
    # Create 7x4 grid for days and shifts
    for day in range(7):
        for shift in ["morning", "afternoon", "night"]:
            var schedule_cell = preload("res://scenes/ui/schedule_cell.tscn").instantiate()
            schedule_cell.setup(day, shift)
            schedule_cell.staff_dropped.connect(_on_staff_dropped)
            schedule_grid.add_child(schedule_cell)

func _populate_staff_list():
    for staff_member in GameManager.staff_manager.staff_members:
        var staff_item = preload("res://scenes/ui/staff_schedule_item.tscn").instantiate()
        staff_item.setup(staff_member)
        staff_item.staff_dragged.connect(_on_staff_dragged)
        staff_list.add_child(staff_item)

func _on_staff_dropped(staff_member: StaffMember, day: int, shift: String):
    GameManager.staff_manager.assign_shift(staff_member, shift, day)
    _update_schedule_display()

func _on_optimize_pressed():
    GameManager.staff_manager.optimize_schedule()
    _update_schedule_display()
```

## Day 4: Advanced Features and Integration

### Session 7: Staff Communication and Events (2-3 hours)

#### Step 1: Implement Communication System
```gdscript
# Add to scripts/systems/staff_manager.gd
var staff_meetings: Array[Dictionary] = []
var staff_feedback: Dictionary = {}
var staff_announcements: Array[String] = []

func hold_staff_meeting(meeting_type: String, duration: float):
    var meeting = {
        "type": meeting_type,
        "start_time": Time.get_time_dict_from_system(),
        "duration": duration,
        "participants": staff_members.duplicate(),
        "effects": _get_meeting_effects(meeting_type)
    }
    
    staff_meetings.append(meeting)
    EventManager.emit_event("staff_meeting_started", {"type": meeting_type})
    
    # Apply meeting effects
    for staff_member in staff_members:
        _apply_meeting_effects(staff_member, meeting.effects)

func _get_meeting_effects(meeting_type: String) -> Dictionary:
    match meeting_type:
        "team_building":
            return {"happiness": 0.1, "productivity": 0.05}
        "training_session":
            return {"experience": 0.5, "productivity": 0.1}
        "performance_review":
            return {"happiness": -0.05, "productivity": 0.15}
        "celebration":
            return {"happiness": 0.2, "productivity": 0.1}
        _:
            return {}

func _apply_meeting_effects(staff_member: StaffMember, effects: Dictionary):
    for effect_type in effects:
        match effect_type:
            "happiness":
                staff_member.happiness = clamp(staff_member.happiness + effects[effect_type], 0.0, 1.0)
            "productivity":
                staff_member.productivity += effects[effect_type]
            "experience":
                staff_member.add_experience(effects[effect_type])

func collect_staff_feedback(staff_member: StaffMember, feedback_type: String, rating: float):
    if not staff_feedback.has(staff_member.staff_id):
        staff_feedback[staff_member.staff_id] = []
    
    var feedback = {
        "type": feedback_type,
        "rating": rating,
        "timestamp": Time.get_time_dict_from_system()
    }
    
    staff_feedback[staff_member.staff_id].append(feedback)
    
    # Process feedback effects
    _process_feedback_effects(staff_member, feedback)

func _process_feedback_effects(staff_member: StaffMember, feedback: Dictionary):
    if feedback.rating > 0.7:
        # Positive feedback
        staff_member.happiness += 0.05
        EventManager.emit_event("positive_feedback", {"staff": staff_member.name})
    elif feedback.rating < 0.3:
        # Negative feedback
        staff_member.happiness -= 0.05
        EventManager.emit_event("negative_feedback", {"staff": staff_member.name})
```

#### Step 2: Create Communication UI
```gdscript
# scenes/ui/staff_communication.gd
extends Control

@onready var meetings_panel = $MeetingsPanel
@onready var feedback_panel = $FeedbackPanel
@onready var announcements_panel = $AnnouncementsPanel

func _ready():
    _populate_meetings_panel()
    _populate_feedback_panel()

func _populate_meetings_panel():
    var meeting_types = ["team_building", "training_session", "performance_review", "celebration"]
    
    for meeting_type in meeting_types:
        var meeting_button = preload("res://scenes/ui/meeting_button.tscn").instantiate()
        meeting_button.setup(meeting_type)
        meeting_button.meeting_requested.connect(_on_meeting_requested)
        meetings_panel.add_child(meeting_button)

func _on_meeting_requested(meeting_type: String):
    var meeting_dialog = preload("res://scenes/ui/meeting_dialog.tscn").instantiate()
    meeting_dialog.setup(meeting_type)
    meeting_dialog.meeting_confirmed.connect(_on_meeting_confirmed)
    add_child(meeting_dialog)

func _on_meeting_confirmed(meeting_type: String, duration: float):
    GameManager.staff_manager.hold_staff_meeting(meeting_type, duration)
```

### Session 8: Final Integration and Testing (2-3 hours)

#### Step 1: Integrate with Other Systems
```gdscript
# Add to scripts/autoload/game_manager.gd
func _connect_staff_signals():
    staff_manager.staff_hired.connect(_on_staff_hired)
    staff_manager.staff_fired.connect(_on_staff_fired)
    staff_manager.staff_trained.connect(_on_staff_trained)
    staff_manager.staff_assigned.connect(_on_staff_assigned)

func _on_staff_hired(staff_member: StaffMember):
    # Apply staff bonuses to production and sales
    _apply_staff_bonuses()

func _on_staff_fired(staff_member: StaffMember):
    # Remove staff bonuses
    _apply_staff_bonuses()

func _on_staff_trained(staff_member: StaffMember):
    # Recalculate staff bonuses
    _apply_staff_bonuses()

func _apply_staff_bonuses():
    var production_bonus = 0.0
    var sales_bonus = 0.0
    var marketing_bonus = 0.0
    
    for staff_member in staff_manager.staff_members:
        var staff_type_data = staff_manager.available_positions[staff_member.staff_type]
        var individual_bonus = staff_member.productivity * staff_type_data.get("production_bonus", 0.0)
        
        match staff_member.staff_type:
            "cook":
                production_bonus += individual_bonus
            "cashier":
                sales_bonus += individual_bonus
            "marketer":
                marketing_bonus += individual_bonus
            "manager":
                production_bonus += individual_bonus * 0.5
                sales_bonus += individual_bonus * 0.5
    
    # Apply bonuses to game systems
    hot_dog_production.production_efficiency = 1.0 + production_bonus
    sales_system.marketing_multiplier = 1.0 + marketing_bonus
    sales_system.sales_rate *= (1.0 + sales_bonus)
```

#### Step 2: Create Comprehensive Tests
```gdscript
# scripts/tests/staff_system_test.gd
extends GutTest

func test_staff_hiring():
    var staff_manager = StaffManager.new()
    add_child_autofree(staff_manager)
    
    var new_staff = staff_manager.hire_staff("cook", "main_location")
    assert_not_null(new_staff)
    assert_eq(new_staff.staff_type, "cook")
    assert_eq(staff_manager.staff_members.size(), 1)

func test_staff_training():
    var staff_manager = StaffManager.new()
    add_child_autofree(staff_manager)
    
    var staff_member = staff_manager.hire_staff("cook", "main_location")
    var initial_skill = staff_member.get_skill_level("cooking")
    
    staff_manager.train_staff(staff_member, "basic_cooking")
    # Simulate training completion
    staff_manager._complete_training(staff_member.staff_id, {"training_data": {"skills": {"cooking": 1.0}}})
    
    assert_gt(staff_member.get_skill_level("cooking"), initial_skill)

func test_staff_happiness_calculation():
    var staff_manager = StaffManager.new()
    add_child_autofree(staff_manager)
    
    var staff_member = staff_manager.hire_staff("cook", "main_location")
    var happiness = staff_manager._calculate_happiness(staff_member)
    
    assert_gte(happiness, 0.0)
    assert_lte(happiness, 1.0)
```

## Success Criteria Checklist

- [ ] Staff hiring and firing mechanics work correctly
- [ ] Staff training system improves skills and productivity
- [ ] Staff happiness system affects performance
- [ ] Staff scheduling system manages workload
- [ ] Staff communication system provides engagement
- [ ] Staff bonuses integrate with production and sales
- [ ] Staff analytics provide meaningful insights
- [ ] Staff UI is intuitive and functional
- [ ] Staff system integrates with save/load
- [ ] Staff balance provides strategic depth

## Risk Mitigation

1. **System Complexity**: Implement modular design with clear interfaces
2. **Performance Issues**: Use efficient algorithms and batch updates
3. **Balance Problems**: Extensive testing and balance configuration
4. **UI Complexity**: Create intuitive, hierarchical interface design

## Godot 4.4 Alignment Improvements

### High Priority Improvements
1. **Signal Management Enhancement**
   - Implement proper signal disconnection in `_exit_tree()` methods
   - Use `@export` annotations for inspector configuration
   - Add signal cleanup patterns to prevent memory leaks

2. **Resource Lifecycle Management**
   - Implement `_notification()` methods for proper resource cleanup
   - Add `NOTIFICATION_PREDELETE` handling for all resources
   - Ensure proper resource disposal and memory management

3. **Inspector Integration**
   - Add `@export` annotations for all configurable properties
   - Use `@export_group` for better organization in inspector
   - Implement `@export_enum` for type-safe selections

### Medium Priority Improvements
1. **Performance Optimization**
   - Use `@onready` for better performance in node initialization
   - Implement update throttling with delta time
   - Add performance monitoring from the start

2. **Testing Enhancement**
   - Set up comprehensive GUT testing framework
   - Create integration tests for all system interactions
   - Implement performance regression testing

3. **Documentation Standards**
   - Add proper GDScript documentation comments
   - Create architecture documentation templates
   - Document signal flow and system interactions

### Code Quality Improvements
1. **Enhanced Staff Management System**
   ```gdscript
   class_name StaffManager
   extends Node
   
   @export var max_staff_capacity: int = 50
   @export var salary_budget: float = 1000.0
   @export_group("Performance Settings")
   @export var update_interval: float = 60.0
   
   signal staff_hired(staff_member: StaffMember)
   signal staff_fired(staff_member: StaffMember)
   signal staff_trained(staff_member: StaffMember)
   
   func _ready():
       _initialize_system()
   
   func _exit_tree():
       _cleanup_system()
   
   func _initialize_system():
       # System initialization
       pass
   
   func _cleanup_system():
       # Disconnect all signals to prevent memory leaks
       for signal_name in get_signal_list():
           if signal_name.is_connected(_on_signal):
               signal_name.disconnect(_on_signal)
   ```

2. **Better Staff Resource Management**
   ```gdscript
   class_name StaffMember
   extends Resource
   
   @export var staff_id: String
   @export var name: String
   @export_enum("Cook", "Cashier", "Manager", "Marketer") var staff_type: String
   @export_group("Skills")
   @export var skills: Dictionary = {}
   @export var experience: float = 0.0
   @export_group("Performance")
   @export var salary: float = 0.0
   @export var happiness: float = 1.0
   @export var productivity: float = 1.0
   
   func _notification(what: int):
       if what == NOTIFICATION_PREDELETE:
           _cleanup_resources()
   
   func _cleanup_resources():
       # Clean up resources before deletion
       pass
   ```

3. **Improved Testing Framework**
   ```gdscript
   extends GutTest
   
   func test_staff_hiring():
       var staff_manager = StaffManager.new()
       add_child_autofree(staff_manager)
       
       var new_staff = staff_manager.hire_staff("cook", "main_location")
       assert_not_null(new_staff)
       assert_eq(new_staff.staff_type, "cook")
       assert_eq(staff_manager.staff_members.size(), 1)
   
   func test_staff_training():
       var staff_manager = StaffManager.new()
       add_child_autofree(staff_manager)
       
       var staff_member = staff_manager.hire_staff("cook", "main_location")
       var initial_skill = staff_member.get_skill_level("cooking")
       
       staff_manager.train_staff(staff_member, "basic_cooking")
       # Simulate training completion
       staff_manager._complete_training(staff_member.staff_id, {"training_data": {"skills": {"cooking": 1.0}}})
       
       assert_gt(staff_member.get_skill_level("cooking"), initial_skill)
   ```

### Risk Mitigation Updates
1. **Memory Leak Prevention**
   - Implement consistent signal disconnection patterns
   - Add proper resource cleanup in all systems
   - Use object pooling for frequently created objects

2. **Performance Monitoring**
   - Add real-time performance monitoring
   - Implement adaptive quality settings
   - Monitor memory usage and cleanup

3. **Code Maintainability**
   - Use consistent naming conventions
   - Implement proper error handling
   - Add comprehensive logging and debugging

## Next Steps

After completing the Staff Management System:
1. Move to Multiple Locations implementation
2. Integrate with Advanced Upgrades and Research
3. Connect to Events System for staff-related events
4. Implement staff achievements and progression 