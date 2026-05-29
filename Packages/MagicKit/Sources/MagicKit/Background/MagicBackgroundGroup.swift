import SwiftUI

public struct MagicBackgroundGroup {
    public enum GradientName: String, CaseIterable {
        case amber2orange_t2b
        case aquamarine2teal_l2r
        case beige2brown_tl2br
        case black2white_tl2br
        case blue2clear_tl2br
        case blue2cyan
        case blue2green
        case blue2indigo_tl2br
        case blue2purple_l2r
        case blue2white_center
        case blue2yellow_tl2br
        case brown2orange_l2r
        case burgundy2pink_bl2tr
        case charcoal2silver_r2l
        case coral2peach_t2b
        case crimson2rose_bl2tr
        case cyan2green_r2l
        case emerald2jade_bl2tr
        case forest2lime_t2b
        case fuchsia2purple_t2b
        case gold2silver_l2r
        case gray2white_tl2br
        case green2blue_tl2br
        case green2cyan_tl2br
        case green2yellow_br2tl
        case indigo2blue_t2b
        case khaki2olive_l2r
        case lavender2purple_t2b
        case lemon2lime_l2r
        case magenta2pink_r2l
        case maroon2red_bl2tr
        case mint2teal_tl2br
        case navy2skyblue_bl2tr
        case olive2lime_r2l
        case orange2yellow_tl2br
        case peach2cream_t2b
        case pink2purple_t2b
        case plum2lavender_t2b
        case purple2pink_tl2br
        case purple2red_b2t
        case red2orange_tl2br
        case red2yellow_tl2br
        case rose2coral_l2r
        case ruby2garnet_t2b
        case salmon2peach_l2r
        case sapphire2aqua_t2b
        case seagreen2turquoise_bl2tr
        case sienna2tan_r2l
        case slate2gray_t2b
        case sunflower2marigold_bl2tr
        case turquoise2aqua_l2r
        case violet2indigo_r2l
        case yellow2blue_tl2br
        case yellow2green_bl2tr
    }

    struct GradientInfo {
        let startColor: Color
        let endColor: Color
        let startPoint: UnitPoint
        let endPoint: UnitPoint
    }

