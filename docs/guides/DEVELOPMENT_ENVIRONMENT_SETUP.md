# Development Environment Setup Guide

## Overview
This document provides comprehensive setup instructions for the Hot Dog Printer game development environment, including tools, workflows, and guidelines for background agents to work effectively with Godot 4.4.

## Required Tools and Software

### Core Development Tools
- **Godot 4.4.x** (Latest stable version)
  - Download from: https://godotengine.org/download
  - Install with .NET support for C# development (optional but recommended)
  - Verify installation: `godot --version`

- **Git** (Version control)
  - Windows: https://git-scm.com/download/win
  - Verify installation: `git --version`

- **Visual Studio Code** (Recommended IDE)
  - Download from: https://code.visualstudio.com/
  - Required extensions:
    - Godot Tools (official Godot extension)
    - GDScript (syntax highlighting)
    - GitLens (enhanced Git integration)
    - Auto Rename Tag (for UI development)
    - Bracket Pair Colorizer
    - Error Lens (error highlighting)

### Additional Tools
- **GitHub Desktop** (Optional - for easier Git management)
- **7-Zip** (For asset compression and management)
- **GIMP/Photoshop** (For image editing and asset creation)
- **Audacity** (For audio editing)

## Project Structure and Workflows

### Repository Structure
```
hotdogprinter/
├── .godot/                    # Godot cache and settings
├── assets/                    # Game assets
│   ├── sprites/              # 2D graphics
│   ├── audio/                # Sound effects and music
│   ├── fonts/                # Custom fonts
│   └── ui/                   # UI elements and themes
├── scenes/                    # Godot scene files
│   ├── ui/                   # UI scenes
│   ├── game/                 # Game logic scenes
│   └── systems/              # System manager scenes
├── scripts/                   # GDScript files
│   ├── autoload/             # Global singletons
│   ├── ui/                   # UI scripts
│   ├── game/                 # Game logic scripts
│   └── systems/              # System manager scripts
├── resources/                 # Resource files
│   ├── data/                 # Game data and configurations
│   ├── themes/               # UI themes
│   └── materials/            # Shader materials
├── tests/                     # Test files
│   ├── unit/                 # Unit tests
│   └── integration/          # Integration tests
└── docs/                      # Documentation
```

### Background Agent Workflows

#### 1. Godot Project Management
**Workflow for creating new scenes:**
```bash
# 1. Open Godot and load the project
godot --path "C:\Users\pleas\Documents\My Games\hotdogprinter"

# 2. Create new scene from template
# Use File -> New Scene -> Choose template (Node, Control, etc.)

# 3. Save scene with proper naming convention
# File -> Save Scene As -> scenes/[category]/[scene_name].tscn

# 4. Attach script if needed
# Right-click node -> Attach Script -> scripts/[category]/[script_name].gd
```

**Workflow for script development:**
```bash
# 1. Create script file following naming conventions
# scripts/[category]/[class_name].gd

# 2. Use proper class structure:
extends [ParentClass]
class_name [ClassName]

# 3. Follow coding standards from CODING_STANDARDS.md
# 4. Add proper documentation and type hints
```

#### 2. Asset Management
**Workflow for adding new assets:**
```bash
# 1. Place assets in appropriate folders:
# - Sprites: assets/sprites/[category]/
# - Audio: assets/audio/[category]/
# - Fonts: assets/fonts/
# - UI: assets/ui/[category]/

# 2. Import settings in Godot:
# - Select asset in FileSystem
# - Configure import settings in Inspector
# - Set compression and optimization options

# 3. Reference in code using proper paths:
# "res://assets/sprites/[category]/[asset_name].png"
```

#### 3. Testing Workflows
**Unit Testing Setup:**
```bash
# 1. Install GUT (Godot Unit Test) plugin
# Project -> Project Settings -> Plugins -> Add GUT

# 2. Create test files in tests/unit/
# tests/unit/test_[class_name].gd

# 3. Run tests:
# Scene -> Run Tests or use GUT panel
```

**Integration Testing:**
```bash
# 1. Create integration test scenes
# tests/integration/test_[feature].tscn

# 2. Write test scripts
# tests/integration/test_[feature].gd

# 3. Run integration tests
# Use GUT or custom test runner
```

