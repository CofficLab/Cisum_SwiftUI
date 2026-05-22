import AppKit
import SwiftUI
import Testing
@testable import LumiUI

private struct RGBA: Equatable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat

    init(_ color: Color) {
        let nsColor = NSColor(color).usingColorSpace(.sRGB) ?? .black
        self.red = nsColor.redComponent
        self.green = nsColor.greenComponent
        self.blue = nsColor.blueComponent
        self.alpha = nsColor.alphaComponent
    }

    func isApproximatelyEqual(to other: RGBA, tolerance: CGFloat = 0.005) -> Bool {
        abs(red - other.red) <= tolerance
            && abs(green - other.green) <= tolerance
            && abs(blue - other.blue) <= tolerance
            && abs(alpha - other.alpha) <= tolerance
    }
}

struct ColorHexTests {
    @Test
    @MainActor
    func sixDigitHexParsesPureRed() {
        let parsed = RGBA(Color(hex: "FF0000"))

        #expect(parsed.isApproximatelyEqual(to: RGBA(red: 1, green: 0, blue: 0)))
    }

    @Test
    @MainActor
    func threeDigitHexExpandsToSixDigitEquivalent() {
        let short = RGBA(Color(hex: "F0A"))
        let long = RGBA(Color(hex: "FF00AA"))

        #expect(short.isApproximatelyEqual(to: long))
    }

    @Test
    @MainActor
    func eightDigitHexAppliesAlphaChannel() {
        let opaque = RGBA(Color(hex: "FF00FF00"))
        let halfAlpha = RGBA(Color(hex: "8000FF00"))

        #expect(opaque.alpha > 0.99)
        #expect(halfAlpha.alpha < opaque.alpha)
        #expect(halfAlpha.alpha > 0.45 && halfAlpha.alpha < 0.55)
    }

    @Test
    @MainActor
    func nonStandardLengthFallsBackToDefaultBranch() {
        // 4-character strings hit the `default` branch, which uses
        // (a, r, g, b) = (1, 1, 1, 0); confirm the result is essentially black with near-zero alpha.
        let parsed = RGBA(Color(hex: "FFFF"))

        #expect(parsed.alpha < 0.01)
    }

    @Test
    @MainActor
    func adaptiveColorDoesNotCrashAndResolvesToOneOfTheVariants() {
        let adaptive = Color.adaptive(light: "FFFFFF", dark: "000000")
        let resolved = NSColor(adaptive).usingColorSpace(.sRGB)

        #expect(resolved != nil)
        let isWhite = (resolved?.redComponent ?? 0) > 0.95 && (resolved?.alphaComponent ?? 0) > 0.95
        let isBlack = (resolved?.redComponent ?? 1) < 0.05 && (resolved?.alphaComponent ?? 0) > 0.95
        #expect(isWhite || isBlack)
    }
}

private extension RGBA {
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}
