# Folder Structure Mapping - Complete File Organization

## Overview
This document provides the complete folder structure mapping for all files, scenes, resources, and custom files mentioned throughout the implementation plans across all 5 phases of the hot dog idle game project.

## Root Project Structure
```
hotdogprinter/
├── project.godot                    # Godot project file
├── icon.svg                         # Project icon
├── icon.svg.import                  # Icon import settings
│
├── scenes/                          # All game scenes
│   ├── ui/                          # UI scenes
│   ├── systems/                     # System scenes
│   └── components/                  # Reusable components
│
├── scripts/                         # All GDScript files
│   ├── autoload/                    # Autoload scripts
│   ├── scenes/                      # Scene-specific scripts
│   ├── data/                        # Data structures and resources
│   ├── utils/                       # Utility functions and base classes
│   └── tests/                       # Test scripts
│
├── assets/                          # All game assets
│   ├── ui/                          # UI assets
│   ├── fonts/                       # Font files
│   ├── sounds/                      # Audio files
│   └── sprites/                     # Image assets
│
├── tests/                           # Test files
│   ├── unit/                        # Unit tests
│   └── integration/                 # Integration tests
│
├── docs/                            # Documentation
│   ├── architecture/                # Architecture docs
│   ├── api/                         # API documentation
│   └── guides/                      # Development guides
│
└── resources/                       # Game resources
    ├── data/                        # Data resources
    ├── configs/                     # Configuration files
    └── themes/                      # UI themes
```

## Phase 1: Core Foundation

### Autoload Scripts
```
scripts/autoload/
├── game_manager.gd                  # Main game manager
├── event_manager.gd                 # Event system
├── save_manager.gd                  # Save/load system
└── ui_manager.gd                    # UI management
```

### Base Classes and Utilities
```
scripts/utils/
├── base_component.gd                # Base component class
├── base_scene.gd                    # Base scene class
└── resource_loader.gd               # Resource loading utilities
```

### Data Structures
```
scripts/data/
├── game_data.gd                     # Main game data class
├── save_data.gd                     # Save data structure
└── settings_data.gd                 # Settings data structure
```

### UI Components
```
scenes/components/
├── custom_button.tscn               # Custom button component
├── custom_button.gd                 # Custom button script
├── modal_dialog.tscn                # Modal dialog component
├── modal_dialog.gd                  # Modal dialog script
├── custom_panel.tscn                # Custom panel component
└── custom_panel.gd                  # Custom panel script
```

### UI Scenes
```
scenes/ui/
├── main_menu.tscn                   # Main menu scene
├── main_menu.gd                     # Main menu script
├── settings_panel.tscn              # Settings panel
├── settings_panel.gd                # Settings script
├── loading_screen.tscn              # Loading screen
└── loading_screen.gd                # Loading screen script
```

### System Scenes
```
scenes/systems/
├── game_system.tscn                 # Main game system
├── game_system.gd                   # Game system script
└── scene_transition.tscn            # Scene transition system
```

### Documentation
```
docs/
├── coding_standards.md              # Coding standards (already created)
├── architecture/
│   ├── overview.md                  # Architecture overview
│   ├── system_interactions.md       # System interaction docs
│   └── component_diagrams.md        # Component diagrams
├── api/
│   ├── autoload_api.md              # Autoload API documentation
│   └── data_api.md                  # Data API documentation
└── guides/
    ├── setup_instructions.md        # Development setup guide
    ├── development_workflow.md      # Development workflow
    └── debugging_procedures.md      # Debugging guide
```

## Phase 2: Core Gameplay

### Hot Dog Production System
```
scripts/systems/
├── hot_dog_production.gd            # Production system
└── production_manager.gd            # Production management

scenes/ui/
├── production_display.tscn          # Production UI
├── production_display.gd            # Production display script
├── production_controls.tscn         # Production controls
└── production_controls.gd           # Production controls script

resources/data/
├── production_data.tres             # Production data resource
└── production_balance.tres          # Production balance data
```

