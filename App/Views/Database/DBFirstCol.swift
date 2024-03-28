import SwiftUI

struct DBFirstCol: View {
    @EnvironmentObject var audioManager: AudioManager
    var audio: AudioModel
    var selected: Bool = false
    
    var body: some View {
            HStack {
                if audio.downloadingPercent < 100 {
                    ProgressView(value: audio.downloadingPercent/100)
                        .progressViewStyle(CircularProgressViewStyle(size: 14))
                        .controlSize(.regular)
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                } else {
                    audio.getCover()
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .border(audioManager.audio == audio ? .clear : .clear)
                }
                
                Text(audio.title).foregroundStyle(selected ? .blue : .primary)
                Spacer()
                if audio.downloadingPercent < 100 {
                    Text("\(String(format: "%.2f", audio.downloadingPercent/100))%").font(.footnote)
                }
            }

            // 如果在这里定义了tap事件，会影响table的单击选择功能
    }
}

public struct CircularProgressViewStyle: ProgressViewStyle {
    var size: CGFloat = 20
    private let lineWidth: CGFloat = 8
    private let defaultProgress = 0.0
    private let gradient = LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
    
    public func makeBody(configuration: ProgressViewStyleConfiguration) -> some View {
        ZStack {
            configuration.label
            progressCircleView(fractionCompleted: configuration.fractionCompleted ?? defaultProgress)
            configuration.currentValueLabel
        }
    }
    
    private func progressCircleView(fractionCompleted: Double) -> some View {
        Circle()
            .stroke(gradient, lineWidth: lineWidth)
            .opacity(0.2)
            .overlay(progressFill(fractionCompleted: fractionCompleted))
            .frame(width: size, height: size)
    }
    
    private func progressFill(fractionCompleted: Double) -> some View {
        Circle()
            .trim(from: 0, to: CGFloat(fractionCompleted))
            .stroke(gradient, lineWidth: lineWidth)
            .frame(width: size)
            .rotationEffect(.degrees(-90))
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
