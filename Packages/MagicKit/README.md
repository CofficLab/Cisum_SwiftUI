# MagicKit

MagicKit 是一个综合性的 SwiftUI 工具包，为 macOS 和 iOS 应用开发提供辅助功能。

## 安装

### Swift Package Manager

将以下依赖添加到您的 `Package.swift` 文件中：

```swift
dependencies: [
    .package(url: "https://github.com/nookery/MagicKit.git", from: "1.0.0")
]
```

然后在目标中添加：

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "MagicKit", package: "MagicKit")
    ]
)
```

或者在 Xcode 中：

1. 打开您的项目
2. 选择 File > Swift Packages > Add Package Dependency
3. 输入仓库 URL：`https://github.com/nookery/MagicKit.git`

## 系统要求

- iOS 17.0+ 或 macOS 14.0+
- Swift 5.9+

## 测试

要运行 MagicKit 的单元测试，请在终端中导航到项目根目录，然后运行以下命令：

```bash
swift test
```

## 构建

```bash
swift build
```

## Maintainers

Work for Joy & Live for Love ➡️ <https://github.com/nookery>
