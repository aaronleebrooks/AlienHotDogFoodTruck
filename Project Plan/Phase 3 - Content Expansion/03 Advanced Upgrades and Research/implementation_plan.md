# Advanced Upgrades and Research System - Implementation Plan

## Overview
This document provides a detailed step-by-step implementation plan for the Advanced Upgrades and Research System, which adds deep progression mechanics and strategic technology development to the hot dog idle game.

## Implementation Timeline
**Estimated Duration**: 4-5 days
**Sessions**: 8-10 coding sessions of 2-3 hours each

## Day 1: Core Research System Foundation

### Session 1: Research Data Structure (2-3 hours)

#### Step 1: Create Research Item Resource Class
```bash
# Create research system directory
mkdir -p scripts/systems
touch scripts/systems/research_manager.gd
mkdir -p resources
touch resources/research_item.gd
```

```gdscript
# resources/research_item.gd
class_name ResearchItem
extends Resource

@export var research_id: String
@export var name: String
@export var description: String
@export var research_type: String  # "production", "sales", "automation", "quality"
@export var cost: float = 0.0
@export var duration: float = 0.0
@export var prerequisites: Array[String] = []
@export var effects: Dictionary = {}
@export var research_points_required: float = 0.0
@export var success_rate: float = 1.0
@export var research_level: int = 0
@export var max_level: int = 1
@export var icon_path: String = ""
@export var category: String = ""

func _init():
    research_id = _generate_research_id()

func _generate_research_id() -> String:
    return "research_" + str(randi() % 100000)

func can_start_research() -> bool:
    # Check if prerequisites are met
    for prereq in prerequisites:
        if not GameManager.research_manager.is_research_completed(prereq):
            return false
    return GameManager.research_manager.research_points >= research_points_required

func get_progress_percentage() -> float:
    var elapsed_time = GameManager.research_manager.get_research_elapsed_time(research_id)
    return min(elapsed_time / duration, 1.0)

func get_cost_at_level(level: int) -> float:
    return cost * pow(1.5, level)

func get_effect_at_level(level: int) -> Dictionary:
    var scaled_effects = {}
    for effect_type in effects:
        scaled_effects[effect_type] = effects[effect_type] * level
    return scaled_effects

func get_research_time_at_level(level: int) -> float:
    return duration * pow(1.2, level)
```

