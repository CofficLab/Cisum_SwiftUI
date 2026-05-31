import Foundation

enum BookPathContainment {
    static func hasSameResolvedParent(_ url: URL, as parent: URL) -> Bool {
        let resolvedParent = resolvedStandardizedPath(for: url.deletingLastPathComponent())
        return resolvedParent == resolvedStandardizedPath(for: parent)
    }

    static func contains(_ parent: URL, child: URL) -> Bool {
        let parentPath = resolvedStandardizedPath(for: parent)
        let childPath = resolvedStandardizedPath(for: child)
        return childPath == parentPath || childPath.hasPrefix(parentPath + "/")
    }

    private static func resolvedStandardizedPath(for url: URL) -> String {
        url.resolvingSymlinksInPath().standardizedFileURL.path
    }
}
