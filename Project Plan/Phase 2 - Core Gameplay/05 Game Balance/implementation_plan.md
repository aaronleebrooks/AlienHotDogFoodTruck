# Game Balance - Implementation Plan

## Overview
This document provides a detailed step-by-step implementation plan for the Game Balance system, which ensures the hot dog idle game provides engaging and fair progression.

## Implementation Timeline
**Estimated Duration**: 2-3 days
**Sessions**: 4-6 coding sessions of 2-3 hours each

## Day 1: Core Balance Framework

### Session 1: Balance Data Structure (2-3 hours)

#### Step 1: Create Balance Configuration System
```bash
# Create balance system directory
mkdir -p scripts/systems
touch scripts/systems/balance_manager.gd
mkdir -p resources
touch resources/game_balance.gd
```

```gdscript
# resources/game_balance.gd
class_name GameBalance
extends Resource

# Production Balance
@export_group("Production")
@export var base_production_rate: float = 1.0
@export var production_rate_scaling: float = 1.2
@export var base_production_capacity: int = 100
@export var capacity_scaling: float = 1.5
@export var production_upgrade_cost_base: float = 10.0
@export var production_upgrade_cost_multiplier: float = 1.5

# Sales Balance
@export_group("Sales")
@export var base_sales_rate: float = 0.8
@export var sales_rate_scaling: float = 1.1
@export var base_hot_dog_price: float = 2.0
@export var price_volatility: float = 0.05
@export var customer_satisfaction_decay: float = 0.1
@export var marketing_cost_base: float = 100.0
@export var marketing_cost_multiplier: float = 1.3

# Economy Balance
@export_group("Economy")
@export var inflation_rate: float = 0.01
@export var money_multiplier: float = 1.0
@export var offline_progress_multiplier: float = 0.5
@export var max_offline_time: float = 86400.0  # 24 hours

# Upgrade Balance
@export_group("Upgrades")
@export var upgrade_cost_base: float = 10.0
@export var upgrade_cost_multiplier: float = 1.5
@export var upgrade_effect_scaling: float = 1.2
@export var max_upgrade_level: int = 50
@export var prestige_multiplier: float = 2.0

# Progression Balance
@export_group("Progression")
@export var milestone_intervals: Array[int] = [10, 25, 50, 100, 200, 500]
@export var milestone_rewards: Array[float] = [100, 500, 1000, 2500, 5000, 10000]
@export var prestige_requirement: float = 1000000.0
@export var prestige_bonus: float = 0.1

func calculate_production_cost(level: int) -> float:
    return production_upgrade_cost_base * pow(production_upgrade_cost_multiplier, level)

func calculate_sales_cost(level: int) -> float:
    return marketing_cost_base * pow(marketing_cost_multiplier, level)

func calculate_upgrade_cost(base_cost: float, level: int) -> float:
    return base_cost * pow(upgrade_cost_multiplier, level)

func calculate_upgrade_effect(base_effect: float, level: int) -> float:
    return base_effect * pow(upgrade_effect_scaling, level)

func get_milestone_reward(milestone_index: int) -> float:
    if milestone_index < milestone_rewards.size():
        return milestone_rewards[milestone_index]
    return 0.0
```