    static let gradientInfos: [GradientName: GradientInfo] = [
        .amber2orange_t2b: GradientInfo(startColor: .init(red: 1, green: 0.75, blue: 0), endColor: .orange, startPoint: .top, endPoint: .bottom),
        .aquamarine2teal_l2r: GradientInfo(startColor: .init(red: 0.5, green: 1.0, blue: 0.83), endColor: .teal, startPoint: .leading, endPoint: .trailing),
        .beige2brown_tl2br: GradientInfo(startColor: .init(red: 0.96, green: 0.96, blue: 0.86), endColor: .brown, startPoint: .topLeading, endPoint: .bottomTrailing),
        .black2white_tl2br: GradientInfo(startColor: .black, endColor: .white, startPoint: .topLeading, endPoint: .bottomTrailing),
        .blue2clear_tl2br: GradientInfo(startColor: .blue, endColor: .clear, startPoint: .topLeading, endPoint: .bottomTrailing),
        .blue2cyan: GradientInfo(startColor: .blue, endColor: .cyan, startPoint: .top, endPoint: .bottom),
        .blue2green: GradientInfo(startColor: .blue, endColor: .green, startPoint: .top, endPoint: .bottom),
        .blue2indigo_tl2br: GradientInfo(startColor: .blue, endColor: .indigo, startPoint: .topLeading, endPoint: .bottomTrailing),
        .blue2purple_l2r: GradientInfo(startColor: .blue, endColor: .purple, startPoint: .leading, endPoint: .trailing),
        .blue2yellow_tl2br: GradientInfo(startColor: .blue, endColor: .yellow, startPoint: .topLeading, endPoint: .bottomTrailing),
        .brown2orange_l2r: GradientInfo(startColor: .brown, endColor: .orange, startPoint: .leading, endPoint: .trailing),
        .burgundy2pink_bl2tr: GradientInfo(startColor: .init(red: 0.5, green: 0, blue: 0.13), endColor: .pink, startPoint: .bottomLeading, endPoint: .topTrailing),
        .charcoal2silver_r2l: GradientInfo(startColor: .init(red: 0.21, green: 0.27, blue: 0.31), endColor: .init(red: 0.75, green: 0.75, blue: 0.75), startPoint: .trailing, endPoint: .leading),
        .coral2peach_t2b: GradientInfo(startColor: .init(red: 1, green: 0.5, blue: 0.31), endColor: .init(red: 1, green: 0.89, blue: 0.71), startPoint: .top, endPoint: .bottom),
        .crimson2rose_bl2tr: GradientInfo(startColor: .init(red: 0.86, green: 0.08, blue: 0.24), endColor: .init(red: 1, green: 0, blue: 0.5), startPoint: .bottomLeading, endPoint: .topTrailing),
        .cyan2green_r2l: GradientInfo(startColor: .cyan, endColor: .green, startPoint: .trailing, endPoint: .leading),
        .emerald2jade_bl2tr: GradientInfo(startColor: .init(red: 0.31, green: 0.78, blue: 0.47), endColor: .init(red: 0, green: 0.66, blue: 0.42), startPoint: .bottomLeading, endPoint: .topTrailing),
        .forest2lime_t2b: GradientInfo(startColor: .init(red: 0.13, green: 0.55, blue: 0.13), endColor: .init(red: 0.2, green: 0.8, blue: 0.2), startPoint: .top, endPoint: .bottom),
        .fuchsia2purple_t2b: GradientInfo(startColor: .init(red: 1, green: 0, blue: 1), endColor: .purple, startPoint: .top, endPoint: .bottom),
        .gold2silver_l2r: GradientInfo(startColor: .init(red: 1, green: 0.84, blue: 0), endColor: .init(red: 0.75, green: 0.75, blue: 0.75), startPoint: .leading, endPoint: .trailing),
        .gray2white_tl2br: GradientInfo(startColor: .gray, endColor: .white, startPoint: .topLeading, endPoint: .bottomTrailing),
        .green2blue_tl2br: GradientInfo(startColor: .green, endColor: .blue, startPoint: .topLeading, endPoint: .bottomTrailing),
        .green2cyan_tl2br: GradientInfo(startColor: .green, endColor: .cyan, startPoint: .topLeading, endPoint: .bottomTrailing),
        .green2yellow_br2tl: GradientInfo(startColor: .green, endColor: .yellow, startPoint: .bottomTrailing, endPoint: .topLeading),
        .indigo2blue_t2b: GradientInfo(startColor: .indigo, endColor: .blue, startPoint: .top, endPoint: .bottom),
        .khaki2olive_l2r: GradientInfo(startColor: .init(red: 0.94, green: 0.9, blue: 0.55), endColor: .init(red: 0.5, green: 0.5, blue: 0), startPoint: .leading, endPoint: .trailing),
        .lavender2purple_t2b: GradientInfo(startColor: .init(red: 0.9, green: 0.9, blue: 0.98), endColor: .purple, startPoint: .top, endPoint: .bottom),
        .lemon2lime_l2r: GradientInfo(startColor: .init(red: 1, green: 0.97, blue: 0), endColor: .init(red: 0.75, green: 1, blue: 0), startPoint: .leading, endPoint: .trailing),
        .magenta2pink_r2l: GradientInfo(startColor: .init(red: 1, green: 0, blue: 1), endColor: .init(red: 1, green: 0.75, blue: 0.8), startPoint: .trailing, endPoint: .leading),
        .maroon2red_bl2tr: GradientInfo(startColor: .init(red: 0.5, green: 0, blue: 0), endColor: .red, startPoint: .bottomLeading, endPoint: .topTrailing),
        .mint2teal_tl2br: GradientInfo(startColor: .mint, endColor: .teal, startPoint: .topLeading, endPoint: .bottomTrailing),
        .navy2skyblue_bl2tr: GradientInfo(startColor: .init(red: 0, green: 0, blue: 0.5), endColor: .init(red: 0.53, green: 0.81, blue: 0.92), startPoint: .bottomLeading, endPoint: .topTrailing),
        .olive2lime_r2l: GradientInfo(startColor: .init(red: 0.5, green: 0.5, blue: 0), endColor: .init(red: 0.75, green: 1, blue: 0), startPoint: .trailing, endPoint: .leading),
        .orange2yellow_tl2br: GradientInfo(startColor: .orange, endColor: .yellow, startPoint: .topLeading, endPoint: .bottomTrailing),
        .peach2cream_t2b: GradientInfo(startColor: .init(red: 1, green: 0.89, blue: 0.71), endColor: .init(red: 1, green: 0.99, blue: 0.82), startPoint: .top, endPoint: .bottom),
        .pink2purple_t2b: GradientInfo(startColor: .pink, endColor: .purple, startPoint: .top, endPoint: .bottom),
        .plum2lavender_t2b: GradientInfo(startColor: .init(red: 0.87, green: 0.63, blue: 0.87), endColor: .init(red: 0.9, green: 0.9, blue: 0.98), startPoint: .top, endPoint: .bottom),
        .purple2pink_tl2br: GradientInfo(startColor: .purple, endColor: .pink, startPoint: .topLeading, endPoint: .bottomTrailing),
        .purple2red_b2t: GradientInfo(startColor: .purple, endColor: .red, startPoint: .bottom, endPoint: .top),
        .red2orange_tl2br: GradientInfo(startColor: .red, endColor: .orange, startPoint: .topLeading, endPoint: .bottomTrailing),
        .red2yellow_tl2br: GradientInfo(startColor: .red, endColor: .yellow, startPoint: .topLeading, endPoint: .bottomTrailing),
        .rose2coral_l2r: GradientInfo(startColor: .init(red: 1, green: 0, blue: 0.5), endColor: .init(red: 1, green: 0.5, blue: 0.31), startPoint: .leading, endPoint: .trailing),
        .ruby2garnet_t2b: GradientInfo(startColor: .init(red: 0.88, green: 0.07, blue: 0.37), endColor: .init(red: 0.64, green: 0.08, blue: 0.18), startPoint: .top, endPoint: .bottom),
        .salmon2peach_l2r: GradientInfo(startColor: .init(red: 0.98, green: 0.5, blue: 0.45), endColor: .init(red: 1, green: 0.89, blue: 0.71), startPoint: .leading, endPoint: .trailing),
        .sapphire2aqua_t2b: GradientInfo(startColor: .init(red: 0.06, green: 0.32, blue: 0.73), endColor: .init(red: 0, green: 1, blue: 1), startPoint: .top, endPoint: .bottom),
        .seagreen2turquoise_bl2tr: GradientInfo(startColor: .init(red: 0.18, green: 0.55, blue: 0.34), endColor: .init(red: 0.25, green: 0.88, blue: 0.82), startPoint: .bottomLeading, endPoint: .topTrailing),
        .sienna2tan_r2l: GradientInfo(startColor: .init(red: 0.63, green: 0.32, blue: 0.18), endColor: .init(red: 0.82, green: 0.71, blue: 0.55), startPoint: .trailing, endPoint: .leading),
        .slate2gray_t2b: GradientInfo(startColor: .init(red: 0.44, green: 0.5, blue: 0.56), endColor: .gray, startPoint: .top, endPoint: .bottom),
        .sunflower2marigold_bl2tr: GradientInfo(startColor: .init(red: 1, green: 0.84, blue: 0), endColor: .init(red: 0.91, green: 0.59, blue: 0), startPoint: .bottomLeading, endPoint: .topTrailing),
        .turquoise2aqua_l2r: GradientInfo(startColor: .init(red: 0.25, green: 0.88, blue: 0.82), endColor: .init(red: 0, green: 1, blue: 1), startPoint: .leading, endPoint: .trailing),
        .violet2indigo_r2l: GradientInfo(startColor: .init(red: 0.93, green: 0.51, blue: 0.93), endColor: .indigo, startPoint: .trailing, endPoint: .leading),
        .yellow2blue_tl2br: GradientInfo(startColor: .yellow, endColor: .blue, startPoint: .topLeading, endPoint: .bottomTrailing),
        .yellow2green_bl2tr: GradientInfo(startColor: .yellow, endColor: .green, startPoint: .bottomLeading, endPoint: .topTrailing),
    ]

