import SwiftUI

public struct LumiMotionPreference: Equatable, Sendable {
    public var reduceMotion: Bool
    public var disableAnimations: Bool
    public var disableListAnimations: Bool

    public init(
        reduceMotion: Bool = false,
        disableAnimations: Bool = false,
        disableListAnimations: Bool = false
    ) {
        self.reduceMotion = reduceMotion
        self.disableAnimations = disableAnimations
        self.disableListAnimations = disableListAnimations
    }

    public var allowsMotion: Bool {
        !reduceMotion && !disableAnimations
    }

    public var allowsListMotion: Bool {
        allowsMotion && !disableListAnimations
    }
}

private struct LumiMotionPreferenceKey: EnvironmentKey {
    static let defaultValue = LumiMotionPreference()
}

public extension EnvironmentValues {
    var lumiMotionPreference: LumiMotionPreference {
        get { self[LumiMotionPreferenceKey.self] }
        set { self[LumiMotionPreferenceKey.self] = newValue }
    }
}

@propertyWrapper
public struct LumiMotionPreferenceReader: DynamicProperty {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.lumiMotionPreference) private var preference

    public init() {}

    public var wrappedValue: LumiMotionPreference {
        LumiMotionPreference(
            reduceMotion: systemReduceMotion || preference.reduceMotion,
            disableAnimations: preference.disableAnimations,
            disableListAnimations: preference.disableListAnimations
        )
    }
}

public extension View {
    func lumiMotionPreference(_ preference: LumiMotionPreference) -> some View {
        environment(\.lumiMotionPreference, preference)
    }

    func lumiDisableAnimations(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.lumiMotionPreference) { preference in
            preference.disableAnimations = disabled
        }
    }

    func lumiDisableListAnimations(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.lumiMotionPreference) { preference in
            preference.disableListAnimations = disabled
        }
    }
}
