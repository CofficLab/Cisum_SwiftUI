# 重构清理

通过测试验证安全地识别和移除死代码：

1. 运行死代码分析工具：
   - **Xcode 死代码分析**：使用 Xcode 的静态分析功能
   - **SwiftLint**：查找未使用的代码和导入
   - **Periphery**：识别未使用的 Swift 代码
   - **Swift Package Manager**：检查未使用的依赖

2. 在 .reports/dead-code-analysis.md 中生成综合报告

3. 按严重性分类发现：
   - **安全**：测试文件、未使用的工具函数
   - **谨慎**：视图组件、插件、数据模型
   - **危险**：配置文件、SuperPlugin 协议、核心框架

4. 仅提出安全的删除建议

5. 每次删除前：
   - 运行完整测试套件（xcodebuild test）
   - 验证测试通过
   - 应用更改
   - 重新运行测试
   - 如果测试失败则回滚

6. 在 DELETION_LOG.md 中记录所有删除

7. 显示清理项目的摘要

**Swift 工具：**
```bash
# 使用 Periphery 查找未使用的代码
periphery --setupFiles "Cisum.xcodeproj/project.pbxproj" \
  --index-exclude "*/Pods/*" \
  --index-exclude "*/.build/*"

# 使用 SwiftLint 检查代码质量
swiftlint analyze --compiler-log-path build.log

# 运行 Xcode 测试
xcodebuild test -scheme Cisum -destination 'platform=macOS'
```

永远不要在未先运行测试的情况下删除代码！
