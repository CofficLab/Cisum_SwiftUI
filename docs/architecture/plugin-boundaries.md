# Plugin 边界

Cisum 的插件分为三层：

1. `Provider*`：稳定的跨插件协议、事件和 Observer 句柄。
2. `*Core`：领域数据模型、仓库和外部存储访问。它不拥有插件生命周期，也不导入 `Plugin*`。
3. `Plugin*`：生命周期、UI、Observers 和 Capabilities。它通过 Provider 接收外部变化，通过 Capability 操作外部能力。

当前书籍和音频包先在原包内用独立 SwiftPM target 暴露中立产品，避免一次大规模物理迁移带来的风险：

- `ProviderBook`：书籍跨插件契约与书籍领域核心类型。
- `AudioLibraryCore`：音频模型、数据库、仓库和存储宿主桥接。
- `AudioLikeCore`：喜欢模型与喜欢仓库。
- `StoreCore`：订阅状态与商店服务，供音频复制能力使用。

功能插件只能依赖这些中立产品和公共 Provider，不能导入其他 `Plugin*` 模块。架构检查：

```text
Scripts/check-plugin-boundaries.sh
```

新增功能插件时，应先定义 Provider，再在插件内部实现 Provider；外部文件变化放在 Observer，外部写入、播放、复制等动作放在 Capability。
