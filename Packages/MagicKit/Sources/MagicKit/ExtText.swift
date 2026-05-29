import SwiftUI

// MARK: - Text Extensions

public extension Text {
    // MARK: - Font Weight

    /// 设置文字为半粗体
    /// - Returns: 半粗体文字
    func semibold() -> Text {
        self.fontWeight(.semibold)
    }

    /// 设置文字为中等粗细
    /// - Returns: 中等粗细文字
    func medium() -> Text {
        self.fontWeight(.medium)
    }

    /// 设置文字为细体
    /// - Returns: 细体文字
    func light() -> Text {
        self.fontWeight(.light)
    }

    /// 设置文字为超细体
    /// - Returns: 超细体文字
    func ultraLight() -> Text {
        self.fontWeight(.ultraLight)
    }

    /// 设置文字为常规体
    /// - Returns: 常规粗细文字
    func regular() -> Text {
        self.fontWeight(.regular)
    }

    // MARK: - Font Size Quick Access

    /// 设置大标题样式
    /// - Returns: 大标题文字
    func largeTitle() -> Text {
        self.font(.largeTitle)
    }

    /// 设置标题样式
    /// - Returns: 标题文字
    func title() -> Text {
        self.font(.title)
    }

    /// 设置标题2样式
    /// - Returns: 标题2文字
    func title2() -> Text {
        self.font(.title2)
    }

    /// 设置标题3样式
    /// - Returns: 标题3文字
    func title3() -> Text {
        self.font(.title3)
    }

    /// 设置正文样式
    /// - Returns: 正文文字
    func body() -> Text {
        self.font(.body)
    }

    /// 设置小标题文字（headline）
    /// - Returns: 小标题文字
    func headline() -> Text {
        self.font(.headline)
    }

    /// 设置副标题文字（subheadline）
    /// - Returns: 副标题文字
    func subheadline() -> Text {
        self.font(.subheadline)
    }

    /// 设置脚注文字（footnote）
    /// - Returns: 脚注文字
    func footnote() -> Text {
        self.font(.footnote)
    }

    /// 设置说明文字（caption）
    /// - Returns: 说明文字
    func caption() -> Text {
        self.font(.caption)
    }

    /// 设置大号说明文字（caption2）
    /// - Returns: 大号说明文字
    func caption2() -> Text {
        self.font(.caption2)
    }

    /// 设置大号正文（callout）
    /// - Returns: 大号正文文字
    func callout() -> Text {
        self.font(.callout)
    }

    // MARK: - Font Design

    /// 设置为圆角设计字体
    /// - Returns: 圆角设计文字
    func rounded() -> Text {
        self.font(.system(.body, design: .rounded))
    }

    /// 设置为等宽设计字体
    /// - Returns: 等宽设计文字
    func monospaced() -> Text {
        self.font(.system(.body, design: .monospaced))
    }

    /// 设置为衬线设计字体
    /// - Returns: 衬线设计文字
    func serif() -> Text {
        self.font(.system(.body, design: .serif))
    }

    // MARK: - Custom Font Size

    /// 自定义字体大小
    /// - Parameter size: 字体大小
    /// - Returns: 指定大小的文字
    func size(_ size: CGFloat) -> Text {
        self.font(.system(size: size))
    }

    /// 自定义字体大小和粗细
    /// - Parameters:
    ///   - size: 字体大小
    ///   - weight: 字体粗细
    /// - Returns: 指定大小和粗细的文字
    func size(_ size: CGFloat, weight: Font.Weight) -> Text {
        self.font(.system(size: size, weight: weight))
    }

    /// 自定义字体大小、粗细和设计
    /// - Parameters:
    ///   - size: 字体大小
    ///   - weight: 字体粗细
    ///   - design: 字体设计
    /// - Returns: 自定义样式的文字
    func size(_ size: CGFloat, weight: Font.Weight, design: Font.Design) -> Text {
        self.font(.system(size: size, weight: weight, design: design))
    }

    // MARK: - Text Style Combinations

    /// 大标题粗体
    func largeTitleBold() -> Text {
        self.font(.largeTitle).fontWeight(.bold)
    }

    /// 标题粗体
    func titleBold() -> Text {
        self.font(.title).fontWeight(.bold)
    }

    /// 标题2粗体
    func title2Bold() -> Text {
        self.font(.title2).fontWeight(.bold)
    }

    /// 标题3粗体
    func title3Bold() -> Text {
        self.font(.title3).fontWeight(.bold)
    }

    /// 正文粗体
    func bodyBold() -> Text {
        self.font(.body).fontWeight(.bold)
    }

    /// 大号粗体圆角文字
    func largeBoldRounded() -> Text {
        self.font(.system(size: 28, weight: .bold, design: .rounded))
    }

    /// 大号粗体等宽文字
    func largeBoldMonospaced() -> Text {
        self.font(.system(size: 24, weight: .bold, design: .monospaced))
    }

    // MARK: - Color Quick Access

    /// 设置文字颜色为红色
    func red() -> Text {
        self.foregroundColor(.red)
    }

