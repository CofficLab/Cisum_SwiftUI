# MagicPlayMan

Universal media playback engine for Cisum, supporting audio and video playback with rich controls and preview capabilities.

## Overview

MagicPlayMan provides a comprehensive media playback experience, including audio player, video player, and preview views with full playback controls.

## Architecture

```
MagicPlayMan/
├── Package.swift
├── Sources/
│   ├── Man.swift                    # Core playback manager
│   ├── Man+Initialize.swift         # Setup and initialization
│   ├── Man+PlayMode.swift           # Playback mode management
│   ├── Man+Controls.swift           # Playback control actions
│   ├── Man+Buttons.swift            # Button state management
│   ├── Man+Views.swift              # View generation
│   ├── Man+Load.swift               # Asset loading
│   ├── Man+Get.swift                # Data accessors
│   ├── Man+Subscription.swift       # Event subscriptions
│   ├── Man+Samples.swift            # Sample data
│   ├── Man+Remote.swift             # Remote control support
│   ├── ViewAudio/                   # Audio player views
│   ├── ViewVideo/                   # Video player views
│   ├── ViewPreview/                 # Media preview views
│   ├── View/                        # Shared UI components
│   ├── Models/                      # Data models
│   └── Events/                      # Playback events
└── Tests/
```

## Dependencies

- `MagicKit`
- `CisumUI`

## Features

- **Audio Playback**: Full-featured audio player with progress control
- **Video Playback**: Video player with overlay controls
- **Media Preview**: Preview media assets with playback capabilities
- **Play Modes**: Shuffle, repeat, and sequential play modes
- **Playback Controls**: Play, pause, next, previous, rewind, forward
- **Progress View**: Visual progress bar with seek support
- **Loading & Error States**: Overlay indicators for buffering and errors
- **Subscriber Management**: Track and display subscriber counts
- **Like Button**: Integrated like/favorite functionality
- **Remote Control**: System remote command center integration

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
