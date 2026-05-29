import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// SwiftUI Image 的平台扩展
public extension Image {
    #if os(macOS)
        /// 平台特定的图片类型 (macOS 使用 NSImage)
        typealias PlatformImage = NSImage
    #else
        /// 平台特定的图片类型 (iOS/tvOS/watchOS 使用 UIImage)
        typealias PlatformImage = UIImage
    #endif
}

/// 平台特定图片类型的扩展
public extension Image.PlatformImage {
    /// 图片缩放质量
    enum ResizeQuality {
        /// 无优化，最快速度
        case none
        /// 低质量，适合缩略图
        case low
        /// 中等质量，平衡速度和质量
        case medium
        /// 高质量，最佳效果但较慢
        case high
    }

    /// 获取默认音频图标
    /// ```swift
    /// let audioIcon = Image.PlatformImage.defaultAudioIcon
    /// imageView.image = audioIcon
    /// ```
    static var defaultAudioIcon: Image.PlatformImage? {
        systemImage(.iconMusicNote)
    }

    /// 获取系统图标
    /// - Parameter name: SF Symbols 图标名称
    /// - Returns: 系统图标，如果不存在则返回 nil
    /// ```swift
    /// let icon = Image.PlatformImage.systemImage("star.fill")
    /// ```
    static func systemImage(_ name: String) -> Image.PlatformImage? {
        #if os(macOS)
            return NSImage(systemSymbolName: name, accessibilityDescription: nil)
        #else
            return UIImage(systemName: name)
        #endif
    }

    /// 从文件 URL 创建图片
    /// - Parameter url: 图片文件的 URL
    /// - Returns: 创建的图片，如果失败则返回 nil
    /// ```swift
    /// let url = URL(fileURLWithPath: "/path/to/image.jpg")
    /// if let image = Image.PlatformImage.fromFile(url) {
    ///     imageView.image = image
    /// }
    /// ```
    static func fromFile(_ url: URL) -> Image.PlatformImage? {
        #if os(macOS)
            return NSImage(contentsOf: url)
        #else
            return UIImage(contentsOfFile: url.path)
        #endif
    }

    /// 从 CGImage 创建图片
    /// - Parameters:
    ///   - cgImage: CGImage 对象
    ///   - size: 目标大小（仅 macOS 需要）
    /// - Returns: 创建的图片
    static func fromCGImage(_ cgImage: CGImage, size: CGSize) -> Image.PlatformImage {
        #if os(macOS)
            return NSImage(cgImage: cgImage, size: size)
        #else
            return UIImage(cgImage: cgImage)
        #endif
    }

    /// 调整图片大小
    /// - Parameters:
    ///   - size: 目标大小
    ///   - quality: 缩放质量
    /// - Returns: 调整大小后的图片
    func resize(to size: CGSize, quality: ResizeQuality = .none) -> Image.PlatformImage {
        #if os(macOS)
            let newImage = NSImage(size: size)
            newImage.lockFocus()
            draw(in: NSRect(origin: .zero, size: size),
                 from: NSRect(origin: .zero, size: self.size),
                 operation: .copy,
                 fraction: 1.0)
            newImage.unlockFocus()
            return newImage
        #else
            let format = UIGraphicsImageRendererFormat()
            #if os(visionOS)
                format.scale = quality == .none ? 1 : 2 // Use a default scale for visionOS
            #else
                format.scale = quality == .none ? 1 : UIScreen.main.scale
            #endif
            let renderer = UIGraphicsImageRenderer(size: size, format: format)

            return renderer.image { _ in
                draw(in: CGRect(origin: .zero, size: size))
            }
        #endif
    }

    /// 从缓存数据创建图片
    static func fromCacheData(_ data: Data) -> Image.PlatformImage? {
        #if os(macOS)
            return NSImage(data: data)
        #else
            return UIImage(data: data)
        #endif
    }

    /// 获取图片的二进制数据
    var cacheData: Data? {
        #if os(macOS)
            return tiffRepresentation
        #else
            return pngData()
        #endif
    }

    /// 获取文件夹图标
    /// - Parameter size: 目标大小
    /// - Returns: 调整大小后的文件夹图标
    static func folderIcon(size: CGSize) -> Image.PlatformImage? {
        if let folderIcon = systemImage(.iconFolderFill) {
            #if !os(macOS)
                folderIcon.withTintColor(.systemBlue)
            #endif
            return folderIcon.resize(to: size)
        }
        return systemImage(.iconFolder)
    }

