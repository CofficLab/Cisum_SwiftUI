#!/usr/bin/env swift

import Foundation

// 检查 .xcstrings 文件的完整性
func checkXCStringsFile(path: String) -> (hasIssue: Bool, issues: [String]) {
    var issues: [String] = []
    
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let strings = json["strings"] as? [String: [String: Any]] else {
        return (true, ["无法解析文件"])
    }
    
    let sourceLanguage = json["sourceLanguage"] as? String ?? "en"
    
    for (key, value) in strings {
        let localizations = value["localizations"] as? [String: [String: Any]]
        
        if localizations == nil || localizations!.isEmpty {
            issues.append("字符串 '\(key)' 没有任何翻译")
            continue
        }
        
        // 检查是否有中文翻译（简体）
        let hasZhHans = localizations?["zh-Hans"] != nil
        // 检查是否有英文翻译
        let hasEn = localizations?["en"] != nil || sourceLanguage == "en"
        
        if !hasZhHans {
            issues.append("字符串 '\(key)' 缺少简体中文翻译")
        }
        
        if !hasEn && sourceLanguage != "en" {
            issues.append("字符串 '\(key)' 缺少英文翻译")
        }
    }
    
    return (!issues.isEmpty, issues)
}

// 主函数
func main() {
    let pluginsPath = "/Users/colorfy/Code/CofficLab/Cisum/Packages"
    
    print("=== Cisum 插件多语言检查报告 ===\n")
    
    let fileManager = FileManager.default
    guard let plugins = try? fileManager.contentsOfDirectory(atPath: pluginsPath) else {
        print("无法读取插件目录")
        return
    }
    
    var totalIssues = 0
    var pluginsWithIssues: [String: [String]] = [:]
    
    for plugin in plugins where plugin.hasPrefix("Plugin") {
        let pluginPath = "\(pluginsPath)/\(plugin)"
        
        // 查找所有 .xcstrings 文件
        if let xcstringsFiles = try? fileManager.subpathsOfDirectory(atPath: pluginPath) {
            for file in xcstringsFiles where file.hasSuffix(".xcstrings") && !file.contains(".build/") {
                let fullPath = "\(pluginPath)/\(file)"
                let (hasIssue, issues) = checkXCStringsFile(path: fullPath)
                
                if hasIssue {
                    totalIssues += issues.count
                    pluginsWithIssues[plugin] = issues
                    print("⚠️ \(plugin)/\(file)")
                    for issue in issues {
                        print("   - \(issue)")
                    }
                    print("")
                }
            }
        }
    }
    
    // 检查没有 .xcstrings 文件的插件
    var pluginsWithoutXCStrings: [String] = []
    for plugin in plugins where plugin.hasPrefix("Plugin") {
        let pluginPath = "\(pluginsPath)/\(plugin)"
        let xcstringsFiles = (try? fileManager.subpathsOfDirectory(atPath: pluginPath))?
            .filter { $0.hasSuffix(".xcstrings") && !$0.contains(".build/") } ?? []
        
        if xcstringsFiles.isEmpty {
            pluginsWithoutXCStrings.append(plugin)
        }
    }
    
    print("=== 统计 ===")
    print("有问题的插件数: \(pluginsWithIssues.count)")
    print("问题总数: \(totalIssues)")
    print("缺少多语言文件的插件: \(pluginsWithoutXCStrings.count)")
    
    if !pluginsWithoutXCStrings.isEmpty {
        print("\n=== 缺少多语言文件的插件 ===")
        for plugin in pluginsWithoutXCStrings {
            print("❌ \(plugin)")
        }
    }
}

main()