### Sales and Economy System
```
scripts/systems/
├── sales_system.gd                  # Sales system
├── economy_manager.gd               # Economy management
└── customer_manager.gd              # Customer management

scenes/ui/
├── sales_display.tscn               # Sales UI
├── sales_display.gd                 # Sales display script
├── economy_panel.tscn               # Economy panel
└── economy_panel.gd                 # Economy panel script

resources/data/
├── sales_data.tres                  # Sales data resource
├── economy_data.tres                # Economy data resource
└── customer_data.tres               # Customer data resource
```

### Upgrade System
```
scripts/systems/
├── upgrade_system.gd                # Upgrade system
├── upgrade_manager.gd               # Upgrade management
└── upgrade_balance.gd               # Upgrade balance

scenes/ui/
├── upgrade_panel.tscn               # Upgrade panel
├── upgrade_panel.gd                 # Upgrade panel script
├── upgrade_tree.tscn                # Upgrade tree
└── upgrade_tree.gd                  # Upgrade tree script

resources/data/
├── upgrade_data.tres                # Upgrade data resource
├── upgrade_balance.tres             # Upgrade balance data
└── upgrade_trees.tres               # Upgrade tree data
```

### Core UI Screens
```
scenes/ui/
├── game_screen.tscn                 # Main game screen
├── game_screen.gd                   # Game screen script
├── menu_screen.tscn                 # Menu screen
├── menu_screen.gd                   # Menu screen script
├── hud_screen.tscn                  # HUD screen
├── hud_screen.gd                    # HUD script
├── pause_screen.tscn                # Pause screen
└── pause_screen.gd                  # Pause screen script
```

### Game Balance
```
scripts/systems/
├── game_balance.gd                  # Game balance system
└── balance_manager.gd               # Balance management

resources/data/
├── game_balance.tres                # Game balance data
├── progression_data.tres            # Progression data
└── milestone_data.tres              # Milestone data
```

## Phase 3: Content Expansion

### Staff Management System
```
scripts/systems/
├── staff_manager.gd                 # Staff management system
├── staff_member.gd                  # Staff member class
├── training_manager.gd              # Training management
└── shift_manager.gd                 # Shift management

scenes/ui/
├── staff_management.tscn            # Staff management UI
├── staff_management.gd              # Staff management script
├── staff_hiring_panel.tscn          # Staff hiring panel
├── staff_hiring_panel.gd            # Staff hiring script
├── staff_training_panel.tscn        # Staff training panel
├── staff_training_panel.gd          # Staff training script
├── staff_schedule_panel.tscn        # Staff schedule panel
└── staff_schedule_panel.gd          # Staff schedule script

resources/data/
├── staff_member.tres                # Staff member resource
├── staff_types.tres                 # Staff type definitions
├── training_programs.tres           # Training program data
└── shift_schedules.tres             # Shift schedule data
```

### Multiple Locations
```
scripts/systems/
├── location_manager.gd              # Location management
├── game_location.gd                 # Location class
├── facility_manager.gd              # Facility management
└── transfer_manager.gd              # Transfer management

scenes/ui/
├── location_management.tscn         # Location management UI
├── location_management.gd           # Location management script
├── location_panel.tscn              # Location panel
├── location_panel.gd                # Location panel script
├── facility_panel.tscn              # Facility panel
├── facility_panel.gd                # Facility panel script
├── transfer_panel.tscn              # Transfer panel
└── transfer_panel.gd                # Transfer panel script

resources/data/
├── game_location.tres               # Location resource
├── location_types.tres              # Location type definitions
├── facility_types.tres              # Facility type definitions
└── transfer_data.tres               # Transfer data
```

### Advanced Upgrades and Research
```
scripts/systems/
├── research_manager.gd              # Research management
├── research_item.gd                 # Research item class
├── technology_manager.gd            # Technology management
└── research_balance.gd              # Research balance

scenes/ui/
├── research_panel.tscn              # Research panel
├── research_panel.gd                # Research panel script
├── technology_tree.tscn             # Technology tree
├── technology_tree.gd               # Technology tree script
├── research_queue.tscn              # Research queue
└── research_queue.gd                # Research queue script

resources/data/
├── research_item.tres               # Research item resource
├── research_projects.tres           # Research project data
├── technology_tree.tres             # Technology tree data
└── research_balance.tres            # Research balance data
```

