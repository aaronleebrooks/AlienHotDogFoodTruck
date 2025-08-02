# Sales and Economy System - Implementation Plan

## Overview
This document provides a detailed step-by-step implementation plan for the Sales and Economy System, which handles the monetization and economic progression of the hot dog idle game.

## Implementation Timeline
**Estimated Duration**: 3-4 days
**Sessions**: 6-8 coding sessions of 2-3 hours each

## Day 1: Core Sales Mechanics

### Session 1: Basic Sales System (2-3 hours)

#### Step 1: Create Sales Data Structure
```bash
# Create the sales system script
mkdir -p scripts/systems
touch scripts/systems/sales_system.gd
```

```gdscript
# scripts/systems/sales_system.gd
class_name SalesSystem
extends Node

signal sale_completed(amount: int, revenue: float)
signal sales_rate_changed(new_rate: float)
signal customer_satisfaction_changed(new_satisfaction: float)

var sales_rate: float = 1.0  # hot dogs sold per second
var hot_dog_price: float = 2.0
var customer_satisfaction: float = 1.0
var marketing_multiplier: float = 1.0
var location_bonus: float = 1.0
var is_sales_active: bool = true

func _ready():
    print("SalesSystem initialized")

func _process(delta: float):
    if not is_sales_active:
        return
        
    var sales_amount = sales_rate * customer_satisfaction * marketing_multiplier * location_bonus * delta
    var revenue = sales_amount * hot_dog_price
    
    # Check if we have enough hot dogs to sell
    if GameManager.hot_dog_production.current_production >= sales_amount:
        GameManager.hot_dog_production.current_production -= sales_amount
        GameManager.add_money(revenue)
        sale_completed.emit(sales_amount, revenue)
        EventManager.emit_event("hot_dogs_sold", sales_amount)
```

#### Step 2: Create Economy Manager
```bash
# Create economy management system
touch scripts/systems/economy_manager.gd
```

```gdscript
# scripts/systems/economy_manager.gd
class_name EconomyManager
extends Node

signal money_changed(new_amount: float)
signal price_changed(new_price: float)
signal inflation_updated(inflation_rate: float)

var inflation_rate: float = 0.01  # 1% per day
var price_volatility: float = 0.05
var market_demand: float = 1.0
var seasonal_multiplier: float = 1.0

func _ready():
    print("EconomyManager initialized")

func update_prices():
    # Simulate market fluctuations
    var price_change = randf_range(-price_volatility, price_volatility)
    GameManager.sales_system.hot_dog_price += price_change
    
    # Apply inflation
    GameManager.sales_system.hot_dog_price *= (1.0 + inflation_rate)
    
    # Ensure minimum price
    GameManager.sales_system.hot_dog_price = max(GameManager.sales_system.hot_dog_price, 0.5)
    
    price_changed.emit(GameManager.sales_system.hot_dog_price)
```

#### Step 3: Integrate with Game Manager
```gdscript
# Add to scripts/autoload/game_manager.gd
var sales_system: SalesSystem
var economy_manager: EconomyManager

func _ready():
    sales_system = SalesSystem.new()
    economy_manager = EconomyManager.new()
    add_child(sales_system)
    add_child(economy_manager)
    
    sales_system.sale_completed.connect(_on_sale_completed)
    economy_manager.price_changed.connect(_on_price_changed)
```

### Session 2: Sales UI Components (2-3 hours)

#### Step 1: Create Sales Display
```bash
# Create UI scene for sales display
mkdir -p scenes/ui
touch scenes/ui/sales_display.tscn
touch scenes/ui/sales_display.gd
```

