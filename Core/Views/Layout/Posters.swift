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

    var plugins: [SuperPlugin] {
        return p.plugins.filter { $0.hasPoster }
    }
    
    var body: some View {
        VStack {
            Picker("", selection: $id) {
                ForEach(plugins, id: \.label) { item in
                    Text(item.title)
                        .tag(item.label)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if let currentLayout = plugins.first(where: { $0.label == id }) {
                VStack {
                    Text(currentLayout.description)
        
                    GroupBox {
                        AnyView(currentLayout.addPosterView())
                    }.padding()
                }
        
                Button("选择") {
                    do {
                        Task {
                            await self.man.stop()
                        }
                        try p.setCurrentGroup(currentLayout)
                        self.isPresented = false
                    } catch {
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
