import MagicKit

import OSLog
import SwiftUI

enum MigrationProgressUpdatePolicy {
    static func shouldApplyUpdate(currentGeneration: Int, updateGeneration: Int) -> Bool {
        currentGeneration == updateGeneration
    }
}

struct MigrationProgressView: View {
    @Environment(\.pluginStorageDependencies) private var dependencies
    @StateObject private var migrationManager = MigrationManager()
    let sourceLocation: PluginStorageLocation?
    let targetLocation: PluginStorageLocation
    let sourceURL: URL?
    let targetURL: URL?
    let onDismiss: () -> Void

    @State private var processedFiles: [FileStatus] = []
    @State private var sourceFiles: [String] = []
    @State private var targetFiles: [String] = []
    @State private var errorMessage: String?
    @State private var migrationProgress = 0.0
    @State private var currentMigratingFile = ""
    @State private var completionMessage = ""
    @State private var showConfirmation = true // 用于显示确认对话框
    @State private var migrationCompleted = false // 添加新状态变量
    @State private var migrationCancelled = false // 添加新状态来跟踪取消状态
    @State private var cancellationRequested = false
    @State private var showCancelConfirmation = false
    @State private var migrationGeneration = 0

    // 添加 errorAlertMessage 计算属性
    var errorAlertMessage: String {
        """
        \(errorMessage ?? "未知错误")

        存储位置已重置为原位置，未做更改。

        \(errorMessage?.contains("取消") == true ? "部分文件可能已迁移至新位置。" : "")

        建议：
        1. 请检查新旧仓库的权限和空间
        2. 可以手动查看并两个仓库中的数据
        3. 确认问题解决后可以重试迁移
        """
    }

    nonisolated static func completionMessage(shouldMigrate: Bool) -> String {
        shouldMigrate ? "迁移已完成" : "已切换到新位置"
    }

    nonisolated static func shouldPerformMigration(sourceURL: URL?, targetURL: URL?, requestedMigration: Bool) -> Bool {
        requestedMigration && sourceURL != nil && targetURL != nil
    }

    nonisolated static func canMigrateExistingData(sourceLocation: PluginStorageLocation?, sourceURL: URL?) -> Bool {
        guard sourceLocation != nil, let sourceURL else { return false }
        return FileManager.default.fileExists(atPath: sourceURL.path)
    }

    nonisolated static func shouldDisableInteractiveDismiss(
        showConfirmation: Bool,
        migrationCompleted: Bool,
        migrationCancelled: Bool,
        errorMessage: String?
    ) -> Bool {
        !showConfirmation && !migrationCompleted && !migrationCancelled && errorMessage == nil
    }

    nonisolated static func migrationRoots(
        sourceURL: URL?,
        targetURL: URL?,
        requestedMigration: Bool
    ) throws -> (source: URL, target: URL)? {
        guard let targetURL else {
            throw MigrationError.targetDirectoryNotFound
        }

        guard requestedMigration else { return nil }
        guard let sourceURL else {
            throw MigrationError.sourceDirectoryNotFound
        }

        return (sourceURL, targetURL)
    }

    private func prepareForRetry() {
        migrationGeneration += 1
        migrationManager.resetCancellation()
        processedFiles.removeAll()
        sourceFiles.removeAll()
        targetFiles.removeAll()
        errorMessage = nil
        migrationProgress = 0.0
        currentMigratingFile = ""
        completionMessage = ""
        migrationCompleted = false
        migrationCancelled = false
        cancellationRequested = false
        loadSourceFiles()
        loadTargetFiles()
    }