### Events System
```
scripts/systems/
├── events_manager.gd                # Events management
├── game_event.gd                    # Event class
├── event_trigger.gd                 # Event trigger system
└── event_balance.gd                 # Event balance

scenes/ui/
├── events_panel.tscn                # Events panel
├── events_panel.gd                  # Events panel script
├── event_notification.tscn          # Event notification
├── event_notification.gd            # Event notification script
├── event_details.tscn               # Event details panel
└── event_details.gd                 # Event details script

resources/data/
├── game_event.tres                  # Event resource
├── event_types.tres                 # Event type definitions
├── event_triggers.tres              # Event trigger data
└── event_balance.tres               # Event balance data
```

### Enhanced Progression
```
scripts/systems/
├── progression_manager.gd           # Progression management
├── progression_milestone.gd         # Milestone class
├── achievement_manager.gd           # Achievement management
└── progression_balance.gd           # Progression balance

scenes/ui/
├── progression_panel.tscn           # Progression panel
├── progression_panel.gd             # Progression panel script
├── milestone_display.tscn           # Milestone display
├── milestone_display.gd             # Milestone display script
├── achievement_panel.tscn           # Achievement panel
└── achievement_panel.gd             # Achievement panel script

resources/data/
├── progression_milestone.tres       # Milestone resource
├── progression_data.tres            # Progression data
├── achievement_data.tres            # Achievement data
└── progression_balance.tres         # Progression balance data
```

## Phase 4: Polish & Optimization

### UI/UX Polish
```
scripts/systems/
├── enhanced_ui_manager.gd           # Enhanced UI management
├── animation_system.gd              # Animation system
├── accessibility_manager.gd         # Accessibility management
└── ui_performance_monitor.gd        # UI performance monitoring

scenes/ui/
├── polished_components.tscn         # Polished UI components
├── polished_components.gd           # Polished components script
├── responsive_layout.tscn           # Responsive layout
├── responsive_layout.gd             # Responsive layout script
├── accessibility_panel.tscn         # Accessibility panel
└── accessibility_panel.gd           # Accessibility panel script

resources/themes/
├── default_theme.tres               # Default UI theme
├── high_contrast_theme.tres         # High contrast theme
├── large_text_theme.tres            # Large text theme
└── colorblind_theme.tres            # Colorblind-friendly theme
```

### Performance Optimization
```
scripts/systems/
├── performance_monitor.gd           # Performance monitoring
├── memory_manager.gd                # Memory management
├── rendering_optimizer.gd           # Rendering optimization
└── performance_analytics.gd         # Performance analytics

scenes/systems/
├── performance_monitor.tscn         # Performance monitor UI
├── performance_monitor.gd           # Performance monitor script
├── memory_monitor.tscn              # Memory monitor UI
└── memory_monitor.gd                # Memory monitor script

resources/configs/
├── performance_settings.tres        # Performance settings
├── quality_presets.tres             # Quality presets
└── optimization_config.tres         # Optimization configuration
```

### Bug Fixes
```
scripts/systems/
├── bug_tracker.gd                   # Bug tracking system
├── automated_tester.gd              # Automated testing
├── regression_tester.gd             # Regression testing
└── error_logger.gd                  # Error logging

scenes/ui/
├── bug_report_panel.tscn            # Bug report panel
├── bug_report_panel.gd              # Bug report script
├── test_results_panel.tscn          # Test results panel
└── test_results_panel.gd            # Test results script

resources/data/
├── bug_reports.tres                 # Bug report data
├── test_cases.tres                  # Test case data
└── error_logs.tres                  # Error log data
```

### Visual Polish
```
scripts/systems/
├── visual_effects_manager.gd        # Visual effects management
├── animation_manager.gd             # Animation management
├── ui_polish_manager.gd             # UI polish management
└── feedback_system.gd               # Feedback system

scenes/ui/
├── visual_effects.tscn              # Visual effects scene
├── visual_effects.gd                # Visual effects script
├── animation_player.tscn            # Animation player
├── animation_player.gd              # Animation player script
├── feedback_panel.tscn              # Feedback panel
└── feedback_panel.gd                # Feedback panel script

assets/ui/
├── effects/                         # Visual effect assets
├── animations/                      # Animation assets
└── feedback/                        # Feedback assets
```

