# Multiple Locations System - Implementation Plan

## Overview
This document provides a detailed step-by-step implementation plan for the Multiple Locations System, which allows players to expand their hot dog business empire across different venues and markets.

## Implementation Timeline
**Estimated Duration**: 4-5 days
**Sessions**: 8-10 coding sessions of 2-3 hours each

## Day 1: Core Location System Foundation

### Session 1: Location Data Structure (2-3 hours)

#### Step 1: Create Location Resource Class
```bash
# Create location system directory
mkdir -p scripts/systems
touch scripts/systems/location_manager.gd
mkdir -p resources
touch resources/game_location.gd
```

```gdscript
# resources/game_location.gd
class_name GameLocation
extends Resource

@export var location_id: String
@export var location_type: String  # "stand", "restaurant", "food_truck", "franchise"
@export var name: String
@export var position: Vector2
@export var capacity: int = 100
@export var staff_capacity: int = 5
@export var upgrade_level: int = 0
@export var facilities: Array[String] = []
@export var market_demand: float = 1.0
@export var operating_costs: float = 0.0
@export var revenue_multiplier: float = 1.0
@export var customer_satisfaction: float = 1.0
@export var is_open: bool = true
@export var opening_date: Dictionary = {}
@export var total_revenue: float = 0.0
@export var total_customers: int = 0

func _init():
    location_id = _generate_location_id()
    opening_date = Time.get_time_dict_from_system()

func _generate_location_id() -> String:
    return "location_" + str(randi() % 100000)

func calculate_revenue() -> float:
    var base_revenue = GameManager.sales_system.total_revenue
    var location_bonus = revenue_multiplier
    var demand_bonus = market_demand
    var facility_bonus = 1.0
    var satisfaction_bonus = customer_satisfaction
    
    for facility in facilities:
        facility_bonus += 0.1
    
    return base_revenue * location_bonus * demand_bonus * facility_bonus * satisfaction_bonus

func calculate_operating_costs() -> float:
    var base_costs = operating_costs
    var staff_costs = _calculate_staff_costs()
    var facility_costs = _calculate_facility_costs()
    var maintenance_costs = upgrade_level * 10.0
    
    return base_costs + staff_costs + facility_costs + maintenance_costs

func _calculate_staff_costs() -> float:
    var total_cost = 0.0
    var assigned_staff = GameManager.staff_manager._get_staff_at_location(location_id)
    
    for staff_member in assigned_staff:
        total_cost += staff_member.salary
    
    return total_cost

func _calculate_facility_costs() -> float:
    var total_cost = 0.0
    for facility in facilities:
        total_cost += _get_facility_cost(facility)
    return total_cost

func _get_facility_cost(facility_type: String) -> float:
    var facility_costs = {
        "kitchen": 50.0,
        "dining_area": 30.0,
        "drive_thru": 40.0,
        "outdoor_seating": 20.0,
        "delivery_service": 60.0,
        "catering_equipment": 80.0
    }
    return facility_costs.get(facility_type, 25.0)

func upgrade_facility(facility_type: String):
    if not facilities.has(facility_type):
        facilities.append(facility_type)
        _recalculate_bonuses()
        EventManager.emit_event("facility_upgraded", {"location": name, "facility": facility_type})

func _recalculate_bonuses():
    # Recalculate revenue and capacity bonuses based on facilities
    revenue_multiplier = 1.0 + (facilities.size() * 0.1)
    capacity += facilities.size() * 20
```

