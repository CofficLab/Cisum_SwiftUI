import MagicAlert
import MagicKit
import OSLog
import SwiftData
import SwiftUI

struct Posters: View, SuperLog {
    nonisolated static let emoji = "🪧"
    nonisolated static let verbose = true

    @EnvironmentObject var p: PluginProvider
    @EnvironmentObject var man: PlayMan

    @Binding var isPresented: Bool

    @State var id: String = ""
    @State private var posterItems: [(label: String, sceneName: String?, title: String, description: String, view: AnyView)] = []

    var body: some View {
        VStack {
            Picker("", selection: $id) {
                ForEach(posterItems, id: \.label) { item in
                    Text(item.title.isEmpty ? item.label : item.title)
                        .tag(item.label)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if let current = posterItems.first(where: { $0.label == id }) {
                VStack {
                    if !current.description.isEmpty {
                        Text(current.description)
                    }

                    GroupBox {
                        current.view
                            .environment(\.posterDismissAction, { self.isPresented = false })
                            .environment(\.setCurrentSceneAction, { sceneName in
                                try p.setCurrentScene(sceneName)
                            })
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onAppear(perform: handleOnAppear)
    }
}

// MARK: - Event Handler

extension Posters {
    func handleOnAppear() {
        // 预先提取插件属性避免在视图渲染期间访问 Actor 属性导致的问题
        posterItems = p.plugins.compactMap { plugin in
            guard let poster = plugin.addPosterView() else { return nil }
            return (
                label: plugin.label,
                sceneName: plugin.addSceneItem(),
                title: plugin.title,
                description: plugin.description,
                view: poster
            )
        }

        let currentItem = posterItems.first { $0.sceneName == p.currentSceneName }
        id = currentItem?.label ?? posterItems.first?.label ?? ""
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
