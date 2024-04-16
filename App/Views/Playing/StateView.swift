import SwiftUI

struct StateView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager

    private var audio: Audio? { audioManager.audio }
    @State private var next: Audio?

    var totalStorage: String { iCloudHelper.getTotalStorageReadable() }
    var availableStorage: String { iCloudHelper.getAvailableStorageReadable() }

    var body: some View {
        ZStack {
            if let audio = audio {
                HStack(spacing: 2) {
                    if let n = next {
                        Text("下一首：\(n.title)")
                    } else {
                        Text("无下一首")
                    }

                    Text("共 \(totalStorage)")
                    Text("余 \(availableStorage)")
                }
                .onAppear {
                    Task {
                        self.next = audioManager.db.nextOf(audio)
                        iCloudHelper.checkiCloudStorage1()
                    }
                }
                .onChange(of: audio) {
                    Task {
                        self.next = audioManager.db.nextOf(audio)
                    }
                }
            }
        }
    }
}

#Preview("APP") {
    AppPreview()
}
