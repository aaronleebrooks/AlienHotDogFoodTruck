# Core UI Screens - Implementation Plan

## Overview
This document provides a detailed step-by-step implementation plan for the Core UI Screens, which provide the main user interface for the hot dog idle game.

## Implementation Timeline
**Estimated Duration**: 3-4 days
**Sessions**: 6-8 coding sessions of 2-3 hours each

## Day 1: Main Game Screen and Navigation

### Session 1: Main Game Screen Layout (2-3 hours)

#### Step 1: Create Main Game Scene
```bash
# Create main game scene structure
mkdir -p scenes
touch scenes/main_game.tscn
touch scenes/main_game.gd
mkdir -p scenes/ui
touch scenes/ui/main_hud.tscn
touch scenes/ui/main_hud.gd
```

```gdscript
# scenes/main_game.gd
extends Control

@onready var hud = $MainHUD
@onready var production_panel = $ProductionPanel
@onready var sales_panel = $SalesPanel
@onready var upgrade_panel = $UpgradePanel
@onready var settings_panel = $SettingsPanel

var current_screen: String = "main"

func _ready():
    print("MainGame initialized")
    _setup_ui_connections()
    _show_screen("main")

func _setup_ui_connections():
    # Connect navigation buttons
    hud.production_button.pressed.connect(_on_production_pressed)
    hud.sales_button.pressed.connect(_on_sales_pressed)
    hud.upgrades_button.pressed.connect(_on_upgrades_pressed)
    hud.settings_button.pressed.connect(_on_settings_pressed)
    
    # Connect game state changes
    GameManager.game_state_changed.connect(_on_game_state_changed)

func _show_screen(screen_name: String):
    # Hide all panels
    production_panel.visible = false
    sales_panel.visible = false
    upgrade_panel.visible = false
    settings_panel.visible = false
    
    # Show selected panel
    match screen_name:
        "main":
            production_panel.visible = true
            sales_panel.visible = true
        "production":
            production_panel.visible = true
        "sales":
            sales_panel.visible = true
        "upgrades":
            upgrade_panel.visible = true
        "settings":
            settings_panel.visible = true
    
    current_screen = screen_name
    hud.update_navigation(screen_name)

func _on_production_pressed():
    _show_screen("production")

func _on_sales_pressed():
    _show_screen("sales")

func _on_upgrades_pressed():
    _show_screen("upgrades")

func _on_settings_pressed():
    _show_screen("settings")

func _on_game_state_changed(new_state: String):
    match new_state:
        "menu":
            get_tree().change_scene_to_file("res://scenes/menu.tscn")
        "game":
            _show_screen("main")
```

#### Step 2: Create Main HUD
```gdscript
# scenes/ui/main_hud.gd
extends Control

@onready var money_label = $MoneyLabel
@onready var production_button = $NavigationPanel/ProductionButton
@onready var sales_button = $NavigationPanel/SalesButton
@onready var upgrades_button = $NavigationPanel/UpgradesButton
@onready var settings_button = $NavigationPanel/SettingsButton
@onready var notification_area = $NotificationArea

func _ready():
    GameManager.money_changed.connect(_on_money_changed)
    _update_money_display()

func _update_money_display():
    money_label.text = "$%.2f" % GameManager.player_money

func _on_money_changed(new_amount: float):
    _update_money_display()

func update_navigation(current_screen: String):
    # Update button states to show current screen
    production_button.pressed = (current_screen == "production" or current_screen == "main")
    sales_button.pressed = (current_screen == "sales" or current_screen == "main")
    upgrades_button.pressed = (current_screen == "upgrades")
    settings_button.pressed = (current_screen == "settings")

func show_notification(message: String, duration: float = 3.0):
    var notification = preload("res://scenes/ui/notification_popup.tscn").instantiate()
    notification.set_message(message)
    notification.set_duration(duration)
    notification_area.add_child(notification)
```

### Session 2: Navigation and Panel System (2-3 hours)

#### Step 1: Create Panel Base Class
```gdscript
# scenes/ui/panel_base.gd
extends Control
class_name PanelBase

signal panel_opened
signal panel_closed

var is_open: bool = false

func _ready():
    visible = false
    _setup_panel()

func _setup_panel():
    # Override in subclasses
    pass

func open_panel():
    visible = true
    is_open = true
    _on_panel_opened()
    panel_opened.emit()

func close_panel():
    visible = false
    is_open = false
    _on_panel_closed()
    panel_closed.emit()

func _on_panel_opened():
    # Override in subclasses
    pass

func _on_panel_closed():
    # Override in subclasses
    pass

func update_panel():
    # Override in subclasses
    pass
```

