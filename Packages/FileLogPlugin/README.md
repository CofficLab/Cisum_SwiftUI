# FileLogPlugin

File logging plugin for Cisum, providing configurable file-based logging with log coordination.

## Overview

This plugin registers with ID `FileLogPlugin` and provides file logging functionality through the Cisum plugin system.

## Architecture

```
FileLogPlugin/
├── Package.swift
├── Sources/FileLogPlugin/
│   ├── FileLogPlugin.swift
│   ├── FileLogPluginInfo.swift
│   ├── FileLogConfiguration.swift
│   └── FileLogCoordinator.swift
└── Tests/
```

## Features

- **File Logging**: Write logs to local files
- **Configuration**: Configurable log levels and output settings
- **Log Coordinator**: Centralized log management and rotation

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