#### Step 2: Create Research Manager System
```gdscript
# scripts/systems/research_manager.gd
class_name ResearchManager
extends Node

signal research_completed(research_item: ResearchItem)
signal research_started(research_item: ResearchItem)
signal research_progress_updated(research_item: ResearchItem)
signal technology_unlocked(technology_id: String)

var research_queue: Array[ResearchItem] = []
var active_research: Dictionary = {}
var completed_research: Array[String] = []
var available_technologies: Dictionary = {}
var research_points: float = 0.0
var research_points_per_second: float = 1.0
var research_efficiency: float = 1.0

func _ready():
    print("ResearchManager initialized")
    _setup_research_categories()
    _setup_technology_tree()

func _setup_research_categories():
    # Define research categories and their effects
    available_technologies = {
        "production": {
            "name": "Production Research",
            "description": "Improve hot dog production efficiency",
            "base_research_points": 10.0,
            "effects": ["production_rate", "production_capacity", "production_efficiency"]
        },
        "sales": {
            "name": "Sales Research",
            "description": "Enhance sales and marketing capabilities",
            "base_research_points": 10.0,
            "effects": ["sales_rate", "customer_satisfaction", "marketing_efficiency"]
        },
        "automation": {
            "name": "Automation Research",
            "description": "Automate production and sales processes",
            "base_research_points": 15.0,
            "effects": ["auto_collection", "auto_upgrades", "auto_management"]
        },
        "quality": {
            "name": "Quality Research",
            "description": "Improve product quality and customer satisfaction",
            "base_research_points": 12.0,
            "effects": ["product_quality", "customer_loyalty", "reputation"]
        }
    }

func _setup_technology_tree():
    # Create initial research items
    var research_items = [
        {
            "id": "basic_production",
            "name": "Basic Production Methods",
            "description": "Learn efficient hot dog production techniques",
            "type": "production",
            "cost": 50.0,
            "duration": 300.0,
            "prerequisites": [],
            "effects": {"production_rate": 0.2}
        },
        {
            "id": "advanced_production",
            "name": "Advanced Production Methods",
            "description": "Master advanced production techniques",
            "type": "production",
            "cost": 100.0,
            "duration": 600.0,
            "prerequisites": ["basic_production"],
            "effects": {"production_rate": 0.3, "production_efficiency": 0.1}
        },
        {
            "id": "basic_marketing",
            "name": "Basic Marketing",
            "description": "Learn fundamental marketing strategies",
            "type": "sales",
            "cost": 75.0,
            "duration": 450.0,
            "prerequisites": [],
            "effects": {"sales_rate": 0.15}
        },
        {
            "id": "auto_collection",
            "name": "Auto Collection",
            "description": "Automate hot dog collection process",
            "type": "automation",
            "cost": 200.0,
            "duration": 900.0,
            "prerequisites": ["basic_production"],
            "effects": {"auto_collection": 1.0}
        }
    ]
    
    for item_data in research_items:
        var research_item = ResearchItem.new()
        research_item.research_id = item_data.id
        research_item.name = item_data.name
        research_item.description = item_data.description
        research_item.research_type = item_data.type
        research_item.cost = item_data.cost
        research_item.duration = item_data.duration
        research_item.prerequisites = item_data.prerequisites
        research_item.effects = item_data.effects
        research_item.research_points_required = item_data.cost * 0.5
        
        research_queue.append(research_item)

func _process(delta: float):
    _update_research_progress(delta)
    _generate_research_points(delta)

func _generate_research_points(delta: float):
    research_points += research_points_per_second * research_efficiency * delta

func _update_research_progress(delta: float):
    var completed_research_ids = []
    
    for research_id in active_research:
        var research_info = active_research[research_id]
        research_info.elapsed_time += delta
        
        # Emit progress update
        research_progress_updated.emit(research_info.research_item)
        
        if research_info.elapsed_time >= research_info.research_item.duration:
            _complete_research(research_id, research_info)
            completed_research_ids.append(research_id)
    
    for research_id in completed_research_ids:
        active_research.erase(research_id)

func start_research(research_id: String) -> bool:
    var research_item = _get_research_by_id(research_id)
    if not research_item:
        print("Error: Research item not found: %s" % research_id)
        return false
    
    if not research_item.can_start_research():
        print("Error: Cannot start research - prerequisites not met or insufficient points")
        return false
    
    if active_research.has(research_id):
        print("Error: Research already in progress")
        return false
    
    # Deduct research points
    research_points -= research_item.research_points_required
    
    # Start research
    active_research[research_id] = {
        "research_item": research_item,
        "start_time": Time.get_time_dict_from_system(),
        "elapsed_time": 0.0
    }
    
    research_started.emit(research_item)
    EventManager.emit_event("research_started", {"research": research_item.name})
    
    return true

func _complete_research(research_id: String, research_info: Dictionary):
    var research_item = research_info.research_item
    
    # Apply research effects
    _apply_research_effects(research_item)
    
    # Mark as completed
    completed_research.append(research_id)
    
    # Increase research level
    research_item.research_level += 1
    
    research_completed.emit(research_item)
    EventManager.emit_event("research_completed", {"research": research_item.name})
    
    # Check for technology unlocks
    _check_technology_unlocks(research_item)

func _apply_research_effects(research_item: ResearchItem):
    var effects = research_item.get_effect_at_level(research_item.research_level)
    
    for effect_type in effects:
        match effect_type:
            "production_rate":
                GameManager.hot_dog_production.production_rate += effects[effect_type]
            "production_capacity":
                GameManager.hot_dog_production.max_production_capacity += int(effects[effect_type] * 10)
            "production_efficiency":
                GameManager.hot_dog_production.production_efficiency += effects[effect_type]
            "sales_rate":
                GameManager.sales_system.sales_rate += effects[effect_type]
            "customer_satisfaction":
                GameManager.sales_system.customer_satisfaction += effects[effect_type]
            "auto_collection":
                GameManager.hot_dog_production.auto_collect_enabled = true
            "marketing_efficiency":
                GameManager.sales_system.marketing_multiplier += effects[effect_type]

func _get_research_by_id(research_id: String) -> ResearchItem:
    for research_item in research_queue:
        if research_item.research_id == research_id:
            return research_item
    return null

func is_research_completed(research_id: String) -> bool:
    return completed_research.has(research_id)

func get_research_elapsed_time(research_id: String) -> float:
    if active_research.has(research_id):
        return active_research[research_id].elapsed_time
    return 0.0

func _check_technology_unlocks(research_item: ResearchItem):
    # Check if completing this research unlocks new technologies
    var unlock_conditions = {
        "basic_production": ["advanced_production", "auto_collection"],
        "basic_marketing": ["advanced_marketing", "customer_loyalty"],
        "auto_collection": ["auto_upgrades", "auto_management"]
    }
    
    if unlock_conditions.has(research_item.research_id):
        for unlock_id in unlock_conditions[research_item.research_id]:
            technology_unlocked.emit(unlock_id)
```