#### Step 2: Create Production Panel
```gdscript
# scenes/ui/production_panel.gd
extends PanelBase

@onready var production_display = $ProductionDisplay
@onready var upgrade_buttons = $UpgradeButtons
@onready var stats_panel = $StatsPanel

func _setup_panel():
    # Connect to production system signals
    GameManager.hot_dog_production.production_updated.connect(_on_production_updated)
    GameManager.hot_dog_production.production_rate_changed.connect(_on_rate_changed)
    GameManager.hot_dog_production.capacity_upgraded.connect(_on_capacity_upgraded)

func _on_panel_opened():
    _update_production_display()

func _update_production_display():
    production_display.update_display()
    stats_panel.update_stats()

func _on_production_updated(current: int, max_capacity: int):
    production_display.update_production(current, max_capacity)

func _on_rate_changed(new_rate: float):
    production_display.update_rate(new_rate)

func _on_capacity_upgraded(new_capacity: int):
    production_display.update_capacity(new_capacity)
```

## Day 2: Specialized UI Components

### Session 3: Production Display Component (2-3 hours)

#### Step 1: Create Production Display
```gdscript
# scenes/ui/production_display.gd
extends Control

@onready var production_label = $ProductionLabel
@onready var rate_label = $RateLabel
@onready var capacity_label = $CapacityLabel
@onready var progress_bar = $ProgressBar
@onready var collect_button = $CollectButton
@onready var auto_collect_toggle = $AutoCollectToggle

func _ready():
    collect_button.pressed.connect(_on_collect_pressed)
    auto_collect_toggle.toggled.connect(_on_auto_collect_toggled)
    _update_display()

func update_display():
    var production = GameManager.hot_dog_production
    production_label.text = "Hot Dogs: %d/%d" % [production.current_production, production.max_production_capacity]
    rate_label.text = "Rate: %.1f/s" % production.production_rate
    capacity_label.text = "Capacity: %d" % production.max_production_capacity
    
    progress_bar.max_value = production.max_production_capacity
    progress_bar.value = production.current_production
    
    # Update button states
    collect_button.disabled = production.current_production == 0
    auto_collect_toggle.button_pressed = production.auto_collect_enabled

func update_production(current: int, max_capacity: int):
    production_label.text = "Hot Dogs: %d/%d" % [current, max_capacity]
    progress_bar.max_value = max_capacity
    progress_bar.value = current
    collect_button.disabled = current == 0

func update_rate(new_rate: float):
    rate_label.text = "Rate: %.1f/s" % new_rate

func update_capacity(new_capacity: int):
    capacity_label.text = "Capacity: %d" % new_capacity

func _on_collect_pressed():
    GameManager.hot_dog_production.collect_production()

func _on_auto_collect_toggled(button_pressed: bool):
    GameManager.hot_dog_production.auto_collect_enabled = button_pressed
```

#### Step 2: Create Sales Display Component
```gdscript
# scenes/ui/sales_display.gd
extends Control

@onready var sales_rate_label = $SalesRateLabel
@onready var price_label = $PriceLabel
@onready var satisfaction_label = $SatisfactionLabel
@onready var marketing_label = $MarketingLabel
@onready var adjust_price_button = $AdjustPriceButton
@onready var marketing_button = $MarketingButton

func _ready():
    adjust_price_button.pressed.connect(_on_adjust_price_pressed)
    marketing_button.pressed.connect(_on_marketing_pressed)
    
    # Connect to sales system signals
    GameManager.sales_system.sales_rate_changed.connect(_on_sales_rate_changed)
    GameManager.sales_system.customer_satisfaction_changed.connect(_on_satisfaction_changed)
    GameManager.economy_manager.price_changed.connect(_on_price_changed)
    
    _update_display()

func _update_display():
    var sales = GameManager.sales_system
    sales_rate_label.text = "Sales Rate: %.1f/s" % sales.sales_rate
    price_label.text = "Price: $%.2f" % sales.hot_dog_price
    satisfaction_label.text = "Satisfaction: %.1f%%" % (sales.customer_satisfaction * 100)
    marketing_label.text = "Marketing: Level %d" % sales.marketing_level

func _on_sales_rate_changed(new_rate: float):
    sales_rate_label.text = "Sales Rate: %.1f/s" % new_rate

func _on_price_changed(new_price: float):
    price_label.text = "Price: $%.2f" % new_price

func _on_satisfaction_changed(new_satisfaction: float):
    satisfaction_label.text = "Satisfaction: %.1f%%" % (new_satisfaction * 100)

func _on_adjust_price_pressed():
    var price_dialog = preload("res://scenes/ui/price_adjustment_dialog.tscn").instantiate()
    add_child(price_dialog)

func _on_marketing_pressed():
    GameManager.sales_system.improve_marketing()
```

