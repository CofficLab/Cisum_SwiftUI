import SwiftUI
import MagicKit

public enum CisumMagicBackground {
    public static let sunset = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.36, blue: 0.20),
            Color(red: 1.0, green: 0.64, blue: 0.33),
            Color(red: 0.34, green: 0.68, blue: 1.0),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let aurora = LinearGradient(
        colors: [
            Color.green.opacity(0.35),
            Color.cyan.opacity(0.25),
            Color.purple.opacity(0.35),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let deepOceanCurrent = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.18, blue: 0.29),
            Color(red: 0.07, green: 0.36, blue: 0.42),
            Color(red: 0.16, green: 0.48, blue: 0.55),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let deepForest = LinearGradient(
        colors: [
            Color(red: 0.07, green: 0.18, blue: 0.11),
            Color(red: 0.12, green: 0.32, blue: 0.18),
            Color(red: 0.33, green: 0.48, blue: 0.30),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
