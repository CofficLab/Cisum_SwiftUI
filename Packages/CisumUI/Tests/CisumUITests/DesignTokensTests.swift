import AppKit
import SwiftUI
import Testing
@testable import LumiUI

struct DesignTokensTests {
    // MARK: - Spacing

    @Test
    func spacingScaleIsMonotonicallyIncreasing() {
        let scale: [CGFloat] = [
            DesignTokens.Spacing.xs,
            DesignTokens.Spacing.sm,
            DesignTokens.Spacing.md,
            DesignTokens.Spacing.lg,
            DesignTokens.Spacing.xl,
            DesignTokens.Spacing.xxl,
        ]

        #expect(scale == [4, 8, 16, 24, 32, 48])
        #expect(scale == scale.sorted())
    }

    @Test
    func spacingPaddingPresetsUseMatchingScale() {
        let cardPadding = DesignTokens.Spacing.cardPadding
        let compactPadding = DesignTokens.Spacing.compactPadding
        let comfortablePadding = DesignTokens.Spacing.comfortablePadding

        #expect(cardPadding.top == DesignTokens.Spacing.md)
        #expect(cardPadding.leading == DesignTokens.Spacing.md)
        #expect(cardPadding.bottom == DesignTokens.Spacing.md)
        #expect(cardPadding.trailing == DesignTokens.Spacing.md)

        #expect(compactPadding.top == DesignTokens.Spacing.sm)
        #expect(compactPadding.leading == DesignTokens.Spacing.sm)
        #expect(compactPadding.bottom == DesignTokens.Spacing.sm)
        #expect(compactPadding.trailing == DesignTokens.Spacing.sm)

        #expect(comfortablePadding.top == DesignTokens.Spacing.lg)
        #expect(comfortablePadding.leading == DesignTokens.Spacing.lg)
        #expect(comfortablePadding.bottom == DesignTokens.Spacing.lg)
        #expect(comfortablePadding.trailing == DesignTokens.Spacing.lg)
    }

    // MARK: - Radius

    @Test
    func radiusScaleIsMonotonicallyIncreasing() {
        #expect(DesignTokens.Radius.sm == 8)
        #expect(DesignTokens.Radius.md == 16)
        #expect(DesignTokens.Radius.lg == 24)
        #expect(DesignTokens.Radius.xl == 32)
        #expect(DesignTokens.Radius.full == .infinity)

        let finiteScale: [CGFloat] = [
            DesignTokens.Radius.sm,
            DesignTokens.Radius.md,
            DesignTokens.Radius.lg,
            DesignTokens.Radius.xl,
        ]
        #expect(finiteScale == finiteScale.sorted())
    }

    // MARK: - Duration

    @Test
    func durationScaleIsMonotonicallyIncreasing() {
        let scale: [TimeInterval] = [
            DesignTokens.Duration.micro,
            DesignTokens.Duration.standard,
            DesignTokens.Duration.moderate,
            DesignTokens.Duration.slow,
        ]

        #expect(scale == [0.15, 0.20, 0.30, 0.50])
        #expect(scale == scale.sorted())
    }

    // MARK: - Shadow

    @Test
    func shadowOffsetsAndRadiiAreNonNegative() {
        #expect(DesignTokens.Shadow.subtleRadius == 12)
        #expect(DesignTokens.Shadow.subtleOffset == 4)
        #expect(DesignTokens.Shadow.deepRadius == 20)
        #expect(DesignTokens.Shadow.deepOffset == 8)

        #expect(DesignTokens.Shadow.deepRadius > DesignTokens.Shadow.subtleRadius)
        #expect(DesignTokens.Shadow.deepOffset > DesignTokens.Shadow.subtleOffset)
    }

    @Test
    @MainActor
    func shadowGlowReducesAlphaToConfiguredOpacity() {
        let glow = DesignTokens.Shadow.glow(color: .red)
        let baseline = Color.red.opacity(0.4)

        let glowOpacity = NSColor(glow).usingColorSpace(.sRGB)?.alphaComponent ?? 0
        let baselineOpacity = NSColor(baseline).usingColorSpace(.sRGB)?.alphaComponent ?? 0

        #expect(abs(glowOpacity - baselineOpacity) < 0.001)
    }
}
