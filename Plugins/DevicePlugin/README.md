# DevicePlugin

Device management plugin for Cisum, providing device information display and device sync management.

## Overview

This plugin registers with ID `DevicePlugin` and provides device management functionality through the Cisum plugin system.

## Architecture

```
DevicePlugin/
├── Package.swift
├── Sources/DevicePlugin/
│   ├── DeviceDataExt.swift
│   ├── DBSynced.swift
│   └── BtnDelDevice.swift
└── Tests/
```

## Features

- **Device Info**: Display device details and capabilities
- **Sync Status**: Track database synchronization across devices
- **Device Management**: Remove and manage connected devices

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
