import AVKit
import OSLog
import SwiftUI

struct HomeView: View {
    var isPreview: Bool = false

    @EnvironmentObject var audioManager: AudioManager

    @State private var value: Double = 0.0
    @State private var isEditing: Bool = false
    @State private var showDatabase: Bool = false

    let timer = Timer
        .publish(every: 0.5, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 32) {
                if audioManager.audios.count > 0 {
                    Text(audioManager.title)
                        .font(.title)
                        .foregroundColor(.white)
                } else {
                    Spacer()

                    CardView {
                        VStack {
                            Spacer(minLength: 40)
                            Text("仓库中没有音乐文件")
                                .font(.headline)
                                .foregroundColor(.white)

                            Spacer(minLength: 40)

                            Image(systemName: "clipboard")
                                .resizable()
                                .foregroundColor(.brown)
                                .frame(width: 60, height: 80)

                            Spacer(minLength: 40)

                            Button {
                                showDatabase = true
                            } label: {
                                HStack {
                                    Text("查看仓库")
                                    Image(systemName: "signpost.right.fill")
                                }
                            }
                            .foregroundColor(.white)

                            Spacer(minLength: 40)
                        }
                    }
                }

                Spacer()

                // MARK: 播放进度

                VStack(spacing: 5) {
                    Slider(value: $value, in: 0 ... audioManager.duration) { editing in
                        isEditing = editing
                        if !editing {
                            audioManager.gotoTime(time: value)
                        }
                    }
                    //                    .accentColor(.white)

                    HStack {
                        Text(DateComponentsFormatter.positional.string(from: audioManager.currentTime()) ?? "0:00")
                        Spacer()
                        Text(DateComponentsFormatter.positional.string(from: audioManager.leftTime())!)
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                }

                // MARK: 控制按钮

                HStack {
                    PlaybackControlButton(systemName: "repeat", fontSize: 48, color: audioManager.isLooping ? .teal : .white) {
                        audioManager.toggleLoop()
                    }
                    Spacer()
                    PlaybackControlButton(systemName: "backward.end.circle", fontSize: 48) {
                        audioManager.prev()
                    }
                    Spacer()
                    PlaybackControlButton(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill", fontSize: 64) {
                        audioManager.togglePlayPause()
                    }
                    Spacer()
                    PlaybackControlButton(systemName: "forward.end.circle", fontSize: 48) {
                        audioManager.next()
                    }
                    Spacer()
                    PlaybackControlButton(systemName: "music.note.list", fontSize: 48) {
                        showDatabase = true
                    }
                }
            }
            .padding(20)
            .onAppear {
                if audioManager.audios.count > 0 && isPreview == false {
                    audioManager.play()
                }
            }
            .onReceive(timer) { _ in
                if audioManager.duration == 0 {
                    return
                }

                // 自动移动进度条
                if !isEditing {
                    value = audioManager.currentTime()
                }
            }
            .sheet(isPresented: $showDatabase) {
                DatabaseView()
                    .frame(width: geo.size.width / 3 * 2, height: geo.size.height / 3 * 2)
            }
            .background(BackgroundView())
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(isPreview: true)
            .environmentObject(AudioManager.shared)
    }
}