#### Step 2: Create Balance Manager
```gdscript
# scripts/systems/balance_manager.gd
class_name BalanceManager
extends Node

signal balance_updated
signal milestone_reached(milestone_index: int, reward: float)

var balance_config: GameBalance
var current_milestone: int = 0
var total_money_earned: float = 0.0
var prestige_count: int = 0

func _ready():
    print("BalanceManager initialized")
    _load_balance_config()
    _setup_balance_monitoring()

func _load_balance_config():
    balance_config = preload("res://resources/game_balance.tres")
    if not balance_config:
        print("Warning: Could not load balance configuration")

func _setup_balance_monitoring():
    # Monitor money changes for milestones
    GameManager.money_changed.connect(_on_money_changed)
    
    # Monitor upgrade purchases for balance adjustments
    GameManager.upgrade_system.upgrade_purchased.connect(_on_upgrade_purchased)

func _on_money_changed(new_amount: float):
    var money_gained = new_amount - GameManager.player_money
    if money_gained > 0:
        total_money_earned += money_gained
        _check_milestones()

func _check_milestones():
    while current_milestone < balance_config.milestone_intervals.size():
        var milestone_threshold = balance_config.milestone_intervals[current_milestone]
        if total_money_earned >= milestone_threshold:
            _trigger_milestone(current_milestone)
            current_milestone += 1
        else:
            break

func _trigger_milestone(milestone_index: int):
    var reward = balance_config.get_milestone_reward(milestone_index)
    GameManager.add_money(reward)
    milestone_reached.emit(milestone_index, reward)
    EventManager.emit_event("milestone_reached", {"index": milestone_index, "reward": reward})

func _on_upgrade_purchased(upgrade_id: String, new_level: int):
    # Adjust balance based on upgrade purchases
    _recalculate_balance()

func _recalculate_balance():
    # Recalculate all game systems based on current balance
    _update_production_balance()
    _update_sales_balance()
    _update_economy_balance()
    balance_updated.emit()

func _update_production_balance():
    var production = GameManager.hot_dog_production
    # Apply prestige multiplier
    var prestige_multiplier = 1.0 + (prestige_count * balance_config.prestige_multiplier)
    production.production_efficiency = prestige_multiplier

func _update_sales_balance():
    var sales = GameManager.sales_system
    # Apply prestige multiplier to sales
    var prestige_multiplier = 1.0 + (prestige_count * balance_config.prestige_multiplier)
    sales.marketing_multiplier *= prestige_multiplier

func _update_economy_balance():
    var economy = GameManager.economy_manager
    economy.inflation_rate = balance_config.inflation_rate
```

#### Step 3: Create Balance Testing Framework
```gdscript
# scripts/tests/balance_tests.gd
extends GutTest

func test_production_cost_calculation():
    var balance = GameBalance.new()
    balance.production_upgrade_cost_base = 10.0
    balance.production_upgrade_cost_multiplier = 1.5
    
    var cost_level_1 = balance.calculate_production_cost(1)
    assert_eq(cost_level_1, 15.0)
    
    var cost_level_2 = balance.calculate_production_cost(2)
    assert_eq(cost_level_2, 22.5)

func test_upgrade_effect_scaling():
    var balance = GameBalance.new()
    balance.upgrade_effect_scaling = 1.2
    
    var effect_level_1 = balance.calculate_upgrade_effect(1.0, 1)
    assert_eq(effect_level_1, 1.2)
    
    var effect_level_2 = balance.calculate_upgrade_effect(1.0, 2)
    assert_eq(effect_level_2, 1.44)
```

### Session 2: Progression Curves and Scaling (2-3 hours)

#### Step 1: Implement Progression Curves
```gdscript
# Add to scripts/systems/balance_manager.gd
func calculate_progression_curve(base_value: float, level: int, curve_type: String = "exponential") -> float:
    match curve_type:
        "linear":
            return base_value * level
        "exponential":
            return base_value * pow(balance_config.upgrade_effect_scaling, level)
        "logarithmic":
            return base_value * log(level + 1)
        "polynomial":
            return base_value * pow(level, 2)
        _:
            return base_value * level

func calculate_cost_curve(base_cost: float, level: int, curve_type: String = "exponential") -> float:
    match curve_type:
        "linear":
            return base_cost * level
        "exponential":
            return base_cost * pow(balance_config.upgrade_cost_multiplier, level)
        "polynomial":
            return base_cost * pow(level, 1.5)
        _:
            return base_cost * level

func get_optimal_upgrade_path() -> Array[String]:
    # Calculate the most efficient upgrade path
    var upgrades = GameManager.upgrade_system.upgrades
    var upgrade_efficiency: Dictionary = {}
    
    for upgrade_id in upgrades:
        var upgrade_data = upgrades[upgrade_id]
        var current_level = GameManager.upgrade_system.upgrade_levels[upgrade_id]
        var cost = calculate_cost_curve(upgrade_data.base_cost, current_level)
        var effect = calculate_progression_curve(upgrade_data.effect_value, current_level + 1)
        var efficiency = effect / cost
        upgrade_efficiency[upgrade_id] = efficiency
    
    # Sort by efficiency
    var sorted_upgrades = upgrade_efficiency.keys()
    sorted_upgrades.sort_custom(func(a, b): return upgrade_efficiency[a] > upgrade_efficiency[b])
    
    return sorted_upgrades
```

