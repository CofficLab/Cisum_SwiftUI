import SwiftUI

public extension View {
    func cisumInfinite() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func cisumInfiniteHeight(alignment: Alignment = .center) -> some View {
        frame(maxHeight: .infinity, alignment: alignment)
    }

    @ViewBuilder
    func cisumIf(_ condition: Bool) -> some View {
        if condition {
            self
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func cisumIf<Else: View>(_ condition: Bool, otherwise: () -> Else) -> some View {
        if condition {
            self
        } else {
            otherwise()
        }
    }

    @ViewBuilder
    func cisumIf<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func cisumIf<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if trueTransform: (Self) -> TrueContent,
        otherwise falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }

    func cisumButtonNoAction() -> some View {
        Button(action: {}) {
            self
        }
        .buttonStyle(.plain)
    }

    func cisumButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            self
        }
        .buttonStyle(.plain)
    }

    func cisumHoverScale(_ scale: CGFloat) -> some View {
        modifier(CisumHoverScaleModifier(scale: scale / 100.0))
    }

    func cisumHoverScale(_ scale: CGFloat, duration: Double) -> some View {
        modifier(CisumHoverScaleModifier(scale: scale / 100.0, duration: duration))
    }

    func cisumShadow(
        color: Color = .black.opacity(0.1),
        radius: CGFloat = 8,
        x: CGFloat = 0,
        y: CGFloat = 2
    ) -> some View {
        shadow(color: color, radius: radius, x: x, y: y)
    }

    func cisumShadowXs() -> some View {
        cisumShadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }

    func cisumShadowSm() -> some View {
        cisumShadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    func cisumShadowMd() -> some View {
        cisumShadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 1)
    }

    func cisumShadowLg() -> some View {
        cisumShadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
    }

    func cisumShadowXl() -> some View {
        cisumShadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
    }

    func cisumShadow2xl() -> some View {
        cisumShadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 12)
    }

    func cisumShadow3xl() -> some View {
        cisumShadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 20)
    }

    func cisumRounded(
        radius: CGFloat = 8,
        style: RoundedCornerStyle = .continuous
    ) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius, style: style))
    }

    func cisumRoundedSmall() -> some View {
        cisumRounded(radius: 4)
    }

    func cisumRoundedMedium() -> some View {
        cisumRounded(radius: 8)
    }

    func cisumRoundedLarge() -> some View {
        cisumRounded(radius: 16)
    }

    func cisumRoundedExtraLarge() -> some View {
        cisumRounded(radius: 24)
    }

    func cisumRoundedFull() -> some View {
        clipShape(Circle())
    }

    func cisumCard(_ material: Material = .regularMaterial) -> some View {
        padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.clear.background(material))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    func cisumCard(color: Color) -> some View {
        padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    func cisumCentered() -> some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    self
                    Spacer()
                }
                Spacer()
            }
        }
    }

    func cisumVStackCenter(
        spacing: CGFloat? = nil,
        alignment: HorizontalAlignment = .center,
        topSpacer: Bool = true,
        bottomSpacer: Bool = true
    ) -> some View {
        VStack(alignment: alignment, spacing: spacing) {
            if topSpacer {
                Spacer()
            }
            self
            if bottomSpacer {
                Spacer()
            }
        }
    }

    func cisumHStackCenter(
        spacing: CGFloat? = nil,
        alignment: VerticalAlignment = .center,
        leadingSpacer: Bool = true,
        trailingSpacer: Bool = true
    ) -> some View {
        HStack(alignment: alignment, spacing: spacing) {
            if leadingSpacer {
                Spacer()
            }
            self
            if trailingSpacer {
                Spacer()
            }
        }
    }

    func cisumScrollView(
        axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        contentInsets: EdgeInsets? = nil
    ) -> some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            if let contentInsets {
                self.padding(contentInsets)
            } else {
                self
            }
        }
    }

    func cisumDivider(spacing: CGFloat = 0) -> some View {
        VStack(spacing: spacing) {
            self
            Divider()
        }
    }

    func cisumDashedBorder(
        color: Color = .gray,
        lineWidth: CGFloat = 1,
        dash: [CGFloat] = [5, 5]
    ) -> some View {
        overlay(
            Rectangle()
                .strokeBorder(style: StrokeStyle(lineWidth: lineWidth, dash: dash))
                .foregroundColor(color)
        )
    }

    func cisumPt1() -> some View {
        padding(.top, 4)
    }

    func cisumPx2() -> some View {
        padding(.horizontal, 8)
    }

    func cisumPy4() -> some View {
        padding(.vertical, 16)
    }

    func cisumPreviewContainer(
        _ containerSize: CGSize = CGSize(width: 500, height: 750),
        scale: CGFloat = 1.0
    ) -> some View {
        VStack(spacing: 0) {
            self
                .frame(width: containerSize.width, height: containerSize.height)
                .cisumDashedBorder(color: .accentColor)
                .scaleEffect(scale)
                .frame(width: containerSize.width * scale, height: containerSize.height * scale)
        }
        .padding(24)
        .background(.background)
    }
}

public extension CGSize {
    static let cisumIPhone55 = CGSize(width: 1242, height: 2208)
    static let cisumIPhone65 = CGSize(width: 1242, height: 2688)
    static let cisumIPhone69 = CGSize(width: 1290, height: 2796)
    static let cisumMacBook13 = CGSize(width: 2560, height: 1600)
    static let cisumIMac27 = CGSize(width: 5120, height: 2880)
}

private struct CisumHoverScaleModifier: ViewModifier {
    let scale: CGFloat
    let duration: Double

    @State private var isHovering = false

    init(scale: CGFloat, duration: Double = 0.2) {
        self.scale = scale
        self.duration = duration
    }

    func body(content: Content) -> some View {
        #if os(macOS)
            content
                .scaleEffect(isHovering ? scale : 1.0)
                .animation(.easeInOut(duration: duration), value: isHovering)
                .onHover { hovering in
                    isHovering = hovering
                }
        #else
            content
        #endif
    }
}
