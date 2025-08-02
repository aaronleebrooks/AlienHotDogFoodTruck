# Upgrade System - Implementation Plan

## Overview
This document provides a detailed step-by-step implementation plan for the Upgrade System, which provides progression and advancement opportunities for players in the hot dog idle game.

## Implementation Timeline
**Estimated Duration**: 3-4 days
**Sessions**: 6-8 coding sessions of 2-3 hours each

## Day 1: Core Upgrade Framework

### Session 1: Upgrade Data Structure (2-3 hours)

#### Step 1: Create Upgrade Resource Class
```bash
# Create upgrade system directory
mkdir -p scripts/systems
touch scripts/systems/upgrade_system.gd
mkdir -p resources
touch resources/upgrade_data.gd
```

```gdscript
# resources/upgrade_data.gd
class_name UpgradeData
extends Resource

@export var upgrade_id: String
@export var display_name: String
@export var description: String
@export var category: String  # "production", "sales", "automation", "quality"
@export var base_cost: float
@export var cost_multiplier: float = 1.5
@export var max_level: int = 50
@export var effect_type: String  # "multiplier", "additive", "unlock"
@export var effect_value: float
@export var icon_path: String
@export var prerequisites: Array[String] = []
@export var unlock_condition: String = ""

func get_cost_at_level(level: int) -> float:
    return base_cost * pow(cost_multiplier, level)

func get_effect_at_level(level: int) -> float:
    match effect_type:
        "multiplier":
            return 1.0 + (effect_value * level)
        "additive":
            return effect_value * level
        "unlock":
            return 1.0 if level > 0 else 0.0
        _:
            return effect_value
```

#### Step 2: Create Upgrade System Manager
```gdscript
# scripts/systems/upgrade_system.gd
class_name UpgradeSystem
extends Node

signal upgrade_purchased(upgrade_id: String, new_level: int)
signal upgrade_effect_applied(upgrade_id: String, effect_value: float)
signal upgrade_available(upgrade_id: String)

var upgrades: Dictionary = {}
var upgrade_levels: Dictionary = {}
var available_upgrades: Array[String] = []

func _ready():
    print("UpgradeSystem initialized")
    _load_upgrade_data()
    _check_available_upgrades()

func _load_upgrade_data():
    # Load all upgrade data from resources
    var upgrade_files = [
        "production_rate_upgrade",
        "production_capacity_upgrade", 
        "sales_rate_upgrade",
        "marketing_upgrade",
        "auto_collect_upgrade",
        "quality_upgrade"
    ]
    
    for file_name in upgrade_files:
        var upgrade_data = load("res://resources/upgrades/" + file_name + ".tres")
        if upgrade_data:
            upgrades[upgrade_data.upgrade_id] = upgrade_data
            upgrade_levels[upgrade_data.upgrade_id] = 0

func purchase_upgrade(upgrade_id: String) -> bool:
    if not upgrades.has(upgrade_id):
        return false
        
    var upgrade_data = upgrades[upgrade_id]
    var current_level = upgrade_levels[upgrade_id]
    
    if current_level >= upgrade_data.max_level:
        return false
        
    var cost = upgrade_data.get_cost_at_level(current_level)
    
    if GameManager.player_money >= cost:
        GameManager.player_money -= cost
        upgrade_levels[upgrade_id] += 1
        _apply_upgrade_effect(upgrade_id)
        upgrade_purchased.emit(upgrade_id, upgrade_levels[upgrade_id])
        EventManager.emit_event("upgrade_purchased", upgrade_id)
        return true
    
    return false

func _apply_upgrade_effect(upgrade_id: String):
    var upgrade_data = upgrades[upgrade_id]
    var level = upgrade_levels[upgrade_id]
    var effect_value = upgrade_data.get_effect_at_level(level)
    
    match upgrade_id:
        "production_rate":
            GameManager.hot_dog_production.production_rate += upgrade_data.effect_value
        "production_capacity":
            GameManager.hot_dog_production.max_production_capacity += int(upgrade_data.effect_value)
        "sales_rate":
            GameManager.sales_system.sales_rate += upgrade_data.effect_value
        "marketing":
            GameManager.sales_system.marketing_multiplier += upgrade_data.effect_value
        "auto_collect":
            GameManager.hot_dog_production.auto_collect_enabled = true
        "quality":
            GameManager.sales_system.service_quality += upgrade_data.effect_value
    
    upgrade_effect_applied.emit(upgrade_id, effect_value)
```