#### Step 2: Create Location Manager System
```gdscript
# scripts/systems/location_manager.gd
class_name LocationManager
extends Node

signal location_opened(location: GameLocation)
signal location_upgraded(location: GameLocation)
signal location_closed(location: GameLocation)
signal location_revenue_updated(location: GameLocation, revenue: float)

var locations: Dictionary = {}
var current_location: GameLocation
var location_types: Dictionary = {}
var expansion_costs: Dictionary = {}
var total_revenue: float = 0.0
var total_operating_costs: float = 0.0

func _ready():
    print("LocationManager initialized")
    _setup_location_types()
    _setup_expansion_costs()
    _create_initial_location()

func _setup_location_types():
    location_types = {
        "stand": {
            "name": "Hot Dog Stand",
            "base_cost": 1000.0,
            "capacity": 50,
            "staff_capacity": 3,
            "revenue_multiplier": 1.0,
            "operating_costs": 10.0,
            "upgrade_cost": 500.0
        },
        "restaurant": {
            "name": "Hot Dog Restaurant",
            "base_cost": 5000.0,
            "capacity": 200,
            "staff_capacity": 8,
            "revenue_multiplier": 1.5,
            "operating_costs": 50.0,
            "upgrade_cost": 2000.0
        },
        "food_truck": {
            "name": "Food Truck",
            "base_cost": 3000.0,
            "capacity": 100,
            "staff_capacity": 4,
            "revenue_multiplier": 1.2,
            "operating_costs": 25.0,
            "upgrade_cost": 1000.0
        },
        "franchise": {
            "name": "Franchise Location",
            "base_cost": 10000.0,
            "capacity": 500,
            "staff_capacity": 15,
            "revenue_multiplier": 2.0,
            "operating_costs": 100.0,
            "upgrade_cost": 5000.0
        }
    }

func _setup_expansion_costs():
    expansion_costs = {
        "stand_to_restaurant": 4000.0,
        "restaurant_to_franchise": 5000.0,
        "stand_to_food_truck": 2000.0,
        "food_truck_to_restaurant": 2000.0
    }

func _create_initial_location():
    var initial_location = GameLocation.new()
    initial_location.location_type = "stand"
    initial_location.name = "Main Street Stand"
    initial_location.position = Vector2(0, 0)
    
    var type_data = location_types["stand"]
    initial_location.capacity = type_data.capacity
    initial_location.staff_capacity = type_data.staff_capacity
    initial_location.revenue_multiplier = type_data.revenue_multiplier
    initial_location.operating_costs = type_data.operating_costs
    
    locations[initial_location.location_id] = initial_location
    current_location = initial_location
    
    location_opened.emit(initial_location)

func open_location(location_type: String, position: Vector2) -> GameLocation:
    if not location_types.has(location_type):
        print("Error: Unknown location type: %s" % location_type)
        return null
    
    var type_data = location_types[location_type]
    
    if GameManager.player_money < type_data.base_cost:
        print("Error: Not enough money to open location")
        return null
    
    GameManager.player_money -= type_data.base_cost
    
    var new_location = GameLocation.new()
    new_location.location_type = location_type
    new_location.name = _generate_location_name(location_type)
    new_location.position = position
    new_location.capacity = type_data.capacity
    new_location.staff_capacity = type_data.staff_capacity
    new_location.revenue_multiplier = type_data.revenue_multiplier
    new_location.operating_costs = type_data.operating_costs
    
    locations[new_location.location_id] = new_location
    
    location_opened.emit(new_location)
    EventManager.emit_event("location_opened", {"type": location_type, "name": new_location.name})
    
    return new_location

func _generate_location_name(location_type: String) -> String:
    var location_names = {
        "stand": ["Downtown Stand", "Park Corner", "Mall Entrance", "Beach Stand"],
        "restaurant": ["Gourmet Dogs", "Hot Dog Palace", "Frank's Place", "Dog House"],
        "food_truck": ["Mobile Dogs", "Wheels & Wieners", "Truck Dogs", "Street Eats"],
        "franchise": ["Hot Dog Empire", "Dog Dynasty", "Frank's Kingdom", "Wieners World"]
    }
    
    var names = location_names.get(location_type, ["New Location"])
    return names[randi() % names.size()]

func upgrade_location(location: GameLocation, upgrade_type: String):
    if not expansion_costs.has(upgrade_type):
        print("Error: Unknown upgrade type: %s" % upgrade_type)
        return false
    
    var cost = expansion_costs[upgrade_type]
    
    if GameManager.player_money < cost:
        print("Error: Not enough money for upgrade")
        return false
    
    GameManager.player_money -= cost
    
    # Apply upgrade effects
    match upgrade_type:
        "stand_to_restaurant":
            location.location_type = "restaurant"
            _apply_restaurant_upgrade(location)
        "restaurant_to_franchise":
            location.location_type = "franchise"
            _apply_franchise_upgrade(location)
        "stand_to_food_truck":
            location.location_type = "food_truck"
            _apply_food_truck_upgrade(location)
    
    location_upgraded.emit(location)
    EventManager.emit_event("location_upgraded", {"location": location.name, "upgrade": upgrade_type})
    return true

func _apply_restaurant_upgrade(location: GameLocation):
    var type_data = location_types["restaurant"]
    location.capacity = type_data.capacity
    location.staff_capacity = type_data.staff_capacity
    location.revenue_multiplier = type_data.revenue_multiplier
    location.operating_costs = type_data.operating_costs

func _apply_franchise_upgrade(location: GameLocation):
    var type_data = location_types["franchise"]
    location.capacity = type_data.capacity
    location.staff_capacity = type_data.staff_capacity
    location.revenue_multiplier = type_data.revenue_multiplier
    location.operating_costs = type_data.operating_costs

func _apply_food_truck_upgrade(location: GameLocation):
    var type_data = location_types["food_truck"]
    location.capacity = type_data.capacity
    location.staff_capacity = type_data.staff_capacity
    location.revenue_multiplier = type_data.revenue_multiplier
    location.operating_costs = type_data.operating_costs
```

