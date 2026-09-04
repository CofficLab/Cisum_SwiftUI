# BookPlayModePlugin

Book play mode configuration plugin for Cisum, managing shuffle, repeat, and sequential play modes for audiobooks.

## Overview

This plugin registers with ID `BookPlayModePlugin` and provides play mode configuration through the Cisum plugin system.

## Architecture

```
BookPlayModePlugin/
├── Package.swift
├── Sources/BookPlayModePlugin/
│   ├── BookPlayModePlugin.swift
│   ├── BookPlayModePluginInfo.swift
│   ├── BookPlayModeRootView.swift
│   └── BookPlayModeStore.swift
└── Tests/
```

## Features

- **Play Modes**: Shuffle, repeat, and sequential playback modes
- **Mode Store**: Persistent play mode preferences
- **Mode View**: Visual mode selection interface

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