#### Step 3: Create Upgrade Data Resources
```gdscript
# Create individual upgrade resource files
# resources/upgrades/production_rate_upgrade.tres
var production_rate_upgrade = UpgradeData.new()
production_rate_upgrade.upgrade_id = "production_rate"
production_rate_upgrade.display_name = "Faster Production"
production_rate_upgrade.description = "Increase hot dog production rate"
production_rate_upgrade.category = "production"
production_rate_upgrade.base_cost = 10.0
production_rate_upgrade.effect_type = "additive"
production_rate_upgrade.effect_value = 0.5
production_rate_upgrade.max_level = 20

# resources/upgrades/production_capacity_upgrade.tres
var production_capacity_upgrade = UpgradeData.new()
production_capacity_upgrade.upgrade_id = "production_capacity"
production_capacity_upgrade.display_name = "Larger Storage"
production_capacity_upgrade.description = "Increase production capacity"
production_capacity_upgrade.category = "production"
production_capacity_upgrade.base_cost = 25.0
production_capacity_upgrade.effect_type = "additive"
production_capacity_upgrade.effect_value = 50.0
production_capacity_upgrade.max_level = 15
```

### Session 2: Upgrade UI Framework (2-3 hours)

#### Step 1: Create Upgrade Panel
```bash
# Create upgrade UI scene
mkdir -p scenes/ui
touch scenes/ui/upgrade_panel.tscn
touch scenes/ui/upgrade_panel.gd
```

```gdscript
# scenes/ui/upgrade_panel.gd
extends Control

@onready var upgrade_container = $UpgradeContainer
@onready var category_tabs = $CategoryTabs

var upgrade_button_scene = preload("res://scenes/ui/upgrade_button.tscn")
var current_category: String = "production"

func _ready():
    GameManager.upgrade_system.upgrade_purchased.connect(_on_upgrade_purchased)
    GameManager.upgrade_system.upgrade_available.connect(_on_upgrade_available)
    
    category_tabs.tab_changed.connect(_on_category_changed)
    _populate_upgrades()

func _populate_upgrades():
    # Clear existing upgrades
    for child in upgrade_container.get_children():
        child.queue_free()
    
    # Add upgrades for current category
    for upgrade_id in GameManager.upgrade_system.upgrades:
        var upgrade_data = GameManager.upgrade_system.upgrades[upgrade_id]
        if upgrade_data.category == current_category:
            var upgrade_button = upgrade_button_scene.instantiate()
            upgrade_button.setup(upgrade_data)
            upgrade_container.add_child(upgrade_button)

func _on_category_changed(tab_index: int):
    var categories = ["production", "sales", "automation", "quality"]
    current_category = categories[tab_index]
    _populate_upgrades()

func _on_upgrade_purchased(upgrade_id: String, new_level: int):
    _populate_upgrades()  # Refresh display

func _on_upgrade_available(upgrade_id: String):
    # Highlight newly available upgrade
    pass
```

#### Step 2: Create Upgrade Button Component
```gdscript
# scenes/ui/upgrade_button.gd
extends Button

@onready var name_label = $NameLabel
@onready var description_label = $DescriptionLabel
@onready var cost_label = $CostLabel
@onready var level_label = $LevelLabel
@onready var progress_bar = $ProgressBar

var upgrade_data: UpgradeData

func setup(data: UpgradeData):
    upgrade_data = data
    name_label.text = data.display_name
    description_label.text = data.description
    
    pressed.connect(_on_pressed)
    _update_display()

func _update_display():
    var current_level = GameManager.upgrade_system.upgrade_levels[upgrade_data.upgrade_id]
    var cost = upgrade_data.get_cost_at_level(current_level)
    
    level_label.text = "Level: %d/%d" % [current_level, upgrade_data.max_level]
    cost_label.text = "Cost: $%.1f" % cost
    progress_bar.max_value = upgrade_data.max_level
    progress_bar.value = current_level
    
    # Disable button if max level reached or not enough money
    disabled = current_level >= upgrade_data.max_level or GameManager.player_money < cost

func _on_pressed():
    if GameManager.upgrade_system.purchase_upgrade(upgrade_data.upgrade_id):
        _update_display()
```

