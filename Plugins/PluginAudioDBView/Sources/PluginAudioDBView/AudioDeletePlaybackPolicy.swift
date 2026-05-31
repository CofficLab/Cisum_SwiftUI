import Foundation

enum AudioDeletePlaybackPolicy {
    static func deletedURLsContainCurrentAudio(currentURL: URL?, deletedURLs: [URL]) -> Bool {
        guard let currentURL else { return false }
        let currentPath = resolvedStandardizedPath(for: currentURL)
        return deletedURLs.contains { deletedURL in
            resolvedStandardizedPath(for: deletedURL) == currentPath
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

    private static func resolvedStandardizedPath(for url: URL) -> String {
        url.resolvingSymlinksInPath().standardizedFileURL.path
    }
}
