import SwiftUI

public enum LumiTransition {
    public static func messageInsertion(reduceMotion: Bool) -> AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .bottom)),
                removal: .opacity
            )
    }

    public static func disclosureContent(reduceMotion: Bool) -> AnyTransition {
        reduceMotion
            ? .opacity
            : .opacity.combined(with: .move(edge: .top))
    }

    public static func statusPresentation(reduceMotion: Bool) -> AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .top)),
                removal: .opacity
            )
    }

    /// 切歌时标题等文本切换
    public static func trackChange(reduceMotion: Bool) -> AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .opacity.combined(with: .offset(y: 6)),
                removal: .opacity.combined(with: .offset(y: -6))
            )
    }

    /// 播放/暂停图标切换
    public static func playbackIcon(reduceMotion: Bool) -> AnyTransition {
        reduceMotion
            ? .opacity
            : .scale(scale: 0.82).combined(with: .opacity)
    }

    /// 曲库面板展开
    public static func panelReveal(reduceMotion: Bool) -> AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .opacity
            )
    }

    public static func trackChange(preference: LumiMotionPreference) -> AnyTransition {
        trackChange(reduceMotion: !preference.allowsMotion)
    }

    public static func playbackIcon(preference: LumiMotionPreference) -> AnyTransition {
        playbackIcon(reduceMotion: !preference.allowsMotion)
    }

    public static func panelReveal(preference: LumiMotionPreference) -> AnyTransition {
        panelReveal(reduceMotion: !preference.allowsMotion)
    }

    public static func messageInsertion(preference: LumiMotionPreference) -> AnyTransition {
        messageInsertion(reduceMotion: !preference.allowsListMotion)
    }

    public static func disclosureContent(preference: LumiMotionPreference) -> AnyTransition {
        disclosureContent(reduceMotion: !preference.allowsMotion)
    }

    public static func statusPresentation(preference: LumiMotionPreference) -> AnyTransition {
        statusPresentation(reduceMotion: !preference.allowsMotion)
    }
}

public extension View {
    func appMessageInsertionTransition(reduceMotion: Bool) -> some View {
        transition(LumiTransition.messageInsertion(reduceMotion: reduceMotion))
    }

    func appMessageInsertionTransition(preference: LumiMotionPreference) -> some View {
        transition(LumiTransition.messageInsertion(preference: preference))
    }

    func appDisclosureContentTransition(reduceMotion: Bool) -> some View {
        transition(LumiTransition.disclosureContent(reduceMotion: reduceMotion))
    }

    func appDisclosureContentTransition(preference: LumiMotionPreference) -> some View {
        transition(LumiTransition.disclosureContent(preference: preference))
    }

    func appStatusPresentationTransition(reduceMotion: Bool) -> some View {
        transition(LumiTransition.statusPresentation(reduceMotion: reduceMotion))
    }

    func appStatusPresentationTransition(preference: LumiMotionPreference) -> some View {
        transition(LumiTransition.statusPresentation(preference: preference))
    }

    func appTrackChangeTransition(preference: LumiMotionPreference) -> some View {
        transition(LumiTransition.trackChange(preference: preference))
    }

    func appPlaybackIconTransition(preference: LumiMotionPreference) -> some View {
        transition(LumiTransition.playbackIcon(preference: preference))
    }

    func appPanelRevealTransition(preference: LumiMotionPreference) -> some View {
        transition(LumiTransition.panelReveal(preference: preference))
    }
}
