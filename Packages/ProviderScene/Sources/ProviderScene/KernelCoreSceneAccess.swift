import KernelCore

/// Scene-specific convenience accessors live beside the Scene provider so the
/// core package does not depend on this optional capability package.
public extension CisumKernelContainer {
    var scene: (any SceneProviding)? {
        resolveProvider(SceneProviding.self)
    }

    func registerSceneService(_ scene: any SceneProviding) {
        registerProvider(SceneProviding.self, scene)
    }
}