#### Step 3: Integrate with Game Manager
```gdscript
# Add to scripts/autoload/game_manager.gd
var research_manager: ResearchManager

func _ready():
    research_manager = ResearchManager.new()
    add_child(research_manager)
    
    research_manager.research_completed.connect(_on_research_completed)
    research_manager.research_started.connect(_on_research_started)
    research_manager.technology_unlocked.connect(_on_technology_unlocked)
```

### Session 2: Research UI Components (2-3 hours)

#### Step 1: Create Research Management Interface
```bash
# Create research UI scenes
mkdir -p scenes/ui
touch scenes/ui/research_management.tscn
touch scenes/ui/research_management.gd
touch scenes/ui/research_tree.tscn
touch scenes/ui/research_tree.gd
```

```gdscript
# scenes/ui/research_management.gd
extends Control

@onready var research_tree = $ResearchTree
@onready var active_research_panel = $ActiveResearchPanel
@onready var research_points_label = $ResearchPointsLabel
@onready var research_efficiency_label = $ResearchEfficiencyLabel

func _ready():
    GameManager.research_manager.research_started.connect(_on_research_started)
    GameManager.research_manager.research_completed.connect(_on_research_completed)
    GameManager.research_manager.research_progress_updated.connect(_on_research_progress_updated)
    
    _update_research_tree()
    _update_active_research()
    _update_research_points()

func _update_research_tree():
    research_tree.clear_research()
    
    for research_item in GameManager.research_manager.research_queue:
        research_tree.add_research_item(research_item)
        research_tree.research_selected.connect(_on_research_selected)

func _on_research_started(research_item: ResearchItem):
    _update_active_research()
    _update_research_points()

func _on_research_completed(research_item: ResearchItem):
    _update_active_research()
    _update_research_tree()
    _show_completion_notification(research_item)

func _on_research_progress_updated(research_item: ResearchItem):
    _update_active_research()

func _on_research_selected(research_item: ResearchItem):
    _show_research_details(research_item)

func _update_active_research():
    active_research_panel.clear_research()
    
    for research_id in GameManager.research_manager.active_research:
        var research_info = GameManager.research_manager.active_research[research_id]
        active_research_panel.add_active_research(research_info.research_item, research_info.elapsed_time)

func _update_research_points():
    research_points_label.text = "Research Points: %.1f" % GameManager.research_manager.research_points
    research_efficiency_label.text = "Efficiency: %.1fx" % GameManager.research_manager.research_efficiency

func _show_completion_notification(research_item: ResearchItem):
    var notification = preload("res://scenes/ui/research_completion_notification.tscn").instantiate()
    notification.setup(research_item)
    add_child(notification)

func _show_research_details(research_item: ResearchItem):
    var details_dialog = preload("res://scenes/ui/research_details_dialog.tscn").instantiate()
    details_dialog.setup(research_item)
    details_dialog.research_started.connect(_on_start_research_requested)
    add_child(details_dialog)

func _on_start_research_requested(research_item: ResearchItem):
    var success = GameManager.research_manager.start_research(research_item.research_id)
    if success:
        _update_research_points()
```

#### Step 2: Create Research Tree Component
```gdscript
# scenes/ui/research_tree.gd
extends Control

@onready var tree_container = $TreeContainer

signal research_selected(research_item: ResearchItem)

var research_nodes: Dictionary = {}

func clear_research():
    for node in research_nodes.values():
        node.queue_free()
    research_nodes.clear()

func add_research_item(research_item: ResearchItem):
    var research_node = preload("res://scenes/ui/research_tree_node.tscn").instantiate()
    research_node.setup(research_item)
    research_node.research_clicked.connect(_on_research_clicked)
    tree_container.add_child(research_node)
    research_nodes[research_item.research_id] = research_node

func _on_research_clicked(research_item: ResearchItem):
    research_selected.emit(research_item)
```

