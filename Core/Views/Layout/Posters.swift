import OSLog
import SwiftData
import SwiftUI

struct Posters: View {
    @EnvironmentObject var p: PluginProvider
    
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
                    p.setCurrent(currentLayout)
                    self.isPresented = false
                }.controlSize(.extraLarge)
        
                Spacer()
            }
        }
        .onAppear {
            id = plugins.first?.label ?? ""
        }
    }
}
