import Foundation

enum AudioDeletePlaybackPolicy {
    static func shouldResetAfterDelete(currentURL: URL?, deletedURLs: [URL]) -> Bool {
        guard let currentURL else { return false }
        let currentPath = currentURL.standardizedFileURL.path
        return deletedURLs.contains { deletedURL in
            deletedURL.standardizedFileURL.path == currentPath
        }
    }
}
