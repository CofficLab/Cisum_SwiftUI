import SwiftUI

private struct SceneProvidingKey: EnvironmentKey {
    static let defaultValue: (any SceneProviding)? = nil
}

public extension EnvironmentValues {
    /// The scene provider made available to plugin-owned settings and views.
    var sceneProviding: (any SceneProviding)? {
        get { self[SceneProvidingKey.self] }
        set { self[SceneProvidingKey.self] = newValue }
    }
}
