import OSLog
import MagicAlert
import SwiftData
import SwiftUI
import MagicCore

struct Posters: View, SuperLog {
    nonisolated static let emoji = "🪧"
    
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
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onAppear {
            id = posterItems.first?.plugin.label ?? ""
        }
    }
}

#Preview("App") {
    AppPreview()
    #if os(macOS)
        .frame(height: 800)
    #endif
}
