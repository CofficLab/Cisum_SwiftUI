# AudioScenePlugin

Audio scene and poster plugin for Cisum, providing visual scene/poster artwork for audio content.

## Overview

This plugin registers with ID `AudioScenePlugin` and provides the music scene poster UI through the Cisum plugin system.

The music scene itself is a fixed built-in enum (`AppScene.music`) owned by the `ProviderScene` package; plugins no longer register scenes via `addSceneItem()`.

## Architecture

```
AudioScenePlugin/
├── Package.swift
├── Sources/AudioScenePlugin/
│   ├── AudioScenePlugin.swift
│   ├── AudioScenePluginInfo.swift
│   └── AudioPosterView.swift
└── Tests/
```

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