## Day 2: Advanced Upgrade Features

### Session 3: Prerequisites and Unlock System (2-3 hours)

#### Step 1: Implement Prerequisite Checking
```gdscript
# Add to scripts/systems/upgrade_system.gd
func _check_available_upgrades():
    available_upgrades.clear()
    
    for upgrade_id in upgrades:
        var upgrade_data = upgrades[upgrade_id]
        if _can_purchase_upgrade(upgrade_id):
            available_upgrades.append(upgrade_id)
            upgrade_available.emit(upgrade_id)

func _can_purchase_upgrade(upgrade_id: String) -> bool:
    var upgrade_data = upgrades[upgrade_id]
    var current_level = upgrade_levels[upgrade_id]
    
    # Check if max level reached
    if current_level >= upgrade_data.max_level:
        return false
    
    # Check prerequisites
    for prereq_id in upgrade_data.prerequisites:
        if not upgrade_levels.has(prereq_id) or upgrade_levels[prereq_id] == 0:
            return false
    
    # Check unlock conditions
    if upgrade_data.unlock_condition != "":
        if not _check_unlock_condition(upgrade_data.unlock_condition):
            return false
    
    return true

func _check_unlock_condition(condition: String) -> bool:
    match condition:
        "money_1000":
            return GameManager.player_money >= 1000.0
        "production_rate_5":
            return GameManager.hot_dog_production.production_rate >= 5.0
        "sales_100":
            return GameManager.sales_system.total_sales >= 100
        "time_played_1_hour":
            return GameManager.game_time >= 3600.0
        _:
            return true
```

#### Step 2: Create Unlock Notifications
```gdscript
# Add to scenes/ui/upgrade_panel.gd
func _on_upgrade_available(upgrade_id: String):
    var upgrade_data = GameManager.upgrade_system.upgrades[upgrade_id]
    show_unlock_notification(upgrade_data.display_name)

func show_unlock_notification(upgrade_name: String):
    var notification = preload("res://scenes/ui/notification_popup.tscn").instantiate()
    notification.set_message("New upgrade available: %s!" % upgrade_name)
    add_child(notification)
```

### Session 4: Upgrade Categories and Organization (2-3 hours)

#### Step 1: Create Category System
```gdscript
# Add to scripts/systems/upgrade_system.gd
var upgrade_categories: Dictionary = {
    "production": {
        "name": "Production",
        "description": "Improve hot dog production",
        "icon": "res://assets/icons/production.png"
    },
    "sales": {
        "name": "Sales",
        "description": "Boost sales and marketing",
        "icon": "res://assets/icons/sales.png"
    },
    "automation": {
        "name": "Automation",
        "description": "Automate processes",
        "icon": "res://assets/icons/automation.png"
    },
    "quality": {
        "name": "Quality",
        "description": "Improve customer satisfaction",
        "icon": "res://assets/icons/quality.png"
    }
}

func get_upgrades_by_category(category: String) -> Array[String]:
    var category_upgrades: Array[String] = []
    for upgrade_id in upgrades:
        if upgrades[upgrade_id].category == category:
            category_upgrades.append(upgrade_id)
    return category_upgrades

func get_category_info(category: String) -> Dictionary:
    return upgrade_categories.get(category, {})
```

#### Step 2: Create Category Tab System
```gdscript
# Add to scenes/ui/upgrade_panel.gd
func _setup_category_tabs():
    var categories = ["production", "sales", "automation", "quality"]
    
    for category in categories:
        var category_info = GameManager.upgrade_system.get_category_info(category)
        var tab_index = category_tabs.add_tab(category_info.name)
        
        # Set tab icon if available
        if category_info.has("icon"):
            category_tabs.set_tab_icon(tab_index, load(category_info.icon))
```

## Day 3: Upgrade Effects and Balance

### Session 5: Complex Upgrade Effects (2-3 hours)

