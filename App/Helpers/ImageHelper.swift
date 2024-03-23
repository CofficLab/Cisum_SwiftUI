import Foundation
import SwiftUI
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#endif

class ImageHelper {
    static func toJpeg(image: CGImage) {
        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            print("Failed to access downloads folder.")
            return
        }

        let path = downloadsURL.appendingPathComponent("c.jpeg")

        guard let destination = CGImageDestinationCreateWithURL(path as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else {
            print("创建图像目标失败")
            return
        }

        CGImageDestinationAddImage(destination, image, nil)

        guard CGImageDestinationFinalize(destination) else {
            print("图像保存失败")
            return
        }
    }
    
    #if os(macOS)
    static func toJpeg(image: NSImage, saveTo: URL? = nil) {
        var saveToUrl = saveTo
        if saveToUrl == nil {
            guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
                let message = "Failed to access downloads folder."
                print(message)
                return
            }

            saveToUrl = downloadsURL.appendingPathComponent("\(getTimeString()).jpeg")
        }
        
        // 将 NSImage 对象转换为 NSBitmapImageRep 对象
        guard let imageData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: imageData) else {
            // 转换失败
            return
        }

        // 设置保存选项
        let properties: [NSBitmapImageRep.PropertyKey: Any] = [
            .compressionFactor: 0.8 // 设置 JPEG 压缩质量为 80%
        ]

        // 将位图写入磁盘
        if let jpgData = bitmapRep.representation(using: .jpeg, properties: properties) {
            do {
                try jpgData.write(to: saveToUrl!)
            } catch {
                // 保存失败
                print("保存图像失败：\(error)")
            }
        }
    }
    #endif
    
    static private func getTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter.string(from: Date())
    }
    
    @MainActor static func getViewWidth(_ view: some View) -> Int {
        makeCGImage(view).width
    }

    @MainActor static func getViewHeigth(_ view: some View) -> Int {
        makeCGImage(view).height
    }
    
    @MainActor static func makeCGImage(_ view: some View) -> CGImage {
        ImageRenderer(content: view).cgImage!
    }

    @MainActor static func makeImage(_ view: some View) -> Image {
        Image(makeCGImage(view), scale: 1, label: Text("目标图像"))
    }
    
    @MainActor static func snapshot(_ view: some View, path: URL? = nil) -> String {
        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            return "Failed to access downloads folder."
        }

        let width = getViewWidth(view)
        let heigth = getViewHeigth(view)
        let defaultPath = downloadsURL.appendingPathComponent("\(getTimeString())-\(width)x\(heigth).png")
        let path = path == nil ? defaultPath : path!

        guard let destination = CGImageDestinationCreateWithURL(path as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            return "创建图像目标失败"
        }

        CGImageDestinationAddImage(destination, makeCGImage(view), nil)

        guard CGImageDestinationFinalize(destination) else {
            return "图像保存失败"
        }

        return "已存储到下载文件夹"
    }
}
