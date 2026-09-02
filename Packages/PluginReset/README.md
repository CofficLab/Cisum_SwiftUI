# ResetPlugin

System reset and settings plugin for Cisum, providing data reset, system settings, and confirmation workflows.

## Overview

This plugin registers with ID `ResetPlugin` and provides system reset functionality through the Cisum plugin system.

## Architecture

```
ResetPlugin/
├── Package.swift
├── Sources/ResetPlugin/
│   ├── SystemPlugin.swift
│   ├── ResetPluginInfo.swift
│   ├── ResetConfirm.swift
│   ├── SystemSetting.swift
│   └── ...
└── Tests/
```

## Features

- **Data Reset**: Clear all user data with confirmation workflow
- **System Settings**: Access and configure system-level settings
- **Confirmation Flow**: Safety confirmations before destructive operations

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