#### Step 3: Integrate with Game Manager
```gdscript
# Add to scripts/autoload/game_manager.gd
var location_manager: LocationManager

func _ready():
    location_manager = LocationManager.new()
    add_child(location_manager)
    
    location_manager.location_opened.connect(_on_location_opened)
    location_manager.location_upgraded.connect(_on_location_upgraded)
    location_manager.location_revenue_updated.connect(_on_location_revenue_updated)
```

### Session 2: Location Management UI (2-3 hours)

#### Step 1: Create Location Management Interface
```bash
# Create location UI scenes
mkdir -p scenes/ui
touch scenes/ui/location_management.tscn
touch scenes/ui/location_management.gd
touch scenes/ui/location_map.tscn
touch scenes/ui/location_map.gd
```

```gdscript
# scenes/ui/location_management.gd
extends Control

@onready var location_map = $LocationMap
@onready var location_details = $LocationDetails
@onready var expansion_panel = $ExpansionPanel
@onready var total_locations_label = $TotalLocationsLabel
@onready var total_revenue_label = $TotalRevenueLabel

func _ready():
    GameManager.location_manager.location_opened.connect(_on_location_opened)
    GameManager.location_manager.location_upgraded.connect(_on_location_upgraded)
    _update_location_map()
    _update_summary()

func _update_location_map():
    location_map.clear_locations()
    
    for location in GameManager.location_manager.locations.values():
        location_map.add_location(location)
        location_map.location_selected.connect(_on_location_selected)

func _on_location_opened(location: GameLocation):
    _update_location_map()
    _update_summary()

func _on_location_upgraded(location: GameLocation):
    _update_location_map()
    _update_summary()

func _on_location_selected(location: GameLocation):
    location_details.show_location_details(location)

func _update_summary():
    var total_locations = GameManager.location_manager.locations.size()
    var total_revenue = GameManager.location_manager.total_revenue
    
    total_locations_label.text = "Total Locations: %d" % total_locations
    total_revenue_label.text = "Total Revenue: $%.1f/hr" % total_revenue
```

#### Step 2: Create Location Map Component
```gdscript
# scenes/ui/location_map.gd
extends Control

@onready var map_container = $MapContainer
@onready var new_location_button = $NewLocationButton

signal location_selected(location: GameLocation)

var location_markers: Dictionary = {}

func _ready():
    new_location_button.pressed.connect(_on_new_location_pressed)

func clear_locations():
    for marker in location_markers.values():
        marker.queue_free()
    location_markers.clear()

func add_location(location: GameLocation):
    var location_marker = preload("res://scenes/ui/location_marker.tscn").instantiate()
    location_marker.setup(location)
    location_marker.location_clicked.connect(_on_location_clicked)
    map_container.add_child(location_marker)
    location_markers[location.location_id] = location_marker

func _on_location_clicked(location: GameLocation):
    location_selected.emit(location)

func _on_new_location_pressed():
    var expansion_dialog = preload("res://scenes/ui/location_expansion_dialog.tscn").instantiate()
    expansion_dialog.expansion_requested.connect(_on_expansion_requested)
    add_child(expansion_dialog)

func _on_expansion_requested(location_type: String, position: Vector2):
    var new_location = GameManager.location_manager.open_location(location_type, position)
    if new_location:
        add_location(new_location)
```

## Day 2: Location Economics and Operations

### Session 3: Location Revenue and Cost Systems (2-3 hours)

