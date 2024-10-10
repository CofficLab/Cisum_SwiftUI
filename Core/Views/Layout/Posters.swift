import OSLog
import SwiftData
import SwiftUI

struct Posters: View {
    @EnvironmentObject var l: RootProvider
    
    @Binding var isPresented: Bool
    
    @State var layoutId: String = ""
    
    var body: some View {
        VStack {
            Picker("", selection: $layoutId) {
                ForEach(l.items.map({$0.id}), id: \.self) { item in
                    Text(item)
                        .tag(item)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if let currentLayout = l.items.first(where: { $0.id == layoutId }) {
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
                    l.setLayout(currentLayout)
                    self.isPresented = false
                }.controlSize(.extraLarge)
        
                Spacer()
            }
        }
        .onAppear {
            layoutId = l.items.first?.id ?? ""
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
