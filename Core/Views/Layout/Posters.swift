import OSLog
import MagicAlert
import SwiftData
import SwiftUI
import MagicCore

// MARK: - Environment Key for Poster Dismiss Action

private struct PosterDismissActionKey: EnvironmentKey {
    static let defaultValue: @MainActor () -> Void = {}
}

extension EnvironmentValues {
    var posterDismissAction: @MainActor () -> Void {
        get { self[PosterDismissActionKey.self] }
        set { self[PosterDismissActionKey.self] = newValue }
    }
}

struct Posters: View, SuperLog {
    nonisolated static let emoji = "🪧"
    nonisolated static let verbose = false
    
    @EnvironmentObject var p: PluginProvider
    @EnvironmentObject var m: MagicMessageProvider
    @EnvironmentObject var man: PlayMan
    
    @Binding var isPresented: Bool
    
    @State var id: String = ""

    var posterItems: [(plugin: SuperPlugin, view: AnyView)] {
        p.plugins.compactMap { plugin in
            guard let poster = plugin.addPosterView() else { return nil }
            return (plugin, poster)
        }
    }

    var body: some View {
        VStack {
            Picker("", selection: $id) {
                ForEach(posterItems, id: \.plugin.label) { item in
                    Text(item.plugin.title)
                        .tag(item.plugin.label)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if let current = posterItems.first(where: { $0.plugin.label == id }) {
                VStack {
                    Text(current.plugin.description)
        
                    GroupBox {
                        current.view
                            .environment(\.posterDismissAction, { self.isPresented = false })
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
        id = posterItems.first?.plugin.label ?? ""
    }
}

// MARK: - Preview

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 600, height: 600)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
