import AVKit
import SwiftUI
import OSLog

struct SliderView: View {
    static var label = "👀 SliderView::"
    
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    @State private var value: Double = 0
    @State private var isEditing: Bool = false
    @State private var shouldDisable = false
    @State private var lastDownloadTime: Date = .now

    let timer = Timer
        .publish(every: 0.5, on: .main, in: .common)
        .autoconnect()

    var geo: GeometryProxy
    var player: SmartPlayer { audioManager.player }
    var duration: TimeInterval { player.duration }
    var current: String { player.currentTimeDisplay }
    var left: String { player.leftTimeDisplay }
    var db: DB { audioManager.db }
    var label: String { "\(Logger.isMain)\(Self.label)"}

    var body: some View {
        HStack {
            Text(current)
                .font(getFont())

            Slider(value: $value, in: 0 ... duration) { editing in
                isEditing = editing
                if !editing {
                    player.goto(value)
                }
            }
            .disabled(shouldDisable)

            Text(left)
                .font(getFont())
        }
        .font(.caption)
        .onReceive(timer) { _ in
            if audioManager.error != nil {
                disable()
            } else if audioManager.player.duration > 0 && !isEditing {
                enable()
            }
            
            if Date.now.timeIntervalSince(lastDownloadTime) > 10, let audio = audioManager.audio {
                lastDownloadTime = .now
                Task.detached(priority: .low) {
                    await db.downloadNext(audio, reason: "SliderView确保下一个准备好")
                }
            }
        }
        .padding(.horizontal, 10)
    }

    func enable() {
        value = player.currentTime
        shouldDisable = false
    }

    func disable() {
        value = 0
        shouldDisable = true
    }

    func getFont() -> Font {
        return .title3
    }
}

#Preview {
    AppPreview()
}

#Preview("iPad") {
    LayoutView(device: .iPad_mini)
}

#Preview("iMac") {
    LayoutView(device: .iMac)
}