#### 4. Version Control Workflows
**Daily Development Workflow:**
```bash
# 1. Pull latest changes
git pull origin main

# 2. Create feature branch
git checkout -b feature/[feature-name]

# 3. Make changes and test
# Work in Godot, test thoroughly

# 4. Commit changes
git add .
git commit -m "feat: [description of changes]"

# 5. Push to remote
git push origin feature/[feature-name]

# 6. Create pull request on GitHub
```

**Release Workflow:**
```bash
# 1. Merge feature branches to main
git checkout main
git merge feature/[feature-name]

# 2. Create release tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# 3. Export game builds
# Project -> Export -> Configure platforms
```

## Godot-Specific Guidelines for Background Agents

### Scene Organization
- **Use proper node hierarchy**: Follow Godot's scene tree structure
- **Group related nodes**: Use Node groups for organization
- **Use signals for communication**: Avoid direct node references when possible
- **Implement proper scene inheritance**: Create base scenes for common elements

### Script Organization
- **Follow GDScript best practices**: Use type hints, proper naming conventions
- **Implement autoloads correctly**: Global singletons for managers
- **Use resources for data**: Store game data in Resource files
- **Implement proper error handling**: Use assert() and error checking

### Performance Guidelines
- **Optimize node usage**: Minimize node count in complex scenes
- **Use object pooling**: For frequently created/destroyed objects
- **Implement proper cleanup**: Disconnect signals, free resources
- **Monitor performance**: Use Godot's profiler tools

### UI Development
- **Use Control nodes**: For all UI elements
- **Implement responsive design**: Use anchors and containers
- **Follow theme system**: Create and use UI themes consistently
- **Test on different resolutions**: Ensure UI works on various screen sizes

## Development Phases and Milestones

### Phase 1: Core Foundation
**Tools needed:**
- Godot 4.4
- Git
- VS Code with Godot Tools extension

**Key workflows:**
- Project structure setup
- Autoload configuration
- Basic scene creation
- Script organization

### Phase 2: Core Gameplay
**Additional tools:**
- Asset creation tools (GIMP/Photoshop)
- Audio editing tools (Audacity)

**Key workflows:**
- Game system implementation
- UI development
- Asset integration
- Testing and debugging

### Phase 3: Content Expansion
**Tools needed:**
- Advanced asset creation tools
- Performance monitoring tools

**Key workflows:**
- Content creation pipeline
- Performance optimization
- Advanced testing
- Content management

### Phase 4: Polish & Optimization
**Tools needed:**
- Profiling tools
- Build automation tools

**Key workflows:**
- Performance profiling
- Bug fixing
- Visual polish
- Release preparation

### Phase 5: Advanced Features
**Tools needed:**
- Analytics tools
- Social platform integration tools

**Key workflows:**
- Analytics implementation
- Social feature integration
- Advanced progression systems
- Engagement optimization

## Quality Assurance

### Code Quality
- **Follow coding standards**: Use established conventions
- **Write tests**: Unit and integration tests for all features
- **Code review**: Peer review for all changes
- **Documentation**: Keep documentation updated

### Testing Strategy
- **Unit tests**: Test individual functions and classes
- **Integration tests**: Test system interactions
- **Performance tests**: Monitor frame rate and memory usage
- **User acceptance tests**: Test complete user workflows

### Build and Deployment
- **Automated builds**: Set up CI/CD pipeline
- **Platform testing**: Test on target platforms
- **Performance monitoring**: Track performance metrics
- **User feedback**: Collect and analyze user feedback

## Troubleshooting

### Common Issues
1. **Godot project not loading**: Check .godot folder and project.godot file
2. **Script errors**: Verify syntax and check error console
3. **Asset import issues**: Check import settings and file formats
4. **Performance problems**: Use profiler to identify bottlenecks
5. **Git conflicts**: Resolve merge conflicts carefully

### Support Resources
- **Godot Documentation**: https://docs.godotengine.org/
- **Godot Forums**: https://forum.godotengine.org/
- **GitHub Issues**: Project-specific issues and discussions
- **Community Discord**: For real-time support and collaboration

## Next Steps

1. **Install all required tools** following the guidelines above
2. **Set up the project structure** as outlined
3. **Configure development environment** with proper settings
4. **Begin Phase 1 implementation** following the established workflows
5. **Set up testing infrastructure** for quality assurance
6. **Establish CI/CD pipeline** for automated builds and testing

This setup guide ensures that background agents can work effectively with real Godot while maintaining code quality, performance, and project organization standards. 