#### Step 1: Implement Location Economics
```gdscript
# Add to scripts/systems/location_manager.gd
func _process(delta: float):
    _update_location_revenues(delta)

func _update_location_revenues(delta: float):
    total_revenue = 0.0
    total_operating_costs = 0.0
    
    for location in locations.values():
        if location.is_open:
            var revenue = location.calculate_revenue() * delta
            var costs = location.calculate_operating_costs() * delta
            
            location.total_revenue += revenue
            total_revenue += revenue
            total_operating_costs += costs
            
            location_revenue_updated.emit(location, revenue)

func get_location_statistics() -> Dictionary:
    var stats = {
        "total_locations": locations.size(),
        "total_revenue": total_revenue,
        "total_operating_costs": total_operating_costs,
        "net_profit": total_revenue - total_operating_costs,
        "locations_by_type": {},
        "average_revenue_per_location": 0.0,
        "most_profitable_location": null,
        "least_profitable_location": null
    }
    
    if locations.size() > 0:
        stats.average_revenue_per_location = total_revenue / locations.size()
        
        var max_revenue = 0.0
        var min_revenue = INF
        
        for location in locations.values():
            # Count by type
            if not stats.locations_by_type.has(location.location_type):
                stats.locations_by_type[location.location_type] = 0
            stats.locations_by_type[location.location_type] += 1
            
            # Find most/least profitable
            var location_revenue = location.calculate_revenue()
            if location_revenue > max_revenue:
                max_revenue = location_revenue
                stats.most_profitable_location = location
            
            if location_revenue < min_revenue:
                min_revenue = location_revenue
                stats.least_profitable_location = location
    
    return stats

func transfer_resources(from_location: GameLocation, to_location: GameLocation, resource_type: String, amount: float):
    match resource_type:
        "money":
            # Transfer money between locations
            pass
        "staff":
            # Transfer staff between locations
            pass
        "inventory":
            # Transfer inventory between locations
            pass
        "customers":
            # Transfer customer demand between locations
            pass
```

#### Step 2: Create Location Analytics UI
```gdscript
# scenes/ui/location_analytics.gd
extends Control

@onready var total_revenue_label = $TotalRevenueLabel
@onready var total_costs_label = $TotalCostsLabel
@onready var net_profit_label = $NetProfitLabel
@onready var average_revenue_label = $AverageRevenueLabel
@onready var location_type_chart = $LocationTypeChart
@onready var revenue_chart = $RevenueChart

func _ready():
    # Update analytics every 5 seconds
    var timer = Timer.new()
    timer.wait_time = 5.0
    timer.timeout.connect(_update_analytics)
    add_child(timer)
    timer.start()
    
    _update_analytics()

func _update_analytics():
    var stats = GameManager.location_manager.get_location_statistics()
    
    total_revenue_label.text = "Total Revenue: $%.1f/hr" % stats.total_revenue
    total_costs_label.text = "Total Costs: $%.1f/hr" % stats.total_operating_costs
    net_profit_label.text = "Net Profit: $%.1f/hr" % stats.net_profit
    average_revenue_label.text = "Avg Revenue: $%.1f/hr" % stats.average_revenue_per_location
    
    _update_location_type_chart(stats.locations_by_type)
    _update_revenue_chart()

func _update_location_type_chart(locations_by_type: Dictionary):
    location_type_chart.clear()
    for location_type in locations_by_type:
        location_type_chart.add_slice(locations_by_type[location_type], location_type)

func _update_revenue_chart():
    # Update revenue trend chart
    revenue_chart.clear()
    var locations = GameManager.location_manager.locations.values()
    for location in locations:
        revenue_chart.add_data_point(location.name, location.calculate_revenue())
```

### Session 4: Location Staff and Operations (2-3 hours)

#### Step 1: Implement Location Staff Management
```gdscript
# Add to scripts/systems/location_manager.gd
func assign_staff_to_location(staff_member: StaffMember, location_id: String):
    var location = locations.get(location_id)
    if not location:
        print("Error: Location not found: %s" % location_id)
        return false
    
    var current_staff_count = _get_staff_at_location(location_id).size()
    if current_staff_count >= location.staff_capacity:
        print("Error: Location at maximum staff capacity")
        return false
    
    staff_member.assigned_location = location_id
    EventManager.emit_event("staff_assigned_to_location", {"staff": staff_member.name, "location": location.name})
    return true

func _get_staff_at_location(location_id: String) -> Array[StaffMember]:
    var location_staff: Array[StaffMember] = []
    for staff_member in GameManager.staff_manager.staff_members:
        if staff_member.assigned_location == location_id:
            location_staff.append(staff_member)
    return location_staff

func get_location_performance(location: GameLocation) -> Dictionary:
    var staff_at_location = _get_staff_at_location(location.location_id)
    var total_productivity = 0.0
    var total_happiness = 0.0
    
    for staff_member in staff_at_location:
        total_productivity += staff_member.productivity
        total_happiness += staff_member.happiness
    
    var avg_productivity = total_productivity / staff_at_location.size() if staff_at_location.size() > 0 else 0.0
    var avg_happiness = total_happiness / staff_at_location.size() if staff_at_location.size() > 0 else 0.0
    
    return {
        "staff_count": staff_at_location.size(),
        "staff_capacity": location.staff_capacity,
        "average_productivity": avg_productivity,
        "average_happiness": avg_happiness,
        "utilization_rate": staff_at_location.size() / location.staff_capacity if location.staff_capacity > 0 else 0.0
    }
```

