# Coding Standards and Naming Conventions

## Overview
This document defines the coding standards and naming conventions for the hot dog idle game project, ensuring consistency and maintainability across all code.

## Naming Conventions

### Classes
- **PascalCase** for all class names
- Use descriptive names that indicate the class purpose
- Examples: `HotDogProduction`, `SalesSystem`, `StaffManager`

### Variables
- **snake_case** for all variable names
- Use descriptive names that clearly indicate the variable's purpose
- Examples: `player_money`, `production_rate`, `staff_members`

### Constants
- **UPPER_SNAKE_CASE** for all constants
- Use descriptive names that clearly indicate the constant's purpose
- Examples: `MAX_PRODUCTION_CAPACITY`, `AUTO_SAVE_INTERVAL`, `DEFAULT_HOT_DOG_PRICE`

### Functions
- **snake_case** for all function names
- Use descriptive names that clearly indicate the function's purpose
- Examples: `calculate_production_rate()`, `update_sales_data()`, `hire_staff_member()`

### Signals
- **snake_case** for all signal names
- Use descriptive names that clearly indicate when the signal is emitted
- Examples: `production_updated`, `money_changed`, `staff_hired`

### Files and Directories
- **snake_case** for all file and directory names
- Use descriptive names that clearly indicate the content
- Examples: `hot_dog_production.gd`, `sales_system.gd`, `staff_manager.gd`

## Code Structure

### Class Organization
```gdscript
# 1. Class declaration and inheritance
class_name HotDogProduction
extends Node

# 2. Constants
const DEFAULT_PRODUCTION_RATE = 1.0
const MAX_CAPACITY = 100

# 3. Exported variables (@export)
@export var production_rate: float = DEFAULT_PRODUCTION_RATE
@export var max_capacity: int = MAX_CAPACITY
@export_group("Performance Settings")
@export var update_interval: float = 0.1

# 4. Signals
signal production_updated(current_amount: int, max_capacity: int)
signal production_rate_changed(new_rate: float)

# 5. Private variables
var _current_production: int = 0
var _update_timer: float = 0.0

# 6. Built-in functions
func _ready():
    _initialize_system()

func _process(delta: float):
    _update_production(delta)

func _exit_tree():
    _cleanup_system()

# 7. Public functions
func start_production():
    # Implementation

func stop_production():
    # Implementation

# 8. Private functions
func _initialize_system():
    # Implementation

func _update_production(delta: float):
    # Implementation

func _cleanup_system():
    # Implementation
```

### Function Documentation
```gdscript
## Starts the hot dog production process
## 
## This function initializes the production timer and begins
## generating hot dogs at the current production rate.
## 
## Returns:
##   bool: True if production was successfully started, false otherwise
func start_production() -> bool:
    # Implementation
```

### Signal Documentation
```gdscript
## Emitted when the production amount changes
## 
## Parameters:
##   current_amount: int - The current number of hot dogs produced
##   max_capacity: int - The maximum production capacity
signal production_updated(current_amount: int, max_capacity: int)
```

## Godot 4.4 Best Practices

### Signal Management
- Always disconnect signals in `_exit_tree()` to prevent memory leaks
- Use typed signals when possible for better type safety
- Document all signals with clear parameter descriptions

```gdscript
func _exit_tree():
    _cleanup_system()

func _cleanup_system():
    # Disconnect all signals to prevent memory leaks
    if production_updated.is_connected(_on_production_updated):
        production_updated.disconnect(_on_production_updated)
```

### Resource Management
- Implement `_notification()` methods for proper resource cleanup
- Use `NOTIFICATION_PREDELETE` for cleanup before deletion
- Ensure proper resource disposal and memory management

```gdscript
func _notification(what: int):
    if what == NOTIFICATION_PREDELETE:
        _cleanup_resources()

func _cleanup_resources():
    # Clean up resources before deletion
    data.clear()
```

### Inspector Integration
- Use `@export` annotations for all configurable properties
- Use `@export_group` for better organization in inspector
- Use `@export_enum` for type-safe selections

```gdscript
@export var production_rate: float = 1.0
@export_enum("Low", "Medium", "High") var quality_level: int = 1
@export_group("Performance Settings")
@export var update_interval: float = 0.1
```

### Performance Optimization
- Use `@onready` for better performance in node initialization
- Implement update throttling with delta time
- Add performance monitoring from the start

```gdscript
@onready var production_timer: Timer = $ProductionTimer

var update_timer: float = 0.0
var update_interval: float = 0.1

func _process(delta: float):
    update_timer += delta
    if update_timer >= update_interval:
        _update_system(update_timer)
        update_timer = 0.0
```

## Error Handling

### Assertions
- Use assertions for debugging and development
- Remove assertions in production builds
- Provide clear error messages

```gdscript
func set_production_rate(rate: float):
    assert(rate >= 0.0, "Production rate must be non-negative")
    production_rate = rate
```

### Error Logging
- Use `push_error()` for critical errors
- Use `push_warning()` for warnings
- Use `print()` for debug information (remove in production)

```gdscript
func load_save_data() -> bool:
    if not FileAccess.file_exists(save_path):
        push_error("Save file not found: " + save_path)
        return false
    return true
```

## Testing Standards

### Unit Tests
- Write unit tests for all public functions
- Use descriptive test names
- Test both success and failure cases

```gdscript
extends GutTest

func test_production_rate_setting():
    var production = HotDogProduction.new()
    add_child_autofree(production)
    
    production.set_production_rate(2.0)
    assert_eq(production.production_rate, 2.0)
```

### Integration Tests
- Test system interactions
- Test signal connections
- Test resource management

```gdscript
func test_production_signal_emission():
    var production = HotDogProduction.new()
    add_child_autofree(production)
    
    var signal_emitted = false
    production.production_updated.connect(func(): signal_emitted = true)
    
    production.start_production()
    await get_tree().process_frame
    
    assert_true(signal_emitted)
```

## Code Comments

### Inline Comments
- Use comments to explain complex logic
- Keep comments up to date with code changes
- Use clear and concise language

```gdscript
# Calculate production bonus based on staff efficiency
var efficiency_bonus = staff_efficiency * 0.1
production_rate *= (1.0 + efficiency_bonus)
```

### Block Comments
- Use block comments for complex algorithms
- Explain the purpose and approach
- Include examples when helpful

```gdscript
# Production rate calculation algorithm:
# 1. Start with base production rate
# 2. Apply staff efficiency bonus
# 3. Apply upgrade multipliers
# 4. Apply quality modifiers
# 5. Ensure rate doesn't exceed maximum capacity
```

## File Organization

### Script Files
- One class per file
- File name matches class name (snake_case)
- Place in appropriate directory based on functionality

### Directory Structure
```
scripts/
├── autoload/          # Autoload scripts
├── scenes/           # Scene-specific scripts
├── data/             # Data structures and resources
├── utils/            # Utility functions and base classes
└── tests/            # Test scripts
```

## Version Control

### Commit Messages
- Use clear and descriptive commit messages
- Start with a verb in present tense
- Include scope and description

Examples:
- `feat: add hot dog production system`
- `fix: resolve memory leak in signal connections`
- `docs: update coding standards documentation`

### Branch Naming
- Use descriptive branch names
- Include feature or fix identifier
- Use kebab-case

Examples:
- `feature/hot-dog-production`
- `fix/memory-leak-cleanup`
- `docs/coding-standards`

## Conclusion

These coding standards ensure consistency, maintainability, and alignment with Godot 4.4 best practices. All developers should follow these standards to maintain code quality and facilitate collaboration. 