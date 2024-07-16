import OSLog
import SwiftData
import SwiftUI

struct Scenes: View {
    @Binding var selection: DiskScene
    @Binding var isPresented: Bool
    
    @State var picked: DiskScene?

    var body: some View {
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
                p.card
                
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
}

#Preview("Scenes") {
    BootView {
        Scenes(selection: Binding.constant(.AudiosKids), isPresented: .constant(false))
            .background(.background)
    }
    .frame(height: 800)
}