#### Step 2: Create Location Staff Management UI
```gdscript
# scenes/ui/location_staff_management.gd
extends Control

@onready var staff_list = $StaffList
@onready var available_staff_list = $AvailableStaffList
@onready var performance_panel = $PerformancePanel

var selected_location: GameLocation

func setup(location: GameLocation):
    selected_location = location
    _populate_staff_lists()
    _update_performance_panel()

func _populate_staff_lists():
    # Clear existing lists
    for child in staff_list.get_children():
        child.queue_free()
    for child in available_staff_list.get_children():
        child.queue_free()
    
    # Add assigned staff
    var assigned_staff = GameManager.location_manager._get_staff_at_location(selected_location.location_id)
    for staff_member in assigned_staff:
        var staff_item = preload("res://scenes/ui/location_staff_item.tscn").instantiate()
        staff_item.setup(staff_member, true)  # true = assigned
        staff_item.staff_removed.connect(_on_staff_removed)
        staff_list.add_child(staff_item)
    
    # Add available staff
    for staff_member in GameManager.staff_manager.staff_members:
        if staff_member.assigned_location == "" or staff_member.assigned_location != selected_location.location_id:
            var staff_item = preload("res://scenes/ui/location_staff_item.tscn").instantiate()
            staff_item.setup(staff_member, false)  # false = available
            staff_item.staff_assigned.connect(_on_staff_assigned)
            available_staff_list.add_child(staff_item)

func _on_staff_assigned(staff_member: StaffMember):
    GameManager.location_manager.assign_staff_to_location(staff_member, selected_location.location_id)
    _populate_staff_lists()
    _update_performance_panel()

func _on_staff_removed(staff_member: StaffMember):
    staff_member.assigned_location = ""
    _populate_staff_lists()
    _update_performance_panel()

func _update_performance_panel():
    var performance = GameManager.location_manager.get_location_performance(selected_location)
    
    # Update performance displays
    var utilization_label = $PerformancePanel/UtilizationLabel
    var productivity_label = $PerformancePanel/ProductivityLabel
    var happiness_label = $PerformancePanel/HappinessLabel
    
    utilization_label.text = "Utilization: %.1f%%" % (performance.utilization_rate * 100)
    productivity_label.text = "Avg Productivity: %.2f" % performance.average_productivity
    happiness_label.text = "Avg Happiness: %.2f" % performance.average_happiness
```

## Day 3: Location Expansion and Growth

### Session 5: Location Upgrade and Expansion (2-3 hours)

#### Step 1: Implement Location Upgrade System
```gdscript
# Add to scripts/systems/location_manager.gd
var available_upgrades: Dictionary = {}

func _ready():
    _setup_available_upgrades()

func _setup_available_upgrades():
    available_upgrades = {
        "capacity_expansion": {
            "name": "Capacity Expansion",
            "cost": 1000.0,
            "effect": {"capacity": 50},
            "prerequisites": []
        },
        "staff_expansion": {
            "name": "Staff Expansion",
            "cost": 800.0,
            "effect": {"staff_capacity": 2},
            "prerequisites": []
        },
        "kitchen_upgrade": {
            "name": "Kitchen Upgrade",
            "cost": 1500.0,
            "effect": {"revenue_multiplier": 0.2},
            "prerequisites": []
        },
        "dining_area": {
            "name": "Dining Area",
            "cost": 1200.0,
            "effect": {"capacity": 30, "customer_satisfaction": 0.1},
            "prerequisites": []
        },
        "drive_thru": {
            "name": "Drive-Thru Service",
            "cost": 2000.0,
            "effect": {"revenue_multiplier": 0.3, "operating_costs": 20.0},
            "prerequisites": []
        }
    }

func upgrade_location_facility(location: GameLocation, upgrade_type: String):
    if not available_upgrades.has(upgrade_type):
        print("Error: Unknown upgrade type: %s" % upgrade_type)
        return false
    
    var upgrade_data = available_upgrades[upgrade_type]
    
    if GameManager.player_money < upgrade_data.cost:
        print("Error: Not enough money for upgrade")
        return false
    
    # Check prerequisites
    for prereq in upgrade_data.prerequisites:
        if not _has_prerequisite(location, prereq):
            print("Error: Prerequisite not met: %s" % prereq)
            return false
    
    GameManager.player_money -= upgrade_data.cost
    
    # Apply upgrade effects
    for effect_type in upgrade_data.effect:
        match effect_type:
            "capacity":
                location.capacity += upgrade_data.effect[effect_type]
            "staff_capacity":
                location.staff_capacity += upgrade_data.effect[effect_type]
            "revenue_multiplier":
                location.revenue_multiplier += upgrade_data.effect[effect_type]
            "customer_satisfaction":
                location.customer_satisfaction += upgrade_data.effect[effect_type]
            "operating_costs":
                location.operating_costs += upgrade_data.effect[effect_type]
    
    location.upgrade_level += 1
    location_upgraded.emit(location)
    EventManager.emit_event("location_facility_upgraded", {"location": location.name, "upgrade": upgrade_type})
    
    return true

func _has_prerequisite(location: GameLocation, prereq: String) -> bool:
    # Check if location has the required prerequisite
    match prereq:
        "restaurant_type":
            return location.location_type == "restaurant" or location.location_type == "franchise"
        "kitchen_upgrade":
            return location.facilities.has("kitchen")
        _:
            return true
```

