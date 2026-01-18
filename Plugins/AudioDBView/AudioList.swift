import MagicAlert
import MagicKit
import OSLog
import SwiftData
import SwiftUI

/*
 展示策略（扁平化列表）：
 - 仅展示仓库中的音频文件；文件夹不会作为分组出现
 - 所有子目录中的文件被“拍平”后按统一规则排序与展示

 示例：
   根目录
   ├─ A/
   │  ├─ A1
   │  └─ A2
   └─ B/
      ├─ B1
      └─ B2

   扁平化后展示为：A1、A2、B1、B2（不显示 A、B 目录本身）
 */
struct AudioList: View, SuperThread, SuperLog, SuperEvent {
    nonisolated static let emoji = "📬"
    nonisolated static let verbose = false

    @EnvironmentObject var playManController: PlayManController
    @EnvironmentObject var audioProvider: AudioProvider
    @EnvironmentObject var m: MagicMessageProvider

    /// 当前选中的音频 URL
    @State private var selection: URL? = nil

    /// 音频列表 URL 数组
    @State private var urls: [URL] = []

    /// 是否正在同步数据
    @State private var isSyncing: Bool = false

    /// 是否正在加载
    @State private var isLoading: Bool = true

    /// 防抖更新任务
    @State private var updateURLsDebounceTask: Task<Void, Never>? = nil

    /// 音频总数
    var total: Int { urls.count }

    var body: some View {
        if Self.verbose {
            os_log("\(self.t)📺 开始渲染")
        }
        return Group {
            if isLoading {
                AudioDBTips(variant: .loading)
            } else if total == 0 {
                AudioDBTips(variant: .empty)
            } else {
                List(selection: $selection) {
                    Section(header: HStack {
                        Text("共 \(total.description)")
                        Spacer()
                        if isSyncing {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .controlSize(.small)
                                Text("正在读取仓库")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if Config.isNotDesktop {
                            BtnAdd()
                                .font(.title2)
                                .labelStyle(.iconOnly)
                        }
                    }, content: {
                        ForEach(urls, id: \.self) { url in
                            AudioItemView(url)
                        }
                        .onDelete(perform: handleDeleteItems)
                    })
                }
                .listStyle(.plain)
            }
        }
        .onAppear(perform: handleOnAppear)
        .onChange(of: selection, handleSelectionChange)
        .onDBDeleted(perform: handleDBDeleted)
        .onDBSynced(perform: handleDBSynced)
        .onDBSortDone(perform: handleDBSortDone)
        .onDBUpdated(perform: handleDBUpdated)
        .onDBSyncing(perform: handleDBSyncing)
        .onPlayManAssetChanged(handleAssetChanged)
        .onDisappear(perform: handleOnDisappear)
    }
}

// MARK: - Action

extension AudioList {
    /// 更新音频列表
    ///
    /// 从数据仓库异步获取所有音频文件的 URL 列表并更新界面。
    /// 使用后台优先级执行，避免阻塞主线程。
    private func updateURLs() {
        Task.detached(priority: .background) {
            if Self.verbose {
                os_log("\(self.t)🔄 获取所有音频 URL")
            }

            let urls = await audioProvider.repo.getAll(reason: self.className)

            if Self.verbose {
                os_log("\(self.t)✅ 获取到 \(urls.count) 个音频")
            }

            await self.setUrls(urls)
        }
    }

    /// 调度防抖更新
    ///
    /// 使用防抖机制延迟更新音频列表，避免频繁刷新。
    /// 如果在延迟期间再次调用，会取消之前的任务并重新开始计时。
    ///
    /// - Parameter seconds: 延迟秒数，默认为 0.25 秒
    @MainActor
    private func scheduleUpdateURLsDebounced(delay seconds: Double = 0.25) {
        if Self.verbose {
            os_log("\(self.t)⏱️ 调度防抖更新，延迟 \(seconds) 秒")
        }

        updateURLsDebounceTask?.cancel()
        updateURLsDebounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1000000000))
            guard !Task.isCancelled else { return }
            self.updateURLs()
        }
    }
}

// MARK: - Setter

extension AudioList {
    /// 设置音频 URL 列表
    ///
    /// 更新音频列表并结束加载状态。
    /// 如果当前选中的 URL 不在新列表中，会自动清除选中状态。
    ///
    /// - Parameter newValue: 新的 URL 列表
    @MainActor
    private func setUrls(_ newValue: [URL]) {
        if Self.verbose {
            os_log("\(self.t)📋 设置 URLs，数量: \(newValue.count)")
        }

        urls = newValue
        self.setIsLoading(false)

        // 如果当前选中的URL不在新的URL列表中，重置相关状态
        if let currentSelection = selection, !newValue.contains(currentSelection) {
            if Self.verbose {
                os_log("\(self.t)⚠️ 当前选中的音频不在列表中，清除选中状态")
            }
            selection = nil
        }
    }

    /// 设置选中的音频
    ///
    /// - Parameter newValue: 选中的音频 URL
    private func setSelection(_ newValue: URL?) {
        if Self.verbose {
            if let url = newValue {
                os_log("\(self.t)🎯 选中音频: \(url.lastPathComponent)")
            } else {
                os_log("\(self.t)🎯 清除选中")
            }
        }
        selection = newValue
    }

    /// 设置加载状态
    ///
    /// - Parameter newValue: 是否正在加载
    private func setIsLoading(_ newValue: Bool) {
        if Self.verbose {
            os_log("\(self.t)⏳ 加载状态: \(newValue ? "加载中" : "完成")")
        }
        isLoading = newValue
    }