### Session 4: Settings and Menu Systems (2-3 hours)

#### Step 1: Create Settings Panel
```gdscript
# scenes/ui/settings_panel.gd
extends PanelBase

@onready var music_slider = $MusicSlider
@onready var sfx_slider = $SFXSlider
@onready var auto_save_toggle = $AutoSaveToggle
@onready var notifications_toggle = $NotificationsToggle
@onready var save_button = $SaveButton
@onready var load_button = $LoadButton
@onready var reset_button = $ResetButton

func _setup_panel():
    # Load current settings
    music_slider.value = AudioManager.get_music_volume()
    sfx_slider.value = AudioManager.get_sfx_volume()
    auto_save_toggle.button_pressed = SaveManager.auto_save_enabled
    notifications_toggle.button_pressed = UIManager.notifications_enabled
    
    # Connect signals
    music_slider.value_changed.connect(_on_music_volume_changed)
    sfx_slider.value_changed.connect(_on_sfx_volume_changed)
    auto_save_toggle.toggled.connect(_on_auto_save_toggled)
    notifications_toggle.toggled.connect(_on_notifications_toggled)
    save_button.pressed.connect(_on_save_pressed)
    load_button.pressed.connect(_on_load_pressed)
    reset_button.pressed.connect(_on_reset_pressed)

func _on_music_volume_changed(value: float):
    AudioManager.set_music_volume(value)

func _on_sfx_volume_changed(value: float):
    AudioManager.set_sfx_volume(value)

func _on_auto_save_toggled(button_pressed: bool):
    SaveManager.auto_save_enabled = button_pressed

func _on_notifications_toggled(button_pressed: bool):
    UIManager.notifications_enabled = button_pressed

func _on_save_pressed():
    SaveManager.save_game()
    show_save_notification()

func _on_load_pressed():
    SaveManager.load_game()
    show_load_notification()

func _on_reset_pressed():
    show_reset_confirmation()

func show_save_notification():
    var notification = preload("res://scenes/ui/notification_popup.tscn").instantiate()
    notification.set_message("Game saved successfully!")
    add_child(notification)

func show_load_notification():
    var notification = preload("res://scenes/ui/notification_popup.tscn").instantiate()
    notification.set_message("Game loaded successfully!")
    add_child(notification)

func show_reset_confirmation():
    var dialog = preload("res://scenes/ui/confirmation_dialog.tscn").instantiate()
    dialog.set_message("Are you sure you want to reset your progress? This cannot be undone.")
    dialog.confirmed.connect(_on_reset_confirmed)
    add_child(dialog)

func _on_reset_confirmed():
    GameManager.reset_game()
    close_panel()
```

#### Step 2: Create Main Menu
```gdscript
# scenes/menu.gd
extends Control

@onready var start_button = $StartButton
@onready var load_button = $LoadButton
@onready var settings_button = $SettingsButton
@onready var quit_button = $QuitButton
@onready var title_label = $TitleLabel

func _ready():
    start_button.pressed.connect(_on_start_pressed)
    load_button.pressed.connect(_on_load_pressed)
    settings_button.pressed.connect(_on_settings_pressed)
    quit_button.pressed.connect(_on_quit_pressed)
    
    # Check if save file exists
    load_button.disabled = not SaveManager.save_file_exists()

func _on_start_pressed():
    GameManager.start_new_game()
    get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_load_pressed():
    if SaveManager.load_game():
        GameManager.change_game_state("game")
        get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_settings_pressed():
    var settings_panel = preload("res://scenes/ui/settings_panel.tscn").instantiate()
    add_child(settings_panel)
    settings_panel.open_panel()

func _on_quit_pressed():
    get_tree().quit()
```

## Day 3: Advanced UI Features

### Session 5: Notification and Dialog Systems (2-3 hours)

#### Step 1: Create Notification System
```gdscript
# scenes/ui/notification_popup.gd
extends Control

@onready var message_label = $MessageLabel
@onready var animation_player = $AnimationPlayer

var message: String = ""
var duration: float = 3.0
var fade_timer: float = 0.0

func _ready():
    # Start fade out timer
    var timer = Timer.new()
    timer.wait_time = duration
    timer.timeout.connect(_on_fade_timer_timeout)
    add_child(timer)
    timer.start()
    
    # Play entrance animation
    animation_player.play("fade_in")

func set_message(text: String):
    message = text
    message_label.text = text

func set_duration(time: float):
    duration = time

func _on_fade_timer_timeout():
    animation_player.play("fade_out")
    await animation_player.animation_finished
    queue_free()
```

