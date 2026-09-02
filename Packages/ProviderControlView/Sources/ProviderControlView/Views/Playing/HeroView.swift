import MagicPlayMan
import ProviderPlayback
import SwiftUI

/// 播放封面区域。
struct HeroView: View {
    @EnvironmentObject private var man: MagicPlayMan
    var compact = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: compact ? 18 : 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.indigo.opacity(0.82), .purple.opacity(0.75), .pink.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: compact ? 10 : 14) {
                Image(systemName: man.isPlaying ? "waveform" : "music.note")
                    .font(.system(size: compact ? 44 : 72, weight: .medium))
                    .symbolEffect(.variableColor.iterative, isActive: man.isPlaying)
                    .foregroundStyle(.white.opacity(0.94))

                if !compact {
                    Text("CISUM")
                        .font(.caption.weight(.semibold))
                        .tracking(4)
                        .foregroundStyle(.white.opacity(0.78))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(compact ? 18 : 24)
        .shadow(color: .black.opacity(0.18), radius: 18, y: 8)
    }
}
