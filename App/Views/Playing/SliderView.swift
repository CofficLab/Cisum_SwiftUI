import SwiftUI
import AVKit

struct SliderView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    
    @State private var value: Double = 0.0
    @State private var isEditing: Bool = false
    @State private var shouldDisable = false
    @State private var duration: TimeInterval = 0
    
    let timer = Timer
        .publish(every: 0.5, on: .main, in: .common)
        .autoconnect()
    
    var player: AVAudioPlayer { audioManager.player }
    var currentTime: TimeInterval { player.currentTime }
    var currentTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: currentTime) ?? "0:00"
    }
    var leftTime: TimeInterval { duration - value }
    var leftTimeDisplay: String {
        DateComponentsFormatter.positional.string(from: leftTime) ?? "0:00"
    }

    var body: some View {
        HStack {
            Text(currentTimeDisplay)

            Slider(value: $value, in: 0 ... duration) { editing in
                isEditing = editing
                if !editing {
                    audioManager.gotoTime(time: value)
                }
            }.disabled(shouldDisable)

            Text(leftTimeDisplay)
        }
        .font(.caption)
        .onAppear {
            self.duration = audioManager.player.duration
        }
        .onReceive(timer) { _ in
            if audioManager.isEmpty {
                return disable()
            }
            
            if let audio = audioManager.audio, audio.isDownloading {
                return disable()
            }
            
            if let audio = audioManager.audio, audio.isNotDownloaded {
                return disable()
            }
            
            if audioManager.player.duration > 0 && !isEditing {
                return enable()
            }
        }
        .padding(.horizontal, 10)
    }
    
    func enable() {
        value = currentTime
        shouldDisable = false
        duration = player.duration
    }
    
    func disable() {
        value = 0
        shouldDisable = true
        duration = 0
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
