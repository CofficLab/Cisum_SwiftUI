import OSLog
import SwiftData
import SwiftUI

struct Scenes: View {
    @Binding var selection: DiskScene
    @Binding var isPreseted: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(DiskScene.allCases.filter({
                $0 != .KidsVideo
            })) { scene in
                GroupBox {
                    scene.card
                        .frame(maxWidth: .infinity)
                }
                .border(selection == scene ? Color.accentColor : Color.clear)
                .onTapGesture {
                    self.selection = scene
                    self.isPreseted = false
                }
            }
        }
        .padding()
    }
}

#Preview("APP") {
    BootView {
        Scenes(selection: Binding.constant(.KidsAudio), isPreseted: Binding.constant(false))
    }
    .frame(height: 800)
}
