# AudioProgressPlugin

Audio playback progress tracking plugin for Cisum, providing progress display and state management.

## Overview

This plugin registers with ID `AudioProgressPlugin` and provides playback progress tracking through the Cisum plugin system.

## Architecture

```
AudioProgressPlugin/
├── Package.swift
├── Sources/AudioProgressPlugin/
│   ├── AudioProgressPlugin.swift
│   ├── AudioProgressPluginInfo.swift
│   ├── AudioProgressHost.swift
│   ├── AudioProgressRootView.swift
│   └── AudioStateRepo.swift
└── Tests/
```

## Features

- **Progress Display**: Visual playback progress indicator
- **State Management**: Track and persist playback state
- **State Repository**: Centralized playback state storage

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