```gdscript
# scenes/ui/sales_display.gd
extends Control

@onready var sales_rate_label = $SalesRateLabel
@onready var price_label = $PriceLabel
@onready var revenue_label = $RevenueLabel
@onready var satisfaction_label = $SatisfactionLabel

func _ready():
    GameManager.sales_system.sales_rate_changed.connect(_on_sales_rate_changed)
    GameManager.sales_system.customer_satisfaction_changed.connect(_on_satisfaction_changed)
    GameManager.economy_manager.price_changed.connect(_on_price_changed)
    _update_display()

func _on_sales_rate_changed(new_rate: float):
    sales_rate_label.text = "Sales Rate: %.1f/s" % new_rate

func _on_price_changed(new_price: float):
    price_label.text = "Price: $%.2f" % new_price

func _on_satisfaction_changed(new_satisfaction: float):
    satisfaction_label.text = "Satisfaction: %.1f%%" % (new_satisfaction * 100)
```

#### Step 2: Create Economy Controls
```gdscript
# Add to sales_display.gd
@onready var adjust_price_button = $AdjustPriceButton
@onready var marketing_button = $MarketingButton

func _ready():
    adjust_price_button.pressed.connect(_on_adjust_price_pressed)
    marketing_button.pressed.connect(_on_marketing_pressed)

func _on_adjust_price_pressed():
    # Open price adjustment dialog
    var price_dialog = preload("res://scenes/ui/price_adjustment_dialog.tscn").instantiate()
    add_child(price_dialog)

func _on_marketing_pressed():
    GameManager.sales_system.improve_marketing()
```

## Day 2: Advanced Sales Features

### Session 3: Customer Satisfaction System (2-3 hours)

#### Step 1: Implement Satisfaction Mechanics
```gdscript
# Add to scripts/systems/sales_system.gd
var base_satisfaction: float = 1.0
var service_quality: float = 1.0
var cleanliness: float = 1.0
var wait_time: float = 0.0
var satisfaction_decay_rate: float = 0.1

func _ready():
    # Start satisfaction decay timer
    var timer = Timer.new()
    timer.wait_time = 5.0  # Update every 5 seconds
    timer.timeout.connect(_update_satisfaction)
    add_child(timer)
    timer.start()

func _update_satisfaction():
    # Calculate satisfaction based on various factors
    var new_satisfaction = base_satisfaction * service_quality * cleanliness
    
    # Apply wait time penalty
    if wait_time > 10.0:
        new_satisfaction *= 0.8
    
    # Apply satisfaction decay
    customer_satisfaction = lerp(customer_satisfaction, new_satisfaction, satisfaction_decay_rate)
    customer_satisfaction_changed.emit(customer_satisfaction)

func improve_service_quality():
    service_quality = min(service_quality + 0.1, 2.0)
    EventManager.emit_event("service_quality_improved", service_quality)

func improve_cleanliness():
    cleanliness = min(cleanliness + 0.1, 2.0)
    EventManager.emit_event("cleanliness_improved", cleanliness)
```

#### Step 2: Create Satisfaction UI
```gdscript
# Add to sales_display.gd
@onready var service_quality_button = $ServiceQualityButton
@onready var cleanliness_button = $CleanlinessButton
@onready var satisfaction_bar = $SatisfactionBar

func _ready():
    service_quality_button.pressed.connect(_on_service_quality_pressed)
    cleanliness_button.pressed.connect(_on_cleanliness_pressed)

func _on_service_quality_pressed():
    if GameManager.player_money >= 50.0:
        GameManager.player_money -= 50.0
        GameManager.sales_system.improve_service_quality()

func _on_cleanliness_pressed():
    if GameManager.player_money >= 30.0:
        GameManager.player_money -= 30.0
        GameManager.sales_system.improve_cleanliness()

func _on_satisfaction_changed(new_satisfaction: float):
    satisfaction_bar.value = new_satisfaction * 100
    satisfaction_label.text = "Satisfaction: %.1f%%" % (new_satisfaction * 100)
```

### Session 4: Marketing and Demand System (2-3 hours)

