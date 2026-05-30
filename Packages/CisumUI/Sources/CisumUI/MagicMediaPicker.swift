import SwiftUI

public struct MediaItem: Identifiable {
    public let id = UUID()
    public let name: String
    public let artist: String?
    public let isVideo: Bool
    
    public init(name: String, artist: String? = nil, isVideo: Bool) {
        self.name = name
        self.artist = artist
        self.isVideo = isVideo
    }
}

public struct MagicMediaPicker: View {
    let audioItems: [MediaItem]
    let videoItems: [MediaItem]
    let onSelect: (MediaItem) -> Void
    let onDismiss: () -> Void
    
    public init(
        audioItems: [MediaItem],
        videoItems: [MediaItem],
        onSelect: @escaping (MediaItem) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.audioItems = audioItems
        self.videoItems = videoItems
        self.onSelect = onSelect
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        NavigationView {
            List {
                if !audioItems.isEmpty {
                    Section("Audio") {
                        ForEach(audioItems) { item in
                            Button {
                                onSelect(item)
                            } label: {
                                HStack {
                                    Image(systemName: "music.note")
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                        if let artist = item.artist {
                                            Text(artist)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if !videoItems.isEmpty {
                    Section("Video") {
                        ForEach(videoItems) { item in
                            Button {
                                onSelect(item)
                            } label: {
                                HStack {
                                    Image(systemName: "film")
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                        if let artist = item.artist {
                                            Text(artist)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Media")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
            }
        }
    }
} 