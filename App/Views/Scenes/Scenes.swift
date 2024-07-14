import OSLog
import SwiftData
import SwiftUI

struct Scenes: View {
    @Binding var selection: DiskScene
    @Binding var isPreseted: Bool
    
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
                    self.isPreseted = false
                }
                
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
        Scenes(selection: Binding.constant(.AudiosKids), isPreseted: Binding.constant(false))
            .background(.background)
    }
    .frame(height: 800)
}
