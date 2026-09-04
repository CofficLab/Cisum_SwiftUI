import Foundation

/// PluginPlayBack 的播放状态存储服务（Services 层）。
///
/// 专门负责把当前播放文件持久化到插件专属磁盘目录，下次启动时恢复。
/// 仅有此插件维护该状态，不依赖 `UserDefaults`。
///
/// ## 文件
/// - 路径：`<rootDirectory>/PluginPlayBack/current-playback.plist`
/// - 格式：binary plist，`["url": String]`（URL 的 absoluteString）。
@MainActor
public final class PlaybackStateStore {
    private static let subdirectory = "PluginPlayBack"
    private static let filename = "current-playback.plist"
    private static let urlKey = "url"

    private let fileURL: URL

    /// - Parameter rootDirectory: 数据库根目录（`kernel.storage?.databaseRoot`）。
    public init(rootDirectory: URL) {
        self.fileURL = rootDirectory
            .appendingPathComponent(Self.subdirectory, isDirectory: true)
            .appendingPathComponent(Self.filename, isDirectory: false)
    }

    /// 保存当前播放文件；传 `nil` 表示清除记录。
    public func saveCurrentFile(_ url: URL?) {
        guard let url else {
            try? FileManager.default.removeItem(at: fileURL)
            return
        }
        do {
            let directory = fileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try PropertyListSerialization.data(
                fromPropertyList: [Self.urlKey: url.absoluteString],
                format: .binary,
                options: 0
            )
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // 写入失败不影响播放。
        }
    }

    /// 读取上次播放的文件；无记录或文件不存在时返回 `nil`。
    public func loadCurrentFile() -> URL? {
        guard let data = try? Data(contentsOf: fileURL),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
              let dict = plist as? [String: String],
              let absoluteString = dict[Self.urlKey],
              let url = URL(string: absoluteString) else {
            return nil
        }
        return url
    }
}