    var body: some View {
        VStack(spacing: 5) {
            GroupBox {
                RepositoryInfoView(
                    title: String(localized: "Source Library", table: "Storage", bundle: .module),
                    location: sourceLocation,
                    url: sourceURL
                ).frame(height: 200)
            }

            HStack {
                Spacer()
                Image(systemName: "arrow.down")
                    .foregroundColor(.secondary)
                    .imageScale(.large)
                    .font(.system(size: 12))
                Spacer()
            }

            GroupBox {
                RepositoryInfoView(
                    title: String(localized: "Target Library", table: "Storage", bundle: .module),
                    location: targetLocation,
                    url: targetURL
                ).frame(height: 200)
            }

            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    Text("⚠️ 重要提示：", tableName: "Storage", bundle: .module)
                        .font(.subheadline)
                        .foregroundColor(.orange)

                    Group {
                        Text("• 如果源数据在 iCloud 中且有未下载的文件，需要等待下载完成，可能需要较长时间", tableName: "Storage", bundle: .module)
                        Text("• 迁移过程中请勿关闭应用，取消迁移可能导致数据不完整", tableName: "Storage", bundle: .module)
                        Text("• 迁移数据：将现有数据迁移到新位置", tableName: "Storage", bundle: .module)
                        Text("• 直接使用：直接使用新位置，原有数据保持不变", tableName: "Storage", bundle: .module).foregroundStyle(.primary)
                        Text("• 取消操作：保持原位置不变", tableName: "Storage", bundle: .module)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }.frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)

            if !showConfirmation {
                migrationStatusView
            }

            if showConfirmation {
                confirmationButtons
            } else {
                actionButtons
            }
        }
        .padding()
        .onAppear {
            loadSourceFiles()
            loadTargetFiles()
        }
        .interactiveDismissDisabled(Self.shouldDisableInteractiveDismiss(
            showConfirmation: showConfirmation,
            migrationCompleted: migrationCompleted,
            migrationCancelled: migrationCancelled,
            errorMessage: errorMessage
        ))
    }

    private func startMigration(shouldMigrate: Bool) async {
        migrationGeneration += 1
        let generation = migrationGeneration

        do {
            let migrationRoots = try Self.migrationRoots(
                sourceURL: sourceURL,
                targetURL: targetURL,
                requestedMigration: shouldMigrate
            )

            if let migrationRoots {
                let manager = migrationManager
                manager.resetCancellation()

                try await Task.detached(priority: .userInitiated) {
                    try manager.migrate(
                        from: migrationRoots.source,
                        to: migrationRoots.target,
                        progressCallback: { progress, file in
                            Task { @MainActor in
                                guard Self.shouldApplyMigrationUpdate(
                                    currentGeneration: self.migrationGeneration,
                                    updateGeneration: generation
                                ) else { return }
                                self.migrationProgress = progress
                                self.currentMigratingFile = file
                                self.updateFileStatus(file)
                            }
                        },
                        downloadProgressCallback: { file, downloadStatus in
                            Task { @MainActor in
                                guard Self.shouldApplyMigrationUpdate(
                                    currentGeneration: self.migrationGeneration,
                                    updateGeneration: generation
                                ) else { return }
                                self.updateFileDownloadStatus(file, downloadStatus: downloadStatus)
                            }
                        },
                        verbose: true
                    )
                }.value
            } else {
                // 如果选择直接使用，立即将进度设置为 100%
                await MainActor.run {
                    self.migrationProgress = 1.0
                }
            }

            // 更新存储位置
            await MainActor.run {
                guard Self.shouldApplyMigrationUpdate(
                    currentGeneration: self.migrationGeneration,
                    updateGeneration: generation
                ) else { return }
                let completionMessage = Self.completionMessage(shouldMigrate: migrationRoots != nil)
                dependencies.updateStorageLocation(targetLocation)
                self.migrationCompleted = true
                self.completionMessage = completionMessage
                self.currentMigratingFile = completionMessage
            }
        } catch MigrationError.migrationCancelled {
            await MainActor.run {
                guard Self.shouldApplyMigrationUpdate(
                    currentGeneration: self.migrationGeneration,
                    updateGeneration: generation
                ) else { return }
                self.cancellationRequested = false
                self.migrationCancelled = true
                self.currentMigratingFile = "迁移已取消"
            }
        } catch {
            await MainActor.run {
                guard Self.shouldApplyMigrationUpdate(
                    currentGeneration: self.migrationGeneration,
                    updateGeneration: generation
                ) else { return }
                self.cancellationRequested = false
                self.errorMessage = error.localizedDescription
                self.updateFileStatus(self.currentMigratingFile, error: error.localizedDescription)
            }
        }
    }

    nonisolated static func shouldApplyMigrationUpdate(currentGeneration: Int, updateGeneration: Int) -> Bool {
        MigrationProgressUpdatePolicy.shouldApplyUpdate(
            currentGeneration: currentGeneration,
            updateGeneration: updateGeneration
        )
    }

    private func loadSourceFiles() {
        guard let sourceURL = sourceURL else { return }

        do {
            let fileManager = FileManager.default
            sourceFiles = try fileManager.contentsOfDirectory(atPath: sourceURL.path)
                .sorted()

            // 初始化所有文件为待处理状态
            processedFiles = sourceFiles.map { fileName in
                FileStatus(
                    name: fileName,
                    status: .pending,
                    downloadStatus: .local // 初始状态默认为本地文件
                )
            }
        } catch {
            print("Error loading source files: \(error)")
        }
    }

    private func loadTargetFiles() {
        guard let targetURL = targetURL else { return }

        do {
            let fileManager = FileManager.default
            targetFiles = try fileManager.contentsOfDirectory(atPath: targetURL.path)
                .sorted()
        } catch {
            print("Error loading target files: \(error)")
        }
    }

    private func updateFileStatus(_ fileName: String, error: String? = nil) {
        if let error = error {
            // 如果有错误，更新文件状态失败
            if let index = processedFiles.firstIndex(where: { $0.name == fileName }) {
                processedFiles[index] = FileStatus(
                    name: fileName,
                    status: .failed(error),
                    downloadStatus: processedFiles[index].downloadStatus // 保持原有的下载状态
                )
            }
            errorMessage = error
        } else {
            // 更新当前处理的文件状态
            if let index = processedFiles.firstIndex(where: { $0.name == fileName }) {
                // 当前文件设置为处理中，保持下载状态不变
                processedFiles[index] = FileStatus(
                    name: fileName,
                    status: .processing,
                    downloadStatus: processedFiles[index].downloadStatus
                )

                let sourceFileExists = sourceURL.map {
                    FileManager.default.fileExists(atPath: $0.appendingPathComponent(fileName).path)
                } ?? false

                // 源文件离开原仓库后才算完成，避免重名目标文件导致开始迁移时被误判完成。
                if !sourceFileExists {
                    processedFiles[index] = FileStatus(
                        name: fileName,
                        status: .completed,
                        downloadStatus: .local // 完成后标记为本地文件
                    )
                }
            }
        }
    }

    // 添加新方法来更新文件的下载状态
    private func updateFileDownloadStatus(_ fileName: String, downloadStatus: FileStatus.DownloadStatus) {
        if let index = processedFiles.firstIndex(where: { $0.name == fileName }) {
            processedFiles[index] = FileStatus(
                name: fileName,
                status: processedFiles[index].status,
                downloadStatus: downloadStatus
            )
        }
    }

    private var confirmationButtons: some View {
        HStack(spacing: 48) {
            Button {
                onDismiss()
            } label: {
                Text("取消操作", tableName: "Storage", bundle: .module)
            }
            .buttonStyle(.bordered)
            .help(String(localized: "保持原位置不变", table: "Storage", bundle: .module))

            Button {
                showConfirmation = false
                
                Task {
                    await startMigration(shouldMigrate: false)
                }
            } label: {
                Text("直接使用", tableName: "Storage", bundle: .module)
            }
            .buttonStyle(.borderedProminent)
            .help(String(localized: "直接使用新位置，原有数据保持不变", table: "Storage", bundle: .module))

            if Self.canMigrateExistingData(sourceLocation: sourceLocation, sourceURL: sourceURL) {
                Button {
                    showConfirmation = false

                    Task {
                        await startMigration(shouldMigrate: true)
                    }
                } label: {
                    Text("迁移数据", tableName: "Storage", bundle: .module)
                }
                .buttonStyle(.bordered)
                .help(String(localized: "将现有数据迁移到新位置", table: "Storage", bundle: .module))
            }
        }
        .padding()
        .frame(maxWidth: 500)
    }

    private var actionButtons: some View {
        Group {
            if errorMessage == nil {
                if migrationCompleted || migrationCancelled {
                    Button {
                        onDismiss()
                    } label: {
                        Text("完成", tableName: "Storage", bundle: .module)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        showCancelConfirmation = true
                    } label: {
                        Text(cancellationRequested ? "正在取消..." : "取消迁移", tableName: "Storage", bundle: .module)
                    }
                    .buttonStyle(.borderless)
                    .disabled(cancellationRequested)
                    .alert(Text("确定要取消迁移吗？", tableName: "Storage", bundle: .module), isPresented: $showCancelConfirmation) {
                        Button(role: .cancel) { } label: {
                            Text("继续迁移", tableName: "Storage", bundle: .module)
                        }
                        Button(role: .destructive) {
                            cancellationRequested = true
                            migrationManager.cancelMigration()
                        } label: {
                            Text("确定取消", tableName: "Storage", bundle: .module)
                        }
                    } message: {
                        Text("取消迁移可能会导致数据不完整，建议等待迁移完成。", tableName: "Storage", bundle: .module)
                    }
                }
            } else {
                HStack(spacing: 16) {
                    Button {
                        prepareForRetry()
                        showConfirmation = true
                    } label: {
                        Text("重试", tableName: "Storage", bundle: .module)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        onDismiss()
                    } label: {
                        Text("放弃", tableName: "Storage", bundle: .module)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(.bottom)
    }

    // 修改状态显示部分
    private var migrationStatusView: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Text("迁移状态", tableName: "Storage", bundle: .module)
                    .font(.headline)
                    .foregroundColor(.primary)

                if migrationCompleted {
                    Text(completionMessage.isEmpty ? Self.completionMessage(shouldMigrate: true) : completionMessage)
                        .font(.subheadline)
                        .foregroundColor(.green)
                } else if migrationCancelled {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("迁移已取消", tableName: "Storage", bundle: .module)
                            .font(.subheadline)
                            .foregroundColor(.orange)

                        Button {
                            prepareForRetry()
                            showConfirmation = true
                        } label: {
                            Text("重试迁移", tableName: "Storage", bundle: .module)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if let errorMessage = errorMessage {
                    Text("迁移出现问题: \(errorMessage)", tableName: "Storage", bundle: .module)
                        .font(.subheadline)
                        .foregroundColor(.red)
                } else {
                    Text(cancellationRequested ? "正在取消..." : "迁移中...", tableName: "Storage", bundle: .module)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }

                if !migrationCancelled {
                    ProgressView(value: migrationProgress)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}
