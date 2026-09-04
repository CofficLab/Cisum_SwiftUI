import MagicPlayMan
import ProviderPlayback
import SwiftUI

/// 播放进度。
struct PlayingProgressView: View {
    @EnvironmentObject private var man: MagicPlayMan

    private var progressBinding: Binding<Double> {
        Binding(
            get: { man.progress },
            set: { newValue in man.seek(toProgress: newValue) }
        )
    }

    var body: some View {
        VStack(spacing: 7) {
            Slider(value: progressBinding, in: 0...1)
                .tint(.accentColor)

            HStack {
                Text(format(man.currentTime))
                Spacer()
                Text(format(man.duration))
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
    }

    private func format(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite, seconds > 0 else { return "0:00" }
        let total = Int(seconds)
        return "\(total / 60):\(String(format: "%02d", total % 60))"
    }
}
