import SwiftUI

public protocol SuperScreen {
    var screenWidth: CGFloat { get }
    var screenHeight: CGFloat { get }
    var deviceImageName: String { get }
    var landscapeImageName: String? { get }
    var screenOffsetX: CGFloat { get }
    var screenOffsetY: CGFloat { get }
}

public struct ScreenBase<Content>: View where Content: View {
    private let content: Content
    private let device: SuperScreen
    public var horizon = false

    public init(device: SuperScreen, horizon: Bool = false, @ViewBuilder content: () -> Content) {
        self.device = device
        self.horizon = horizon
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                fullView
            }
            // 缩放，来适配外部提供的容器
            .scaleEffect(getScale(geo), anchor: .topLeading)
            // 显示在外部提供的容器的中心
            .offset(x: getOffsetX(geo), y: getOffsetY(geo))
        }
    }

    @MainActor var fullView: some View {
        ZStack {
            content
                .frame(width: device.screenWidth, height: device.screenHeight)
                .offset(x: device.screenOffsetX, y: device.screenOffsetY)

            getDeviceImage()
        }
        .frame(width: getDeviceWidth())
        .frame(height: getDeviceHeight())
    }

    private func getDeviceImage() -> Image {
        if horizon, let landscapeImageName = device.landscapeImageName {
            return Image(landscapeImageName, bundle: Bundle.module)
        } else {
            return Image(device.deviceImageName, bundle: Bundle.module)
        }
    }

    // MARK: X的偏移量，用于居中

    @MainActor func getOffsetX(_ geo: GeometryProxy) -> CGFloat {
        if getScale(geo) == geo.size.width / getDeviceWidth() {
            return 0
        }

        return (geo.size.width - getScale(geo) * getDeviceWidth()) * 0.5
    }

    // MARK: Y的偏移量，用于居中

    @MainActor func getOffsetY(_ geo: GeometryProxy) -> CGFloat {
        if getScale(geo) == geo.size.height / getDeviceHeight() {
            return 0
        }

        return (geo.size.height - getScale(geo) * getDeviceHeight()) * 0.5
    }

    // MARK: 缩放的比例

    @MainActor func getScale(_ geo: GeometryProxy) -> CGFloat {
        min(geo.size.width / getDeviceWidth(), geo.size.height / getDeviceHeight())
    }

    // MARK: 设备图片的高度

    @MainActor private func getDeviceHeight() -> CGFloat {
        CGFloat(Self.getViewHeight(getDeviceImage()))
    }

    // MARK: 设备图片的宽度

    @MainActor private func getDeviceWidth() -> CGFloat {
        CGFloat(Self.getViewWidth(getDeviceImage()))
    }

    // MARK: 设备图片的尺寸

    @MainActor private func getDeviceSize() -> String {
        let deviceImage = getDeviceImage()
        return "\(Self.getViewWidth(deviceImage)) X \(Self.getViewHeight(deviceImage))"
    }

    // MARK: 设备图片的屏幕尺寸

    @MainActor private func getScreenSize() -> String {
        "\(device.screenWidth) X \(device.screenHeight)"
    }

    /// 获取 SwiftUI 视图的宽度
    ///
    /// - Parameter view: 需要测量的 SwiftUI 视图
    /// - Returns: 视图的宽度（像素）
    /// - Note: 此方法必须在主线程上调用
    @MainActor public static func getViewWidth(_ view: some View) -> Int {
        makeCGImage(view).width
    }

    /// 获取 SwiftUI 视图的高度
    ///
    /// - Parameter view: 需要测量的 SwiftUI 视图
    /// - Returns: 视图的高度（像素）
    /// - Note: 此方法必须在主线程上调用
    @MainActor public static func getViewHeight(_ view: some View) -> Int {
        makeCGImage(view).height
    }

    /// 将 SwiftUI 视图转换为 CGImage
    ///
    /// - Parameter view: 需要转换的 SwiftUI 视图
    /// - Returns: 转换后的 CGImage 对象
    /// - Note: 此方法必须在主线程上调用
    ///        如果转换失败，会创建一个1x1的透明图片作为fallback
    @MainActor public static func makeCGImage(_ view: some View) -> CGImage {
        let renderer = ImageRenderer(content: view)
        if let cgImage = renderer.cgImage {
            return cgImage
        } else {
            // 如果渲染失败，创建一个1x1的透明图片作为fallback
            let size = CGSize(width: 1, height: 1)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            return context.makeImage()!
        }
    }
}

// MARK: - Preview

#Preview("iPhone - Landscape") {
    HStack {
        Spacer()
        Image(systemName: "iphone")
            .font(.system(size: 150))
            .foregroundColor(.green)

        VStack(alignment: .leading) {
            Spacer()
            Text("iPhone 横屏")
                .font(.system(size: 80))
                .fontWeight(.bold)

            Text("横屏模式")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Spacer()
        }
        Spacer()
    }
    .padding(15)
    .background(.green.opacity(0.2))
    .inIPhoneScreen(horizon: true)
}

#Preview("iMac - Basic") {
    HStack {
        Spacer()
        VStack {
            Spacer()
            Image(systemName: "desktopcomputer")
                .font(.system(size: 400))
                .foregroundColor(.blue)

            Text("iMac 预览")
                .font(.system(size: 300))
                .fontWeight(.bold)
            Spacer()
        }
        Spacer()
    }
    .padding(40)
    .background(.orange.opacity(0.2))
    .inIMacScreen()
}

#Preview("iMac - Custom View") {
    HStack {
        Spacer()
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "star.fill")
                .font(.system(size: 400))
                .foregroundColor(.yellow)

            Text("自定义视图")
                .font(.system(size: 400))
                .fontWeight(.semibold)
            Spacer()
        }
        Spacer()
    }
    .padding(30)
    .background(.blue.opacity(0.1))
    .inIMacScreen()
}
