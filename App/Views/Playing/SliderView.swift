import SwiftUI
import AVKit

struct SliderView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    
    @State private var value: Double = 0.0
    @State private var isEditing: Bool = false
    
    let timer = Timer
        .publish(every: 0.5, on: .main, in: .common)
        .autoconnect()
    
    var player: AVAudioPlayer { audioManager.player }
    var currentTime: TimeInterval { player.currentTime }
    var currentTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: currentTime) ?? "0:00"
    }
    var leftTime: TimeInterval { player.duration - player.currentTime }
    var leftTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: leftTime) ?? "0:00"
    }

    var body: some View {
        HStack {
            Text(currentTimeDisplay)

            Slider(value: $value, in: 0 ... player.duration) { editing in
                isEditing = editing
                if !editing {
                    audioManager.gotoTime(time: value)
                }
            }

            Text(leftTimeDisplay)
        }
        .font(.caption)
        .onReceive(timer) { _ in
            if audioManager.player.duration > 0 && !isEditing {
                value = currentTime
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    RootView {
        ContentView()
    }
}

#Preview {
    VStack {
        RootView(content: {
            SliderView()
        })

        RootView {
            SliderView()
        }
    }
}
