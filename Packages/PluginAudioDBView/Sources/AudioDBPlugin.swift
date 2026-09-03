import KernelCore
import CisumUIComponents
import PluginAudio
import PluginAudioScene
import ProviderScene
import SwiftUI

public actor AudioDBPlugin: SuperPlugin {
    public static let shared = AudioDBPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: String.LocalizationValue(AudioDBPluginInfo.titleKey), bundle: .module),
        description: String(localized: String.LocalizationValue(AudioDBPluginInfo.descriptionKey), bundle: .module),
        iconName: "externaldrive",
        order: 1
    )

    nonisolated(unsafe) private let sceneBox = SceneBox()

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        guard let scene = kernel.resolveProvider((any SceneProviding).self) else {
            throw CisumKernelError.serviceNotAvailable(service: "SceneProviding")
        }
        sceneBox.scene = scene
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        sceneBox.scene = nil
    }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioDBPluginRootView(content: content))
    }

    @MainActor
    public func addTabView(reason: String, demoMode: Bool = false) -> (view: AnyView, label: String)? {
        guard sceneBox.scene?.currentSceneName == AudioScenePlugin.sceneName else { return nil }
        guard demoMode == false else { return nil }

        return (AnyView(AudioDBPluginTabView(demoMode: demoMode)), String(localized: "Music Repository", bundle: .module))
    }

    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}

private struct AudioDBPluginRootView<Content>: View where Content: View {
    @Environment(\.demoMode) private var isDemoMode
    @Environment(\.appIsImporting) private var isImporting
    @Environment(\.showAudioDBViewAction) private var showDBView

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        AudioDBRootView(isDemoMode: isDemoMode) {
            content
        }
        .environment(\.audioDBDependencies, dependencies)
    }

    private var dependencies: AudioDBDependencies {
        AudioDBDependencies(
            audioRepo: { AudioPlugin.getAudioRepo() },
            audioDisk: { AudioPlugin.getAudioDisk() },
            supportedExtensions: AudioPlugin.supportedExtensions,
            isDesktop: Self.isDesktop,
            isNotDesktop: !Self.isDesktop,
            showDBView: showDBView,
            isImporting: isImporting
        )
    }

    private static var isDesktop: Bool {
        #if os(macOS)
            true
        #else
            false
        #endif
    }
}

private struct AudioDBPluginTabView: View {
    @Environment(\.appIsImporting) private var isImporting
    @Environment(\.showAudioDBViewAction) private var showDBView

    let demoMode: Bool

    var body: some View {
        AudioDBView(isDemoMode: demoMode)
            .environment(\.audioDBDependencies, dependencies)
    }

    private var dependencies: AudioDBDependencies {
        AudioDBDependencies(
            audioRepo: { AudioPlugin.getAudioRepo() },
            audioDisk: { AudioPlugin.getAudioDisk() },
            supportedExtensions: AudioPlugin.supportedExtensions,
            isDesktop: Self.isDesktop,
            isNotDesktop: !Self.isDesktop,
            showDBView: showDBView,
            isImporting: isImporting
        )
    }

    private static var isDesktop: Bool {
        #if os(macOS)
            true
        #else
            false
        #endif
    }


    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