    /// Create platform image from system icon name
    /// - Parameter icon: The system icon name
    /// - Returns: Platform specific image
    static func fromSystemIcon(_ icon: String) -> Image.PlatformImage? {
        #if os(macOS)
            return NSImage(systemSymbolName: icon, accessibilityDescription: nil)
        #else
            return UIImage(systemName: icon)
        #endif
    }

    /// Convert platform image to SwiftUI Image
    /// - Returns: SwiftUI Image
    func toSwiftUIImage() -> Image {
        #if os(macOS)
            return Image(nsImage: self)
        #else
            return Image(uiImage: self)
        #endif
    }

    /// 创建一个示例图片，包含渐变色和文字
    /// - Parameter size: 图片尺寸
    /// - Returns: 生成的示例图片
    static func sampleImage(size: CGSize) -> Image.PlatformImage {
        #if os(macOS)
            let image = NSImage(size: size)

            image.lockFocus()

            // 创建渐变背景
            let gradient = NSGradient(
                colors: [
                    NSColor.systemBlue,
                    NSColor.systemPurple,
                ]
            )
            gradient?.draw(in: NSRect(origin: .zero, size: size), angle: 45)

            // 添加文字
            let text = "Sample Cover"
            let font = NSFont.systemFont(ofSize: size.width * 0.1)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor.white,
            ]

            let textSize = text.size(withAttributes: attributes)
            let textRect = NSRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            text.draw(in: textRect, withAttributes: attributes)

            image.unlockFocus()

            return image
        #else
            let renderer = UIGraphicsImageRenderer(size: size)

            return renderer.image { context in
                // 创建渐变背景
                let colors = [
                    UIColor.systemBlue.cgColor,
                    UIColor.systemPurple.cgColor,
                ]
                let gradient = CGGradient(
                    colorsSpace: CGColorSpaceCreateDeviceRGB(),
                    colors: colors as CFArray,
                    locations: [0, 1]
                )!

                context.cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )

                // 添加文字
                let text = "Sample Cover"
                let font = UIFont.systemFont(ofSize: size.width * 0.1)
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: UIColor.white,
                ]

                let textSize = text.size(withAttributes: attributes)
                let textRect = CGRect(
                    x: (size.width - textSize.width) / 2,
                    y: (size.height - textSize.height) / 2,
                    width: textSize.width,
                    height: textSize.height
                )

                text.draw(in: textRect, withAttributes: attributes)
            }
        #endif
    }
}

/// 平台图片功能演示视图
struct PlatformImageDemoView: View {
    /// 创建平台无关的 SwiftUI Image
    private func platformImage(_ image: Image.PlatformImage) -> Image {
        #if os(macOS)
            Image(nsImage: image)
        #else
            Image(uiImage: image)
        #endif
    }

    var body: some View {
        TabView {
            // 基础功能演示
            VStack(spacing: 20) {
                // 系统图标
                VStack(alignment: .leading, spacing: 12) {
                    Text("系统图标")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        MagicKeyValue(key: "默认音频图标", value: "music.note") {
                            if let icon = Image.PlatformImage.defaultAudioIcon {
                                platformImage(icon)
                            }
                        }
                        MagicKeyValue(key: "文件夹图标", value: "folder.fill") {
                            if let icon = Image.PlatformImage.folderIcon(size: CGSize(width: 24, height: 24)) {
                                platformImage(icon)
                            }
                        }
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // 示例图片
                VStack(alignment: .leading, spacing: 12) {
                    Text("示例图片")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    let sampleImage = Image.PlatformImage.sampleImage(size: CGSize(width: 200, height: 100))
                    platformImage(sampleImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()

            .tabItem {
                Image(systemName: "1.circle.fill")
                Text("基础")
            }

            // 图片处理演示
            VStack(spacing: 20) {
                // 缩放质量演示
                VStack(alignment: .leading, spacing: 12) {
                    Text("缩放质量")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    let originalImage = Image.PlatformImage.sampleImage(size: CGSize(width: 300, height: 150))
                    let targetSize = CGSize(width: 150, height: 75)

                    VStack(spacing: 8) {
                        ForEach([
                            Image.PlatformImage.ResizeQuality.none,
                            .low,
                            .medium,
                            .high,
                        ], id: \.self) { quality in
                            let resizedImage = originalImage.resize(to: targetSize, quality: quality)
                            MagicKeyValue(key: "\(quality)".capitalized, value: "\(Int(targetSize.width))x\(Int(targetSize.height))") {
                                platformImage(resizedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: targetSize.width)
                            }
                        }
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()

            .tabItem {
                Image(systemName: "2.circle.fill")
                Text("处理")
            }
        }
    }
}

#if DEBUG
#Preview("平台图片演示") {
    NavigationStack {
        PlatformImageDemoView()
    }
}
#endif
