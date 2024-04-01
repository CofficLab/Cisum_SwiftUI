import SwiftUI

struct SliderView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    @State private var value: Double = 0.0
    @State private var isEditing: Bool = false

    let timer = Timer
        .publish(every: 0.5, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        HStack {
            Text(audioManager.currentTimeDisplay())
            
            if appManager.appMode == .Normal {
                Slider(value: $value, in: 0 ... audioManager.duration) { editing in
                    isEditing = editing
                    if !editing {
                        audioManager.gotoTime(time: value)
                    }
                }.disabled(audioManager.playlist.isEmpty)
            } else {
                GeometryReader { geo in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.gray.opacity(0.3))
                            .frame(height: 8)
                        
                        Circle()
                            .foregroundColor(.white)
                            .frame(height: geo.size.height/10)
                    }}
            }
            

            Text(audioManager.leftTimeDisplay())
        }
        .font(.caption)
        .onReceive(timer) { _ in
            if audioManager.duration > 0 && !isEditing {
                value = audioManager.currentTime()
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