## Day 2: Research Categories and Technology Tree

### Session 3: Research Categories Implementation (2-3 hours)

#### Step 1: Implement Research Categories
```gdscript
# Add to scripts/systems/research_manager.gd
var research_categories: Dictionary = {}

func _ready():
    _setup_research_categories()

func _setup_research_categories():
    research_categories = {
        "production": {
            "name": "Production Research",
            "description": "Improve hot dog production efficiency and capacity",
            "color": Color.BLUE,
            "icon": "production_icon",
            "unlock_condition": "none",
            "research_bonus": 1.0
        },
        "sales": {
            "name": "Sales Research",
            "description": "Enhance sales and marketing capabilities",
            "color": Color.GREEN,
            "icon": "sales_icon",
            "unlock_condition": "production_level_2",
            "research_bonus": 1.0
        },
        "automation": {
            "name": "Automation Research",
            "description": "Automate production and management processes",
            "color": Color.ORANGE,
            "icon": "automation_icon",
            "unlock_condition": "production_level_3",
            "research_bonus": 1.2
        },
        "quality": {
            "name": "Quality Research",
            "description": "Improve product quality and customer satisfaction",
            "color": Color.PURPLE,
            "icon": "quality_icon",
            "unlock_condition": "sales_level_2",
            "research_bonus": 1.1
        }
    }

func get_research_by_category(category: String) -> Array[ResearchItem]:
    var category_research: Array[ResearchItem] = []
    for research_item in research_queue:
        if research_item.research_type == category:
            category_research.append(research_item)
    return category_research

func get_category_progress(category: String) -> Dictionary:
    var category_research = get_research_by_category(category)
    var total_research = category_research.size()
    var completed_research = 0
    var active_research = 0
    
    for research_item in category_research:
        if is_research_completed(research_item.research_id):
            completed_research += 1
        elif GameManager.research_manager.active_research.has(research_item.research_id):
            active_research += 1
    
    return {
        "total": total_research,
        "completed": completed_research,
        "active": active_research,
        "progress": float(completed_research) / total_research if total_research > 0 else 0.0
    }

func get_category_bonus(category: String) -> float:
    var category_data = research_categories.get(category, {})
    var progress = get_category_progress(category)
    var base_bonus = category_data.get("research_bonus", 1.0)
    
    return base_bonus * (1.0 + progress.progress * 0.5)
```

#### Step 2: Create Research Category UI
```gdscript
# scenes/ui/research_categories.gd
extends Control

@onready var category_tabs = $CategoryTabs
@onready var research_list = $ResearchList

var current_category: String = "production"

func _ready():
    _setup_category_tabs()
    _show_category_research("production")

func _setup_category_tabs():
    for category in GameManager.research_manager.research_categories:
        var category_data = GameManager.research_manager.research_categories[category]
        category_tabs.add_tab(category_data.name)
    
    category_tabs.tab_changed.connect(_on_category_changed)

func _on_category_changed(tab_index: int):
    var categories = GameManager.research_manager.research_categories.keys()
    if tab_index < categories.size():
        current_category = categories[tab_index]
        _show_category_research(current_category)

func _show_category_research(category: String):
    research_list.clear_research()
    
    var category_research = GameManager.research_manager.get_research_by_category(category)
    for research_item in category_research:
        research_list.add_research_item(research_item)
    
    _update_category_progress(category)

func _update_category_progress(category: String):
    var progress = GameManager.research_manager.get_category_progress(category)
    var category_data = GameManager.research_manager.research_categories[category]
    
    # Update progress bar
    var progress_bar = $CategoryProgress/ProgressBar
    progress_bar.value = progress.progress * 100
    
    # Update progress label
    var progress_label = $CategoryProgress/ProgressLabel
    progress_label.text = "%d/%d Completed" % [progress.completed, progress.total]
    
    # Update bonus label
    var bonus = GameManager.research_manager.get_category_bonus(category)
    var bonus_label = $CategoryProgress/BonusLabel
    bonus_label.text = "Bonus: %.1fx" % bonus
```

### Session 4: Technology Tree Visualization (2-3 hours)