#### Step 1: Implement Multiplier Effects
```gdscript
# Add to scripts/systems/upgrade_system.gd
var active_multipliers: Dictionary = {}

func _apply_upgrade_effect(upgrade_id: String):
    var upgrade_data = upgrades[upgrade_id]
    var level = upgrade_levels[upgrade_id]
    var effect_value = upgrade_data.get_effect_at_level(level)
    
    match upgrade_data.effect_type:
        "multiplier":
            _apply_multiplier_effect(upgrade_id, effect_value)
        "additive":
            _apply_additive_effect(upgrade_id, effect_value)
        "unlock":
            _apply_unlock_effect(upgrade_id, effect_value)
        "percentage":
            _apply_percentage_effect(upgrade_id, effect_value)

func _apply_multiplier_effect(upgrade_id: String, multiplier: float):
    active_multipliers[upgrade_id] = multiplier
    
    # Apply to relevant systems
    match upgrade_id:
        "production_efficiency":
            GameManager.hot_dog_production.production_efficiency = multiplier
        "sales_multiplier":
            GameManager.sales_system.marketing_multiplier = multiplier
        "money_multiplier":
            GameManager.money_multiplier = multiplier

func _apply_additive_effect(upgrade_id: String, value: float):
    match upgrade_id:
        "production_rate":
            GameManager.hot_dog_production.production_rate += value
        "production_capacity":
            GameManager.hot_dog_production.max_production_capacity += int(value)
        "sales_rate":
            GameManager.sales_system.sales_rate += value
        "marketing":
            GameManager.sales_system.marketing_multiplier += value
```

#### Step 2: Create Upgrade Effect Display
```gdscript
# Add to scenes/ui/upgrade_button.gd
@onready var effect_label = $EffectLabel

func _update_display():
    # Existing display code...
    
    var current_level = GameManager.upgrade_system.upgrade_levels[upgrade_data.upgrade_id]
    var current_effect = upgrade_data.get_effect_at_level(current_level)
    var next_effect = upgrade_data.get_effect_at_level(current_level + 1)
    
    match upgrade_data.effect_type:
        "multiplier":
            effect_label.text = "Effect: %.1fx → %.1fx" % [current_effect, next_effect]
        "additive":
            effect_label.text = "Effect: +%.1f → +%.1f" % [current_effect, next_effect]
        "percentage":
            effect_label.text = "Effect: %.1f%% → %.1f%%" % [current_effect * 100, next_effect * 100]
```

### Session 6: Upgrade Balance and Progression (2-3 hours)

#### Step 1: Create Balance Configuration
```gdscript
# resources/upgrade_balance.gd
class_name UpgradeBalance
extends Resource

@export var base_upgrade_cost: float = 10.0
@export var cost_multiplier: float = 1.5
@export var max_upgrade_level: int = 50
@export var effect_scaling: float = 1.2
@export var unlock_intervals: Array[int] = [1, 5, 10, 20, 50, 100]

func calculate_balanced_cost(base_cost: float, level: int) -> float:
    return base_cost * pow(cost_multiplier, level)

func calculate_balanced_effect(base_effect: float, level: int) -> float:
    return base_effect * pow(effect_scaling, level)
```

#### Step 2: Implement Progression Tracking
```gdscript
# Add to scripts/systems/upgrade_system.gd
var total_upgrades_purchased: int = 0
var upgrade_progression: Dictionary = {}

func purchase_upgrade(upgrade_id: String) -> bool:
    if super.purchase_upgrade(upgrade_id):
        total_upgrades_purchased += 1
        upgrade_progression[upgrade_id] = upgrade_levels[upgrade_id]
        _check_progression_milestones()
        return true
    return false

func _check_progression_milestones():
    var milestones = [10, 25, 50, 100, 200]
    for milestone in milestones:
        if total_upgrades_purchased == milestone:
            EventManager.emit_event("upgrade_milestone_reached", milestone)
            _unlock_milestone_rewards(milestone)

func _unlock_milestone_rewards(milestone: int):
    match milestone:
        10:
            # Unlock new upgrade category
            pass
        25:
            # Give bonus money
            GameManager.add_money(1000.0)
        50:
            # Unlock special upgrade
            pass
```

## Day 4: UI Polish and Integration

### Session 7: Upgrade UI Polish (2-3 hours)

