import KernelCore
import CisumUIComponents
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
            Button {
                isPresented.toggle()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: icon(for: current))
                    Text(current)
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isPresented) {
                PostersView(isPresented: $isPresented, kernel: kernel)
                    .frame(minWidth: 350)
            }
        }
    }

    @State private var isPresented = false
}

private struct PostersView: View {
    struct Item: Identifiable {
        let id: String
        let title: String
        let description: String
        let view: AnyView
    }

    @Binding var isPresented: Bool
    let kernel: CisumKernel
    @State private var selectedID = ""
    @State private var items: [Item] = []

    var body: some View {
        VStack {
            Picker("", selection: $selectedID) {
                ForEach(items) { item in
                    Text(item.title.isEmpty ? item.id : item.title)
                        .tag(item.id)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            if let item = items.first(where: { $0.id == selectedID }) {
                VStack {
                    if !item.description.isEmpty {
                        Text(item.description)
                    }

                    GroupBox {
                        item.view
                            .environment(\.posterDismissAction, { isPresented = false })
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onAppear { loadItems() }
    }

    private func loadItems() {
        items = (kernel.plugin?.allPlugins ?? []).compactMap { plugin in
            guard let view = plugin.addPosterView() else { return nil }
            return Item(
                id: plugin.label,
                title: plugin.title,
                description: plugin.description,
                view: view
            )
        }
        selectedID = items.first?.id ?? ""
    }
}
