//
//  ExtNSImage.swift
//  MagicKit
//
//  NSImage 扩展，提供图片生成和转换功能
//

#if canImport(AppKit)
import AppKit
import SwiftUI

public extension NSImage {
    /// 创建一个简单的测试图片，带有渐变背景和文字
    /// - Parameters:
    ///   - size: 图片尺寸，默认为 800x600
    ///   - text: 显示的文字，默认为 "MagicKit\nTest Image"
    ///   - colors: 渐变颜色数组，默认为蓝紫渐变
    /// - Returns: 生成的测试图片
    static func testImage(
        size: NSSize = NSSize(width: 800, height: 600),
        text: String = "MagicKit\nTest Image",
        colors: [NSColor] = [
            NSColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0),
            NSColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1.0)
        ]
    ) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()

        // 创建渐变背景
        let gradient = NSGradient(colors: colors)
        gradient?.draw(in: NSRect(origin: .zero, size: size), angle: 45)

        // 添加文字
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 48, weight: .bold),
            .foregroundColor: NSColor.white
        ]
        let textSize = text.size(withAttributes: attrs)
        let textRect = NSRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: attrs)

        image.unlockFocus()
        return image
    }

    /// 将 NSImage 转换为 JPEG 数据
    /// - Parameter compressionFactor: 压缩质量（0.0-1.0），默认为 0.8
    /// - Returns: JPEG 数据，如果转换失败则返回 nil
    func jpegData(compressionFactor: CGFloat = 0.8) -> Data? {
        guard let tiffData = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: compressionFactor])
    }

    /// 将 NSImage 转换为 PNG 数据
    /// - Returns: PNG 数据，如果转换失败则返回 nil
    func pngData() -> Data? {
        guard let tiffData = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmap.representation(using: .png, properties: [:])
    }

    /// 将图片保存到文件
    /// - Parameters:
    ///   - url: 目标文件 URL
    ///   - compressionFactor: JPEG 压缩质量（0.0-1.0），默认为 0.8
    /// - Returns: 是否保存成功
    @discardableResult
    func writeToURL(_ url: URL, compressionFactor: CGFloat = 0.8) -> Bool {
        guard let jpegData = jpegData(compressionFactor: compressionFactor) else {
            return false
        }
        do {
            try jpegData.write(to: url)
            return true
        } catch {
            return false
        }
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("测试图片") {
        VStack(spacing: 20) {
            VStack {
                Image(nsImage: .testImage())
                    .resizable()
                    .frame(width: 200, height: 150)
                Text("默认测试图片")
                    .font(.caption)
            }
            
            Divider()

            VStack {
                Image(nsImage: .testImage(
                    size: NSSize(width: 200, height: 150),
                    text: "自定义"
                ))
                .resizable()
                .frame(width: 200, height: 150)
                Text("自定义文字")
                    .font(.caption)
            }
            
            Divider()

            VStack {
                Image(nsImage: .testImage(
                    size: NSSize(width: 200, height: 150),
                    colors: [
                        NSColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0),
                        NSColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
                    ]
                ))
                .resizable()
                .frame(width: 200, height: 150)
                Text("自定义颜色")
                    .font(.caption)
            }
        }
        .padding()
        .frame(width: 300)
        .frame(height: 800)
    }
#endif

#endif
