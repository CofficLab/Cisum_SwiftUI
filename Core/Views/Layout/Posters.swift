import OSLog
import SwiftData
import SwiftUI
import MagicCore

struct Posters: View, SuperLog {
    nonisolated static let emoji = "🪧"
    
    @EnvironmentObject var p: PluginProvider
    @EnvironmentObject var m: MessageProvider
    @EnvironmentObject var man: PlayMan
    
    @Binding var isPresented: Bool
    
    @State var id: String = ""

    var plugins: [SuperPlugin] {
        return p.plugins.filter { $0.hasPoster }
    }
    
    var body: some View {
        VStack {
            Picker("", selection: $id) {
                ForEach(plugins, id: \.label) { item in
                    Text(item.label)
                        .tag(item.label)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if let currentLayout = plugins.first(where: { $0.label == id }) {
                VStack {
                    HStack {
                        Text(currentLayout.label)
                    }
                    .font(.title)
                    .padding()
        
                    Text(currentLayout.description)
        
                    GroupBox {
                        AnyView(currentLayout.addPosterView())
                    }.padding()
                }
        
                Button("选择") {
                    do {
                        self.man.stop()
                        try p.setCurrentGroup(currentLayout)
                        self.isPresented = false
                    } catch {
                        os_log("🐷 PluginProvider::setCurrentGroup, error: \(error)")

                        m.error(error)
                    }
                }.controlSize(.extraLarge)
        
                Spacer()
            }
        }
        .onAppear {
            id = plugins.first?.label ?? ""
        }
    }
}

#Preview("App") {
    AppPreview()
    #if os(macOS)
        .frame(height: 800)
    #endif
}
