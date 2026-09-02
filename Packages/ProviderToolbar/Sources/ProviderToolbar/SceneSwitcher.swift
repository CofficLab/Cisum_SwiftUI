import CisumKernel
import ProviderScene
import SwiftUI

/// 场景切换器：工具栏入口，列出全部可用场景（如「音乐库」「有声书」），
/// 选择后切换 `currentSceneName`，从而改变内容区展示的 Tab。
struct SceneSwitcher: View {
    @ObservedObject var kernel: CisumKernel

    private var scene: (any SceneProviding)? { kernel.scene }
    private var sceneNames: [String] { scene?.sceneNames ?? [] }
    private var current: String? { scene?.currentSceneName }

    private func icon(for sceneName: String) -> String {
        scene?.plugin(for: sceneName)?.iconName ?? "rectangle.3.group"
    }

    var body: some View {
        if sceneNames.count > 1, let current {
            Menu {
                ForEach(sceneNames, id: \.self) { name in
                    Button {
                        try? scene?.setCurrentScene(name)
                    } label: {
                        if name == current {
                            Label(name, systemImage: "checkmark")
                        } else {
                            Label(name, systemImage: icon(for: name))
                        }
                    }
                }
            } label: {
                Label(current, systemImage: icon(for: current))
            }
        } else if let current {
            // 仅一个场景时，纯展示当前场景名，不可切换。
            Label(current, systemImage: icon(for: current))
                .foregroundStyle(.secondary)
        }
    }
}