#### Step 1: Implement Technology Tree Structure
```gdscript
# Add to scripts/systems/research_manager.gd
var technology_tree: Dictionary = {}

func _setup_technology_tree():
    technology_tree = {
        "production": {
            "basic_production": {
                "position": Vector2(0, 0),
                "connections": ["advanced_production", "auto_collection"]
            },
            "advanced_production": {
                "position": Vector2(0, 100),
                "connections": ["mass_production", "efficiency_mastery"]
            },
            "auto_collection": {
                "position": Vector2(100, 0),
                "connections": ["auto_upgrades", "smart_collection"]
            }
        },
        "sales": {
            "basic_marketing": {
                "position": Vector2(0, 0),
                "connections": ["advanced_marketing", "customer_analysis"]
            },
            "advanced_marketing": {
                "position": Vector2(0, 100),
                "connections": ["brand_management", "market_dominance"]
            }
        }
    }

func get_research_connections(research_id: String) -> Array[String]:
    for category in technology_tree:
        if technology_tree[category].has(research_id):
            return technology_tree[category][research_id].connections
    return []

func get_research_position(research_id: String) -> Vector2:
    for category in technology_tree:
        if technology_tree[category].has(research_id):
            return technology_tree[category][research_id].position
    return Vector2.ZERO

func is_research_unlocked(research_id: String) -> bool:
    var research_item = _get_research_by_id(research_id)
    if not research_item:
        return false
    
    for prereq in research_item.prerequisites:
        if not is_research_completed(prereq):
            return false
    
    return true
```

#### Step 2: Create Technology Tree Visualization
```gdscript
# scenes/ui/technology_tree_view.gd
extends Control

@onready var tree_canvas = $TreeCanvas
@onready var zoom_slider = $ZoomSlider

var research_nodes: Dictionary = {}
var connection_lines: Array = []
var zoom_level: float = 1.0

func _ready():
    _setup_zoom_controls()
    _build_technology_tree()

func _setup_zoom_controls():
    zoom_slider.value_changed.connect(_on_zoom_changed)

func _on_zoom_changed(value: float):
    zoom_level = value
    _update_tree_scale()

func _build_technology_tree():
    _clear_tree()
    
    # Create research nodes
    for research_item in GameManager.research_manager.research_queue:
        _create_research_node(research_item)
    
    # Create connections
    _create_connections()
    
    _update_tree_scale()

func _create_research_node(research_item: ResearchItem):
    var node = preload("res://scenes/ui/technology_tree_node.tscn").instantiate()
    node.setup(research_item)
    node.position = GameManager.research_manager.get_research_position(research_item.research_id)
    tree_canvas.add_child(node)
    research_nodes[research_item.research_id] = node

func _create_connections():
    for research_item in GameManager.research_manager.research_queue:
        var connections = GameManager.research_manager.get_research_connections(research_item.research_id)
        for connection_id in connections:
            if research_nodes.has(connection_id):
                _create_connection_line(research_item.research_id, connection_id)

func _create_connection_line(from_id: String, to_id: String):
    var line = Line2D.new()
    var from_node = research_nodes[from_id]
    var to_node = research_nodes[to_id]
    
    line.points = [from_node.position, to_node.position]
    line.width = 2.0
    line.default_color = Color.WHITE
    
    tree_canvas.add_child(line)
    connection_lines.append(line)

func _clear_tree():
    for node in research_nodes.values():
        node.queue_free()
    research_nodes.clear()
    
    for line in connection_lines:
        line.queue_free()
    connection_lines.clear()

func _update_tree_scale():
    tree_canvas.scale = Vector2(zoom_level, zoom_level)
```

## Day 3: Research Projects and Advanced Features

### Session 5: Research Projects and Experiments (2-3 hours)

