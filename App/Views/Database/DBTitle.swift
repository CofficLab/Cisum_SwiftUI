import SwiftUI
import OSLog

struct DBTitle: View {
    @EnvironmentObject var audioManager: AudioManager

    var audio: AudioModel

    var body: some View {
        var text = Text(audio.title)

        if audio == audioManager.audio {
            if #available(macOS 14.0, *) {
                if #available(iOS 17.0, *) {
                    text = text.foregroundStyle(.secondary)
                } else {
                    // Fallback on earlier versions
                }
            } else {
                // Fallback on earlier versions
            }
        }

        return ZStack {
            text
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