#### Step 1: Create Upgrade Animations
```gdscript
# Add to scenes/ui/upgrade_button.gd
func _on_pressed():
    if GameManager.upgrade_system.purchase_upgrade(upgrade_data.upgrade_id):
        _play_purchase_animation()
        _update_display()

func _play_purchase_animation():
    # Create purchase effect animation
    var tween = create_tween()
    tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
    
    # Show purchase notification
    var notification = preload("res://scenes/ui/notification_popup.tscn").instantiate()
    notification.set_message("Upgrade purchased!")
    add_child(notification)
```

#### Step 2: Create Upgrade Statistics Panel
```gdscript
# scenes/ui/upgrade_statistics.gd
extends Control

@onready var total_upgrades_label = $TotalUpgradesLabel
@onready var total_spent_label = $TotalSpentLabel
@onready var category_breakdown = $CategoryBreakdown

func _ready():
    GameManager.upgrade_system.upgrade_purchased.connect(_on_upgrade_purchased)
    _update_statistics()

func _update_statistics():
    var total_upgrades = GameManager.upgrade_system.total_upgrades_purchased
    var total_spent = _calculate_total_spent()
    
    total_upgrades_label.text = "Total Upgrades: %d" % total_upgrades
    total_spent_label.text = "Total Spent: $%.1f" % total_spent
    
    _update_category_breakdown()

func _calculate_total_spent() -> float:
    var total = 0.0
    for upgrade_id in GameManager.upgrade_system.upgrade_levels:
        var level = GameManager.upgrade_system.upgrade_levels[upgrade_id]
        var upgrade_data = GameManager.upgrade_system.upgrades[upgrade_id]
        
        for i in range(level):
            total += upgrade_data.get_cost_at_level(i)
    
    return total
```

### Session 8: Integration and Testing (2-3 hours)

#### Step 1: Integrate with Main Game UI
```gdscript
# Add to main game scene
func _ready():
    var upgrade_panel = preload("res://scenes/ui/upgrade_panel.tscn").instantiate()
    $UI/UpgradePanel.add_child(upgrade_panel)
    
    var upgrade_stats = preload("res://scenes/ui/upgrade_statistics.tscn").instantiate()
    $UI/StatisticsPanel.add_child(upgrade_stats)
```

#### Step 2: Create Comprehensive Tests
```gdscript
# scripts/tests/upgrade_system_test.gd
extends GutTest

func test_upgrade_purchase():
    var upgrade_system = UpgradeSystem.new()
    GameManager.player_money = 1000.0
    
    var result = upgrade_system.purchase_upgrade("production_rate")
    assert_eq(result, true)
    assert_eq(upgrade_system.upgrade_levels["production_rate"], 1)

func test_upgrade_cost_calculation():
    var upgrade_data = UpgradeData.new()
    upgrade_data.base_cost = 10.0
    upgrade_data.cost_multiplier = 1.5
    
    var cost_level_1 = upgrade_data.get_cost_at_level(1)
    assert_eq(cost_level_1, 15.0)

func test_upgrade_prerequisites():
    var upgrade_system = UpgradeSystem.new()
    var upgrade_data = UpgradeData.new()
    upgrade_data.prerequisites = ["production_rate"]
    
    # Should not be available without prerequisite
    var can_purchase = upgrade_system._can_purchase_upgrade("advanced_upgrade")
    assert_eq(can_purchase, false)
```

## Success Criteria Checklist

- [ ] Upgrade system allows purchasing upgrades with money
- [ ] Upgrade effects are properly applied to game systems
- [ ] Prerequisites and unlock conditions work correctly
- [ ] Upgrade categories organize upgrades logically
- [ ] UI displays upgrade information clearly
- [ ] Upgrade progression provides engaging advancement
- [ ] Balance system ensures fair progression
- [ ] All upgrades integrate with save system
- [ ] Performance is optimized for smooth gameplay
- [ ] Comprehensive testing covers all upgrade scenarios

## Risk Mitigation

1. **Balance Issues**: Implement extensive testing and balance configuration
2. **UI Complexity**: Use modular components and clear organization
3. **Performance**: Optimize upgrade calculations and UI updates
4. **Save Data**: Implement efficient upgrade data serialization

## Next Steps

After completing the Upgrade System:
1. Move to Core UI Screens implementation
2. Integrate with Game Balance system for fine-tuning
3. Connect to advanced features like achievements and milestones
4. Implement upgrade presets and quick-purchase features 