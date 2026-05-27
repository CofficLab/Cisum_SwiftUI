# 插件国际化（i18n）规范

> 本规范定义了 Cisum 项目中所有插件的多语言（国际化）实现方式和最佳实践。

---

## 核心原则

**每个插件独立管理国际化资源，使用统一的 `.xcstrings` 格式，支持动态多语言切换。**

所有用户可见的文本都必须进行国际化，禁止在代码中硬编码用户可见字符串。

---

## 文件格式

### 文件扩展名

```
<PluginName>.xcstrings
```

### 文件结构

```json
{
  "sourceLanguage": "en",
  "version": "1.0",
  "strings": {
    "Key String": {
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "Key String"
          }
        },
        "zh-Hans": {
          "stringUnit": {
            "state": "translated",
            "value": "键字符串"
          }
        },
        "zh-HK": {
          "stringUnit": {
            "state": "translated",
            "value": "鍵字符串"
          }
        }
      }
    }
  }
}
```

### 字段说明

| 字段 | 说明 | 必填 | 示例 |
|------|------|------|------|
| `sourceLanguage` | 源语言代码 | ✅ | `"en"` |
| `version` | 文件格式版本 | ✅ | `"1.0"` |
| `strings` | 字符串字典 | ✅ | - |
| `localizations` | 语言列表 | ✅ | - |
| `state` | 翻译状态 | ✅ | `"translated"` |
| `value` | 翻译后的文本 | ✅ | `"键字符串"` |

### 翻译状态

| 状态 | 说明 |
|------|------|
| `translated` | 已完成翻译 |
| `needsReview` | 需要审查 |
| `notTranslated` | 未翻译 |

---

## 支持语言

| 语言代码 | 语言 | 优先级 |
|---------|------|--------|
| `en` | 英语 | 必须（源语言） |
| `zh-Hans` | 简体中文 | 必须 |
| `zh-HK` | 繁体中文 | 推荐 |

---

## 文件命名

### 标准命名

```
<PluginName>.xcstrings
```

**示例**：
```
GitBranch.xcstrings
GitCommit.xcstrings
AutoPush.xcstrings
Banner.xcstrings
```

### 文件位置

```
CisumApp/Plugins/<PluginName>/<PluginName>.xcstrings
```

---

## 使用方式

### 基础用法

```swift
// 视图中使用
Text(String(localized: "Hello World", table: "PluginName"))

// 属性定义
static let displayName = String(localized: "Plugin Name", table: "PluginName")

// 动态消息
let message = String(localized: "Hello, %@", table: "PluginName", arguments: userName)
```

### 完整示例

```swift
import SwiftUI

struct GitBranchPlugin: CisumPlugin {
    static let displayName = String(localized: "Git Branch Management", table: "GitBranch")
    static let description = String(localized: "Manage Git branches", table: "GitBranch")
    
    var body: some View {
        VStack {
            Text(String(localized: "Branches", table: "GitBranch"))
                .font(.headline)
            
            Text(String(localized: "Current branch: %@", table: "GitBranch", arguments: branchName))
            
            Button(String(localized: "Create Branch", table: "GitBranch")) {
                // ...
            }
        }
    }
}
```

### 带参数的字符串

**xcstrings 文件**：
```json
{
  "Selected: %@": {
    "localizations": {
      "en": {
        "stringUnit": {
          "state": "translated",
          "value": "Selected: %@"
        }
      },
      "zh-Hans": {
        "stringUnit": {
          "state": "translated",
          "value": "已选：%@"
        }
      }
    }
  },
  "%lld files": {
    "localizations": {
      "en": {
        "stringUnit": {
          "state": "translated",
          "value": "%lld files"
        }
      },
      "zh-Hans": {
        "stringUnit": {
          "state": "translated",
          "value": "%lld 个文件"
        }
      }
    }
  }
}
```

**Swift 代码**：
```swift
Text(String(localized: "Selected: %@", table: "GitBranch", arguments: selectedCount))
Text(String(localized: "%lld files", table: "GitBranch", arguments: fileCount))
```

### 带命名参数的字符串

**xcstrings 文件**：
```json
{
  "Auto-push \(status): \(project.title)/\(branch.name)": {
    "localizations": {
      "en": {
        "stringUnit": {
          "state": "translated",
          "value": "Auto-push %1$@: %2$@/%3$@"
        }
      },
      "zh-Hans": {
        "stringUnit": {
          "state": "translated",
          "value": "自动推送 %@：%@/%@"
        }
      }
    }
  }
}
```

