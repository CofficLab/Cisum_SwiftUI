import Foundation

enum AudioDeletePlaybackPolicy {
    static func shouldResetAfterDelete(currentURL: URL?, deletedURLs: [URL]) -> Bool {
        guard let currentURL else { return false }
        return deletedURLs.contains(currentURL)
    }
}
