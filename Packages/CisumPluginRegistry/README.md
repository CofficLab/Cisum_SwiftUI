# CisumPluginRegistry

Plugin registry for the Cisum plugin system. Auto-generated registry that manages plugin registration and lifecycle.

## Overview

This package contains the generated plugin registry code that automatically discovers and registers all Cisum plugins at startup.

## Architecture

```
CisumPluginRegistry/
├── Package.swift
├── Sources/
│   └── GeneratedPluginRegistry.swift
└── Tests/
```

## Dependencies

- `CisumApp` (host application)

## How It Works

The registry is auto-generated during the build process. Each plugin module conforming to the plugin protocol is collected and registered automatically, eliminating the need for manual plugin registration.

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
