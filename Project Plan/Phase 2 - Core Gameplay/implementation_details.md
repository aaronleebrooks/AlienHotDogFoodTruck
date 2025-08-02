# Phase 2 Implementation Details

## Technical Architecture

### Core Gameplay Systems

#### Hot Dog Production System
```gdscript
class_name HotDogProduction
extends Node

var production_rate: float = 1.0  # hot dogs per second
var production_efficiency: float = 1.0
var max_production_capacity: int = 100
var current_production: int = 0

func _process(delta: float):
    var production_amount = production_rate * production_efficiency * delta
    current_production += production_amount
    
    if current_production >= max_production_capacity:
        current_production = max_production_capacity
        # Stop production or trigger overflow handling

func upgrade_production_rate(upgrade_amount: float):
    production_rate += upgrade_amount
    EventManager.emit_event("production_upgraded", production_rate)
```

#### Sales System
```gdscript
class_name SalesSystem
extends Node

var hot_dog_price: float = 2.0
var customer_demand: float = 1.0
var sales_rate: float = 0.5  # hot dogs per second
var customer_satisfaction: float = 1.0

func _process(delta: float):
    if current_production > 0:
        var sales_amount = min(sales_rate * customer_demand * delta, current_production)
        current_production -= sales_amount
        var revenue = sales_amount * hot_dog_price * customer_satisfaction
        GameManager.add_money(revenue)
        EventManager.emit_event("hot_dog_sold", sales_amount)
```

#### Upgrade System
```gdscript
class_name UpgradeSystem
extends Node

var available_upgrades: Array[Upgrade] = []
var purchased_upgrades: Array[String] = []

func purchase_upgrade(upgrade_id: String) -> bool:
    var upgrade = get_upgrade_by_id(upgrade_id)
    if upgrade and GameManager.spend_money(upgrade.cost):
        apply_upgrade(upgrade)
        purchased_upgrades.append(upgrade_id)
        EventManager.emit_event("upgrade_purchased", upgrade_id)
        return true
    return false

func apply_upgrade(upgrade: Upgrade):
    match upgrade.type:
        "production_rate":
            HotDogProduction.upgrade_production_rate(upgrade.value)
        "production_capacity":
            HotDogProduction.max_production_capacity += upgrade.value
        "sales_rate":
            SalesSystem.sales_rate += upgrade.value
        "price":
            SalesSystem.hot_dog_price += upgrade.value
```

### UI Architecture

#### Main Game Screen
```gdscript
# scenes/ui/main_game_screen.tscn + .gd
extends Control

@onready var production_display = $ProductionDisplay
@onready var sales_display = $SalesDisplay
@onready var money_display = $MoneyDisplay
@onready var upgrade_panel = $UpgradePanel

func _ready():
    setup_ui_connections()
    update_displays()

func setup_ui_connections():
    EventManager.connect("money_changed", update_money_display)
    EventManager.connect("production_upgraded", update_production_display)
    EventManager.connect("hot_dog_sold", update_sales_display)

func update_displays():
    update_money_display(GameManager.player_money)
    update_production_display(HotDogProduction.production_rate)
    update_sales_display(SalesSystem.sales_rate)
```

#### Upgrade Panel
```gdscript
# scenes/ui/upgrade_panel.tscn + .gd
extends Panel

var upgrade_buttons: Array[Button] = []

func _ready():
    create_upgrade_buttons()
    update_upgrade_availability()

func create_upgrade_buttons():
    for upgrade in UpgradeSystem.available_upgrades:
        var button = create_upgrade_button(upgrade)
        upgrade_buttons.append(button)
        add_child(button)

func create_upgrade_button(upgrade: Upgrade) -> Button:
    var button = Button.new()
    button.text = upgrade.name + " - $" + str(upgrade.cost)
    button.pressed.connect(func(): purchase_upgrade(upgrade.id))
    return button
```

### Data Structures

#### Upgrade Data
```gdscript
class_name Upgrade
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export var cost: float
@export var type: String  # "production_rate", "capacity", "sales", "price"
@export var value: float
@export var max_level: int = -1  # -1 for unlimited
@export var current_level: int = 0
@export var icon: Texture2D
```

#### Game Balance Data
```gdscript
class_name GameBalance
extends Resource

@export var base_production_rate: float = 1.0
@export var base_sales_rate: float = 0.5
@export var base_hot_dog_price: float = 2.0
@export var base_production_capacity: int = 100
@export var upgrade_cost_multiplier: float = 1.5
@export var production_rate_upgrade_value: float = 0.5
@export var capacity_upgrade_value: int = 50
@export var sales_rate_upgrade_value: float = 0.2
@export var price_upgrade_value: float = 0.5
```

### Game Balance Formulas

#### Production Rate Upgrade Cost
```gdscript
func calculate_production_upgrade_cost(current_level: int) -> float:
    return base_cost * pow(upgrade_cost_multiplier, current_level)
```

#### Sales Rate Upgrade Cost
```gdscript
func calculate_sales_upgrade_cost(current_level: int) -> float:
    return base_cost * pow(upgrade_cost_multiplier, current_level)
```

#### Price Upgrade Cost
```gdscript
func calculate_price_upgrade_cost(current_level: int) -> float:
    return base_cost * pow(upgrade_cost_multiplier, current_level)
```

### Event System Integration

#### Game Events
```gdscript
# Events emitted by core systems
"money_changed" -> (new_amount: float)
"production_upgraded" -> (new_rate: float)
"hot_dog_sold" -> (amount: float)
"upgrade_purchased" -> (upgrade_id: String)
"production_capacity_reached" -> ()
"customer_satisfaction_changed" -> (new_satisfaction: float)
```

#### UI Events
```gdscript
# Events for UI updates
"ui_update_required" -> ()
"upgrade_availability_changed" -> (upgrade_id: String, available: bool)
"notification_show" -> (message: String, type: String)
"achievement_unlocked" -> (achievement_id: String)
```

### Performance Considerations

#### Update Optimization
- Batch UI updates to reduce frame rate impact
- Use object pooling for frequently created/destroyed UI elements
- Implement efficient event handling and filtering
- Cache frequently accessed data

#### Memory Management
- Efficient data structures for upgrade tracking
- Proper resource cleanup for UI elements
- Memory monitoring for long play sessions
- Optimize save data size

### Testing Strategy

#### Unit Testing
- Test all production calculations
- Verify upgrade system logic
- Test sales and economy calculations
- Validate data integrity

#### Integration Testing
- Test system interactions
- Verify event propagation
- Test UI responsiveness
- Validate save/load functionality

#### Balance Testing
- Automated balance validation
- Progression curve testing
- Economy stability testing
- Performance under load testing

### UI/UX Design

#### Visual Design
- Clean, modern interface design
- Consistent color scheme and typography
- Clear visual hierarchy
- Responsive layout for different screen sizes

#### User Experience
- Intuitive navigation and controls
- Clear feedback for all actions
- Helpful tooltips and explanations
- Smooth animations and transitions

#### Accessibility
- High contrast mode support
- Screen reader compatibility
- Keyboard navigation support
- Scalable text and UI elements 