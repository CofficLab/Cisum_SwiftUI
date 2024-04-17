import AVKit
import SwiftUI

struct SliderView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    @State private var value: Double = 0
    @State private var isEditing: Bool = false
    @State private var shouldDisable = false

    let timer = Timer
        .publish(every: 0.5, on: .main, in: .common)
        .autoconnect()

    var player: SmartPlayer { audioManager.player }
    var duration: TimeInterval { player.duration }
    var current: String { player.currentTimeDisplay }
    var left: String { player.leftTimeDisplay }

    var body: some View {
        HStack {
            Text(current)

            Slider(value: $value, in: 0 ... duration) { editing in
                isEditing = editing
                if !editing {
                    player.goto(value)
                }
            }.disabled(shouldDisable)

            Text(left)
        }
        .font(.caption)
        .onReceive(timer) { _ in
            if audioManager.playerError != nil {
                return disable()
            }

            if audioManager.player.duration > 0 && !isEditing {
                return enable()
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
}

#Preview {
    AppPreview()
}
