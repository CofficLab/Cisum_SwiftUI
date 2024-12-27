import SwiftUI
import MagicKit
import MagicUI

struct PlayTime: View {
    @State var playTime = 0
    
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("播放次数").font(.headline)
                    Text("\(playTime)").font(.footnote)
                }
                Spacer()
            }.padding(10)
        }.background(MagicBackground.aurora.opacity(0.1))
            .onAppear {
                getTime()
            }
    }
    
    func getTime() {
        Task {
//            self.playTime = await db.getAudioPlayTime()
        }
    }
}

#Preview {
    PlayTime()
}
