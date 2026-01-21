# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cisum is a clean, ad-free audio player application for macOS and iOS, built with SwiftUI. It follows a plugin-based architecture with strong separation of concerns.

**Key Philosophy**: Simple, minimal, anti-bloatware design - no splash screen ads, no shake-to-navigate, no endless popups.

## Build & Development Commands

### Building
```bash
# Build for development
xcodebuild -scheme Cisum -configuration Debug build

# Build for release
xcodebuild -scheme Cisum -configuration Release build

# Build for specific platform
xcodebuild -scheme Cisum -destination 'platform=iOS Simulator,name=iPhone 16' build

# Clean build
xcodebuild clean -scheme Cisum
```

### Development
- Open `Cisum.xcodeproj` in Xcode
- The app supports both macOS and iOS with conditional compilation
- Use Xcode Previews (`.preview` macros) for UI development

## Architecture

### Plugin System (Core Pattern)

The application uses a sophisticated **plugin-based architecture** where all functionality is modularized into plugins.

**Plugin Protocol** (`Core/Contract/SuperPlugin.swift`):
- All plugins conform to `SuperPlugin` protocol (actors)
- Auto-discovery via Objective-C runtime scanning
- Order-based execution via `static var order`
- Plugins can provide:
  - Scenes (via `addSceneItem()`) - e.g., "音乐库", "书籍库"
  - Root view wrappers (via `addRootView()`) - chain-like wrapping system
  - Sheets, posters, toolbars, status views
  - Settings and tab views

**Plugin Locations**: All plugins are in `Plugins/` directory with consistent naming:
- `Audio-Scene/` - Provides music library scene
- `Audio-*/` - Audio-related features (play, download, like, progress, etc.)
- `Book-Scene/` - Provides book library scene
- `Book-*/` - Book-related features
- `Storage/`, `Store/`, `Welcome/` - System features

### Data Flow

**MVVM + Combine**:
- ViewModels use `@ObservableObject` (SwiftUI) or `@Model` (SwiftData)
- Combine framework for reactive programming
- Event-driven architecture via NotificationCenter

**State Management**:
- `StateProvider` - Global state management
- `PluginProvider` - Plugin registration and lifecycle
- `CloudProvider` - iCloud sync

**Persistence**:
- SwiftData for local data storage
- iCloud Documents for cloud sync
- Storage abstraction: local, iCloud, or custom locations

### Key Architectural Decisions

1. **Scene Management**: Dynamic scene provision by plugins. Last active scene is restored on launch.
2. **View Wrapping**: Plugins wrap root views in a chain: `Plugin1(Plugin2(Plugin3(OriginalContent)))`
3. **Actor-Based Concurrency**: All plugins are actors for thread safety
4. **Protocol-Oriented Design**: Heavy use of protocols for loose coupling

### Directory Structure

```
Cisum_SwiftUI/
├── Core/                      # Core framework
│   ├── Bootstrap/            # App initialization (BootApp.swift, Config.swift)
│   ├── Contract/             # Protocols (SuperPlugin.swift)
│   ├── Providers/            # Service providers
│   ├── Events/               # Event definitions
│   ├── Models/               # Data models
│   └── Views/Layout/         # Main UI components
├── Plugins/                  # Feature plugins (32+ plugins)
│   ├── Audio-*/              # Audio functionality
│   ├── Book-*/               # E-book functionality
│   └── [System plugins]      # Storage, Store, Welcome, etc.
└── AppStore/                 # App Store assets
```

## Configuration

**Config.swift** (`Core/Bootstrap/Config.swift`):
- `Config.debug` - Debug mode flag
- `Config.supportedExtensions` - Audio file extensions (mp3, m4a, flac, wav)
- `Config.maxAudioCount` - Maximum audio files (100)
- Storage location management (iCloud/local/custom)
- Window size configurations
- Platform detection (`isDesktop`, `isiOS`)

**Important**: NSMetadataUbiquitousItemPercentDownloadedKey returns 0-100 range, not 0-1.

## Dependencies

Key frameworks and libraries:
- **MagicKit** (1.2.7) - Core utilities by CofficLab
- **MagicPlayMan** - Audio playback management
- **MagicUI** - UI components
- **MagicAlert** - Alert system
- **SwiftData** - Data persistence
- **Combine** - Reactive programming
- **ZIPFoundation** - File compression

## Development Guidelines (from .cursorrules)

### Language & Framework
- Use latest Swift and SwiftUI
- Follow Apple Human Interface Guidelines
- Use Combine for reactive programming
- Use SwiftData for local storage
- Implement adaptive layouts for different devices
- Type-safe code with strict type checking

### Code Quality
- Add detailed code comments
- Implement proper error handling and logging (use `OSLog`)
- Manage memory properly to avoid leaks
- Write Chinese comments for user-facing features

### Problem Solving
- Read all related code files before making changes
- Analyze root cause of errors
- Discuss solutions with user before implementing
- Use concise language to explain concepts

### Plugin Development
When creating new plugins:
1. Create plugin directory in `Plugins/`
2. Implement `SuperPlugin` protocol (actor)
3. Set `static var order` for execution order
4. Implement relevant view methods (`addRootView`, `addSceneItem`, etc.)
5. Plugin will be auto-discovered at runtime

## Language Preference

The codebase uses Chinese for user-facing strings and comments. Use Chinese when working with UI text, error messages, and documentation that users will see.
