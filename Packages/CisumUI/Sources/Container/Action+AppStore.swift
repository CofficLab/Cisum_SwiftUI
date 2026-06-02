import MagicAlert
import SwiftUI

extension MagicContainer {
    /// App Store截图功能实现 (生成多种分辨率的图片)
    func captureAppStoreView() {
        #if os(macOS)
            // App Store要求的iPhone截图尺寸
            let iPhoneSizes: [(String, CGSize)] = [
                ("iPhone_6.9inch", CGSize(width: 1290, height: 2796)), // iPhone 14 Pro Max, etc.
                ("iPhone_6.5inch", CGSize(width: 1284, height: 2778)), // iPhone 12 Pro Max, etc.
                ("iPhone_5.8inch", CGSize(width: 1170, height: 2532)), // iPhone 12, etc.
                ("iPhone_5.5inch", CGSize(width: 1242, height: 2208)), // iPhone 8 Plus, etc.
                ("iPhone_4.7inch", CGSize(width: 750, height: 1334)), // iPhone SE 2nd gen, etc.
            ]

            // App Store要求的iPad截图尺寸
            let iPadSizes: [(String, CGSize)] = [
                ("iPad_12.9inch", CGSize(width: 2048, height: 2732)), // iPad Pro 12.9"
                ("iPad_11inch", CGSize(width: 1668, height: 2388)), // iPad Pro 11"
                ("iPad_10.5inch", CGSize(width: 1668, height: 2224)), // iPad Pro 10.5"
            ]

            // 为每种尺寸生成截图
            for (name, size) in iPhoneSizes + iPadSizes {
                let scaledContent = content
                    .frame(width: size.width, height: size.height)

                let title = "\(name)_\(Date().compactDateTime)_\(Int(size.width))x\(Int(size.height))"
                do {
                    try scaledContent.snapshot(title: title, scale: 1.0)
                } catch {
                    alert_error(error)
                    return
                }
            }

            alert_info("已生成App Store所需的各种尺寸截图")
        #endif
    }

    /// macOS App Store截图功能实现 (生成多种分辨率的图片)
    func captureMacAppStoreView() {
        #if os(macOS)
            // App Store要求的macOS截图尺寸 (16:10比例)
            let macOSSizes: [(String, CGSize)] = [
                ("macOS_1280x800", CGSize(width: 1280, height: 800)),
                ("macOS_1440x900", CGSize(width: 1440, height: 900)),
                ("macOS_2560x1600", CGSize(width: 2560, height: 1600)),
                ("macOS_2880x1800", CGSize(width: 2880, height: 1800)),
            ]

            // 为每种尺寸生成截图
            for (name, size) in macOSSizes {
                let scaledContent = content
                    .frame(width: size.width, height: size.height)

                let title = "\(name)_\(Date().compactDateTime)_\(Int(size.width))x\(Int(size.height))"
                do {
                    try scaledContent.snapshot(title: title, scale: 1.0)
                } catch {
                    alert_error("生成 \(name) 截图失败: \(error.localizedDescription)")
                    return
                }
            }

            alert_info("已生成macOS App Store所需的各种尺寸截图")
        #endif
    }
}

#Preview("iMac 27 - 20%") {
    GeometryReader { geo in
        Text("Hello, World!")
            .font(.system(size: geo.size.width * 0.1))
            .padding()
            .infinite()
            .inBackgroundMint()
    }
    .inMagicContainer(.iMac27, scale: 0.2)
}

#Preview("iMac 27 - 10%") {
    GeometryReader { geo in
        Text("Hello, World!")
            .font(.system(size: geo.size.width * 0.1))
            .padding()
            .infinite()
            .inBackgroundMint()
    }
    .inMagicContainer(.iMac27, scale: 0.1)
}
