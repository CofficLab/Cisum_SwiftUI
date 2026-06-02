# BookPlugin

Core audiobook management plugin for Cisum, providing the central book library with database, models, events, and repository layers.

## Overview

This plugin registers with ID `BookPlugin` and provides the core audiobook library functionality through the Cisum plugin system. It serves as the foundation for other book-related plugins.

## Architecture

```
BookPlugin/
├── Package.swift
├── Sources/BookPlugin/
│   ├── BookPlugin.swift
│   ├── BookPluginHost.swift
│   ├── BookPluginInfo.swift
│   ├── BookPluginError.swift
│   ├── BookRootView.swift
│   ├── BookModel.swift
│   ├── BookDTO.swift
│   ├── BookModelExt+DTO.swift
│   ├── BookDB.swift
│   ├── BookRepo.swift
│   ├── BookConfig.swift
│   ├── BookCoverRepo.swift
│   ├── BookSettingRepo.swift
│   ├── BookEvent.swift
│   ├── BookState.swift
│   ├── BookWorker.swift
│   ├── BookRead.swift
│   ├── BookUpdate.swift
│   └── BookPathContainment.swift
└── Tests/
```

## Features

- **Book Library**: Core audiobook content management
- **Database Layer**: Persistent storage for book metadata
- **Cover Art**: Book cover art management and caching
- **Worker**: Background book processing tasks
- **Configuration**: Book settings and preferences

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
