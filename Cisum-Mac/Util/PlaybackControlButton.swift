import SwiftUI
import Foundation

struct PlaybackControlButton: View {
    var systemName: String = "play.circle.fill"
    var fontSize: CGFloat = 24
    var color: Color = .clear
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: fontSize))
                .foregroundColor(.white)
        }.buttonStyle(.plain)
    }
}

struct PlaybackControlButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue.opacity(0.5).ignoresSafeArea()
            
            PlaybackControlButton(action: {})
        }
    }
}