### Release Preparation
```
scripts/systems/
├── release_manager.gd               # Release management
├── quality_assurance_manager.gd     # QA management
├── distribution_manager.gd          # Distribution management
└── build_system.gd                  # Build system

scenes/ui/
├── release_panel.tscn               # Release panel
├── release_panel.gd                 # Release panel script
├── qa_panel.tscn                    # QA panel
├── qa_panel.gd                      # QA panel script
├── distribution_panel.tscn          # Distribution panel
└── distribution_panel.gd            # Distribution panel script

resources/configs/
├── release_config.tres              # Release configuration
├── build_settings.tres              # Build settings
└── distribution_config.tres         # Distribution configuration
```

## Phase 5: Advanced Features

### Analytics System
```
scripts/systems/
├── analytics_manager.gd             # Analytics management
├── player_behavior_tracker.gd       # Player behavior tracking
├── performance_analytics.gd         # Performance analytics
└── analytics_data.gd                # Analytics data structure

scenes/ui/
├── analytics_panel.tscn             # Analytics panel
├── analytics_panel.gd               # Analytics panel script
├── analytics_dashboard.tscn         # Analytics dashboard
└── analytics_dashboard.gd           # Analytics dashboard script

resources/data/
├── analytics_data.tres              # Analytics data resource
├── player_metrics.tres              # Player metrics data
└── performance_metrics.tres         # Performance metrics data
```

### Social Features
```
scripts/systems/
├── social_manager.gd                # Social features management
├── leaderboard_manager.gd           # Leaderboard management
├── achievement_manager.gd           # Achievement management
└── friend_manager.gd                # Friend management

scenes/ui/
├── social_panel.tscn                # Social panel
├── social_panel.gd                  # Social panel script
├── leaderboard_panel.tscn           # Leaderboard panel
├── leaderboard_panel.gd             # Leaderboard panel script
├── achievement_panel.tscn           # Achievement panel
├── achievement_panel.gd             # Achievement panel script
├── friend_panel.tscn                # Friend panel
└── friend_panel.gd                  # Friend panel script

resources/data/
├── social_data.tres                 # Social data resource
├── leaderboard_data.tres            # Leaderboard data
├── achievement_data.tres            # Achievement data
└── friend_data.tres                 # Friend data
```

### Advanced Progression
```
scripts/systems/
├── prestige_manager.gd              # Prestige management
├── skill_tree_manager.gd            # Skill tree management
├── advanced_upgrade_manager.gd      # Advanced upgrade management
└── progression_balance.gd           # Advanced progression balance

scenes/ui/
├── prestige_panel.tscn              # Prestige panel
├── prestige_panel.gd                # Prestige panel script
├── skill_tree_panel.tscn            # Skill tree panel
├── skill_tree_panel.gd              # Skill tree panel script
├── advanced_upgrade_panel.tscn      # Advanced upgrade panel
└── advanced_upgrade_panel.gd        # Advanced upgrade panel script

resources/data/
├── prestige_data.tres               # Prestige data resource
├── skill_tree_data.tres             # Skill tree data
├── advanced_upgrade_data.tres       # Advanced upgrade data
└── progression_balance.tres         # Progression balance data
```

### Customization
```
scripts/systems/
├── customization_manager.gd         # Customization management
├── visual_customization_manager.gd  # Visual customization
├── ui_theme_manager.gd              # UI theme management
└── preference_manager.gd            # Preference management

scenes/ui/
├── customization_panel.tscn         # Customization panel
├── customization_panel.gd           # Customization panel script
├── theme_panel.tscn                 # Theme panel
├── theme_panel.gd                   # Theme panel script
├── preference_panel.tscn            # Preference panel
└── preference_panel.gd              # Preference panel script

resources/themes/
├── custom_themes/                   # Custom theme directory
├── hot_dog_styles.tres              # Hot dog style data
├── stand_designs.tres               # Stand design data
└── ui_themes.tres                   # UI theme data
```

