import SwiftUI

/// Public typography tokens for app and plugin UI.
public enum AppTypography {
    public static let largeTitle = Font.system(size: 34, weight: .bold)
    public static let title = Font.system(size: 22, weight: .semibold)
    public static let sectionTitle = Font.system(size: 15, weight: .semibold)
    public static let body = Font.system(size: 15, weight: .regular)
    public static let bodyEmphasized = Font.system(size: 15, weight: .medium)
    public static let callout = Font.system(size: 13, weight: .medium)
    public static let caption = Font.system(size: 12, weight: .regular)
    public static let captionEmphasized = Font.system(size: 12, weight: .medium)
    public static let micro = Font.system(size: 11, weight: .regular)
    public static let microEmphasized = Font.system(size: 11, weight: .medium)
    public static let monoCaption = Font.system(size: 12, weight: .regular, design: .monospaced)
    public static let monoMicro = Font.system(size: 11, weight: .regular, design: .monospaced)
}

public extension Font {
    static var appLargeTitle: Font { AppTypography.largeTitle }
    static var appTitle: Font { AppTypography.title }
    static var appSectionTitle: Font { AppTypography.sectionTitle }
    static var appBody: Font { AppTypography.body }
    static var appBodyEmphasized: Font { AppTypography.bodyEmphasized }
    static var appCallout: Font { AppTypography.callout }
    static var appCaption: Font { AppTypography.caption }
    static var appCaptionEmphasized: Font { AppTypography.captionEmphasized }
    static var appMicro: Font { AppTypography.micro }
    static var appMicroEmphasized: Font { AppTypography.microEmphasized }
    static var appMonoCaption: Font { AppTypography.monoCaption }
    static var appMonoMicro: Font { AppTypography.monoMicro }
}
