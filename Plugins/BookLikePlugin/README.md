# BookLikePlugin

Book favorites/likes management plugin for Cisum, providing like/unlike functionality with a dedicated favorites view.

## Overview

This plugin registers with ID `BookLikePlugin` and provides audiobook like/favorite functionality through the Cisum plugin system.

## Architecture

```
BookLikePlugin/
├── Package.swift
├── Sources/BookLikePlugin/
│   ├── BookLikePlugin.swift
│   ├── BookLikePluginInfo.swift
│   ├── BookLikeRootView.swift
│   ├── BookLikeSettingsView.swift
│   └── BookLikeStore.swift
└── Tests/
```

## Features

- **Like/Unlike**: Toggle favorite status for audiobooks
- **Favorites View**: Dedicated view for liked book content
- **Settings**: Configurable like behavior preferences

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
