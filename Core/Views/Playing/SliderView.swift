import AVKit
import Combine
import MagicKit
import MagicUI
import OSLog
import SwiftUI

struct SliderView: View, SuperThread, @preconcurrency SuperLog {
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var app: AppProvider

    @State private var value: Double = 0
    @State private var isEditing: Bool = false
    @State private var shouldDisable = false
    @State private var lastDownloadTime: Date = .now

    static let emoji = "👀"
    let timer = Timer
        .publish(every: 0.1, on: .main, in: .common)
        .autoconnect()

    var geo: GeometryProxy
    var duration: TimeInterval { playMan.duration }
    var current: String { playMan.currentTimeForDisplay }
    var left: String { playMan.durationForDisplay }

    var body: some View {
        HStack {
            Text(current)
                .font(getFont())

            Slider(value: $value, in: 0 ... duration) { editing in
                isEditing = editing
                if !editing {
                    playMan.seek(time: value)
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
//        .onReceive(NotificationCenter.default.publisher(for: .PlayManStateChange), perform: handlePlayManStateChange)
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

extension SliderView {
    func handlePlayManStateChange(_ notification: Notification) {
        if playMan.asset == nil {
            disable()
        }
    }

    func handleTimer(_ timer: Publishers.Autoconnect<Timer.TimerPublisher>.Output) {
        if app.error != nil {
            disable()
        } else if playMan.duration > 0 && !isEditing {
            enable()
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