#### Step 1: Implement Research Projects
```gdscript
# Add to scripts/systems/research_manager.gd
var research_projects: Dictionary = {}

func create_research_project(project_type: String, duration: float, cost: float) -> String:
    var project_id = "project_" + str(randi() % 100000)
    
    research_projects[project_id] = {
        "type": project_type,
        "duration": duration,
        "cost": cost,
        "start_time": Time.get_time_dict_from_system(),
        "elapsed_time": 0.0,
        "success_rate": _calculate_success_rate(project_type),
        "effects": _get_project_effects(project_type)
    }
    
    EventManager.emit_event("research_project_started", {"type": project_type, "id": project_id})
    return project_id

func _calculate_success_rate(project_type: String) -> float:
    var base_success_rate = 0.8
    var research_bonus = 0.0
    
    # Add bonuses based on completed research
    for category in research_categories:
        var progress = get_category_progress(category)
        research_bonus += progress.progress * 0.1
    
    return min(base_success_rate + research_bonus, 0.95)

func _get_project_effects(project_type: String) -> Dictionary:
    var effects = {
        "breakthrough": {
            "research_points": 100.0,
            "efficiency_boost": 0.2,
            "unlock_bonus": 1.0
        },
        "experiment": {
            "research_points": 50.0,
            "efficiency_boost": 0.1,
            "unlock_bonus": 0.5
        },
        "discovery": {
            "research_points": 200.0,
            "efficiency_boost": 0.3,
            "unlock_bonus": 1.5
        }
    }
    
    return effects.get(project_type, {})

func _process(delta: float):
    _update_research_projects(delta)

func _update_research_projects(delta: float):
    var completed_projects = []
    
    for project_id in research_projects:
        var project = research_projects[project_id]
        project.elapsed_time += delta
        
        if project.elapsed_time >= project.duration:
            _complete_research_project(project_id, project)
            completed_projects.append(project_id)
    
    for project_id in completed_projects:
        research_projects.erase(project_id)

func _complete_research_project(project_id: String, project: Dictionary):
    var success = randf() < project.success_rate
    
    if success:
        # Apply project effects
        _apply_project_effects(project)
        EventManager.emit_event("research_project_completed", {"id": project_id, "type": project.type, "success": true})
    else:
        EventManager.emit_event("research_project_failed", {"id": project_id, "type": project.type})

func _apply_project_effects(project: Dictionary):
    var effects = project.effects
    
    if effects.has("research_points"):
        research_points += effects.research_points
    
    if effects.has("efficiency_boost"):
        research_efficiency += effects.efficiency_boost
    
    if effects.has("unlock_bonus"):
        # Unlock bonus research or technologies
        _apply_unlock_bonus(effects.unlock_bonus)
```

#### Step 2: Create Research Projects UI
```gdscript
# scenes/ui/research_projects.gd
extends Control

@onready var projects_list = $ProjectsList
@onready var new_project_button = $NewProjectButton

func _ready():
    new_project_button.pressed.connect(_on_new_project_pressed)
    _update_projects_list()

func _update_projects_list():
    projects_list.clear_projects()
    
    for project_id in GameManager.research_manager.research_projects:
        var project = GameManager.research_manager.research_projects[project_id]
        projects_list.add_project(project_id, project)

func _on_new_project_pressed():
    var project_dialog = preload("res://scenes/ui/new_research_project_dialog.tscn").instantiate()
    project_dialog.project_created.connect(_on_project_created)
    add_child(project_dialog)

func _on_project_created(project_type: String, duration: float, cost: float):
    var project_id = GameManager.research_manager.create_research_project(project_type, duration, cost)
    _update_projects_list()
```

### Session 6: Research Points and Resource Management (2-3 hours)

#### Step 1: Implement Research Points System
```gdscript
# Add to scripts/systems/research_manager.gd
var research_points_multiplier: float = 1.0
var research_points_decay_rate: float = 0.01
var max_research_points: float = 1000.0

func _generate_research_points(delta: float):
    var base_generation = research_points_per_second * research_efficiency * delta
    var multiplier_bonus = research_points_multiplier
    var category_bonus = _calculate_category_bonus()
    
    var total_generation = base_generation * multiplier_bonus * category_bonus
    
    research_points += total_generation
    research_points = min(research_points, max_research_points)
    
    # Apply decay
    research_points -= research_points_decay_rate * delta
    research_points = max(research_points, 0.0)

func _calculate_category_bonus() -> float:
    var total_bonus = 1.0
    
    for category in research_categories:
        var progress = get_category_progress(category)
        var category_bonus = get_category_bonus(category)
        total_bonus += (category_bonus - 1.0) * progress.progress
    
    return total_bonus

func spend_research_points(amount: float) -> bool:
    if research_points >= amount:
        research_points -= amount
        return true
    return false

func add_research_points_bonus(bonus: float):
    research_points_multiplier += bonus

func increase_max_research_points(amount: float):
    max_research_points += amount
```