    /// 设置文字颜色为蓝色
    func blue() -> Text {
        self.foregroundColor(.blue)
    }

    /// 设置文字颜色为绿色
    func green() -> Text {
        self.foregroundColor(.green)
    }

    /// 设置文字颜色为橙色
    func orange() -> Text {
        self.foregroundColor(.orange)
    }

    /// 设置文字颜色为黄色
    func yellow() -> Text {
        self.foregroundColor(.yellow)
    }

    /// 设置文字颜色为粉色
    func pink() -> Text {
        self.foregroundColor(.pink)
    }

    /// 设置文字颜色为紫色
    func purple() -> Text {
        self.foregroundColor(.purple)
    }

    /// 设置文字颜色为灰色
    func gray() -> Text {
        self.foregroundColor(.gray)
    }

    /// 设置文字颜色为次要颜色
    func secondary() -> Text {
        self.foregroundColor(.secondary)
    }

    /// 设置文字颜色为白色
    func white() -> Text {
        self.foregroundColor(.white)
    }

    /// 设置文字颜色为黑色
    func black() -> Text {
        self.foregroundColor(.black)
    }

    /// 设置文字颜色为主色调
    func primary() -> Text {
        self.foregroundColor(.primary)
    }

    // MARK: - Combined Quick Styles

    /// 大标题样式：粗体、主色调
    func heroTitle() -> Text {
        self.font(.largeTitle).fontWeight(.bold).foregroundColor(.primary)
    }

    /// 副标题样式：中等粗细、次要颜色
    func subtitle() -> Text {
        self.font(.title3).fontWeight(.medium).foregroundColor(.secondary)
    }

    /// 说明文字样式：小号、次要颜色
    func description() -> Text {
        self.font(.body).foregroundColor(.secondary)
    }

    /// 标签文字样式：小号、粗体
    func tag() -> Text {
        self.font(.caption).fontWeight(.semibold)
    }

    /// 按钮文字样式：中等粗细
    func buttonStyle() -> Text {
        self.font(.body).fontWeight(.medium)
    }
}

// MARK: - Preview

#if DEBUG

#Preview("Text Extensions") {
    VStack(spacing: 25) {
        Text("📝 Text Extensions")
            .font(.largeTitle)
            .fontWeight(.bold)

        VStack(spacing: 12) {
            Text("Bold").bold()
            Text("Semibold").semibold()
            Text("Medium").medium()
            Text("Light").light()
        }

        VStack(spacing: 12) {
            Text("Large Title").largeTitle()
            Text("Title").title()
            Text("Body").body()
            Text("Caption").caption()
        }

        HStack(spacing: 12) {
            Text("Red").red().bold()
            Text("Blue").blue().bold()
            Text("Green").green().bold()
            Text("Purple").purple().bold()
        }

        VStack(spacing: 12) {
            Text("Hero Title").heroTitle()
            Text("Subtitle Text").subtitle()
            Text("Description text").description()
            Text("TAG").tag()
        }

        VStack(spacing: 12) {
            Text("Custom Size 12").size(12)
            Text("Custom Size 20").size(20)
            Text("Custom Size 32").size(32)
        }

        VStack(spacing: 8) {
            Text("Text(\"Hello\").bold()")
                .font(.system(.caption, design: .monospaced))
            Text("Text(\"Title\").largeTitle()")
                .font(.system(.caption, design: .monospaced))
            Text("Text(\"Red\").red().size(20)")
                .font(.system(.caption, design: .monospaced))
            Text("Text(\"Hero\").heroTitle()")
                .font(.system(.caption, design: .monospaced))
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    .padding()
    .frame(maxWidth: .infinity)
    .inScrollView()
    .frame(height: 750)
    .frame(width: 550)
}

#if DEBUG
#Preview("Quick Usage Examples") {
    VStack(spacing: 20) {
        Text("Quick Usage Examples")
            .font(.title)
            .fontWeight(.bold)

        VStack(spacing: 15) {
            HStack {
                Text("Bold").bold()
                Text("Red").red()
                Text("Large").largeTitle()
            }

            HStack {
                Text("Custom").size(20, weight: .semibold, design: .rounded)
                Text("Purple").purple()
                Text("Italic").italic()
            }

            Text("Hero Title Example")
                .heroTitle()

            Text("This is a subtitle with secondary color")
                .subtitle()

            Text("TAG")
                .tag()
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
    }
    .padding()
    .frame(maxWidth: .infinity)
    .inScrollView()
    .frame(height: 750)
    .frame(width: 550)
}
#endif

#if DEBUG
#Preview("Text Style Demo") {
    VStack(spacing: 20) {
        Text("Text Style Demo")
            .font(.title)
            .fontWeight(.bold)

        VStack(spacing: 12) {
            Text("Normal Text")

            Text("Bold Text").bold()

            Text("Semibold Text").semibold()

            Text("Large Title").largeTitle()

            Text("Custom Size 24").size(24)

            Text("Hero Title").heroTitle()
        }
    }
    .padding()
    .frame(maxWidth: .infinity)
    .inScrollView()
    .frame(height: 750)
    .frame(width: 550)
}
#endif

#endif
