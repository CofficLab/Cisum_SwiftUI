# BookScenePlugin

Book scene and poster plugin for Cisum, providing visual scene/poster artwork for audiobook content.

## Overview

This plugin registers with ID `BookScenePlugin` and provides the audiobook scene poster UI through the Cisum plugin system.

The audiobook scene itself is a fixed built-in enum (`AppScene.audiobooks`) owned by the `ProviderScene` package; plugins no longer register scenes via `addSceneItem()`.

## Architecture

```
BookScenePlugin/
├── Package.swift
├── Sources/BookScenePlugin/
│   ├── BookScenePlugin.swift
│   ├── BookScenePluginInfo.swift
│   └── BookPosterView.swift
└── Tests/
```

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