#### Step 2: Create Location Upgrade UI
```gdscript
# scenes/ui/location_upgrade_panel.gd
extends Control

@onready var upgrade_list = $UpgradeList
@onready var upgrade_button = $UpgradeButton

var selected_location: GameLocation
var selected_upgrade: String = ""

func setup(location: GameLocation):
    selected_location = location
    _populate_upgrade_list()

func _populate_upgrade_list():
    # Clear existing upgrades
    for child in upgrade_list.get_children():
        child.queue_free()
    
    # Add available upgrades
    for upgrade_type in GameManager.location_manager.available_upgrades:
        var upgrade_data = GameManager.location_manager.available_upgrades[upgrade_type]
        var upgrade_item = preload("res://scenes/ui/location_upgrade_item.tscn").instantiate()
        upgrade_item.setup(upgrade_type, upgrade_data)
        upgrade_item.upgrade_selected.connect(_on_upgrade_selected)
        upgrade_list.add_child(upgrade_item)

func _on_upgrade_selected(upgrade_type: String):
    selected_upgrade = upgrade_type
    upgrade_button.disabled = false

func _on_upgrade_button_pressed():
    if selected_location and selected_upgrade != "":
        var success = GameManager.location_manager.upgrade_location_facility(selected_location, selected_upgrade)
        if success:
            hide()
            EventManager.emit_event("location_upgrade_completed", {"location": selected_location.name, "upgrade": selected_upgrade})
```

### Session 6: Location Market and Competition (2-3 hours)

#### Step 1: Implement Market Dynamics
```gdscript
# Add to scripts/systems/location_manager.gd
var market_conditions: Dictionary = {}
var competition_levels: Dictionary = {}

func _ready():
    _setup_market_conditions()
    _setup_competition_system()

func _setup_market_conditions():
    market_conditions = {
        "downtown": {"demand": 1.5, "competition": 0.8, "cost_multiplier": 1.2},
        "suburban": {"demand": 1.0, "competition": 0.5, "cost_multiplier": 1.0},
        "mall": {"demand": 1.3, "competition": 0.7, "cost_multiplier": 1.1},
        "beach": {"demand": 1.8, "competition": 0.9, "cost_multiplier": 1.3},
        "airport": {"demand": 2.0, "competition": 1.0, "cost_multiplier": 1.5}
    }

func _setup_competition_system():
    competition_levels = {
        "low": {"price_competition": 0.1, "demand_reduction": 0.05},
        "medium": {"price_competition": 0.2, "demand_reduction": 0.1},
        "high": {"price_competition": 0.3, "demand_reduction": 0.2}
    }

func calculate_market_demand(location: GameLocation) -> float:
    var base_demand = 1.0
    var market_bonus = _get_market_bonus(location)
    var competition_penalty = _get_competition_penalty(location)
    var seasonal_bonus = _get_seasonal_bonus()
    
    return base_demand * market_bonus * (1.0 - competition_penalty) * seasonal_bonus

func _get_market_bonus(location: GameLocation) -> float:
    # Determine market type based on location position or type
    var market_type = _determine_market_type(location)
    return market_conditions.get(market_type, {"demand": 1.0}).demand

func _get_competition_penalty(location: GameLocation) -> float:
    var competition_level = _determine_competition_level(location)
    return competition_levels.get(competition_level, {"demand_reduction": 0.0}).demand_reduction

func _get_seasonal_bonus() -> float:
    var current_time = Time.get_time_dict_from_system()
    var month = current_time["month"]
    
    # Seasonal demand variations
    match month:
        6, 7, 8:  # Summer
            return 1.3
        12, 1, 2:  # Winter
            return 0.8
        _:  # Spring/Fall
            return 1.0

func _determine_market_type(location: GameLocation) -> String:
    # Simple market type determination based on location type
    match location.location_type:
        "stand":
            return "downtown"
        "restaurant":
            return "suburban"
        "food_truck":
            return "mall"
        "franchise":
            return "airport"
        _:
            return "suburban"

func _determine_competition_level(location: GameLocation) -> String:
    # Determine competition level based on location and market
    var market_type = _determine_market_type(location)
    var base_competition = market_conditions.get(market_type, {"competition": 0.5}).competition
    
    if base_competition > 0.8:
        return "high"
    elif base_competition > 0.5:
        return "medium"
    else:
        return "low"
```

