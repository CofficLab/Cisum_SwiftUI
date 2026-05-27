import SwiftUI

public struct MagicAudioView: View {
    let title: String
    let artist: String?
    
    public init(title: String, artist: String? = nil) {
        self.title = title
        self.artist = artist
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.circle")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                
                if let artist = artist {
                    Text(artist)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
} 