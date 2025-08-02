# Hot Dog Idle Game

A comprehensive idle/incremental game where players manage and expand their hot dog stand business empire.

## 🎮 Game Overview

Players start with a simple hot dog stand and gradually expand their business through:
- **Production Management**: Produce and sell hot dogs to earn money
- **Business Expansion**: Upgrade equipment, hire staff, and open new locations
- **Strategic Growth**: Research new technologies and optimize operations
- **Progression Systems**: Unlock achievements, prestige mechanics, and advanced features

## 🚀 Development Status

This project is currently in the **planning and architecture phase**. The development is organized into 5 comprehensive phases:

### Phase 1: Core Foundation ✅
- [x] Project architecture and coding standards
- [x] Godot 4.4 best practices alignment
- [x] Folder structure and organization
- [x] Version control workflow
- [ ] Development environment setup
- [ ] Basic game loop implementation
- [ ] Save/load system foundation

### Phase 2: Core Gameplay (Planned)
- [ ] Hot dog production and sales mechanics
- [ ] Basic upgrades and progression
- [ ] User interface and feedback systems
- [ ] Game balance and economy

### Phase 3: Content Expansion (Planned)
- [ ] Staff management system
- [ ] Multiple locations and expansion
- [ ] Advanced upgrades and research
- [ ] Events and enhanced progression

### Phase 4: Polish & Optimization (Planned)
- [ ] UI/UX improvements and accessibility
- [ ] Performance optimization
- [ ] Bug fixes and balancing
- [ ] Visual polish and effects

### Phase 5: Advanced Features (Planned)
- [ ] Analytics and player behavior tracking
- [ ] Social features and leaderboards
- [ ] Advanced progression systems
- [ ] Customization and engagement features

## 🛠️ Technology Stack

- **Game Engine**: Godot 4.4
- **Scripting Language**: GDScript
- **Version Control**: Git with GitHub
- **Testing Framework**: GUT (Godot Unit Test)
- **Documentation**: Markdown

## 📁 Project Structure

```
hotdogprinter/
├── scenes/           # Game scenes (UI, systems, components)
├── scripts/          # GDScript files (autoload, systems, utils)
├── assets/           # Game assets (UI, fonts, sounds, sprites)
├── tests/            # Test files (unit, integration)
├── docs/             # Documentation (architecture, API, guides)
├── resources/        # Game resources (data, configs, themes)
└── Project Plan/     # Phase-specific implementation plans
```

## 🚀 Getting Started

### Prerequisites

- **Godot 4.4** or later
- **Git** for version control
- **GitHub account** for repository access

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/hotdogprinter.git
   cd hotdogprinter
   ```

2. **Open in Godot**
   - Launch Godot 4.4
   - Click "Import" and select the project folder
   - Click "Import & Edit"

3. **Set up development environment**
   - Install recommended extensions (see Development Guide)
   - Configure editor settings
   - Set up testing framework

### Development Setup

1. **Install GUT testing framework**
   - Download GUT from the Asset Library
   - Add to project as a plugin

2. **Configure autoloads**
   - GameManager
   - EventManager
   - SaveManager
   - UIManager

3. **Set up folder structure**
   - Create all planned directories
   - Organize files according to the folder structure mapping

## 📚 Documentation

All documentation is organized in the `docs/` folder:

### 📁 Architecture Documentation (`docs/architecture/`)
- **[Folder Structure](docs/architecture/folder_structure_mapping.md)**: Complete file organization
- **[Godot 4.4 Review](docs/architecture/godot_4.4_architecture_review.md)**: Best practices alignment
- **[Project Structure](docs/architecture/project_structure.md)**: High-level architecture overview

### 📁 Development Guides (`docs/guides/`)
- **[Coding Standards](docs/guides/coding_standards.md)**: Code conventions and best practices
- **[Development Setup](docs/guides/development_environment_setup.md)**: Environment setup guide
- **[Project Plan](docs/guides/README.md)**: Complete development planning

### 📁 API Documentation (`docs/api/`)
- *Coming soon: System and component APIs*

### Quick Start
1. Review `docs/guides/development_environment_setup.md` for setup instructions
2. Check `docs/guides/coding_standards.md` for development guidelines
3. Understand the project structure in `docs/architecture/folder_structure_mapping.md`

## 🧪 Testing

The project uses GUT (Godot Unit Test) framework for comprehensive testing:

```bash
# Run all tests
gut --dir=res://tests/

# Run specific test file
gut --unit-test-file=res://tests/unit/test_game_manager.gd
```

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Follow coding standards**
   - Use established naming conventions
   - Follow Godot 4.4 best practices
   - Write comprehensive tests
4. **Commit your changes**
   ```bash
   git commit -m "feat: add your feature description"
   ```
5. **Push to your branch**
   ```bash
   git push origin feature/your-feature-name
   ```
6. **Create a Pull Request**

## 📋 Development Workflow

1. **Planning**: Follow the comprehensive project plan
2. **Implementation**: Use established architecture and standards
3. **Testing**: Write tests for all new features
4. **Documentation**: Update relevant documentation
5. **Review**: Code review and quality assurance
6. **Integration**: Merge and deploy

## 🎯 Current Focus

The project is currently focused on:
- ✅ **Architecture Planning**: Complete project structure and standards
- ✅ **Godot 4.4 Alignment**: Best practices and modern features
- ✅ **Documentation**: Comprehensive planning and guidelines
- 🔄 **Development Setup**: Environment configuration and tooling

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Godot Engine** community for the excellent game engine
- **GUT Framework** for comprehensive testing capabilities
- **Open source contributors** for inspiration and best practices

## 📞 Support

For questions, issues, or contributions:
- **Issues**: [GitHub Issues](https://github.com/yourusername/hotdogprinter/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/hotdogprinter/discussions)
- **Documentation**: Check the [docs/](docs/) folder for comprehensive documentation

---

**Happy coding! 🎮** 