#### Step 2: Create Market Analysis UI
```gdscript
# scenes/ui/location_market_analysis.gd
extends Control

@onready var market_demand_label = $MarketDemandLabel
@onready var competition_level_label = $CompetitionLevelLabel
@onready var seasonal_bonus_label = $SeasonalBonusLabel
@onready var market_type_label = $MarketTypeLabel

var selected_location: GameLocation

func setup(location: GameLocation):
    selected_location = location
    _update_market_analysis()

func _update_market_analysis():
    var market_demand = GameManager.location_manager.calculate_market_demand(selected_location)
    var market_type = GameManager.location_manager._determine_market_type(selected_location)
    var competition_level = GameManager.location_manager._determine_competition_level(selected_location)
    var seasonal_bonus = GameManager.location_manager._get_seasonal_bonus()
    
    market_demand_label.text = "Market Demand: %.1fx" % market_demand
    competition_level_label.text = "Competition: %s" % competition_level.capitalize()
    seasonal_bonus_label.text = "Seasonal Bonus: %.1fx" % seasonal_bonus
    market_type_label.text = "Market Type: %s" % market_type.capitalize()
```

## Day 4: Advanced Features and Integration

### Session 7: Location Transfer and Resource Management (2-3 hours)

#### Step 1: Implement Resource Transfer System
```gdscript
# Add to scripts/systems/location_manager.gd
func transfer_resources_between_locations(from_location: GameLocation, to_location: GameLocation, resource_type: String, amount: float):
    match resource_type:
        "staff":
            _transfer_staff(from_location, to_location, int(amount))
        "money":
            _transfer_money(from_location, to_location, amount)
        "customers":
            _transfer_customer_demand(from_location, to_location, amount)
        "inventory":
            _transfer_inventory(from_location, to_location, amount)

func _transfer_staff(from_location: GameLocation, to_location: GameLocation, staff_count: int):
    var staff_at_from = _get_staff_at_location(from_location.location_id)
    var available_slots = to_location.staff_capacity - _get_staff_at_location(to_location.location_id).size()
    
    var transfer_count = min(staff_count, staff_at_from.size(), available_slots)
    
    for i in range(transfer_count):
        var staff_member = staff_at_from[i]
        assign_staff_to_location(staff_member, to_location.location_id)
    
    EventManager.emit_event("staff_transferred", {"from": from_location.name, "to": to_location.name, "count": transfer_count})

func _transfer_money(from_location: GameLocation, to_location: GameLocation, amount: float):
    # Transfer money between locations (affects their individual revenue)
    from_location.total_revenue -= amount
    to_location.total_revenue += amount
    
    EventManager.emit_event("money_transferred", {"from": from_location.name, "to": to_location.name, "amount": amount})

func _transfer_customer_demand(from_location: GameLocation, to_location: GameLocation, amount: float):
    # Transfer customer demand between locations
    from_location.market_demand -= amount
    to_location.market_demand += amount
    
    EventManager.emit_event("demand_transferred", {"from": from_location.name, "to": to_location.name, "amount": amount})
```