#### Step 2: Create Balance Analytics
```gdscript
# Add to scripts/systems/balance_manager.gd
func get_balance_analytics() -> Dictionary:
    var analytics = {
        "total_money_earned": total_money_earned,
        "current_milestone": current_milestone,
        "prestige_count": prestige_count,
        "upgrade_efficiency": {},
        "progression_rate": 0.0,
        "balance_issues": []
    }
    
    # Calculate upgrade efficiency
    var upgrades = GameManager.upgrade_system.upgrades
    for upgrade_id in upgrades:
        var upgrade_data = upgrades[upgrade_id]
        var current_level = GameManager.upgrade_system.upgrade_levels[upgrade_id]
        var cost = calculate_cost_curve(upgrade_data.base_cost, current_level)
        var effect = calculate_progression_curve(upgrade_data.effect_value, current_level)
        analytics.upgrade_efficiency[upgrade_id] = effect / cost if cost > 0 else 0
    
    # Calculate progression rate (money per hour)
    var play_time = GameManager.game_time
    analytics.progression_rate = total_money_earned / (play_time / 3600.0) if play_time > 0 else 0
    
    # Check for balance issues
    _check_balance_issues(analytics)
    
    return analytics

func _check_balance_issues(analytics: Dictionary):
    # Check if any upgrade is too expensive
    var upgrades = GameManager.upgrade_system.upgrades
    for upgrade_id in upgrades:
        var upgrade_data = upgrades[upgrade_id]
        var current_level = GameManager.upgrade_system.upgrade_levels[upgrade_id]
        var cost = calculate_cost_curve(upgrade_data.base_cost, current_level)
        
        if cost > GameManager.player_money * 10:
            analytics.balance_issues.append("Upgrade %s is too expensive" % upgrade_id)
    
    # Check if progression is too slow
    if analytics.progression_rate < 100.0 and GameManager.game_time > 3600.0:
        analytics.balance_issues.append("Progression rate is too slow")
    
    # Check if progression is too fast
    if analytics.progression_rate > 10000.0:
        analytics.balance_issues.append("Progression rate is too fast")
```

## Day 2: Advanced Balance Features

### Session 3: Dynamic Balance Adjustment (2-3 hours)

