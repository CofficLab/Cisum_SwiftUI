import OSLog
import SwiftData
import SwiftUI

struct DBList: View {
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var modelContext
    
    @State var updatedAt: Date = .now
    @Query var audios: [Audio]

    var total: Int { audioManager.db.getTotal() }
    var audio: Audio? { audioManager.audio }

    var body: some View {
        VStack(spacing: 0) {
            if total > 0 {
                Text("共 \(total.description)").foregroundStyle(.white)
            }
            List(audios) { audio in
                    Row(audio)
                }
        }.onChange(of: audioManager.lastUpdatedAt, {
            self.updatedAt = .now
            print("SSSSSS")
        })
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
