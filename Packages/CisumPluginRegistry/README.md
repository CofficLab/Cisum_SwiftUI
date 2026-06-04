# CisumPluginRegistry

Plugin registry for the Cisum plugin system. Manually maintained list of all plugins available to Cisum.

## Overview

This package serves as the central registry that declares dependencies on all Cisum plugin packages and collects their shared instances at startup.

## Architecture

```
CisumPluginRegistry/
├── Package.swift          ← All plugin dependencies declared here
├── Sources/
│   └── PluginRegistry.swift  ← Manually maintained registry
└── README.md
```

## How It Works

The registry is **manually maintained**, not auto-generated. When adding a new plugin:

1. Add the plugin module to `Package.swift` dependencies and target dependencies
2. Add `import` statement in `PluginRegistry.swift`
3. Append the plugin's shared instance to the `plugins` array
4. Keep the `Package.swift` dependency list in sync with the `import` statements and `plugins.append(...)` calls

## Plugin Type Mapping

Most modules use a matching plugin type name (e.g., `AudioPlugin` module → `AudioPlugin` type). Notable exceptions:

| Module Name           | Plugin Type    |
|-----------------------|----------------|
| `AudioCopyPlugin`     | `CopyPlugin`   |
| `AudioDBViewPlugin`   | `AudioDBPlugin`|
| `BookDBViewPlugin`    | `BookDBPlugin` |
| `ResetPlugin`         | `SystemPlugin` |

