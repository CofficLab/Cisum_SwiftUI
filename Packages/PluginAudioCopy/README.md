# AudioCopyPlugin

Audio file copy and transfer plugin for Cisum, supporting batch copy operations with progress tracking.

## Overview

This plugin registers with ID `AudioCopyPlugin` and provides audio file copy/transfer functionality through the Cisum plugin system.

## Architecture

```
AudioCopyPlugin/
├── Package.swift
├── Sources/AudioCopyPlugin/
│   ├── CopyPlugin.swift
│   ├── CopyService.swift
│   ├── CopyWorker.swift
│   ├── CopyDB.swift
│   ├── CopyEvents.swift
│   ├── CopyList.swift
│   ├── CopyRootView.swift
│   ├── CopyStateView.swift
│   ├── CopyTips.swift
│   ├── CopyTask.swift
│   ├── BtnDelTask.swift
│   └── AudioCopyPluginInfo.swift
└── Tests/
```

## Features

- **Batch Copy**: Copy multiple audio files in batch
- **Progress Tracking**: Real-time copy progress with state views
- **Task Management**: Create, monitor, and delete copy tasks

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
