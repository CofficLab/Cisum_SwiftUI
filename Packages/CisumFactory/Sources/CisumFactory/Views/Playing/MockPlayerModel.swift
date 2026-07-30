import SwiftUI

/// Factory 布局的临时播放状态，等待真实 PlaybackProvider 注入。
@MainActor
final class MockPlayerModel: ObservableObject {
    struct Track: Identifiable {
        let id = UUID()
        let title: String
        let artist: String
        let length: String
        let icon: String
        let color: Color
    }

    @Published var title = "Gentle Breeze"
    @Published var artist = "Cisum Demo Artist"
    @Published var isPlaying = false
    @Published var isLiked = false
    @Published var isShuffle = false
    @Published var progress = 84.0
    let duration = 225.0

    let tracks = [
        Track(title: "Gentle Breeze", artist: "Cisum Demo Artist", length: "3:45", icon: "wind", color: .indigo),
        Track(title: "Morning Coffee", artist: "The Daily Notes", length: "4:12", icon: "sunrise.fill", color: .orange),
        Track(title: "Night Walk", artist: "Coffic Lab", length: "5:08", icon: "moon.stars.fill", color: .purple),
        Track(title: "Rain on Glass", artist: "Ambient Room", length: "2:58", icon: "cloud.rain.fill", color: .teal),
    ]

    var progressText: String { formatTime(progress) }
    var durationText: String { formatTime(duration) }

    func togglePlay() { isPlaying.toggle() }
    func toggleMode() { isShuffle.toggle() }
    func previous() { progress = max(0, progress - 15) }
    func next() { progress = min(duration, progress + 15) }

    func play(_ track: Track) {
        title = track.title
        artist = track.artist
        isPlaying = true
        progress = 0
    }

    private func formatTime(_ value: Double) -> String {
        let totalSeconds = Int(value)
        return "\(totalSeconds / 60):\(String(format: "%02d", totalSeconds % 60))"
    }
}