#### Step 2: Create Confirmation Dialog
```gdscript
# scenes/ui/confirmation_dialog.gd
extends Control

@onready var message_label = $MessageLabel
@onready var confirm_button = $ConfirmButton
@onready var cancel_button = $CancelButton

signal confirmed
signal cancelled

var message: String = ""

func _ready():
    confirm_button.pressed.connect(_on_confirm_pressed)
    cancel_button.pressed.connect(_on_cancel_pressed)
    
    # Play entrance animation
    var tween = create_tween()
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
    tween.tween_callback(self, "_on_entrance_finished")

func set_message(text: String):
    message = text
    message_label.text = text

func _on_confirm_pressed():
    confirmed.emit()
    _close_dialog()

func _on_cancel_pressed():
    cancelled.emit()
    _close_dialog()

func _close_dialog():
    var tween = create_tween()
    tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.2)
    tween.tween_callback(self, "queue_free")

func _on_entrance_finished():
    # Focus the cancel button by default
    cancel_button.grab_focus()
```

### Session 6: Statistics and Analytics UI (2-3 hours)

#### Step 1: Create Statistics Panel
```gdscript
# scenes/ui/statistics_panel.gd
extends PanelBase

@onready var total_money_label = $TotalMoneyLabel
@onready var total_sales_label = $TotalSalesLabel
@onready var play_time_label = $PlayTimeLabel
@onready var upgrades_purchased_label = $UpgradesPurchasedLabel
@onready var production_stats = $ProductionStats
@onready var sales_stats = $SalesStats

func _setup_panel():
    # Update stats every 5 seconds
    var timer = Timer.new()
    timer.wait_time = 5.0
    timer.timeout.connect(_update_statistics)
    add_child(timer)
    timer.start()

func _on_panel_opened():
    _update_statistics()

func _update_statistics():
    var stats = GameManager.get_game_statistics()
    
    total_money_label.text = "Total Money Earned: $%.2f" % stats.total_money_earned
    total_sales_label.text = "Total Hot Dogs Sold: %d" % stats.total_hot_dogs_sold
    play_time_label.text = "Play Time: %s" % _format_time(stats.play_time)
    upgrades_purchased_label.text = "Upgrades Purchased: %d" % stats.upgrades_purchased
    
    production_stats.update_stats(stats.production_stats)
    sales_stats.update_stats(stats.sales_stats)

func _format_time(seconds: float) -> String:
    var hours = int(seconds / 3600)
    var minutes = int((seconds % 3600) / 60)
    var secs = int(seconds % 60)
    return "%02d:%02d:%02d" % [hours, minutes, secs]
```

#### Step 2: Create Production Statistics Component
```gdscript
# scenes/ui/production_stats.gd
extends Control

@onready var current_rate_label = $CurrentRateLabel
@onready var total_produced_label = $TotalProducedLabel
@onready var efficiency_label = $EfficiencyLabel
@onready var capacity_usage_label = $CapacityUsageLabel

func update_stats(stats: Dictionary):
    current_rate_label.text = "Current Rate: %.1f/s" % stats.current_rate
    total_produced_label.text = "Total Produced: %d" % stats.total_produced
    efficiency_label.text = "Efficiency: %.1f%%" % (stats.efficiency * 100)
    capacity_usage_label.text = "Capacity Usage: %.1f%%" % (stats.capacity_usage * 100)
```

## Day 4: UI Polish and Responsive Design

### Session 7: Responsive Layout and Animations (2-3 hours)

#### Step 1: Create Responsive Layout System
```gdscript
# scenes/ui/responsive_layout.gd
extends Control

@onready var main_container = $MainContainer
@onready var side_panel = $SidePanel

var screen_size: Vector2
var is_mobile: bool = false

func _ready():
    screen_size = get_viewport().get_visible_rect().size
    is_mobile = screen_size.x < 800
    
    # Connect to window resize events
    get_tree().root.content_scale_mode_changed.connect(_on_screen_size_changed)
    
    _apply_layout()

func _apply_layout():
    if is_mobile:
        _apply_mobile_layout()
    else:
        _apply_desktop_layout()

func _apply_mobile_layout():
    # Stack panels vertically for mobile
    main_container.custom_minimum_size.x = screen_size.x
    side_panel.custom_minimum_size.x = screen_size.x
    side_panel.position.x = 0
    side_panel.position.y = main_container.size.y

func _apply_desktop_layout():
    # Side-by-side layout for desktop
    main_container.custom_minimum_size.x = screen_size.x * 0.7
    side_panel.custom_minimum_size.x = screen_size.x * 0.3
    side_panel.position.x = main_container.size.x
    side_panel.position.y = 0

func _on_screen_size_changed():
    screen_size = get_viewport().get_visible_rect().size
    is_mobile = screen_size.x < 800
    _apply_layout()
```

