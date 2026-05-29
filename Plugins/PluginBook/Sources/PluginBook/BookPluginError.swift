import Foundation
import SwiftUI

// MARK: - Book Plugin Errors

public enum BookPluginError: Error, LocalizedError {
    case configurationMissing
    case NoNextAsset
    case NoPrevAsset
    case NoDisk
    case DiskNotFound
    case initialization(reason: String)

    public var errorDescription: String? {
        switch self {
        case .configurationMissing:
            return "有声书插件宿主配置未完成"
        case .NoNextAsset:
            return "没有下一个章节/文件"
        case .NoPrevAsset:
            return "没有上一个章节/文件"
        case .NoDisk:
            return "无法访问磁盘"
        case .DiskNotFound:
            return "磁盘未找到"
        case .initialization(let reason):
            return "初始化失败: \(reason)"
        }
    }

    public var failureReason: String? {
        switch self {
        case .configurationMissing:
            return "应用尚未注入数据库和存储路径配置"
        case .NoNextAsset:
            return "当前已是最后一个条目"
        case .NoPrevAsset:
            return "当前已是第一个条目"
        case .NoDisk:
            return "指定的磁盘路径不存在或无法访问"
        case .DiskNotFound:
            return "指定的磁盘路径不存在或无法访问"
        case .initialization:
            return "插件初始化过程中发生错误"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .configurationMissing:
            return "请检查应用启动流程"
        case .NoNextAsset, .NoPrevAsset:
            return "请检查播放顺序或选择其他条目"
        case .NoDisk:
            return "请检查磁盘权限与路径设置"
        case .DiskNotFound:
            return "请检查磁盘权限与路径设置"
        case .initialization:
            return "请尝试重启应用或检查设置"
        }
    }
}
