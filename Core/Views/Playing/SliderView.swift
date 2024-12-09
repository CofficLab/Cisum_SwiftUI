import AVKit
import SwiftUI
import OSLog

struct SliderView: View {
    static var label = "👀 SliderView::"
    
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider

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
                    playMan.seek(value)
                }
            }
            .disabled(shouldDisable)

            Text(left)
                .font(getFont())
        }
        .font(.caption)
        // .onChange(of: playMan.asset?.url, {
        //     if playMan.asset == nil {
        //         disable()
        //     }
        // })        .padding(.horizontal, 10)
        .foregroundStyle(.white)
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
