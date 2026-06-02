import Foundation
import SwiftUI

#if os(macOS)
    import AppKit
#elseif os(iOS) || os(visionOS)
    import UIKit
#endif

/// 最小化 MagicApp 工具类
/// 提供 bundle identifier 和 iCloud 可用性检查
public enum MagicApp {
    /// Whether the current platform is a desktop platform.
    public static var isDesktop: Bool {
        #if os(macOS)
            return true
        #else
            return false
        #endif
    }

    /// Whether the current platform is iOS.
    public static var isiOS: Bool {
        #if os(iOS)
            return true
        #else
            return false
        #endif
    }

    /// Whether the current platform is not a desktop platform.
    public static var isNotDesktop: Bool {
        !isDesktop
    }

    /// 当前平台名称。
    public static var currentPlatform: String {
        #if os(macOS)
            return "macOS"
        #elseif os(iOS)
            return "iOS"
        #elseif os(visionOS)
            return "visionOS"
        #else
            return "unknown"
        #endif
    }

    /// 获取当前应用的 Bundle Identifier
    public static func getBundleIdentifier() -> String {
        Bundle.main.bundleIdentifier ?? "com.unknown.app"
    }

    /// 获取当前应用版本。
    public static func getVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }

    /// 获取当前应用名称。
    public static func getAppName() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }

    /// 获取当前应用构建号。
    public static func getBuildNumber() -> String {
        Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "Unknown"
    }

    /// 检查 iCloud 是否可用
    public static func isICloudAvailable() -> Bool {
        #if os(watchOS)
        return false
        #else
        return FileManager.default.ubiquityIdentityToken != nil
        #endif
    }

    /// 获取当前设备名称。
    public static func getDeviceName() -> String {
        #if os(macOS)
            return Host.current().localizedName ?? "Unknown"
        #elseif os(iOS) || os(visionOS)
            return UIDevice.current.name
        #else
            return "Unknown"
        #endif
    }

    /// 获取当前设备型号标识。
    public static func getDeviceModel() -> String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)

        guard size > 0 else {
            return "Unknown"
        }

        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }

    /// 获取系统名称。
    public static func getSystemName() -> String {
        currentPlatform
    }

    /// 获取系统版本。
    public static func getSystemVersion() -> String {
        if let version = ProcessInfo.processInfo.operatingSystemVersionString.split(separator: " ").last {
            return String(version)
        }
        return "Unknown"
    }

    /// 获取 Application Support 目录。
    public static func getAppSupportDirectory() -> URL {
        (try? URL.applicationSupport) ?? FileManager.default.temporaryDirectory
    }

    /// 获取应用专属 Application Support 目录。
    public static func getAppSpecificSupportDirectory() -> URL {
        (try? URL.appSpecificSupport) ?? FileManager.default.temporaryDirectory
    }

    /// 获取 Documents 目录。
    public static func getDocumentsDirectory() -> URL {
        (try? URL.documents) ?? FileManager.default.temporaryDirectory
    }

    /// 获取应用容器目录。
    public static func getContainerDirectory() -> URL {
        (try? URL.container) ?? FileManager.default.temporaryDirectory
    }

    /// 获取 iCloud 容器目录。
    public static func getCloudContainerDirectory() -> URL? {
        URL.cloudContainer
    }

    /// 获取 iCloud Documents 目录。
    public static func getCloudDocumentsDirectory() -> URL? {
        URL.cloudDocuments
    }

    /// 获取缓存目录。
    public static func getCacheDirectory() -> URL {
        (try? URL.caches) ?? FileManager.default.temporaryDirectory
    }

    /// 获取数据库目录。
    public static func getDatabaseDirectory() -> URL {
        (try? URL.database) ?? FileManager.default.temporaryDirectory
    }

    /// 返回调试命令菜单。
    @available(iOS 14.0, macOS 11.0, *)
    public static func debugCommand() -> CommandMenu<some View> {
        CommandMenu("调试") {
            Group {
                Button("打开 App Support 目录") {
                    getAppSpecificSupportDirectory().open()
                }

                Button("打开容器目录") {
                    getContainerDirectory().open()
                }

                Button("打开文档目录") {
                    getDocumentsDirectory().open()
                }

                Button("打开数据库目录") {
                    getDatabaseDirectory().open()
                }

                Button("打开 iCloud Documents") {
                    getCloudDocumentsDirectory()?.open()
                }

                Button("打开缓存目录") {
                    getCacheDirectory().open()
                }

                Button("打开下载目录") {
                    try? URL.downloads.open()
                }

                Button("打开临时目录") {
                    URL.temp.open()
                }

                Button("打开 iCloud 容器") {
                    getCloudContainerDirectory()?.open()
                }

                Button("打开系统 App Support") {
                    try? URL.applicationSupport.open()
                }
            }
        }
    }
}
