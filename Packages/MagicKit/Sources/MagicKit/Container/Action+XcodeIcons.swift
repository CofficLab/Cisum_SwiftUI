import MagicAlert
import SwiftUI

extension MagicContainer {
    /// Xcode 图标集生成功能实现
    func captureXcodeIcons() {
        #if os(macOS)
            Task {
                await generateXcodeIconSetLegacy()
            }
        #endif
    }

    /// 生成 Xcode 图标集
    @MainActor
    func generateXcodeIconSetLegacy() async {
        let tag = Date().compactDateTime

        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            alert_error("无权访问下载目录，确保你的应用有写入下载目录的权限")
            return
        }

        let folderName = "AppIcon-\(tag).appiconset"
        let folderPath = downloadsURL.appendingPathComponent(folderName, isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true)
        } catch {
            alert_error("创建目录失败：\(error)")
            return
        }

        // iOS 图标（与默认套件一致，仅文件名前缀区分）
        await generateIOSIcon(folderPath: folderPath, tag: tag, prefix: "legacy-")

        // macOS 图标（缩小可视区域，避免在旧系统中显得过大）
        await generateMacOSIcons(folderPath: folderPath, tag: tag, prefix: "legacy-", legacy: true)

        // Contents.json（引用 legacy 前缀文件名）
        await generateContentsJson(folderPath: folderPath, tag: tag, prefix: "legacy-", includeIOS: true)

        alert_success("Xcode 图标集已生成到下载目录")
    }

    /// 生成 iOS 图标 (1024x1024)
    @MainActor
    func generateIOSIcon(folderPath: URL, tag: String, prefix: String) async {
        let size = 1024
        let fileName = "\(tag)-\(prefix)ios-1024x1024.png"
        let saveTo = folderPath.appendingPathComponent(fileName)

        do {
            try content
                .frame(width: CGFloat(size), height: CGFloat(size))
                .snapshot(path: saveTo, scale: 1.0)
        } catch {
            alert_error("生成 iOS 图标失败: \(error)")
        }
    }

    /// 生成 macOS 图标 (1x 和 @2x)
    @MainActor
    func generateMacOSIcons(folderPath: URL, tag: String, prefix: String, legacy: Bool) async {
        let sizes = [16, 32, 128, 256, 512]
        // macOS Big Sur+ 图标圆角比例 (约 22.37%)
        let cornerRadiusRatio: CGFloat = 0.2237
        // 旧系统视觉安全区比例（缩小内容以避免显得过大）
        let legacyContentScale: CGFloat = 0.86

        for size in sizes {
            // 1x 版本
            let fileName = "\(tag)-\(prefix)macos-\(size)x\(size).png"
            let saveTo = folderPath.appendingPathComponent(fileName)
            let cornerRadius = CGFloat(size) * cornerRadiusRatio

            do {
                if legacy {
                    let innerSize = CGFloat(size) * legacyContentScale
                    let innerCorner = innerSize * cornerRadiusRatio
                    try content
                        .frame(width: innerSize, height: innerSize)
                        .clipShape(RoundedRectangle(cornerRadius: innerCorner, style: .continuous))
                        .frame(width: CGFloat(size), height: CGFloat(size))
                        .snapshot(path: saveTo, scale: 1.0)
                } else {
                    try content
                        .frame(width: CGFloat(size), height: CGFloat(size))
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                        .snapshot(path: saveTo, scale: 1.0)
                }
            } catch {
                alert_error("生成 \(fileName) 失败: \(error)")
            }

            // @2x 版本
            let doubleSize = size * 2
            let retinaFileName = "\(tag)-\(prefix)macos-\(size)x\(size)@2x.png"
            let retinaSaveTo = folderPath.appendingPathComponent(retinaFileName)
            let doubleCornerRadius = CGFloat(doubleSize) * cornerRadiusRatio

            do {
                if legacy {
                    let innerSize = CGFloat(doubleSize) * legacyContentScale
                    let innerCorner = innerSize * cornerRadiusRatio
                    try content
                        .frame(width: innerSize, height: innerSize)
                        .clipShape(RoundedRectangle(cornerRadius: innerCorner, style: .continuous))
                        .frame(width: CGFloat(doubleSize), height: CGFloat(doubleSize))
                        .snapshot(path: retinaSaveTo, scale: 1.0)
                } else {
                    try content
                        .frame(width: CGFloat(doubleSize), height: CGFloat(doubleSize))
                        .clipShape(RoundedRectangle(cornerRadius: doubleCornerRadius, style: .continuous))
                        .snapshot(path: retinaSaveTo, scale: 1.0)
                }
            } catch {
                alert_error("生成 \(retinaFileName) 失败: \(error)")
            }
        }
    }

    /// 生成 Contents.json 配置文件
    @MainActor
    func generateContentsJson(folderPath: URL, tag: String, prefix: String, includeIOS: Bool) async {
        var images: [[String: Any]] = []
        if includeIOS {
            images.append([
                "filename": "\(tag)-\(prefix)ios-1024x1024.png",
                "idiom": "universal",
                "platform": "ios",
                "size": "1024x1024",
            ])
        }
        let macSizes = [16, 32, 128, 256, 512]
        for s in macSizes {
            images.append([
                "filename": "\(tag)-\(prefix)macos-\(s)x\(s).png",
                "idiom": "mac",
                "scale": "1x",
                "size": "\(s)x\(s)",
            ])
        }
        for s in macSizes {
            images.append([
                "filename": "\(tag)-\(prefix)macos-\(s)x\(s)@2x.png",
                "idiom": "mac",
                "scale": "2x",
                "size": "\(s)x\(s)",
            ])
        }

        let contents: [String: Any] = [
            "images": images,
            "info": [
                "author": "xcode",
                "version": 1,
            ],
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: contents, options: .prettyPrinted)
            if let jsonString = String(data: data, encoding: .utf8) {
                try jsonString.write(
                    to: folderPath.appendingPathComponent("Contents.json"),
                    atomically: true,
                    encoding: .utf8
                )
            }
        } catch {
            alert_error("生成 Contents.json 失败: \(error)")
        }
    }
}

#Preview("Xcode Icon Generator") {
    Image.star
        .resizable()
        .scaledToFit()
        .infinite()
        .inBackgroundMint()
        .inMagicContainer(CGSize(width: 1024, height: 1024), scale: 0.6)
}