### Engagement Features
```
scripts/systems/
├── engagement_manager.gd            # Engagement management
├── challenge_manager.gd             # Challenge management
├── event_manager.gd                 # Event management
└── engagement_balance.gd            # Engagement balance

scenes/ui/
├── engagement_panel.tscn            # Engagement panel
├── engagement_panel.gd              # Engagement panel script
├── challenge_panel.tscn             # Challenge panel
├── challenge_panel.gd               # Challenge panel script
├── daily_rewards_panel.tscn         # Daily rewards panel
├── daily_rewards_panel.gd           # Daily rewards panel script
├── event_panel.tscn                 # Event panel
└── event_panel.gd                   # Event panel script

resources/data/
├── engagement_data.tres             # Engagement data resource
├── challenge_data.tres              # Challenge data
├── daily_rewards_data.tres          # Daily rewards data
├── event_data.tres                  # Event data
└── engagement_balance.tres          # Engagement balance data
```

## Test Files

### Unit Tests
```
tests/unit/
├── test_game_manager.gd             # Game manager tests
├── test_save_manager.gd             # Save manager tests
├── test_production_system.gd        # Production system tests
├── test_sales_system.gd             # Sales system tests
├── test_staff_manager.gd            # Staff manager tests
├── test_upgrade_system.gd           # Upgrade system tests
├── test_analytics.gd                # Analytics tests
└── test_performance.gd              # Performance tests
```

### Integration Tests
```
tests/integration/
├── test_system_integration.gd       # System integration tests
├── test_ui_integration.gd           # UI integration tests
├── test_data_integration.gd         # Data integration tests
├── test_save_load_integration.gd    # Save/load integration tests
└── test_performance_integration.gd  # Performance integration tests
```

## Asset Files

### UI Assets
```
assets/ui/
├── buttons/                         # Button sprites
├── panels/                          # Panel backgrounds
├── icons/                           # UI icons
├── backgrounds/                     # Background images
└── effects/                         # UI effect assets
```

### Fonts
```
assets/fonts/
├── main_font.ttf                    # Main game font
├── ui_font.ttf                      # UI font
├── title_font.ttf                   # Title font
└── number_font.ttf                  # Number display font
```

### Sounds
```
assets/sounds/
├── ui/                              # UI sounds
│   ├── button_click.wav             # Button click sound
│   ├── menu_select.wav              # Menu selection sound
│   └── notification.wav             # Notification sound
├── game/                            # Game sounds
│   ├── production.wav               # Production sound
│   ├── sale.wav                     # Sale sound
│   └── upgrade.wav                  # Upgrade sound
└── music/                           # Background music
    ├── main_theme.ogg               # Main theme music
    ├── menu_music.ogg               # Menu music
    └── gameplay_music.ogg           # Gameplay music
```

### Sprites
```
assets/sprites/
├── hot_dogs/                        # Hot dog sprites
├── stands/                          # Stand sprites
├── staff/                           # Staff sprites
├── locations/                       # Location sprites
├── upgrades/                        # Upgrade sprites
├── effects/                         # Visual effect sprites
└── ui_elements/                     # UI element sprites
```

## Configuration Files

### Project Configuration
```
.editorconfig                        # Editor configuration
.gitignore                           # Git ignore file
README.md                            # Project readme
CHANGELOG.md                         # Change log
LICENSE                              # Project license
```

### Build Configuration
```
export_presets.cfg                   # Export presets
build_config.json                    # Build configuration
deployment_config.json               # Deployment configuration
```

## Summary

This folder structure provides a comprehensive organization for all files mentioned throughout the implementation plans. The structure follows Godot best practices and maintains clear separation of concerns:

- **scenes/**: All game scenes organized by type
- **scripts/**: All GDScript files organized by functionality
- **assets/**: All game assets organized by type
- **tests/**: All test files organized by test type
- **docs/**: All documentation organized by purpose
- **resources/**: All game resources organized by type

Each phase builds upon this structure, adding new systems and features while maintaining the established organization patterns. 