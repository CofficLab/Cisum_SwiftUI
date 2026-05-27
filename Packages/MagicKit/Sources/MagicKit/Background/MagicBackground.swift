import SwiftUI

/// 提供应用程序的自定义背景效果
///
/// `MagicBackground`是一个可重用的视图组件，提供了多种预设的背景效果，
/// 包括磨砂效果、渐变和动画波浪等。可以根据不同的颜色方案自动调整外观。
///
/// ## 使用示例:
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         Text("Hello, World!")
///             .padding()
///             .background(MagicBackground())
///     }
/// }
/// ```
public struct MagicBackground: View {
    /// 背景的颜色方案，默认为浅色模式
    var colorScheme: ColorScheme = .light
    
    public var body: some View {
        Self.frost
    }
}

/// 颜色扩展，提供从十六进制字符串创建颜色的功能
extension Color {
    /// 使用十六进制字符串初始化颜色
    ///
    /// 支持以下格式的十六进制字符串:
    /// - 3位RGB格式: 例如 "F00"（等同于 "FF0000"）
    /// - 6位RGB格式: 例如 "FF0000"
    /// - 8位ARGB格式: 例如 "FFFF0000"
    ///
    /// - Parameter hex: 表示颜色的十六进制字符串，可以包含或不包含前缀 "#"
    ///
    /// ## 使用示例:
    /// ```swift
    /// // 创建红色
    /// let red = Color(hex: "FF0000")
    /// // 创建半透明蓝色
    /// let translucentBlue = Color(hex: "800000FF")
    /// ```
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

/// 波浪形状，用于创建动画波浪效果
///
/// 这个形状可以用于创建流动的波浪效果，通过调整相位角度可以实现动画效果。
/// 波浪的高度、波长和振幅可以通过修改路径计算来调整。
///
/// ## 使用示例:
/// ```swift
/// struct WaveView: View {
///     @State private var phase = Angle(degrees: 0)
///     
///     var body: some View {
///         Wave(phase: phase)
///             .fill(Color.blue.opacity(0.3))
///             .frame(height: 200)
///             .onAppear {
///                 withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
///                     phase = Angle(degrees: 360)
///                 }
///             }
///     }
/// }
/// ```
struct Wave: Shape {
    /// 波浪的相位角度，用于控制波浪的水平位置
    var phase: Angle
    
    /// 创建波浪形状的路径
    ///
    /// - Parameter rect: 形状的边界矩形
    /// - Returns: 表示波浪的路径
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height * 0.5
        let wavelength = width * 0.8
        let amplitude = height * 0.1
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin(relativeX * 2 * .pi + phase.radians)
            let y = midHeight + amplitude * sine
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

/// 预览辅助视图，用于在预览中展示不同的背景效果
///
/// 这个视图将背景和标题组合在一起，便于在SwiftUI预览中比较不同的背景效果。
struct BackgroundPreviewItem: View {
    /// 要展示的背景视图
    let background: AnyView
    /// 背景的描述标题
    let title: String
    /// 标题文本的颜色，默认为白色
    var textColor: Color = .white
    
    /// 创建一个背景预览项
    ///
    /// - Parameters:
    ///   - background: 要展示的背景视图
    ///   - title: 背景的描述标题
    ///   - textColor: 标题文本的颜色，默认为白色
    init<V: View>(background: V, title: String, textColor: Color = .white) {
        self.background = AnyView(background)
        self.title = title
        self.textColor = textColor
    }
    
    var body: some View {
        ZStack {
            background
            Text(title)
                .foregroundColor(textColor)
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