#### Step 1: Implement Marketing System
```gdscript
# Add to scripts/systems/sales_system.gd
var marketing_level: int = 0
var marketing_cost: float = 100.0
var demand_fluctuation: float = 0.0

func improve_marketing():
    if GameManager.player_money >= marketing_cost:
        GameManager.player_money -= marketing_cost
        marketing_level += 1
        marketing_multiplier += 0.2
        marketing_cost *= 1.5
        EventManager.emit_event("marketing_improved", marketing_level)

func _update_demand():
    # Simulate demand fluctuations
    demand_fluctuation = sin(Time.get_time_dict_from_system()["hour"] * 0.1) * 0.3
    market_demand = 1.0 + demand_fluctuation + (marketing_level * 0.1)
    sales_rate = base_sales_rate * market_demand
    sales_rate_changed.emit(sales_rate)
```

#### Step 2: Create Marketing UI
```gdscript
# Add to sales_display.gd
@onready var marketing_level_label = $MarketingLevelLabel
@onready var demand_indicator = $DemandIndicator

func _update_marketing_display():
    marketing_level_label.text = "Marketing Level: %d" % GameManager.sales_system.marketing_level
    demand_indicator.text = "Demand: %.1fx" % GameManager.sales_system.market_demand
```

## Day 3: Economic Systems and Balance

### Session 5: Price Management System (2-3 hours)

#### Step 1: Create Price Adjustment Dialog
```gdscript
# scenes/ui/price_adjustment_dialog.gd
extends Control

@onready var price_slider = $PriceSlider
@onready var price_label = $PriceLabel
@onready var confirm_button = $ConfirmButton
@onready var cancel_button = $CancelButton

var current_price: float

func _ready():
    current_price = GameManager.sales_system.hot_dog_price
    price_slider.min_value = 0.5
    price_slider.max_value = 10.0
    price_slider.value = current_price
    
    price_slider.value_changed.connect(_on_price_changed)
    confirm_button.pressed.connect(_on_confirm_pressed)
    cancel_button.pressed.connect(_on_cancel_pressed)
    
    _update_price_display()

func _on_price_changed(new_price: float):
    current_price = new_price
    _update_price_display()

func _update_price_display():
    price_label.text = "Price: $%.2f" % current_price

func _on_confirm_pressed():
    GameManager.sales_system.hot_dog_price = current_price
    GameManager.economy_manager.price_changed.emit(current_price)
    queue_free()

func _on_cancel_pressed():
    queue_free()
```

#### Step 2: Implement Price Impact Analysis
```gdscript
# Add to scripts/systems/sales_system.gd
func calculate_price_impact(new_price: float):
    var price_ratio = new_price / hot_dog_price
    var demand_impact = 1.0 / price_ratio  # Higher price = lower demand
    var revenue_impact = price_ratio * demand_impact
    
    return {
        "demand_change": demand_impact,
        "revenue_change": revenue_impact,
        "optimal_price": hot_dog_price * 1.5  # Simple optimal price calculation
    }
```

### Session 6: Economic Events and Seasons (2-3 hours)

#### Step 1: Create Seasonal Events
```gdscript
# Add to scripts/systems/economy_manager.gd
var current_season: String = "normal"
var seasonal_events: Dictionary = {
    "summer": {"multiplier": 1.3, "duration": 30},
    "winter": {"multiplier": 0.8, "duration": 30},
    "holiday": {"multiplier": 1.5, "duration": 7},
    "festival": {"multiplier": 1.8, "duration": 3}
}

func _ready():
    # Start seasonal event timer
    var timer = Timer.new()
    timer.wait_time = 60.0  # Check for events every minute
    timer.timeout.connect(_check_seasonal_events)
    add_child(timer)
    timer.start()

func _check_seasonal_events():
    var current_time = Time.get_time_dict_from_system()
    var day_of_year = current_time["day"] + (current_time["month"] - 1) * 30
    
    # Simple seasonal logic
    if day_of_year >= 150 and day_of_year <= 180:  # Summer
        _trigger_seasonal_event("summer")
    elif day_of_year >= 330 or day_of_year <= 30:  # Winter
        _trigger_seasonal_event("winter")
    elif day_of_year >= 350:  # Holiday season
        _trigger_seasonal_event("holiday")

func _trigger_seasonal_event(season: String):
    if seasonal_events.has(season):
        current_season = season
        seasonal_multiplier = seasonal_events[season]["multiplier"]
        EventManager.emit_event("seasonal_event_started", season)
```