#### Step 2: Create Resource Transfer UI
```gdscript
# scenes/ui/location_transfer_panel.gd
extends Control

@onready var from_location_dropdown = $FromLocationDropdown
@onready var to_location_dropdown = $ToLocationDropdown
@onready var resource_type_dropdown = $ResourceTypeDropdown
@onready var amount_slider = $AmountSlider
@onready var transfer_button = $TransferButton

var from_location: GameLocation
var to_location: GameLocation

func _ready():
    _populate_location_dropdowns()
    _populate_resource_types()
    
    from_location_dropdown.item_selected.connect(_on_from_location_selected)
    to_location_dropdown.item_selected.connect(_on_to_location_selected)
    transfer_button.pressed.connect(_on_transfer_pressed)

func _populate_location_dropdowns():
    from_location_dropdown.clear()
    to_location_dropdown.clear()
    
    for location in GameManager.location_manager.locations.values():
        from_location_dropdown.add_item(location.name)
        to_location_dropdown.add_item(location.name)

func _populate_resource_types():
    resource_type_dropdown.clear()
    resource_type_dropdown.add_item("Staff")
    resource_type_dropdown.add_item("Money")
    resource_type_dropdown.add_item("Customer Demand")

func _on_from_location_selected(index: int):
    var location_name = from_location_dropdown.get_item_text(index)
    from_location = _get_location_by_name(location_name)

func _on_to_location_selected(index: int):
    var location_name = to_location_dropdown.get_item_text(index)
    to_location = _get_location_by_name(location_name)

func _on_transfer_pressed():
    if from_location and to_location:
        var resource_type = resource_type_dropdown.get_item_text(resource_type_dropdown.selected)
        var amount = amount_slider.value
        
        GameManager.location_manager.transfer_resources_between_locations(
            from_location, to_location, resource_type.to_lower(), amount
        )
        
        hide()

func _get_location_by_name(name: String) -> GameLocation:
    for location in GameManager.location_manager.locations.values():
        if location.name == name:
            return location
    return null
```

### Session 8: Final Integration and Testing (2-3 hours)

#### Step 1: Integrate with Other Systems
```gdscript
# Add to scripts/autoload/game_manager.gd
func _connect_location_signals():
    location_manager.location_opened.connect(_on_location_opened)
    location_manager.location_upgraded.connect(_on_location_upgraded)
    location_manager.location_revenue_updated.connect(_on_location_revenue_updated)

func _on_location_opened(location: GameLocation):
    # Apply location bonuses to overall game systems
    _apply_location_bonuses()

func _on_location_upgraded(location: GameLocation):
    # Recalculate location bonuses
    _apply_location_bonuses()

func _on_location_revenue_updated(location: GameLocation, revenue: float):
    # Update overall game revenue
    add_money(revenue)

func _apply_location_bonuses():
    var total_revenue_multiplier = 1.0
    var total_capacity_bonus = 0
    
    for location in location_manager.locations.values():
        if location.is_open:
            total_revenue_multiplier += (location.revenue_multiplier - 1.0)
            total_capacity_bonus += location.capacity
    
    # Apply bonuses to game systems
    sales_system.revenue_multiplier = total_revenue_multiplier
    hot_dog_production.max_production_capacity += total_capacity_bonus
```

#### Step 2: Create Comprehensive Tests
```gdscript
# scripts/tests/location_system_test.gd
extends GutTest

func test_location_creation():
    var location_manager = LocationManager.new()
    add_child_autofree(location_manager)
    
    var new_location = location_manager.open_location("restaurant", Vector2(100, 100))
    assert_not_null(new_location)
    assert_eq(new_location.location_type, "restaurant")
    assert_eq(location_manager.locations.size(), 2)  # Including initial location

func test_location_upgrade():
    var location_manager = LocationManager.new()
    add_child_autofree(location_manager)
    
    var location = location_manager.locations.values()[0]
    var initial_capacity = location.capacity
    
    location_manager.upgrade_location_facility(location, "capacity_expansion")
    assert_gt(location.capacity, initial_capacity)

func test_location_revenue_calculation():
    var location_manager = LocationManager.new()
    add_child_autofree(location_manager)
    
    var location = location_manager.locations.values()[0]
    var revenue = location.calculate_revenue()
    
    assert_gte(revenue, 0.0)
```

## Success Criteria Checklist

- [ ] Location opening and management mechanics work correctly
- [ ] Location upgrade and expansion systems function properly
- [ ] Location revenue and cost calculations are accurate
- [ ] Location staff assignment and management works
- [ ] Location market dynamics provide strategic depth
- [ ] Location transfer and resource management functions
- [ ] Location UI is intuitive and functional
- [ ] Location system integrates with other game systems
- [ ] Location analytics provide meaningful insights
- [ ] Location balance provides engaging progression

## Risk Mitigation

1. **System Complexity**: Implement modular design with clear interfaces
2. **Performance Issues**: Use efficient algorithms and batch updates
3. **Balance Problems**: Extensive testing and balance configuration
4. **UI Complexity**: Create intuitive, hierarchical interface design

## Next Steps

After completing the Multiple Locations System:
1. Move to Advanced Upgrades and Research implementation
2. Integrate with Events System for location-related events
3. Connect to achievement system for location milestones
4. Implement location-specific achievements and progression 