#### Step 2: Create UI Animations
```gdscript
# scenes/ui/ui_animations.gd
extends Node

static func fade_in(node: Control, duration: float = 0.3):
    node.modulate.a = 0.0
    var tween = node.create_tween()
    tween.tween_property(node, "modulate:a", 1.0, duration)

static func fade_out(node: Control, duration: float = 0.3):
    var tween = node.create_tween()
    tween.tween_property(node, "modulate:a", 0.0, duration)

static func slide_in(node: Control, direction: Vector2, duration: float = 0.3):
    var start_pos = node.position + direction * 100
    var end_pos = node.position
    
    node.position = start_pos
    var tween = node.create_tween()
    tween.tween_property(node, "position", end_pos, duration)

static func scale_in(node: Control, duration: float = 0.3):
    node.scale = Vector2.ZERO
    var tween = node.create_tween()
    tween.tween_property(node, "scale", Vector2.ONE, duration)
```

### Session 8: Integration and Testing (2-3 hours)

#### Step 1: Integrate All UI Components
```gdscript
# scenes/main_game.gd - Updated integration
func _ready():
    print("MainGame initialized")
    _setup_ui_components()
    _setup_ui_connections()
    _show_screen("main")

func _setup_ui_components():
    # Initialize all UI panels
    production_panel = preload("res://scenes/ui/production_panel.tscn").instantiate()
    sales_panel = preload("res://scenes/ui/sales_panel.tscn").instantiate()
    upgrade_panel = preload("res://scenes/ui/upgrade_panel.tscn").instantiate()
    settings_panel = preload("res://scenes/ui/settings_panel.tscn").instantiate()
    statistics_panel = preload("res://scenes/ui/statistics_panel.tscn").instantiate()
    
    # Add panels to scene
    add_child(production_panel)
    add_child(sales_panel)
    add_child(upgrade_panel)
    add_child(settings_panel)
    add_child(statistics_panel)
    
    # Setup responsive layout
    var responsive_layout = preload("res://scenes/ui/responsive_layout.tscn").instantiate()
    add_child(responsive_layout)
```

#### Step 2: Create UI Tests
```gdscript
# scripts/tests/ui_tests.gd
extends GutTest

func test_main_hud_money_display():
    var hud = preload("res://scenes/ui/main_hud.tscn").instantiate()
    add_child_autofree(hud)
    
    GameManager.player_money = 100.0
    hud._on_money_changed(100.0)
    
    assert_eq(hud.money_label.text, "$100.00")

func test_production_display_update():
    var production_display = preload("res://scenes/ui/production_display.tscn").instantiate()
    add_child_autofree(production_display)
    
    production_display.update_production(50, 100)
    assert_eq(production_display.production_label.text, "Hot Dogs: 50/100")

func test_settings_panel_volume_control():
    var settings_panel = preload("res://scenes/ui/settings_panel.tscn").instantiate()
    add_child_autofree(settings_panel)
    
    settings_panel._on_music_volume_changed(0.5)
    assert_eq(AudioManager.get_music_volume(), 0.5)
```

## Success Criteria Checklist

- [ ] Main game screen displays all core information
- [ ] Navigation between different screens works smoothly
- [ ] Production and sales displays show real-time data
- [ ] Settings panel allows configuration changes
- [ ] Notification system provides user feedback
- [ ] Statistics panel displays comprehensive game data
- [ ] UI is responsive and works on different screen sizes
- [ ] Animations provide smooth transitions
- [ ] All UI components integrate with game systems
- [ ] Comprehensive testing covers all UI functionality

## Risk Mitigation

1. **UI Complexity**: Use modular components and clear separation of concerns
2. **Performance Issues**: Implement efficient UI updates and animations
3. **Responsive Design**: Test on multiple screen sizes and orientations
4. **User Experience**: Conduct usability testing and gather feedback

## Next Steps

After completing the Core UI Screens:
1. Move to Game Balance system implementation
2. Integrate with advanced features like achievements
3. Add accessibility features and localization
4. Implement advanced UI features like themes and customization 