    /// 设置同步状态
    ///
    /// - Parameter newValue: 是否正在同步
    private func setIsSyncing(_ newValue: Bool) {
        if Self.verbose {
            os_log("\(self.t)🔄 同步状态: \(newValue ? "同步中" : "完成")")
        }
        isSyncing = newValue
    }
}

// MARK: - Event Handler

extension AudioList {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时触发，开始加载音频列表。
    /// 如果播放器有当前音频，会自动选中该音频。
    func handleOnAppear() {
        if Self.verbose {
            os_log("\(self.t)👀 视图已出现")
        }

        setIsLoading(true)
        scheduleUpdateURLsDebounced()

        if let asset = playManController.getAsset() {
            if Self.verbose {
                os_log("\(self.t)🎵 恢复选中当前播放的音频")
            }
            setSelection(asset)
        }
    }

    /// 处理选中项变化事件
    ///
    /// 当用户选中列表中的音频时触发，自动开始播放该音频。
    /// 加载状态下不会触发播放。
    func handleSelectionChange() {
        if let url = selection, isLoading == false {
            if Self.verbose {
                os_log("\(self.t)▶️ 选中变化，播放: \(url.lastPathComponent)")
            }

            Task {
                await self.playManController.play(url: url)
            }
        }
    }

    /// 处理播放资源变化事件
    ///
    /// 当播放器的当前音频改变时触发，同步更新列表的选中状态。
    ///
    /// - Parameter url: 新的播放资源 URL
    func handleAssetChanged(url: URL?) {
        if let asset = url, asset != selection {
            if Self.verbose {
                os_log("\(self.t)🔄 播放资源变化，更新选中: \(asset.lastPathComponent)")
            }
            self.setSelection(asset)
        }
    }

    /// 处理排序完成事件
    ///
    /// 当数据库排序完成时触发，刷新音频列表。
    ///
    /// - Parameter notification: 排序完成的通知
    func handleDBSortDone(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)✅ 排序完成")
        }
        self.scheduleUpdateURLsDebounced()
    }

    /// 处理音频删除事件
    ///
    /// 当音频文件被删除时触发，使用动画效果从列表中移除对应的项。
    ///
    /// - Parameter notification: 删除完成的通知
    func handleDBDeleted(_ notification: Notification) {
        guard let urlsToDelete = notification.userInfo?["urls"] as? [URL] else {
            if Self.verbose {
                os_log("\(self.t)⚠️ 删除通知中没有 URL 信息")
            }
            // 回退到防抖更新
            self.scheduleUpdateURLsDebounced()
            return
        }

        if Self.verbose {
            os_log("\(self.t)🗑️ 收到删除通知: \(urlsToDelete.count) 个文件")
        }

        // 取消防抖任务，直接更新
        updateURLsDebounceTask?.cancel()

        // 使用动画效果移除已删除的文件
        withAnimation(.easeInOut(duration: 0.3)) {
            urls.removeAll { url in
                urlsToDelete.contains(url)
            }

            // 如果删除的是当前选中的文件，清除选中状态
            if let selected = selection, urlsToDelete.contains(selected) {
                selection = nil
            }
        }

        if Self.verbose {
            os_log("\(self.t)✅ 已移除 \(urlsToDelete.count) 个文件，剩余 \(urls.count) 个")
        }
    }

    /// 处理数据同步完成事件
    ///
    /// 当数据库同步完成时触发，刷新音频列表并结束同步状态。
    ///
    /// - Parameter notification: 同步完成的通知
    func handleDBSynced(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)✅ 数据同步完成")
        }
        self.scheduleUpdateURLsDebounced()
        self.setIsSyncing(false)
    }

    /// 处理数据更新事件
    ///
    /// 当音频数据有更新时触发，刷新音频列表。
    ///
    /// - Parameter notification: 更新完成的通知
    func handleDBUpdated(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)🔄 数据已更新")
        }
        self.scheduleUpdateURLsDebounced()
    }

    /// 处理数据同步开始事件
    ///
    /// 当数据库开始同步时触发，显示同步状态。
    ///
    /// - Parameter notification: 同步开始的通知
    func handleDBSyncing(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)🔄 开始同步数据")
        }
        self.setIsSyncing(true)
    }

    /// 处理删除列表项事件
    ///
    /// 当用户通过列表滑动删除音频时触发，删除文件并显示提示。
    ///
    /// - Parameter offsets: 要删除的项目索引集合
    func handleDeleteItems(at offsets: IndexSet) {
        withAnimation {
            // 获取要删除的 URLs
            let urlsToDelete = offsets.map { urls[$0] }

            if Self.verbose {
                os_log("\(self.t)🗑️ 删除 \(urlsToDelete.count) 个项目")
            }

            // 从数据库中删除对应的 AudioModel
            for url in urlsToDelete {
                if Self.verbose {
                    os_log("\(self.t)📄 删除文件: \(url.shortPath())")
                }

                do {
                    try url.delete()
                    m.info("已删除 \(url.title)")

                    if Self.verbose {
                        os_log("\(self.t)✅ 删除成功: \(url.lastPathComponent)")
                    }
                } catch {
                    os_log(.error, "\(self.t)❌ 删除失败: \(error.localizedDescription)")
                    m.error(error)
                }
            }
        }
    }

    /// 处理视图消失事件
    ///
    /// 当视图从屏幕上消失时触发，取消待处理的防抖任务。
    func handleOnDisappear() {
        if Self.verbose {
            os_log("\(self.t)👋 视图已消失")
        }

        updateURLsDebounceTask?.cancel()
        updateURLsDebounceTask = nil
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
    .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
    .inRootView()
            .frame(width: 600, height: 600)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
    .inRootView()
    }
#endif