#### Step 1: Implement Dynamic Scaling
```gdscript
# Add to scripts/systems/balance_manager.gd
var dynamic_scaling_enabled: bool = true
var player_performance_history: Array[float] = []
var balance_adjustments: Dictionary = {}

func _ready():
    # Start performance monitoring
    var timer = Timer.new()
    timer.wait_time = 300.0  # Check every 5 minutes
    timer.timeout.connect(_monitor_performance)
    add_child(timer)
    timer.start()

func _monitor_performance():
    if not dynamic_scaling_enabled:
        return
    
    var current_performance = _calculate_current_performance()
    player_performance_history.append(current_performance)
    
    # Keep only last 24 hours of data
    if player_performance_history.size() > 288:  # 24 hours / 5 minutes
        player_performance_history.pop_front()
    
    _adjust_balance_if_needed()

func _calculate_current_performance() -> float:
    # Calculate money earned in the last 5 minutes
    var recent_money = total_money_earned - (total_money_earned - GameManager.player_money)
    return recent_money / 5.0  # Money per minute

func _adjust_balance_if_needed():
    if player_performance_history.size() < 12:  # Need at least 1 hour of data
        return
    
    var average_performance = _calculate_average_performance()
    var target_performance = _get_target_performance()
    
    if average_performance < target_performance * 0.7:
        _boost_progression()
    elif average_performance > target_performance * 1.3:
        _slow_progression()

func _calculate_average_performance() -> float:
    var sum = 0.0
    for performance in player_performance_history:
        sum += performance
    return sum / player_performance_history.size()

func _get_target_performance() -> float:
    # Target performance based on game time and milestones
    var base_target = 100.0  # $100 per minute
    var time_multiplier = 1.0 + (GameManager.game_time / 3600.0) * 0.1
    var milestone_multiplier = 1.0 + current_milestone * 0.2
    return base_target * time_multiplier * milestone_multiplier

func _boost_progression():
    # Temporarily boost progression
    balance_adjustments["progression_boost"] = 1.5
    balance_adjustments["boost_duration"] = 1800.0  # 30 minutes
    _apply_balance_adjustments()

func _slow_progression():
    # Temporarily slow progression
    balance_adjustments["progression_boost"] = 0.8
    balance_adjustments["boost_duration"] = 1800.0  # 30 minutes
    _apply_balance_adjustments()

func _apply_balance_adjustments():
    if balance_adjustments.has("progression_boost"):
        var boost = balance_adjustments.progression_boost
        GameManager.hot_dog_production.production_efficiency *= boost
        GameManager.sales_system.marketing_multiplier *= boost
        
        # Start timer to remove boost
        var timer = Timer.new()
        timer.wait_time = balance_adjustments.boost_duration
        timer.timeout.connect(_remove_balance_adjustments)
        add_child(timer)
        timer.start()

func _remove_balance_adjustments():
    if balance_adjustments.has("progression_boost"):
        var boost = balance_adjustments.progression_boost
        GameManager.hot_dog_production.production_efficiency /= boost
        GameManager.sales_system.marketing_multiplier /= boost
        balance_adjustments.clear()
```

#### Step 2: Create Balance Presets
```gdscript
# Add to scripts/systems/balance_manager.gd
var balance_presets: Dictionary = {
    "easy": {
        "production_rate_scaling": 1.3,
        "upgrade_cost_multiplier": 1.3,
        "inflation_rate": 0.005,
        "milestone_rewards_multiplier": 1.5
    },
    "normal": {
        "production_rate_scaling": 1.2,
        "upgrade_cost_multiplier": 1.5,
        "inflation_rate": 0.01,
        "milestone_rewards_multiplier": 1.0
    },
    "hard": {
        "production_rate_scaling": 1.1,
        "upgrade_cost_multiplier": 1.7,
        "inflation_rate": 0.015,
        "milestone_rewards_multiplier": 0.7
    }
}

func apply_balance_preset(preset_name: String):
    if not balance_presets.has(preset_name):
        print("Warning: Unknown balance preset: %s" % preset_name)
        return
    
    var preset = balance_presets[preset_name]
    
    # Apply preset values
    balance_config.production_rate_scaling = preset.production_rate_scaling
    balance_config.upgrade_cost_multiplier = preset.upgrade_cost_multiplier
    balance_config.inflation_rate = preset.inflation_rate
    
    # Recalculate all balance values
    _recalculate_balance()
    
    print("Applied balance preset: %s" % preset_name)
```

### Session 4: Prestige and Endgame Balance (2-3 hours)

#### Step 1: Implement Prestige System
```gdscript
# Add to scripts/systems/balance_manager.gd
func check_prestige_available() -> bool:
    return total_money_earned >= balance_config.prestige_requirement

func perform_prestige():
    if not check_prestige_available():
        return false
    
    # Calculate prestige bonus
    var prestige_bonus = balance_config.prestige_bonus
    prestige_count += 1
    
    # Reset game state but keep prestige bonus
    GameManager.reset_game_keep_prestige()
    
    # Apply prestige multiplier
    var prestige_multiplier = 1.0 + (prestige_count * prestige_bonus)
    GameManager.hot_dog_production.production_efficiency = prestige_multiplier
    GameManager.sales_system.marketing_multiplier = prestige_multiplier
    
    # Reset milestone progress
    current_milestone = 0
    total_money_earned = 0.0
    
    EventManager.emit_event("prestige_performed", prestige_count)
    return true

func get_prestige_bonus() -> float:
    return 1.0 + (prestige_count * balance_config.prestige_bonus)

func get_next_prestige_requirement() -> float:
    return balance_config.prestige_requirement * pow(1.5, prestige_count)
```

