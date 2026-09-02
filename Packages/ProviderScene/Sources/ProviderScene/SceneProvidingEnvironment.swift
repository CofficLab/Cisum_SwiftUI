import SwiftUI

private struct SceneProviderKey: EnvironmentKey {
    @MainActor static let defaultValue: (any SceneProviding)? = nil
}

@MainActor
public extension EnvironmentValues {
    /// 当前内核提供的场景能力。
    var sceneProvider: (any SceneProviding)? {
        get { self[SceneProviderKey.self] }
        set { self[SceneProviderKey.self] = newValue }
    }
}
