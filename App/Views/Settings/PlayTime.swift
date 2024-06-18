import SwiftUI

struct PlayTime: View {
    @EnvironmentObject var db: DB
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
        }.background(BackgroundView.type1.opacity(0.1))
            .onAppear {
                getTime()
            }
    }
    
    func getTime() {
        Task {
            self.playTime = await db.getAudioPlayTime()
        }
    }
}

#Preview {
    PlayTime()
}
