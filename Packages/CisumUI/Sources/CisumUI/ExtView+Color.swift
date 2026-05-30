import SwiftUI

// MARK: - Extended Colors

public extension Color {
    // MARK: - Basic Colors

    /// 纯白色
    static let pureWhite = Color(red: 1.0, green: 1.0, blue: 1.0)
    /// 纯黑色
    static let pureBlack = Color(red: 0.0, green: 0.0, blue: 0.0)

    // MARK: - Gray Scale

    /// 极浅灰 #FAFAFA
    static let gray50 = Color(hex: "FAFAFA")
    /// 浅灰 #F5F5F5
    static let gray100 = Color(hex: "F5F5F5")
    /// 中浅灰 #E0E0E0
    static let gray200 = Color(hex: "E0E0E0")
    /// 中灰 #BDBDBD
    static let gray300 = Color(hex: "BDBDBD")
    /// 深中灰 #9E9E9E
    static let gray400 = Color(hex: "9E9E9E")
    /// 暗灰 #757575
    static let gray500 = Color(hex: "757575")
    /// 深灰 #616161
    static let gray600 = Color(hex: "616161")
    /// 极深灰 #424242
    static let gray700 = Color(hex: "424242")
    /// 近黑 #212121
    static let gray800 = Color(hex: "212121")
    /// 深黑 #121212
    static let gray900 = Color(hex: "121212")

    // MARK: - Red Scale

    /// 浅红 #FFCDD2
    static let red50 = Color(hex: "FFCDD2")
    /// 淡红 #F8BBD9
    static let red100 = Color(hex: "EF9A9A")
    /// 中红 #E57373
    static let red200 = Color(hex: "E57373")
    /// 鲜红 #EF5350
    static let red300 = Color(hex: "EF5350")
    /// 亮红 #F44336
    static let red400 = Color(hex: "F44336")
    /// 标准红 #E53935
    static let red500 = Color(hex: "E53935")
    /// 深红 #D32F2F
    static let red600 = Color(hex: "D32F2F")
    /// 暗红 #C62828
    static let red700 = Color(hex: "C62828")
    /// 极深红 #B71C1C
    static let red800 = Color(hex: "B71C1C")
    /// 血红 #880E4F
    static let red900 = Color(hex: "880E4F")

    // MARK: - Pink Scale

    /// 浅粉 #FCE4EC
    static let pink50 = Color(hex: "FCE4EC")
    /// 淡粉 #F8BBD0
    static let pink100 = Color(hex: "F8BBD0")
    /// 中粉 #F48FB1
    static let pink200 = Color(hex: "F48FB1")
    /// 鲜粉 #F06292
    static let pink300 = Color(hex: "F06292")
    /// 亮粉 #EC407A
    static let pink400 = Color(hex: "EC407A")
    /// 标准粉 #E91E63
    static let pink500 = Color(hex: "E91E63")
    /// 深粉 #D81B60
    static let pink600 = Color(hex: "D81B60")
    /// 暗粉 #C2185B
    static let pink700 = Color(hex: "C2185B")
    /// 极深粉 #AD1457
    static let pink800 = Color(hex: "AD1457")
    /// 紫粉 #880E4F
    static let pink900 = Color(hex: "880E4F")

    // MARK: - Purple Scale

    /// 浅紫 #F3E5F5
    static let purple50 = Color(hex: "F3E5F5")
    /// 淡紫 #E1BEE7
    static let purple100 = Color(hex: "E1BEE7")
    /// 中紫 #CE93D8
    static let purple200 = Color(hex: "CE93D8")
    /// 鲜紫 #BA68C8
    static let purple300 = Color(hex: "BA68C8")
    /// 亮紫 #AB47BC
    static let purple400 = Color(hex: "AB47BC")
    /// 标准紫 #9C27B0
    static let purple500 = Color(hex: "9C27B0")
    /// 深紫 #8E24AA
    static let purple600 = Color(hex: "8E24AA")
    /// 暗紫 #7B1FA2
    static let purple700 = Color(hex: "7B1FA2")
    /// 极深紫 #6A1B9A
    static let purple800 = Color(hex: "6A1B9A")
    /// 深紫蓝 #4A148C
    static let purple900 = Color(hex: "4A148C")

    // MARK: - Blue Scale

