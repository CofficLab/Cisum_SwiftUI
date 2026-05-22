import SwiftUI

public enum CisumMagicBackground {
    public static var sunset: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.36, blue: 0.20),
                Color(red: 1.0, green: 0.64, blue: 0.33),
                Color(red: 0.34, green: 0.68, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public static var aurora: some View {
        ZStack {
            Color.black.opacity(0.82)
            LinearGradient(
                colors: [
                    Color.green.opacity(0.45),
                    Color.cyan.opacity(0.34),
                    Color.purple.opacity(0.42)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    public static var deepForest: some View {
        LinearGradient(
            colors: [
                Color(red: 0.04, green: 0.18, blue: 0.12),
                Color(red: 0.11, green: 0.34, blue: 0.22),
                Color(red: 0.02, green: 0.09, blue: 0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public static var deepOceanCurrent: some View {
        LinearGradient(
            colors: [
                Color(red: 0.02, green: 0.09, blue: 0.18),
                Color(red: 0.04, green: 0.27, blue: 0.42),
                Color(red: 0.02, green: 0.12, blue: 0.24)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

