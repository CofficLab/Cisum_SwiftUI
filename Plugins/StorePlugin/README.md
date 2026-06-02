# StorePlugin

In-app store and subscription plugin for Cisum, providing purchase, subscription management, and restore functionality.

## Overview

This plugin registers with ID `StorePlugin` and provides store functionality through the Cisum plugin system.

## Architecture

```
StorePlugin/
├── Package.swift
├── Sources/StorePlugin/
│   ├── StorePlugin.swift
│   ├── StorePluginInfo.swift
│   ├── StoreService.swift
│   ├── StoreConfig.swift
│   ├── StoreState.swift
│   ├── StoreSetting.swift
│   ├── StoreEvents.swift
│   ├── PurchaseView.swift
│   ├── RestoreView.swift
│   ├── SheetContainer.swift
│   ├── ProductCell.swift
│   ├── ProductDTO.swift
│   ├── ProductGroupsDTO.swift
│   ├── SubscriptionDTO.swift
│   ├── SubscriptionGroupDTO.swift
│   ├── Subscriptions.swift
│   ├── DebugView.swift
│   └── VersionComparisonView.swift
└── Tests/
```

## Features

- **In-App Purchase**: Buy products and subscriptions
- **Subscription Management**: View and manage active subscriptions
- **Restore Purchases**: Restore previous purchases
- **Product Display**: Product listing with cells and groups
- **Debug Tools**: Debug view for testing store functionality
- **Version Comparison**: Compare free vs paid features

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