    /// 浅蓝 #E3F2FD
    static let blue50 = Color(hex: "E3F2FD")
    /// 淡蓝 #BBDEFB
    static let blue100 = Color(hex: "BBDEFB")
    /// 中蓝 #90CAF9
    static let blue200 = Color(hex: "90CAF9")
    /// 鲜蓝 #64B5F6
    static let blue300 = Color(hex: "64B5F6")
    /// 亮蓝 #42A5F5
    static let blue400 = Color(hex: "42A5F5")
    /// 标准蓝 #2196F3
    static let blue500 = Color(hex: "2196F3")
    /// 深蓝 #1E88E5
    static let blue600 = Color(hex: "1E88E5")
    /// 暗蓝 #1976D2
    static let blue700 = Color(hex: "1976D2")
    /// 极深蓝 #1565C0
    static let blue800 = Color(hex: "1565C0")
    /// 深蓝黑 #0D47A1
    static let blue900 = Color(hex: "0D47A1")

    // MARK: - Cyan Scale

    /// 浅青 #E0F7FA
    static let cyan50 = Color(hex: "E0F7FA")
    /// 淡青 #B2EBF2
    static let cyan100 = Color(hex: "B2EBF2")
    /// 中青 #80DEEA
    static let cyan200 = Color(hex: "80DEEA")
    /// 鲜青 #4DD0E1
    static let cyan300 = Color(hex: "4DD0E1")
    /// 亮青 #26C6DA
    static let cyan400 = Color(hex: "26C6DA")
    /// 标准青 #00BCD4
    static let cyan500 = Color(hex: "00BCD4")
    /// 深青 #00ACC1
    static let cyan600 = Color(hex: "00ACC1")
    /// 暗青 #0097A7
    static let cyan700 = Color(hex: "0097A7")
    /// 极深青 #00838F
    static let cyan800 = Color(hex: "00838F")
    /// 深青黑 #006064
    static let cyan900 = Color(hex: "006064")

    // MARK: - Teal Scale

    /// 浅青绿 #E0F2F1
    static let teal50 = Color(hex: "E0F2F1")
    /// 淡青绿 #B2DFDB
    static let teal100 = Color(hex: "B2DFDB")
    /// 中青绿 #80CBC4
    static let teal200 = Color(hex: "80CBC4")
    /// 鲜青绿 #4DB6AC
    static let teal300 = Color(hex: "4DB6AC")
    /// 亮青绿 #26A69A
    static let teal400 = Color(hex: "26A69A")
    /// 标准青绿 #009688
    static let teal500 = Color(hex: "009688")
    /// 深青绿 #00897B
    static let teal600 = Color(hex: "00897B")
    /// 暗青绿 #00796B
    static let teal700 = Color(hex: "00796B")
    /// 极深青绿 #00695C
    static let teal800 = Color(hex: "00695C")
    /// 深青绿黑 #004D40
    static let teal900 = Color(hex: "004D40")

    // MARK: - Green Scale

    /// 浅绿 #E8F5E9
    static let green50 = Color(hex: "E8F5E9")
    /// 淡绿 #C8E6C9
    static let green100 = Color(hex: "C8E6C9")
    /// 中绿 #A5D6A7
    static let green200 = Color(hex: "A5D6A7")
    /// 鲜绿 #81C784
    static let green300 = Color(hex: "81C784")
    /// 亮绿 #66BB6A
    static let green400 = Color(hex: "66BB6A")
    /// 标准绿 #4CAF50
    static let green500 = Color(hex: "4CAF50")
    /// 深绿 #43A047
    static let green600 = Color(hex: "43A047")
    /// 暗绿 #388E3C
    static let green700 = Color(hex: "388E3C")
    /// 极深绿 #2E7D32
    static let green800 = Color(hex: "2E7D32")
    /// 深绿黑 #1B5E20
    static let green900 = Color(hex: "1B5E20")

    // MARK: - Lime Scale

    /// 浅柠绿 #F9FBE7
    static let lime50 = Color(hex: "F9FBE7")
    /// 淡柠绿 #F0F4C3
    static let lime100 = Color(hex: "F0F4C3")
    /// 中柠绿 #E6EE9C
    static let lime200 = Color(hex: "E6EE9C")
    /// 鲜柠绿 #DCE775
    static let lime300 = Color(hex: "DCE775")
    /// 亮柠绿 #D4E157
    static let lime400 = Color(hex: "D4E157")
    /// 标准柠绿 #CDDC39
    static let lime500 = Color(hex: "CDDC39")
    /// 深柠绿 #C0CA33
    static let lime600 = Color(hex: "C0CA33")
    /// 暗柠绿 #AFB42B
    static let lime700 = Color(hex: "AFB42B")
    /// 极深柠绿 #9E9D24
    static let lime800 = Color(hex: "9E9D24")
    /// 深柠绿黑 #827717
    static let lime900 = Color(hex: "827717")

    // MARK: - Yellow Scale