#### Step 2: Create Research Points Management UI
```gdscript
# scenes/ui/research_points_management.gd
extends Control

@onready var points_display = $PointsDisplay
@onready var generation_rate_label = $GenerationRateLabel
@onready var efficiency_label = $EfficiencyLabel
@onready var multiplier_label = $MultiplierLabel

func _ready():
    # Update display every second
    var timer = Timer.new()
    timer.wait_time = 1.0
    timer.timeout.connect(_update_display)
    add_child(timer)
    timer.start()
    
    _update_display()

func _update_display():
    var research_manager = GameManager.research_manager
    
    points_display.text = "Research Points: %.1f/%.1f" % [research_manager.research_points, research_manager.max_research_points]
    generation_rate_label.text = "Generation: %.1f/s" % (research_manager.research_points_per_second * research_manager.research_efficiency)
    efficiency_label.text = "Efficiency: %.1fx" % research_manager.research_efficiency
    multiplier_label.text = "Multiplier: %.1fx" % research_manager.research_points_multiplier
    
    # Update progress bar
    var progress_bar = $PointsProgressBar
    progress_bar.max_value = research_manager.max_research_points
    progress_bar.value = research_manager.research_points
```

## Day 4: Advanced Features and Integration

### Session 7: Research Analytics and Optimization (2-3 hours)

#### Step 1: Implement Research Analytics
```gdscript
# Add to scripts/systems/research_manager.gd
var research_statistics: Dictionary = {}

func get_research_statistics() -> Dictionary:
    var stats = {
        "total_research_completed": completed_research.size(),
        "active_research_count": active_research.size(),
        "research_points_generated": 0.0,
        "research_efficiency": research_efficiency,
        "average_research_time": 0.0,
        "success_rate": 0.0,
        "category_progress": {},
        "most_researched_category": "",
        "research_trends": {}
    }
    
    # Calculate category progress
    for category in research_categories:
        stats.category_progress[category] = get_category_progress(category)
    
    # Find most researched category
    var max_progress = 0.0
    for category in stats.category_progress:
        if stats.category_progress[category].progress > max_progress:
            max_progress = stats.category_progress[category].progress
            stats.most_researched_category = category
    
    return stats

func get_research_recommendations() -> Array[String]:
    var recommendations: Array[String] = []
    
    # Check for low-hanging fruit (easy research with good effects)
    for research_item in research_queue:
        if not is_research_completed(research_item.research_id) and not active_research.has(research_item.research_id):
            if research_item.research_points_required <= research_points * 0.5:
                if research_item.prerequisites.size() == 0 or _all_prerequisites_met(research_item):
                    recommendations.append(research_item.research_id)
    
    return recommendations

func _all_prerequisites_met(research_item: ResearchItem) -> bool:
    for prereq in research_item.prerequisites:
        if not is_research_completed(prereq):
            return false
    return true
```

#### Step 2: Create Research Analytics UI
```gdscript
# scenes/ui/research_analytics.gd
extends Control

@onready var statistics_panel = $StatisticsPanel
@onready var recommendations_panel = $RecommendationsPanel
@onready var trends_chart = $TrendsChart

func _ready():
    # Update analytics every 10 seconds
    var timer = Timer.new()
    timer.wait_time = 10.0
    timer.timeout.connect(_update_analytics)
    add_child(timer)
    timer.start()
    
    _update_analytics()

func _update_analytics():
    var stats = GameManager.research_manager.get_research_statistics()
    var recommendations = GameManager.research_manager.get_research_recommendations()
    
    _update_statistics_panel(stats)
    _update_recommendations_panel(recommendations)
    _update_trends_chart(stats.research_trends)

func _update_statistics_panel(stats: Dictionary):
    var total_completed_label = $StatisticsPanel/TotalCompletedLabel
    var active_count_label = $StatisticsPanel/ActiveCountLabel
    var efficiency_label = $StatisticsPanel/EfficiencyLabel
    var success_rate_label = $StatisticsPanel/SuccessRateLabel
    
    total_completed_label.text = "Total Completed: %d" % stats.total_research_completed
    active_count_label.text = "Active Research: %d" % stats.active_research_count
    efficiency_label.text = "Efficiency: %.2f" % stats.research_efficiency
    success_rate_label.text = "Success Rate: %.1f%%" % (stats.success_rate * 100)

func _update_recommendations_panel(recommendations: Array[String]):
    var recommendations_list = $RecommendationsPanel/RecommendationsList
    
    # Clear existing recommendations
    for child in recommendations_list.get_children():
        child.queue_free()
    
    # Add new recommendations
    for research_id in recommendations:
        var research_item = GameManager.research_manager._get_research_by_id(research_id)
        if research_item:
            var recommendation_item = preload("res://scenes/ui/research_recommendation_item.tscn").instantiate()
            recommendation_item.setup(research_item)
            recommendation_item.research_selected.connect(_on_recommendation_selected)
            recommendations_list.add_child(recommendation_item)

func _on_recommendation_selected(research_item: ResearchItem):
    var details_dialog = preload("res://scenes/ui/research_details_dialog.tscn").instantiate()
    details_dialog.setup(research_item)
    add_child(details_dialog)
```

