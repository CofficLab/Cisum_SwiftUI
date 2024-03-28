import SwiftUI

struct DBFirstCol: View {
    @EnvironmentObject var audioManager: AudioManager
    var audio: AudioModel
    var selected: Bool = false
    
    var body: some View {
            HStack {
                audio.getCover()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .border(audioManager.audio == audio ? .clear : .clear)
                Text(audio.title).foregroundStyle(selected ? .blue : .primary)
                Spacer()
//                Text("\(audio.downloadingPercent)").font(.footnote)
                
                if audio.downloadingPercent < 100 {
                    ProgressView(value: audio.downloadingPercent/100)
                            .progressViewStyle(.circular)
                            .controlSize(.regular)
                }
            }

            // 如果在这里定义了tap事件，会影响table的单击选择功能
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
