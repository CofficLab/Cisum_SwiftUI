# SwiftUI 代码检查

按照 SwiftUI 开发标准规范检查代码：

1. **检查代码组织**
   - 每个 struct/class 是否在独立文件中
   - 文件名是否与类型名称一致
   - 相关组件是否组织在同一目录

2. **检查 MARK 分组**
   - 是否使用 // MARK: - 分组
   - 分组顺序是否正确：View → Action → Setter → Event Handler → Preview
   - 是否使用 extension 隔离不同分组

3. **检查 SuperLog 协议**
   - 需要日志的类型是否实现 SuperLog 协议
   - 是否定义 emoji 和 verbose 静态常量
   - 是否使用 self.t 进行日志记录
   - Emoji 是否独特且相关

4. **检查事件监听**
   - 事件抛出时是否添加了对应的 onXxx View 扩展
   - 事件扩展是否放在 Core/Events/ 目录
   - 是否使用 perform: 语法
   - 方法命名是否清晰（onXxx/handleXxx）

5. **检查预览代码**
   - 文件底部是否添加多尺寸预览
   - 是否使用条件编译适配平台
   - 是否使用 inRootView() 包装
   - 是否提供至少 2 种尺寸（macOS）

6. **修复不规范的地方**
   - 自动修复可以自动修复的问题
   - 列出需要手动修复的问题
   - 提供修复建议

## 重要规则

- 使用中文与用户交流
- 仅执行检查和修复，无需总结
