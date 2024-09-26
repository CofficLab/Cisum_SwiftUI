import OSLog
import SwiftData
import SwiftUI

struct Posters: View {
    @EnvironmentObject var l: LayoutProvider
    
    @Binding var selection: DiskScene
    @Binding var isPresented: Bool
    
    @State var picked: DiskScene?
    @State var layoutId: String = ""
    
    var body: some View {
        newView
    }

    var oldView: some View {
        VStack {
            Picker("", selection: $picked) {
                ForEach(DiskScene.allCases.filter { $0.available }) { scene in
                    Text(scene.title)
                        .tag(scene as DiskScene?)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if let p = picked {
                    VStack {
                        HStack {
//                            self.icon
                            Text(l.current.name)
                        }
                        .font(.title)
                        .padding()
            
                        Text(l.current.description)
            
                        GroupBox {
                            AnyView(l.current.poster)
                        }.padding()
                    }
                
                Button("选择") {
                    self.selection = p
                    self.isPresented = false
                }.controlSize(.extraLarge)
                
                Spacer()
            }
        }
        .onAppear {
            picked = selection
        }
    }
    
    var newView: some View {
        VStack {
            Picker("", selection: $layoutId) {
                ForEach(l.items.map{$0.id}, id: \.self) { item in
                    Text(item).tag(item)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if let currentLayout = l.items.first(where: { $0.id == layoutId }) {
                VStack {
                    HStack {
                        Text(currentLayout.name)
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
        Posters(selection: Binding.constant(.AudiosKids), isPresented: .constant(false))
            .background(.background)
    }
    .frame(height: 800)
}