    /// 浅黄 #FFFDE7
    static let yellow50 = Color(hex: "FFFDE7")
    /// 淡黄 #FFF9C4
    static let yellow100 = Color(hex: "FFF9C4")
    /// 中黄 #FFF59D
    static let yellow200 = Color(hex: "FFF59D")
    /// 鲜黄 #FFF176
    static let yellow300 = Color(hex: "FFF176")
    /// 亮黄 #FFEE58
    static let yellow400 = Color(hex: "FFEE58")
    /// 标准黄 #FFEB3B
    static let yellow500 = Color(hex: "FFEB3B")
    /// 深黄 #FDD835
    static let yellow600 = Color(hex: "FDD835")
    /// 暗黄 #FBC02D
    static let yellow700 = Color(hex: "FBC02D")
    /// 极深黄 #F9A825
    static let yellow800 = Color(hex: "F9A825")
    /// 深黄黑 #F57F17
    static let yellow900 = Color(hex: "F57F17")

    // MARK: - Orange Scale

    /// 浅橙 #FFF3E0
    static let orange50 = Color(hex: "FFF3E0")
    /// 淡橙 #FFE0B2
    static let orange100 = Color(hex: "FFE0B2")
    /// 中橙 #FFCC80
    static let orange200 = Color(hex: "FFCC80")
    /// 鲜橙 #FFB74D
    static let orange300 = Color(hex: "FFB74D")
    /// 亮橙 #FFA726
    static let orange400 = Color(hex: "FFA726")
    /// 标准橙 #FF9800
    static let orange500 = Color(hex: "FF9800")
    /// 深橙 #FB8C00
    static let orange600 = Color(hex: "FB8C00")
    /// 暗橙 #F57C00
    static let orange700 = Color(hex: "F57C00")
    /// 极深橙 #EF6C00
    static let orange800 = Color(hex: "EF6C00")
    /// 深橙黑 #E65100
    static let orange900 = Color(hex: "E65100")

    // MARK: - Brown Scale

    /// 浅棕 #EFEBE9
    static let brown50 = Color(hex: "EFEBE9")
    /// 淡棕 #D7CCC8
    static let brown100 = Color(hex: "D7CCC8")
    /// 中棕 #BCAAA4
    static let brown200 = Color(hex: "BCAAA4")
    /// 鲜棕 #A1887F
    static let brown300 = Color(hex: "A1887F")
    /// 亮棕 #8D6E63
    static let brown400 = Color(hex: "8D6E63")
    /// 标准棕 #795548
    static let brown500 = Color(hex: "795548")
    /// 深棕 #6D4C41
    static let brown600 = Color(hex: "6D4C41")
    /// 暗棕 #5D4037
    static let brown700 = Color(hex: "5D4037")
    /// 极深棕 #4E342E
    static let brown800 = Color(hex: "4E342E")
    /// 深棕黑 #3E2723
    static let brown900 = Color(hex: "3E2723")

    // MARK: - Nature Colors

    /// 天空蓝 #87CEEB
    static let skyBlue = Color(hex: "87CEEB")
    /// 海洋蓝 #1E90FF
    static let oceanBlue = Color(hex: "1E90FF")
    /// 森林绿 #228B22
    static let forestGreen = Color(hex: "228B22")
    /// 草地绿 #7CFC00
    static let grassGreen = Color(hex: "7CFC00")
    /// 沙漠黄 #EDC9AF
    static let desertSand = Color(hex: "EDC9AF")
    /// 山岩灰 #8B7355
    static let mountainGray = Color(hex: "8B7355")

    // MARK: - Food Colors

    /// 柠檬黄 #FFF44F
    static let lemonYellow = Color(hex: "FFF44F")
    /// 橙子橙 #FFA500
    static let orangeFruit = Color(hex: "FFA500")
    /// 草莓红 #FF6B6B
    static let strawberryRed = Color(hex: "FF6B6B")
    /// 蓝莓蓝 #4169E1
    static let blueberryBlue = Color(hex: "4169E1")
    /// 葡萄紫 #8B5CF6
    static let grapePurple = Color(hex: "8B5CF6")
    /// 巧克力棕 #3D2314
    static let chocolateBrown = Color(hex: "3D2314")
    /// 薄荷绿 #98FF98
    static let mintGreen = Color(hex: "98FF98")
    /// 桃子粉 #FFDAB9
    static let peachPink = Color(hex: "FFDAB9")

    // MARK: - Season Colors

