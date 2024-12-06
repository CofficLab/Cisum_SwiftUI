import OSLog
import SwiftData
import SwiftUI

struct Posters: View {
    @EnvironmentObject var root: FamalyProvider
    
    @Binding var isPresented: Bool
    
    @State var id: String = ""
    
    var body: some View {
        VStack {
            Picker("", selection: $id) {
                ForEach(root.items, id: \.id) { item in
                    Text(item.title)
                        .tag(item.id)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if let currentLayout = root.items.first(where: { $0.id == id }) {
                VStack {
                    HStack {
                        Text(currentLayout.title)
                    }
                    .font(.title)
                    .padding()
        
                    Text(currentLayout.description)
        
                    GroupBox {
                        AnyView(currentLayout.poster)
                    }.padding()
                }
        
                Button("选择") {
                    root.setLayout(currentLayout)
                    self.isPresented = false
                }.controlSize(.extraLarge)
        
                Spacer()
            }
        }
        .onAppear {
            id = root.items.first?.id ?? ""
        }
    }
}

#Preview("Scenes") {
    BootView {
        Posters(isPresented: .constant(false))
            .background(.background)
    }
    .frame(height: 800)
}