#### Step 2: Create Endgame Content Balance
```gdscript
# Add to scripts/systems/balance_manager.gd
var endgame_unlocks: Dictionary = {
    "multiple_locations": {"requirement": 1000000.0, "unlocked": false},
    "staff_management": {"requirement": 5000000.0, "unlocked": false},
    "franchise_system": {"requirement": 10000000.0, "unlocked": false},
    "research_lab": {"requirement": 50000000.0, "unlocked": false}
}

func _ready():
    # Check for endgame unlocks
    _check_endgame_unlocks()

func _check_endgame_unlocks():
    for unlock_id in endgame_unlocks:
        var unlock_data = endgame_unlocks[unlock_id]
        if not unlock_data.unlocked and total_money_earned >= unlock_data.requirement:
            unlock_data.unlocked = true
            _unlock_endgame_feature(unlock_id)
            EventManager.emit_event("endgame_feature_unlocked", unlock_id)

func _unlock_endgame_feature(feature_id: String):
    match feature_id:
        "multiple_locations":
            # Enable multiple location system
            pass
        "staff_management":
            # Enable staff hiring and management
            pass
        "franchise_system":
            # Enable franchise expansion
            pass
        "research_lab":
            # Enable research and development
            pass
```

## Day 3: Balance Testing and Optimization

### Session 5: Automated Balance Testing (2-3 hours)

#### Step 1: Create Balance Test Suite
```gdscript
# scripts/tests/balance_test_suite.gd
extends GutTest

var balance_manager: BalanceManager
var test_game_manager: Node

func before_each():
    balance_manager = BalanceManager.new()
    test_game_manager = Node.new()
    add_child_autofree(balance_manager)
    add_child_autofree(test_game_manager)

func test_progression_curve_calculation():
    var linear_result = balance_manager.calculate_progression_curve(10.0, 5, "linear")
    assert_eq(linear_result, 50.0)
    
    var exponential_result = balance_manager.calculate_progression_curve(10.0, 3, "exponential")
    assert_gt(exponential_result, 10.0)

func test_cost_curve_calculation():
    var linear_cost = balance_manager.calculate_cost_curve(10.0, 5, "linear")
    assert_eq(linear_cost, 50.0)
    
    var exponential_cost = balance_manager.calculate_cost_curve(10.0, 3, "exponential")
    assert_gt(exponential_cost, 10.0)

func test_milestone_system():
    balance_manager.total_money_earned = 25.0
    balance_manager._check_milestones()
    assert_eq(balance_manager.current_milestone, 1)

func test_prestige_system():
    balance_manager.total_money_earned = 1000000.0
    var can_prestige = balance_manager.check_prestige_available()
    assert_eq(can_prestige, true)
    
    var prestige_success = balance_manager.perform_prestige()
    assert_eq(prestige_success, true)
    assert_eq(balance_manager.prestige_count, 1)
```

#### Step 2: Create Performance Testing
```gdscript
# scripts/tests/balance_performance_test.gd
extends GutTest

func test_balance_calculation_performance():
    var balance_manager = BalanceManager.new()
    add_child_autofree(balance_manager)
    
    var start_time = Time.get_ticks_msec()
    
    # Simulate 1000 balance calculations
    for i in range(1000):
        balance_manager.calculate_progression_curve(10.0, i % 50, "exponential")
        balance_manager.calculate_cost_curve(10.0, i % 50, "exponential")
    
    var end_time = Time.get_ticks_msec()
    var duration = end_time - start_time
    
    # Should complete in less than 100ms
    assert_lt(duration, 100)

func test_memory_usage():
    var balance_manager = BalanceManager.new()
    add_child_autofree(balance_manager)
    
    # Simulate long-term play
    for i in range(1000):
        balance_manager.player_performance_history.append(randf() * 100)
    
    # Memory usage should be reasonable
    var memory_usage = balance_manager.player_performance_history.size() * 8  # bytes per float
    assert_lt(memory_usage, 10000)  # Less than 10KB
```

