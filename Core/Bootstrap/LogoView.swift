import MagicAsset
import SwiftUI

// MARK: - Types

extension LogoView {
    enum BackgroundShape {
        case none
        case circle
        case rectangle
        case roundedRectangle(cornerRadius: CGFloat)
        case capsule
    }
}

struct LogoView: View {
    var background: Color? = nil
    var rotationSpeed: Double = 0.0
    var backgroundShape: BackgroundShape = .none
    
    @State private var rotationAngle: Double = 0.0

    init(background: Color? = nil, rotationSpeed: Double = 0.0, backgroundShape: BackgroundShape = .none) {
        self.background = background
        self.rotationSpeed = rotationSpeed
        self.backgroundShape = backgroundShape
    }

    var body: some View {
        Image.makeCoffeeReelIcon(
            useDefaultBackground: false,
            // x版本指向x点钟方向
            handleRotation: 0
        )
        .frame(height: 200)
        .frame(width: 200)
        .background(backgroundShapeView)
        .rotationEffect(.degrees(rotationAngle))
        .onAppear {
            if rotationSpeed > 0 {
                startRotation()
            }
        }
    }
    
    @ViewBuilder
    private var backgroundShapeView: some View {
        if let background = background {
            switch backgroundShape {
            case .none:
                background
            case .circle:
                Circle().fill(background)
            case .rectangle:
                Rectangle().fill(background)
            case .roundedRectangle(let cornerRadius):
                RoundedRectangle(cornerRadius: cornerRadius).fill(background)
            case .capsule:
                Capsule().fill(background)
            }
        }
    }
    
    private func startRotation() {
        withAnimation(.linear(duration: 1.0 / rotationSpeed).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
}

#if os(macOS)
#Preview("LogoView") {
    ScrollView {
        LogoView()
            .frame(width: 400, height: 250)

        LogoView(background: .blue.opacity(0.2), backgroundShape: .circle)
            .frame(width: 400, height: 250)

        LogoView(background: .green.opacity(0.2), backgroundShape: .roundedRectangle(cornerRadius: 20))
            .frame(width: 400, height: 250)

        LogoView(background: .orange.opacity(0.2), rotationSpeed: 0.5, backgroundShape: .capsule)
            .frame(width: 400, height: 250)
    }
    .frame(height: 800)
}
#endif

#if os(iOS)
#Preview("LogoView - iPhone") {
    LogoView(background: .purple.opacity(0.2), backgroundShape: .circle)
}
#endif
