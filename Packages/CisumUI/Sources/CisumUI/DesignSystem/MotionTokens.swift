import SwiftUI

// MARK: - Motion
extension DesignTokens {
    /// Motion tokens keep interaction timing consistent across LumiUI.
    enum Motion {
        static let hoverScale: CGFloat = 1.006
        static let pressScale: CGFloat = 0.985
        static let rowHoverScale: CGFloat = 1.004

        static let hover = Animation.easeOut(duration: Duration.micro)
        static let selection = Animation.easeInOut(duration: Duration.standard)
        static let reveal = Animation.easeOut(duration: Duration.standard)
        static let disclosure = Animation.easeInOut(duration: Duration.standard)
        static let messageInsertion = Animation.easeOut(duration: Duration.standard)
        static let scroll = Animation.easeOut(duration: Duration.standard)
        static let statusPresentation = Animation.easeOut(duration: Duration.standard)
        static let press = Animation.interactiveSpring(response: 0.16, dampingFraction: 0.78, blendDuration: 0.02)

        static func enabled(_ animation: Animation, reduceMotion: Bool) -> Animation? {
            reduceMotion ? nil : animation
        }

        static func enabled(_ animation: Animation, preference: LumiMotionPreference) -> Animation? {
            preference.allowsMotion ? animation : nil
        }

        static func listEnabled(_ animation: Animation, preference: LumiMotionPreference) -> Animation? {
            preference.allowsListMotion ? animation : nil
        }

        static func animate(_ animation: Animation?, _ updates: () -> Void) {
            if let animation {
                withAnimation(animation, updates)
            } else {
                updates()
            }
        }
    }
}

// MARK: - Public Motion
public enum LumiMotion {
    public static let hoverScale: CGFloat = DesignTokens.Motion.hoverScale
    public static let pressScale: CGFloat = DesignTokens.Motion.pressScale
    public static let rowHoverScale: CGFloat = DesignTokens.Motion.rowHoverScale

    public static let hover: Animation = DesignTokens.Motion.hover
    public static let selection: Animation = DesignTokens.Motion.selection
    public static let reveal: Animation = DesignTokens.Motion.reveal
    public static let disclosure: Animation = DesignTokens.Motion.disclosure
    public static let messageInsertion: Animation = DesignTokens.Motion.messageInsertion
    public static let scroll: Animation = DesignTokens.Motion.scroll
    public static let statusPresentation: Animation = DesignTokens.Motion.statusPresentation
    public static let press: Animation = DesignTokens.Motion.press

    public static func enabled(_ animation: Animation, reduceMotion: Bool) -> Animation? {
        DesignTokens.Motion.enabled(animation, reduceMotion: reduceMotion)
    }

    public static func enabled(_ animation: Animation, preference: LumiMotionPreference) -> Animation? {
        DesignTokens.Motion.enabled(animation, preference: preference)
    }

    public static func listEnabled(_ animation: Animation, preference: LumiMotionPreference) -> Animation? {
        DesignTokens.Motion.listEnabled(animation, preference: preference)
    }

    public static func animate(_ animation: Animation?, _ updates: () -> Void) {
        DesignTokens.Motion.animate(animation, updates)
    }
}