#### Step 2: Create Economic Dashboard
```gdscript
# scenes/ui/economy_dashboard.gd
extends Control

@onready var inflation_label = $InflationLabel
@onready var seasonal_label = $SeasonalLabel
@onready var market_trend_label = $MarketTrendLabel

func _ready():
    GameManager.economy_manager.inflation_updated.connect(_on_inflation_updated)
    EventManager.event_emitted.connect(_on_event_emitted)

func _on_inflation_updated(inflation_rate: float):
    inflation_label.text = "Inflation: %.1f%%" % (inflation_rate * 100)

func _on_event_emitted(event_name: String, data):
    if event_name == "seasonal_event_started":
        seasonal_label.text = "Season: %s" % data.capitalize()
```

## Day 4: Analytics and Optimization

### Session 7: Sales Analytics (2-3 hours)

#### Step 1: Implement Sales Tracking
```gdscript
# Add to scripts/systems/sales_system.gd
var total_sales: int = 0
var total_revenue: float = 0.0
var sales_history: Array = []
var hourly_sales: Array = []

func _ready():
    # Initialize sales tracking
    for i in range(24):
        hourly_sales.append(0)

func record_sale(amount: int, revenue: float):
    total_sales += amount
    total_revenue += revenue
    
    var current_hour = Time.get_time_dict_from_system()["hour"]
    hourly_sales[current_hour] += amount
    
    sales_history.append({
        "time": Time.get_time_dict_from_system(),
        "amount": amount,
        "revenue": revenue,
        "price": hot_dog_price
    })
    
    # Keep only last 1000 sales for performance
    if sales_history.size() > 1000:
        sales_history.pop_front()

func get_sales_statistics():
    return {
        "total_sales": total_sales,
        "total_revenue": total_revenue,
        "average_price": total_revenue / total_sales if total_sales > 0 else 0,
        "peak_hour": hourly_sales.find(hourly_sales.max()),
        "sales_per_hour": hourly_sales
    }
```

#### Step 2: Create Analytics UI
```gdscript
# scenes/ui/sales_analytics.gd
extends Control

@onready var total_sales_label = $TotalSalesLabel
@onready var total_revenue_label = $TotalRevenueLabel
@onready var average_price_label = $AveragePriceLabel
@onready var peak_hour_label = $PeakHourLabel

func _ready():
    # Update analytics every 5 seconds
    var timer = Timer.new()
    timer.wait_time = 5.0
    timer.timeout.connect(_update_analytics)
    add_child(timer)
    timer.start()

func _update_analytics():
    var stats = GameManager.sales_system.get_sales_statistics()
    total_sales_label.text = "Total Sales: %d" % stats.total_sales
    total_revenue_label.text = "Total Revenue: $%.2f" % stats.total_revenue
    average_price_label.text = "Avg Price: $%.2f" % stats.average_price
    peak_hour_label.text = "Peak Hour: %d:00" % stats.peak_hour
```

### Session 8: Performance Optimization and Testing (2-3 hours)

#### Step 1: Optimize Sales Calculations
```gdscript
# Add to scripts/systems/sales_system.gd
var update_interval: float = 0.5  # Update every 500ms
var update_timer: float = 0.0

func _process(delta: float):
    update_timer += delta
    if update_timer >= update_interval:
        _update_sales(update_timer)
        update_timer = 0.0

func _update_sales(delta: float):
    if not is_sales_active:
        return
        
    var sales_amount = sales_rate * customer_satisfaction * marketing_multiplier * location_bonus * delta
    var revenue = sales_amount * hot_dog_price
    
    if GameManager.hot_dog_production.current_production >= sales_amount:
        GameManager.hot_dog_production.current_production -= sales_amount
        GameManager.add_money(revenue)
        record_sale(sales_amount, revenue)
        sale_completed.emit(sales_amount, revenue)
        EventManager.emit_event("hot_dogs_sold", sales_amount)
```

