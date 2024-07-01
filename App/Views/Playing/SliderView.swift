import AVKit
import SwiftUI
import OSLog

struct SliderView: View {
    static var label = "👀 SliderView::"
    
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var app: AppManager
    @EnvironmentObject var dataManager: DataManager

    @State private var value: Double = 0
    @State private var isEditing: Bool = false
    @State private var shouldDisable = false
    @State private var lastDownloadTime: Date = .now

    let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()

    var geo: GeometryProxy
    var duration: TimeInterval { playMan.duration }
    var current: String { playMan.currentTimeDisplay }
    var left: String { playMan.leftTimeDisplay }
    var label: String { "\(Logger.isMain)\(Self.label)"}

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
        .onChange(of: playMan.asset?.url, {
            if playMan.asset == nil {
                disable()
            }
        })
        .onReceive(timer) { _ in
            if app.error != nil {
                disable()
            } else if playMan.duration > 0 && !isEditing {
                enable()
            }
            
            if Date.now.timeIntervalSince(lastDownloadTime) > 10, let asset = playMan.asset {
                lastDownloadTime = .now
                Task.detached(priority: .low) {
                    await dataManager.downloadNextBatch(asset.url, reason: "SliderView确保下一个准备好")
                }
            }
        }
        .padding(.horizontal, 10)
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

#Preview {
    AppPreview()
}

#Preview("iPad") {
    LayoutView(device: .iPad_mini)
}

#Preview("iMac") {
    LayoutView(device: .iMac)
}
