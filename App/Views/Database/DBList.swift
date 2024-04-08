import OSLog
import SwiftData
import SwiftUI

struct DBList: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var updatedAt: Date = .now

    var total: Int { audioManager.db.getTotal() ?? 0 }
    var audio: Audio? { audioManager.audio }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(0 ... max(0, total - 1), id: \.self) { i in
                        if let audio = audioManager.db.get(i) {
                            Row(audio)
                        }
                        Divider().background(.background)
                    }

                    if total > 0 {
                        Text("共 \(total.description)").foregroundStyle(.white)
                    }
                }
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