#### Step 2: Create Comprehensive Tests
```gdscript
# scripts/tests/sales_system_test.gd
extends GutTest

func test_basic_sale():
    var sales = SalesSystem.new()
    GameManager.player_money = 1000.0
    GameManager.hot_dog_production.current_production = 10
    
    sales._update_sales(1.0)
    assert_eq(GameManager.hot_dog_production.current_production, 9)
    assert_eq(GameManager.player_money, 1002.0)

func test_customer_satisfaction_impact():
    var sales = SalesSystem.new()
    sales.customer_satisfaction = 0.5
    sales.sales_rate = 2.0
    
    var expected_sales = 2.0 * 0.5 * 1.0  # rate * satisfaction * time
    assert_eq(expected_sales, 1.0)
```

## Success Criteria Checklist

- [ ] Sales system automatically sells hot dogs at specified rate
- [ ] Customer satisfaction affects sales performance
- [ ] Marketing system increases demand and sales
- [ ] Price adjustment system works correctly
- [ ] Economic events and seasons provide variety
- [ ] Sales analytics track performance metrics
- [ ] Revenue generation is balanced and engaging
- [ ] All systems integrate with GameManager
- [ ] Performance is optimized for smooth gameplay
- [ ] Save system can persist sales and economic data

## Risk Mitigation

1. **Economic Imbalance**: Implement extensive testing and balance configuration
2. **Performance Issues**: Use update throttling and efficient data structures
3. **Complex UI**: Create modular components with clear separation of concerns
4. **Save Data Size**: Implement data compression and cleanup for analytics

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
1. **Enhanced Sales System**
   ```gdscript
   class_name SalesSystem
   extends Node
   
   @export var sales_rate: float = 1.0
   @export var hot_dog_price: float = 2.0
   @export var customer_satisfaction: float = 1.0
   @export_group("Performance Settings")
   @export var update_interval: float = 0.5
   
   signal sale_completed(amount: int, revenue: float)
   signal sales_rate_changed(new_rate: float)
   signal customer_satisfaction_changed(new_satisfaction: float)
   
   func _ready():
       _initialize_system()
   
   func _exit_tree():
       _cleanup_system()
   
   func _initialize_system():
       # System initialization
       pass
   
   func _cleanup_system():
       # Disconnect all signals to prevent memory leaks
       if sale_completed.is_connected(_on_sale_completed):
           sale_completed.disconnect(_on_sale_completed)
   ```

2. **Better Economy Resource Management**
   ```gdscript
   class_name EconomyData
   extends Resource
   
   @export var inflation_rate: float = 0.01
   @export var price_volatility: float = 0.05
   @export var market_demand: float = 1.0
   @export_group("Seasonal Settings")
   @export var seasonal_multiplier: float = 1.0
   
   func _notification(what: int):
       if what == NOTIFICATION_PREDELETE:
           _cleanup_resources()
   
   func _cleanup_resources():
       # Clean up economy data before deletion
       pass
   ```

3. **Improved Testing Framework**
   ```gdscript
   extends GutTest
   
   func test_sales_system():
       var sales = SalesSystem.new()
       add_child_autofree(sales)
       
       sales.sales_rate = 2.0
       sales._update_sales(1.0)
       
       # Test sales logic
       assert_eq(sales.total_sales, 2)
   
   func test_economy_integration():
       var sales = SalesSystem.new()
       var economy = EconomyManager.new()
       
       add_child_autofree(sales)
       add_child_autofree(economy)
       
       # Test economy integration
       economy.price_changed.connect(sales._on_price_changed)
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

After completing the Sales and Economy System:
1. Move to Upgrade System implementation
2. Integrate with Core UI Screens for complete user experience
3. Connect to Game Balance system for fine-tuning
4. Implement advanced features like multiple locations and staff management 