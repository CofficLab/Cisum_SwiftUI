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
}