**Swift 代码**：
```swift
let message = String(
    localized: "Auto-push \(status): \(project.title)/\(branch.name)",
    table: "AutoPush"
)
```

---

## 创建 xcstrings 文件

### 步骤 1：创建文件

在插件目录下创建 `<PluginName>.xcstrings` 文件

### 步骤 2：添加基础结构

```json
{
  "sourceLanguage": "en",
  "version": "1.0",
  "strings": {}
}
```

### 步骤 3：添加字符串

手动添加或使用 Xcode 的本地化导出功能。

### 步骤 4：翻译

为每种支持的语言添加翻译。

---

## 最佳实践

### ✅ 推荐

1. **所有用户可见文本都国际化**
   - 按钮标题、标签、提示信息
   - 错误消息、成功提示
   - 菜单项、工具提示

2. **使用有意义的键**

   ```swift
   // ✅ 好：使用完整句子作为键
   String(localized: "Confirm Delete Branch", table: "GitBranch")
   
   // ❌ 避免：使用无意义的键
   String(localized: "btn_confirm_1", table: "GitBranch")
   ```

3. **保持翻译文件同步**
   - 添加新字符串时同时提供所有语言的翻译
   - 定期审查 `needsReview` 状态的字符串

4. **使用 Xcode 本地化编辑器**
   - 在 Xcode 中打开 `.xcstrings` 文件
   - 使用可视化编辑器管理翻译

5. **注释复杂字符串**

   ```json
   {
     "Auto-push \(status): \(project)/\(branch)": {
       "comment": "status = enabled/disabled, project = project name, branch = branch name",
       "localizations": { ... }
     }
   }
   ```

### ❌ 避免

1. **硬编码用户可见文本**

   ```swift
   // ❌ 错误
   Text("Click here to push")
   
   // ✅ 正确
   Text(String(localized: "Click to push", table: "GitCommit"))
   ```

2. **混合语言**

   ```swift
   // ❌ 错误：中文硬编码
   Text(String(localized: "点击推送", table: "GitCommit"))
   
   // ✅ 正确：使用英文键
   Text(String(localized: "Click to push", table: "GitCommit"))
   ```

3. **过长的字符串**
   - 将长文本拆分为多个可重用的片段

4. **忽略占位符顺序**
   - 不同语言的语法顺序可能不同，使用命名参数

---

## 检查清单

创建新插件时，确保：

- [ ] 创建 `<PluginName>.xcstrings` 文件
- [ ] 设置 `sourceLanguage` 为 `"en"`
- [ ] 提供英文 (`en`) 翻译
- [ ] 提供简体中文 (`zh-Hans`) 翻译
- [ ] 提供繁体中文 (`zh-HK`) 翻译（推荐）
- [ ] 所有用户可见文本使用 `String(localized:table:)`
- [ ] 动态消息使用占位符 (`%@` 或 `{name}`)
- [ ] 在 Xcode 中验证本地化文件

---

## 附录

### A. 常见占位符

| 占位符 | 类型 | 示例 |
|--------|------|------|
| `%@` | 字符串 | `"Hello, %@"` → `"Hello, World"` |
| `%d` | 整数 | `"%d items"` → `"5 items"` |
| `%lld` | 长整数 | `"%lld files"` → `"100 files"` |
| `%.2f` | 浮点数 | `"%.2f MB"` → `"12.34 MB"` |
| `{name}` | 命名参数 | `"Hello, {name}"` |

### B. 语言代码参考

| 代码 | 语言 | 地区 |
|------|------|------|
| `en` | 英语 | - |
| `zh-Hans` | 简体中文 | 中国大陆 |
| `zh-HK` | 繁体中文 | 中国香港 |
| `zh-TW` | 繁体中文 | 中国台湾 |
| `ja` | 日语 | 日本 |
| `ko` | 韩语 | 韩国 |

### C. Xcode 本地化导出

1. 在 Xcode 中选择项目
2. 选择 **Editor** → **Export Localizations**
3. 选择导出格式为 `.xcstrings`
4. 选择要导出的语言

### D. 相关文档

- [Apple Localization 文档](https://developer.apple.com/documentation/xcode/localization)