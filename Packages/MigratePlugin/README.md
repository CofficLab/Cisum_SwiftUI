# MigratePlugin

Data migration plugin for Cisum, handling database schema migrations and data transformations across versions.

## Overview

This plugin registers with ID `MigratePlugin` and provides data migration functionality through the Cisum plugin system.

## Architecture

```
MigratePlugin/
├── Package.swift
├── Sources/MigratePlugin/
│   ├── Migrate.swift
│   ├── Migrate+v25.swift
│   └── MigrateView.swift
└── Tests/
```

## Features

- **Schema Migration**: Automatic database schema updates
- **Version Handling**: Version-specific migration logic (e.g., v25)
- **Migration UI**: Visual progress and status during migration

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
