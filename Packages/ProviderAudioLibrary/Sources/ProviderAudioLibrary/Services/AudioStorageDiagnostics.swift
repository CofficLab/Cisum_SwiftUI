import Foundation
import ProviderStorage

/// 音频仓库路径解析诊断信息。
///
/// 用于设置页在仓库不可用时展示完整的解析链路各环节结果，方便开发者
/// 快速定位「仓库路径拿不到」的原因（存储位置未设置 / iCloud 容器解析失败 /
/// 本地目录解析失败等）。
public struct AudioStorageDiagnostics: Sendable, Equatable {
    public init(
        storageLocationRaw: String?,
        isICloudAvailable: Bool,
        hasUsableStorageLocation: Bool,
        cloudContainer: String?,
        cloudDocuments: String?,
        localDocuments: String?,
        storageRoot: String?,
        audioDisk: String?,
        dbDirName: String
    ) {
        self.storageLocationRaw = storageLocationRaw
        self.isICloudAvailable = isICloudAvailable
        self.hasUsableStorageLocation = hasUsableStorageLocation
        self.cloudContainer = cloudContainer
        self.cloudDocuments = cloudDocuments
        self.localDocuments = localDocuments
        self.storageRoot = storageRoot
        self.audioDisk = audioDisk
        self.dbDirName = dbDirName
    }

    /// 用户配置的存储位置原始值（`UserDefaults["StorageLocation"]`）。
    public let storageLocationRaw: String?

    /// 系统 iCloud 是否可用（`ubiquityIdentityToken` 是否存在）。
    public let isICloudAvailable: Bool

    /// 是否已配置可用存储位置。
    public let hasUsableStorageLocation: Bool

    /// iCloud 容器根目录（`url(forUbiquityContainerIdentifier:)`）。
    public let cloudContainer: String?

    /// iCloud Documents 目录（容器下 Documents 子目录）。
    public let cloudDocuments: String?

    /// 本地 Documents 目录。
    public let localDocuments: String?

    /// 存储服务解析出的根目录（`StorageProviding.storageRoot`）。
    public let storageRoot: String?

    /// 音频仓库目录（`storageRoot` + `dbDirName`，即 `getAudioDisk()`）。
    public let audioDisk: String?

    /// 当前使用的仓库子目录名（Release 为 `audios`，DEBUG 为 `audios_debug`）。
    public let dbDirName: String

    /// 推断的不可用原因（人类可读，便于直接展示）。
    public var failureReason: String? {
        if storageLocationRaw == nil {
            return "Storage location is not set. Go to Storage settings and choose iCloud or Local."
        }
        if !isICloudAvailable, storageLocationRaw == "icloud" {
            return "iCloud is not available on this device (not signed in or not authorized)."
        }
        if cloudContainer == nil, storageLocationRaw == "icloud" {
            return "iCloud container could not be resolved (ubiquity container URL is nil)."
        }
        if storageRoot == nil {
            return "Storage root could not be resolved for location '\(storageLocationRaw ?? "nil")'."
        }
        if audioDisk == nil {
            return "Audio repository directory could not be created at storage root."
        }
        return nil
    }

    /// 人类可读的多行诊断文本，便于一键复制给开发者。
    public var summary: String {
        var lines: [String] = []
        lines.append("StorageLocation(raw) = \(storageLocationRaw ?? "nil")")
        lines.append("hasUsableStorageLocation = \(hasUsableStorageLocation)")
        lines.append("isICloudAvailable = \(isICloudAvailable)")
        lines.append("cloudContainer = \(cloudContainer ?? "nil")")
        lines.append("cloudDocuments = \(cloudDocuments ?? "nil")")
        lines.append("localDocuments = \(localDocuments ?? "nil")")
        lines.append("storageRoot = \(storageRoot ?? "nil")")
        lines.append("audioDisk = \(audioDisk ?? "nil")")
        lines.append("dbDirName = \(dbDirName)")
        if let failureReason {
            lines.append("failureReason = \(failureReason)")
        }
        return lines.joined(separator: "\n")
    }
}

public extension AudioStorageDiagnostics {
    /// 从内核存储服务解析完整的仓库链路诊断（不依赖 `AudioPlugin` actor）。
    ///
    /// `storage` 传入内核的 `StorageProviding`；为 nil 时视为存储服务不可达，
    /// 相关环节如实记为 nil，其余环节（UserDefaults / iCloud 容器）仍独立探测。
    @MainActor
    static func make(storage: (any StorageProviding)?) -> AudioStorageDiagnostics {
        let storageLocationRaw = UserDefaults.standard.string(forKey: "StorageLocation")
        let isICloudAvailable = FileManager.default.ubiquityIdentityToken != nil
        let cloudContainer = FileManager.default.url(forUbiquityContainerIdentifier: nil)
        let cloudDocuments = cloudContainer?.appendingPathComponent("Documents")
        let localDocuments = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let storageRoot = storage?.storageRoot
        let disk = storageRoot?.appendingPathComponent(
            AudioPluginInfo.effectiveDBDirName,
            isDirectory: true
        )

        return AudioStorageDiagnostics(
            storageLocationRaw: storageLocationRaw,
            isICloudAvailable: isICloudAvailable,
            hasUsableStorageLocation: storage?.hasUsableStorageLocation ?? false,
            cloudContainer: cloudContainer?.path,
            cloudDocuments: cloudDocuments?.path,
            localDocuments: localDocuments?.path,
            storageRoot: storageRoot?.path,
            audioDisk: disk?.path,
            dbDirName: AudioPluginInfo.effectiveDBDirName
        )
    }
}