    // 删除 static 关键字，使 gradientView 成为实例方法
    func gradientView(for name: GradientName) -> some View {
        if name == .blue2white_center {
            return AnyView(RadialGradient(gradient: Gradient(colors: [.blue, .white]),
                                          center: .center,
                                          startRadius: 0,
                                          endRadius: 300)
                    .ignoresSafeArea())
        } else {
            let info = Self.gradientInfos[name]!
            return AnyView(LinearGradient(gradient: Gradient(colors: [info.startColor, info.endColor]),
                                          startPoint: info.startPoint,
                                          endPoint: info.endPoint)
                    .ignoresSafeArea())
        }
    }

    // 修改初始化方法
    public init(for name: String) {
        self.name = GradientName(rawValue: name) ?? .blue2cyan // 默认值为 .blue2cyan
    }

    // 保留原有的初始化方法
    public init(for name: GradientName) {
        self.name = name
    }

    // 添加一个存储属性来保存选择的渐变名称
    private let name: GradientName

    // 添加一个计算属性来返回视图
    public var body: some View {
        gradientView(for: name)
    }

    // 添加一个静态属性来提供所有可用的渐变名称
    static public var all: [GradientName] {
        return GradientName.allCases
    }
}

// 使 BackgroundGroup 符合 View 协议
extension MagicBackgroundGroup: View {}

#if DEBUG
#Preview {
    BackgroundGroupPreview()
        .frame(width: 600)
        .frame(height: 800)
}
#endif
