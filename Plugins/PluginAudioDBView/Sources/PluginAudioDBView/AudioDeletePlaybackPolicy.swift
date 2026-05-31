import Foundation

enum AudioDeletePlaybackPolicy {
    static func deletedURLsContainCurrentAudio(currentURL: URL?, deletedURLs: [URL]) -> Bool {
        guard let currentURL else { return false }
        let currentPaths = comparablePaths(for: currentURL)
        return deletedURLs.contains { deletedURL in
            !currentPaths.isDisjoint(with: comparablePaths(for: deletedURL))
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

    private static func comparablePaths(for url: URL) -> Set<String> {
        [
            url.standardizedFileURL.path,
            resolvedStandardizedPath(for: url),
        ]
    }
}