    /// 春天绿 #88B04B
    static let springGreen = Color(hex: "88B04B")
    /// 夏天蓝 #00BFFF
    static let summerBlue = Color(hex: "00BFFF")
    /// 秋天橙 #FF6F00
    static let autumnOrange = Color(hex: "FF6F00")
    /// 冬天蓝 #E0FFFF
    static let winterBlue = Color(hex: "E0FFFF")

    // MARK: - Gradient Helper Colors

    /// 日落渐变起始色 #FF6B6B
    static let sunsetStart = Color(hex: "FF6B6B")
    /// 日落渐变结束色 #4A90E2
    static let sunsetEnd = Color(hex: "4A90E2")
    /// 极光渐变起始色 #667eea
    static let auroraStart = Color(hex: "667eea")
    /// 极光渐变结束色 #764ba2
    static let auroraEnd = Color(hex: "764ba2")
}

// MARK: - Color Convenience Initializers

public extension Color {
    /// 从 RGB 值创建颜色
    /// - Parameters:
    ///   - red: 红色分量 (0-255)
    ///   - green: 绿色分量 (0-255)
    ///   - blue: 蓝色分量 (0-255)
    ///   - opacity: 不透明度 (0-1, 默认 1)
    static func rgb(_ red: Int, _ green: Int, _ blue: Int, opacity: Double = 1.0) -> Color {
        Color(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: opacity
        )
    }
}

// MARK: - Preview

#if DEBUG

#Preview("Extended Colors") {
    ScrollView {
        VStack(spacing: 20) {
            Text("Extended Colors")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom)

            Group {
                ColorSection(title: "Gray Scale", colors: [
                    ("Gray 50", Color.gray50),
                    ("Gray 100", Color.gray100),
                    ("Gray 200", Color.gray200),
                    ("Gray 500", Color.gray500),
                    ("Gray 800", Color.gray800),
                    ("Gray 900", Color.gray900),
                ])

                ColorSection(title: "Red Scale", colors: [
                    ("Red 100", Color.red100),
                    ("Red 300", Color.red300),
                    ("Red 500", Color.red500),
                    ("Red 700", Color.red700),
                    ("Red 900", Color.red900),
                ])

                ColorSection(title: "Nature Colors", colors: [
                    ("Sky Blue", Color.skyBlue),
                    ("Ocean Blue", Color.oceanBlue),
                    ("Forest Green", Color.forestGreen),
                    ("Grass Green", Color.grassGreen),
                    ("Desert Sand", Color.desertSand),
                ])

                ColorSection(title: "Food Colors", colors: [
                    ("Lemon", Color.lemonYellow),
                    ("Orange", Color.orangeFruit),
                    ("Strawberry", Color.strawberryRed),
                    ("Blueberry", Color.blueberryBlue),
                    ("Mint", Color.mintGreen),
                ])

                ColorSection(title: "Season Colors", colors: [
                    ("Spring", Color.springGreen),
                    ("Summer", Color.summerBlue),
                    ("Autumn", Color.autumnOrange),
                    ("Winter", Color.winterBlue),
                ])
            }
        }
        .padding()
    }
}

#if DEBUG
#Preview("Color Usage Examples") {
    VStack(spacing: 20) {
        Text("Color Usage Examples")
            .font(.title)
            .fontWeight(.bold)

        VStack(spacing: 15) {
            Text("Custom Text Color")
                .font(.title2)
                .foregroundColor(Color.red500)

            Text("Custom Background")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue500)

            Text("Border Color")
                .font(.title2)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.purple500, lineWidth: 2)
                )

            HStack(spacing: 15) {
                Circle().fill(Color.red500).frame(width: 50, height: 50)
                Circle().fill(Color.green500).frame(width: 50, height: 50)
                Circle().fill(Color.blue500).frame(width: 50, height: 50)
                Circle().fill(Color.yellow500).frame(width: 50, height: 50)
            }

            Text("Hex Color Example")
                .font(.title2)
                .foregroundColor(Color(hex: "FF6B6B"))
        }
    }
    .padding()
}
#endif

#if DEBUG
#Preview("Color Gradient") {
    VStack(spacing: 20) {
        Text("Gradient Examples")
            .font(.title)
            .fontWeight(.bold)

        VStack(spacing: 15) {
            Text("Sunset Gradient")
                .font(.title2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.sunsetStart, Color.sunsetEnd]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Aurora Gradient")
                .font(.title2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.auroraStart, Color.auroraEnd]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
    .padding()
}
#endif

// MARK: - Helper Views

private struct ColorSection: View {
    let title: String
    let colors: [(String, Color)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)

            VStack(spacing: 8) {
                ForEach(colors, id: \.0) { name, color in
                    HStack {
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )

                        Text(name)
                            .font(.body)
                            .foregroundColor(.primary)

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

#endif
