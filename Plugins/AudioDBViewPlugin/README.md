# AudioDBViewPlugin

Audio database viewer plugin for Cisum, providing a browsable interface for the audio library database.

## Overview

This plugin registers with ID `AudioDBViewPlugin` and provides audio database viewing functionality through the Cisum plugin system.

## Architecture

```
AudioDBViewPlugin/
├── Package.swift
├── Sources/AudioDBViewPlugin/
│   ├── AudioDBPlugin.swift
│   ├── AudioDBPluginInfo.swift
│   ├── AudioDBRootView.swift
│   ├── AudioDBView.swift
│   ├── AudioDBDependencies.swift
│   ├── AudioDBEventViews.swift
│   ├── AudioDBTips.swift
│   ├── AudioItemView.swift
│   ├── AudioList.swift
│   ├── AudioDeletePlaybackPolicy.swift
│   └── BtnAdd.swift
└── Tests/
```

## Features

- **Database Browser**: View and browse audio library contents
- **Item Details**: Detailed view for individual audio items
- **Delete Policy**: Configurable playback deletion policies
- **Event Views**: Real-time database event display

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
