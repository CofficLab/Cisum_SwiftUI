import SwiftUI

public extension String {
    static let cisumIconAppStore = "storefront"
    static let cisumIconArrowUpCircle = "arrow.up.circle"
    static let cisumIconBackward = "backward"
    static let cisumIconCheckmarkSimple = "checkmark"
    static let cisumIconClose = "xmark.circle.fill"
    static let cisumIconCloud = "cloud"
    static let cisumIconDocument = "doc.text"
    static let cisumIconFinder = "macwindow"
    static let cisumIconFolder = "folder"
    static let cisumIconForward = "forward"
    static let cisumIconHeart = "heart"
    static let cisumIconInfo = "info.circle"
    static let cisumIconList = "list.bullet"
    static let cisumIconMore = "ellipsis"
    static let cisumIconMusicFill = "music.note"
    static let cisumIconMusicLibrary = "music.note.house"
    static let cisumIconMusicNote = "music.note"
    static let cisumIconMusicNoteList = "music.note.list"
    static let cisumIconPauseFill = "pause.fill"
    static let cisumIconPhotosFill = "photo.on.rectangle.fill"
    static let cisumIconPlayFill = "play.fill"
    static let cisumIconPreviousPage = "chevron.backward"
    static let cisumIconNextPage = "chevron.forward"
    static let cisumIconRepeat1 = "repeat.1"
    static let cisumIconRepeatAll = "repeat"
    static let cisumIconReset = "arrow.counterclockwise"
    static let cisumIconShowInFinder = "arrow.forward.circle"
    static let cisumIconShuffle = "shuffle"
}

public extension Image {
    static var cisumAppStore: Image { Image(systemName: .cisumIconAppStore) }
    static var cisumBackward: Image { Image(systemName: .cisumIconBackward) }
    static var cisumClose: Image { Image(systemName: .cisumIconClose) }
    static var cisumForward: Image { Image(systemName: .cisumIconForward) }
    static var cisumInfo: Image { Image(systemName: .cisumIconInfo) }
    static var cisumList: Image { Image(systemName: .cisumIconList) }
    static var cisumMore: Image { Image(systemName: .cisumIconMore) }
    static var cisumMusicFill: Image { Image(systemName: .cisumIconMusicFill) }
    static var cisumMusicNote: Image { Image(systemName: .cisumIconMusicNote) }
    static var cisumNextPage: Image { Image(systemName: .cisumIconNextPage) }
    static var cisumPauseFill: Image { Image(systemName: .cisumIconPauseFill) }
    static var cisumPlayFill: Image { Image(systemName: .cisumIconPlayFill) }
    static var cisumPreviousPage: Image { Image(systemName: .cisumIconPreviousPage) }
    static var cisumReset: Image { Image(systemName: .cisumIconReset) }

    static func cisumCoffeeReelIcon(
        useDefaultBackground: Bool = true,
        plateColor: Color = .white,
        handleRotation: Double = 30,
        size: CGFloat? = nil
    ) -> some View {
        Image(systemName: "music.note")
            .resizable()
            .scaledToFit()
            .foregroundStyle(plateColor)
            .padding(size == nil ? 0 : max(4, (size ?? 40) * 0.12))
            .frame(width: size, height: size)
            .background {
                if useDefaultBackground {
                    LinearGradient(
                        colors: [.green.opacity(0.72), .teal.opacity(0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
    }
}
