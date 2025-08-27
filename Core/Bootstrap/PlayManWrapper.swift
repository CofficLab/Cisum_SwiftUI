import SwiftUI

@MainActor
public class PlayManController:ObservableObject {
    let playMan: PlayMan
    
    init(playMan: PlayMan) {
        self.playMan = playMan
    }

    func getAsset() -> URL? {
        playMan.asset
    }

    func play(url: URL, autoPlay: Bool = true) async {
        await playMan.play(url, autoPlay: autoPlay)
    }

    func seek(time: TimeInterval) async {
        playMan.seek(time: time)
    }
}

@MainActor
public class PlayManWrapper {
    let playMan: PlayMan

    init(playMan: PlayMan) {
        self.playMan = playMan
    }

    var playing: Bool {
        playMan.playing
    }

    var currentTime: TimeInterval {
        playMan.currentTime
    }

    func play(url: URL, autoPlay: Bool = true) async {
        await playMan.play(url, autoPlay: autoPlay)
    }

    func seek(time: TimeInterval) async {
        playMan.seek(time: time)
    }

    func setPlayMode(_ mode: PlayMode) {
        playMan.changePlayMode(mode)
    }

    func getPlayMode() -> PlayMode {
        playMan.playMode
    }

    func setLike(_ isLiked: Bool) {
        playMan.setLike(isLiked)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
