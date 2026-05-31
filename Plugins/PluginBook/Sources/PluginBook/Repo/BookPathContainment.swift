import Foundation

enum BookPathContainment {
    static func representsSameFile(_ lhs: URL, _ rhs: URL) -> Bool {
        guard lhs.isFileURL, rhs.isFileURL else {
            return lhs.standardized.absoluteString == rhs.standardized.absoluteString
        }

        return resolvedStandardizedPath(for: lhs) == resolvedStandardizedPath(for: rhs)
    }

    static func hasSameResolvedParent(_ url: URL, as parent: URL) -> Bool {
        let resolvedParent = resolvedStandardizedPath(for: url.deletingLastPathComponent())
        return resolvedParent == resolvedStandardizedPath(for: parent)
    }

    static func contains(_ parent: URL, child: URL) -> Bool {
        let parentPath = resolvedStandardizedPath(for: parent)
        let childPath = resolvedStandardizedPath(for: child)
        return childPath == parentPath || childPath.hasPrefix(childPrefix(for: parentPath))
    }

    private static func resolvedStandardizedPath(for url: URL) -> String {
        url.resolvingSymlinksInPath().standardizedFileURL.path
    }

    private static func childPrefix(for parentPath: String) -> String {
        parentPath.hasSuffix("/") ? parentPath : parentPath + "/"
    }
}
