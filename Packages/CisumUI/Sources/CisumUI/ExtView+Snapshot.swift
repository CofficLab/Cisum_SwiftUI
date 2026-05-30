import SwiftUI
import Foundation
import UniformTypeIdentifiers

// MARK: - Snapshot Extensions
public extension View {
    /// 获取视图的宽度
    /// 
    /// - Returns: 视图的宽度（像素）
    /// - Note: 此方法必须在主线程上调用
    @MainActor func getWidth() -> Int {
        Image.makeCGImage(from: self).width
    }

    /// 获取视图的高度
    /// 
    /// - Returns: 视图的高度（像素）
    /// - Note: 此方法必须在主线程上调用
    @MainActor func getHeight() -> Int {
        Image.makeCGImage(from: self).height
    }
    
    /// 将视图转换为 SwiftUI Image 对象
    /// 
    /// - Returns: 转换后的 SwiftUI Image 对象
    /// - Note: 此方法必须在主线程上调用
    ///        返回的 Image 对象比例因子为 1，标签文本为"目标图像"
    @MainActor func toImage() -> Image {
        Image.fromView(self)
    }
    
    /// 将视图转换为 CGImage
    /// 
    /// - Returns: 转换后的 CGImage 对象
    /// - Note: 此方法必须在主线程上调用
    ///        如果转换失败，会创建一个1x1的透明图片作为fallback
    @MainActor func toCGImage() -> CGImage {
        Image.makeCGImage(from: self)
    }

    /// 将视图快照保存为 PNG 图像文件。
    ///
    /// 此方法通过 `ImageRenderer` 将 SwiftUI 视图转换为图像，并允许通过 `scale` 参数控制输出的分辨率。
    ///
    /// - Parameters:
    ///   - path: 保存文件的目标 URL。如果为 `nil`，将自动生成文件名并保存到用户的“下载”文件夹。
    ///   - title: 文件名（不含扩展名）。如果为 `nil`，将使用时间戳和尺寸信息自动命名。
    ///   - scale: 渲染的缩放因子。
    ///     - `0.0` (默认值): 使用当前显示器的原生缩放因子，能匹配屏幕上的显示效果。
    ///     - `1.0`: 标准分辨率，1 点 = 1 像素。
    ///     - `> 1.0`: 高分辨率。对于矢量图形（如 SVG），应使用高值（如 4.0 或 8.0）以确保导出图像的清晰度。
    /// - Throws: `SnapshotError` 如果在任何步骤中失败。
    @MainActor func snapshot(path: URL? = nil, title: String? = nil, scale: CGFloat = 0.0) throws {
        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            throw SnapshotError.failedToAccessDownloads
        }

        // 使用 ImageRenderer 以支持缩放渲染
        let renderer = ImageRenderer(content: self)
        renderer.scale = scale

        guard let cgImage = renderer.cgImage else {
            throw SnapshotError.imageRenderFailed
        }

        let width = cgImage.width
        let height = cgImage.height
        let fileName = title != nil ? "\(title!).png" : "\(Image.getTimeString())-\(width)x\(height).png"
        let defaultPath = downloadsURL.appendingPathComponent(fileName)
        let finalPath = path ?? defaultPath

        guard let destination = CGImageDestinationCreateWithURL(finalPath as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            throw SnapshotError.destinationCreateFailed
        }

        CGImageDestinationAddImage(destination, cgImage, nil)

        guard CGImageDestinationFinalize(destination) else {
            throw SnapshotError.saveFailed
        }
    }
}

/// 快照过程中可能发生的错误
public enum SnapshotError: Error, LocalizedError {
    case failedToAccessDownloads
    case imageRenderFailed
    case destinationCreateFailed
    case saveFailed

    public var errorDescription: String? {
        switch self {
        case .failedToAccessDownloads:
            return "无法访问下载文件夹。"
        case .imageRenderFailed:
            return "图像渲染失败。"
        case .destinationCreateFailed:
            return "创建图像目标失败，请确保应用有下载目录的写入权限。"
        case .saveFailed:
            return "图像保存失败。"
        }
    }
}
