import Foundation

let emptyAudioModel = AudioModel(
    url: Config.DocumentsDir,
    title: "空",
    description: "无文件",
    track: "1",
    image: "road",
    isEmpty: true
)

struct AudioModel: Equatable {
    let id = UUID()
    let url: URL
    let title: String
    let description: String
    let track: String
    let image: String
    let isEmpty: Bool

    static func fromUrl(url: URL) -> AudioModel {
        return AudioModel(
            url: url,
            title: url.deletingPathExtension().lastPathComponent,
            description: url.lastPathComponent,
            track: url.lastPathComponent,
            image: "image-universe",
            isEmpty: false
        )
    }
}
