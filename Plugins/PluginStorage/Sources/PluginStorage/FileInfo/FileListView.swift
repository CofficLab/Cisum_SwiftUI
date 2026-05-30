import MagicKit

import OSLog
import SwiftUI

struct FileListView: View, SuperLog {
    nonisolated static let emoji = "📂"

    let url: URL
    let expandByDefault: Bool

    @State private var selection = Set<FileItem>()
    @State private var expandedItems = Set<FileItem>()
    @State private var visibleItems: [FileItem] = []
    @State private var itemCache: [URL: [FileItem]] = [:]

    nonisolated private static let ignoredFiles = [
        ".DS_Store",
        ".git",
        ".svn",
        "__pycache__",
        "node_modules"
    ]

    init(url: URL, expandByDefault: Bool = false) {
        self.url = url
        self.expandByDefault = expandByDefault

        // 创建根目录项
        let rootItem = FileItem(url: url, level: 0, isExpanded: expandByDefault)

        // 设置初始可见项
        _visibleItems = State(initialValue: [rootItem])

        if expandByDefault {
            _expandedItems = State(initialValue: [rootItem])
        }
    }

    var body: some View {
        Table(of: FileItem.self) {
            TableColumn("名称") { item in
                HStack(spacing: 0) {
                    // 缩进
                    ForEach(0 ..< item.level, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.secondary.opacity(0.1))
                            .frame(width: 1)
                            .padding(.horizontal, 8)
                    }

                    // 展开/折叠按钮 + 文件图标 + 名称
                    HStack(spacing: 4) {
                        FileExpandButton(
                            isDirectory: (try? item.url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false,
                            isExpanded: expandedItems.contains(item)
                        ) { isExpanded in
                            setExpanded(isExpanded, for: item)
                        }

                        FileTitleView(url: item.url)
                    }
                }
            }
            .width(min: 200)

            TableColumn("大小") { item in
                FileSizeView(url: item.url)
            }
            .width(80)

            TableColumn("状态") { item in
                FileStatusColumnView(url: item.url)
            }
            .width(200)
        } rows: {
            ForEach(visibleItems) { item in
                TableRow(item)
            }
        }
        .font(.system(size: 13))
        .task(priority: .background) {
            if expandByDefault {
                updateVisibleItems(reason: "onAppear")
            }
        }
    }

    private func setExpanded(_ isExpanded: Bool, for item: FileItem) {
        if isExpanded {
            expandedItems.insert(item)
        } else {
            expandedItems.remove(item)
        }

        updateVisibleItems(reason: "toggleExpanded")
    }

    private func updateVisibleItems(reason: String) {
        let rootURL = url
        let expandedURLs = Set(expandedItems.map(\.url))
        let cachedItems = itemCache

        Task.detached(priority: .high, operation: {
            os_log("\(Self.t)🔄 Updating visible items with reason: \(reason)")

            let update = Self.buildVisibleItems(
                rootURL: rootURL,
                expandedURLs: expandedURLs,
                cachedItems: cachedItems
            )

            await setVisibleItems(update.visibleItems)
            await mergeItemCache(update.itemCache)
        })
    }

    nonisolated private static func buildVisibleItems(
        rootURL: URL,
        expandedURLs: Set<URL>,
        cachedItems: [URL: [FileItem]]
    ) -> (visibleItems: [FileItem], itemCache: [URL: [FileItem]]) {
        var cache = cachedItems
        let rootItem = FileItem(url: rootURL, level: 0, isExpanded: expandedURLs.contains(rootURL))
        var result = [rootItem]

        if rootItem.isExpanded {
            addVisibleChildren(from: rootItem, expandedURLs: expandedURLs, itemCache: &cache, into: &result)
        }

        return (result, cache)
    }

    nonisolated private static func addVisibleChildren(
        from item: FileItem,
        expandedURLs: Set<URL>,
        itemCache: inout [URL: [FileItem]],
        into result: inout [FileItem]
    ) {
        let children = itemCache[item.url] ?? childItems(for: item)
        itemCache[item.url] = children

        for child in children {
            let childItem = FileItem(
                url: child.url,
                level: child.level,
                isExpanded: expandedURLs.contains(child.url)
            )
            result.append(childItem)

            if childItem.isExpanded {
                addVisibleChildren(from: childItem, expandedURLs: expandedURLs, itemCache: &itemCache, into: &result)
            }
        }
    }

    nonisolated private static func childItems(for item: FileItem) -> [FileItem] {
        guard let children = item.children() else { return [] }

        return children
            .filter { child in
                !ignoredFiles.contains(child.url.lastPathComponent)
            }
            .sorted { item1, item2 in
                item1.url.lastPathComponent.localizedStandardCompare(item2.url.lastPathComponent) == .orderedAscending
            }
    }

    @MainActor
    private func setVisibleItems(_ items: [FileItem]) {
        visibleItems = items
    }

    @MainActor
    private func mergeItemCache(_ cache: [URL: [FileItem]]) {
        itemCache.merge(cache) { _, new in new }
    }
}

#Preview("文件列表") {
    let url = URL(filePath: "/Users/user/Music")

    return FileListView(url: url, expandByDefault: true)
        .frame(height: 400)
        .padding()
}
