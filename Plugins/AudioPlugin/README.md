# AudioPlugin

Core audio management plugin for Cisum, providing the central audio library with database, models, events, and repository layers.

## Overview

This plugin registers with ID `AudioPlugin` and provides the core audio library functionality through the Cisum plugin system. It serves as the foundation for other audio-related plugins.

## Architecture

```
AudioPlugin/
├── Package.swift
├── Sources/AudioPlugin/
│   ├── AudioPlugin.swift
│   ├── AudioPluginHost.swift
│   ├── AudioPluginInfo.swift
│   ├── AudioPluginError.swift
│   ├── AudioRootView.swift
│   ├── AudioModel.swift
│   ├── AudioDB.swift
│   ├── AudioRepo.swift
│   ├── AudioConfigRepo.swift
│   ├── AudioEvent.swift
│   └── ...
└── Tests/
```

## Features

- **Audio Library**: Core audio content management
- **Database Layer**: Persistent storage for audio metadata
- **Event System**: Audio-related event broadcasting
- **Configuration**: Audio settings and preferences
- **Root View**: Main audio library interface

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
