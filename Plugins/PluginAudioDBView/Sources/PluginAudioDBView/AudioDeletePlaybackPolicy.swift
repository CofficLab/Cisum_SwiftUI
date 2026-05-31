import Foundation

enum AudioDeletePlaybackPolicy {
    static func deletedURLsContainCurrentAudio(currentURL: URL?, deletedURLs: [URL]) -> Bool {
        guard let currentURL else { return false }
        let currentPath = currentURL.standardizedFileURL.path
        return deletedURLs.contains { deletedURL in
            deletedURL.standardizedFileURL.path == currentPath
        }
    }

    static func shouldResetDirectlyAfterDelete(
        currentURL: URL?,
        deletedURLs: [URL],
        isPlaybackControllerHandlingDeletion: Bool
    ) -> Bool {
        !isPlaybackControllerHandlingDeletion && deletedURLsContainCurrentAudio(
            currentURL: currentURL,
            deletedURLs: deletedURLs
        )
    }
}