### Session 6: Balance Optimization and Final Integration (2-3 hours)

#### Step 1: Create Balance Optimization Tools
```gdscript
# Add to scripts/systems/balance_manager.gd
func optimize_balance_for_target_progression(target_hours: float = 10.0):
    # Calculate optimal balance values for target progression time
    var target_money = balance_config.prestige_requirement
    var target_rate = target_money / (target_hours * 3600.0)  # Money per second
    
    # Adjust balance values to achieve target rate
    var current_rate = _calculate_current_progression_rate()
    var adjustment_factor = target_rate / current_rate if current_rate > 0 else 1.0
    
    # Apply adjustments
    balance_config.production_rate_scaling *= adjustment_factor
    balance_config.upgrade_cost_multiplier /= adjustment_factor
    
    _recalculate_balance()
    print("Balance optimized for %f hour progression" % target_hours)

func _calculate_current_progression_rate() -> float:
    # Calculate current money per second
    var production_rate = GameManager.hot_dog_production.production_rate
    var sales_rate = GameManager.sales_system.sales_rate
    var price = GameManager.sales_system.hot_dog_price
    
    return min(production_rate, sales_rate) * price
```

#### Step 2: Final Integration with Game Systems
```gdscript
# Add to scripts/autoload/game_manager.gd
var balance_manager: BalanceManager

func _ready():
    balance_manager = BalanceManager.new()
    add_child(balance_manager)
    
    # Connect balance events
    balance_manager.milestone_reached.connect(_on_milestone_reached)
    balance_manager.balance_updated.connect(_on_balance_updated)

func _on_milestone_reached(milestone_index: int, reward: float):
    # Show milestone notification
    UIManager.show_notification("Milestone reached! +$%.0f" % reward)
    
    # Play milestone sound
    AudioManager.play_sound("milestone")

func _on_balance_updated():
    # Update all UI elements
    UIManager.update_all_displays()
    
    # Save game with new balance
    SaveManager.save_game()

func get_game_statistics() -> Dictionary:
    var stats = {
        "total_money_earned": balance_manager.total_money_earned,
        "current_milestone": balance_manager.current_milestone,
        "prestige_count": balance_manager.prestige_count,
        "play_time": game_time,
        "upgrades_purchased": upgrade_system.total_upgrades_purchased,
        "production_stats": hot_dog_production.get_statistics(),
        "sales_stats": sales_system.get_sales_statistics()
    }
    
    # Add balance analytics
    var balance_analytics = balance_manager.get_balance_analytics()
    stats["balance_analytics"] = balance_analytics
    
    return stats
```

## Success Criteria Checklist

- [ ] Balance system provides engaging progression curves
- [ ] Upgrade costs scale appropriately with player progress
- [ ] Milestone system rewards player achievements
- [ ] Dynamic balance adjustment responds to player performance
- [ ] Prestige system provides long-term progression
- [ ] Balance presets allow for different difficulty levels
- [ ] Automated testing validates balance calculations
- [ ] Performance optimization ensures smooth gameplay
- [ ] Balance analytics provide insights into game economy
- [ ] All balance systems integrate with save/load functionality

## Risk Mitigation

1. **Balance Issues**: Implement extensive testing and dynamic adjustment
2. **Performance Problems**: Optimize calculations and use efficient algorithms
3. **Player Frustration**: Provide multiple difficulty levels and balance presets
4. **Save Data Corruption**: Implement robust balance data serialization

## Next Steps

After completing the Game Balance system:
1. Move to Phase 3 - Content Expansion
2. Integrate with advanced features like achievements and events
3. Add more sophisticated balance algorithms
4. Implement player feedback collection and analysis 