### Session 8: Final Integration and Testing (2-3 hours)

#### Step 1: Integrate with Other Systems
```gdscript
# Add to scripts/autoload/game_manager.gd
func _connect_research_signals():
    research_manager.research_completed.connect(_on_research_completed)
    research_manager.research_started.connect(_on_research_started)
    research_manager.technology_unlocked.connect(_on_technology_unlocked)

func _on_research_completed(research_item: ResearchItem):
    # Apply research effects to game systems
    _apply_research_effects_to_systems(research_item)

func _on_research_started(research_item: ResearchItem):
    # Update UI and notifications
    EventManager.emit_event("research_started", {"research": research_item.name})

func _on_technology_unlocked(technology_id: String):
    # Unlock new technologies and features
    _unlock_technology(technology_id)

func _apply_research_effects_to_systems(research_item: ResearchItem):
    var effects = research_item.get_effect_at_level(research_item.research_level)
    
    for effect_type in effects:
        match effect_type:
            "production_rate":
                hot_dog_production.production_rate += effects[effect_type]
            "production_capacity":
                hot_dog_production.max_production_capacity += int(effects[effect_type] * 10)
            "sales_rate":
                sales_system.sales_rate += effects[effect_type]
            "auto_collection":
                hot_dog_production.auto_collect_enabled = true
            "marketing_efficiency":
                sales_system.marketing_multiplier += effects[effect_type]
```

#### Step 2: Create Comprehensive Tests
```gdscript
# scripts/tests/research_system_test.gd
extends GutTest

func test_research_creation():
    var research_manager = ResearchManager.new()
    add_child_autofree(research_manager)
    
    var research_item = research_manager._get_research_by_id("basic_production")
    assert_not_null(research_item)
    assert_eq(research_item.name, "Basic Production Methods")

func test_research_start():
    var research_manager = ResearchManager.new()
    add_child_autofree(research_manager)
    
    research_manager.research_points = 100.0
    var success = research_manager.start_research("basic_production")
    assert_true(success)
    assert_true(research_manager.active_research.has("basic_production"))

func test_research_completion():
    var research_manager = ResearchManager.new()
    add_child_autofree(research_manager)
    
    research_manager.research_points = 100.0
    research_manager.start_research("basic_production")
    
    # Simulate research completion
    var research_info = research_manager.active_research["basic_production"]
    research_info.elapsed_time = research_info.research_item.duration
    
    research_manager._update_research_progress(0.0)
    assert_true(research_manager.is_research_completed("basic_production"))
```

## Success Criteria Checklist

- [ ] Research system allows starting and completing research projects
- [ ] Research points generation and spending mechanics work correctly
- [ ] Research categories provide meaningful progression paths
- [ ] Technology tree visualization is functional and intuitive
- [ ] Research effects properly integrate with other game systems
- [ ] Research analytics provide useful insights and recommendations
- [ ] Research UI is intuitive and provides clear feedback
- [ ] Research system integrates with save/load functionality
- [ ] Research balance provides engaging long-term progression
- [ ] Research system supports strategic decision-making

## Risk Mitigation

1. **System Complexity**: Implement modular design with clear interfaces
2. **Performance Issues**: Use efficient algorithms and batch updates
3. **Balance Problems**: Extensive testing and balance configuration
4. **UI Complexity**: Create intuitive, hierarchical interface design

## Next Steps

After completing the Advanced Upgrades and Research System:
1. Move to Events System implementation
2. Integrate with achievement system for research milestones
3. Connect to prestige system for research bonuses
4. Implement research-specific events and challenges 