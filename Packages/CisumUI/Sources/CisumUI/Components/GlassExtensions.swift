import SwiftUI

public extension View {
    func glowEffect(
        color: SwiftUI.Color,
        radius: CGFloat = 8,
        intensity: Double = 0.3
    ) -> some View {
        shadow(
            color: color.opacity(intensity),
            radius: radius,
            x: 0,
            y: 0
        )
    }

    func glassOverlay(opacity: Double = 0.1) -> some View {
        overlay(
            SwiftUI.Color.black.opacity(opacity)
                .background(DesignTokens.Material.glass)
        )
    }
}
