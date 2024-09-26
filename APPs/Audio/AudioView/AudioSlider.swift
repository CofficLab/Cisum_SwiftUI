import AVKit
import Combine
import SwiftUI
import OSLog
import MagicKit

struct AudioSlider: View, SuperThread, SuperLog {
    static var label = "👀 SliderView::"
    
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider

    @State private var value: Double = 0
    @State private var isEditing: Bool = false
    @State private var shouldDisable = false
    @State private var lastDownloadTime: Date = .now

    let emoji = "👀"
    let timer = Timer
        .publish(every: 0.1, on: .main, in: .common)
        .autoconnect()

    var geo: GeometryProxy
    var duration: TimeInterval { playMan.duration }
    var current: String { playMan.currentTimeDisplay }
    var left: String { playMan.leftTimeDisplay }

    var body: some View {
        HStack {
            Text(current)
                .font(getFont())

            Slider(value: $value, in: 0 ... duration) { editing in
                isEditing = editing
                if !editing {
                    playMan.goto(value)
                }
            }
            .disabled(shouldDisable)

            Text(left)
                .font(getFont())
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .foregroundStyle(.white)
        .onReceive(timer, perform: handleTimer)
        .onReceive(NotificationCenter.default.publisher(for: .PlayManStateChange), perform: handlePlayManStateChange)
    }

    func enable() {
        value = playMan.currentTime
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

// MARK: Event Handler

extension AudioSlider {
    func handlePlayManStateChange(_ notification: Notification) {
        self.bg.async {
            if playMan.asset == nil {
                disable()
            }
        }
    }

    func handleTimer(_ timer: Publishers.Autoconnect<Timer.TimerPublisher>.Output) {
        if app.error != nil {
            disable()
        } else if playMan.duration > 0 && !isEditing {
                enable()
            }
            
            if Date.now.timeIntervalSince(lastDownloadTime) > 10, let asset = playMan.asset {
                lastDownloadTime = .now
//                Task.detached(priority: .low) {
//                    await data.downloadNextBatch(asset.url,count: data.appScene.prepareCount, reason: "SliderView确保下一个准备好")
//                }
            }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("iPad") {
    LayoutView(device: .iPad_mini)
}

#Preview("iMac") {
    LayoutView(device: .iMac)
}
