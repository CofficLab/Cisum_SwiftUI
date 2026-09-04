# AudioPlayModePlugin

Audio play mode configuration plugin for Cisum, managing shuffle, repeat, and sequential play modes.

## Overview

This plugin registers with ID `AudioPlayModePlugin` and provides play mode configuration through the Cisum plugin system.

## Architecture

```
AudioPlayModePlugin/
├── Package.swift
├── Sources/AudioPlayModePlugin/
│   ├── AudioPlayModePlugin.swift
│   ├── AudioPlayModePluginInfo.swift
│   ├── AudioPlayModeRootView.swift
│   └── AudioPlayModeStore.swift
└── Tests/
```

## Features

- **Play Modes**: Shuffle, repeat, and sequential playback modes
- **Mode Store**: Persistent play mode preferences
- **Mode View**: Visual mode selection interface

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
