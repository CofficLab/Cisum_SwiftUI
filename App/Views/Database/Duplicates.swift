import OSLog
import SwiftUI

struct Duplicates: View {
    @EnvironmentObject var audioManager: AudioManager

    @State var duplicates: [Audio] = []
    @State var showDumplicates = false

    var audio: Audio
    
    var db: DB { audioManager.db }

    init(_ audio: Audio) {
        self.audio = audio
    }

    var body: some View {
        ZStack {
            if duplicates.count > 0 {
                ControlButton(
                    title: "\(duplicates.count)",
                    systemImage: getImageName(),
                    dynamicSize: false,
                    onTap: {
                        showDumplicates.toggle()
                    })
                    .popover(isPresented: $showDumplicates, content: {
                        List {
                            Section("共 \(duplicates.count) 个重复文件",content: {
                                ForEach(duplicates, content: { a in
                                    DBRow(a)
                                })
                            })
                        }
                    })
            }
        }
        .task {
            self.duplicates = await audio.getDuplicates(db)
        }
    }

    private func getImageName() -> String {
        return "doc.circle"
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
