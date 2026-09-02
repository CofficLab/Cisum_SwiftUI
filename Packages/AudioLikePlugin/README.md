# AudioLikePlugin

Audio favorites/likes management plugin for Cisum, providing like/unlike functionality with a dedicated favorites view.

## Overview

This plugin registers with ID `AudioLikePlugin` and provides audio like/favorite functionality through the Cisum plugin system.

## Architecture

```
AudioLikePlugin/
├── Package.swift
├── Sources/AudioLikePlugin/
│   ├── AudioLikePlugin.swift
│   ├── AudioLikePluginInfo.swift
│   ├── AudioLikeModel.swift
│   ├── AudioLikeRepo.swift
│   ├── AudioLikeRootView.swift
│   └── AudioLikeSettingsView.swift
└── Tests/
```

## Features

- **Like/Unlike**: Toggle favorite status for audio tracks
- **Favorites View**: Dedicated view for liked audio content
- **Settings**: Configurable like behavior preferences

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
