import SwiftUI
import MagicKit
import MagicUI
import OSLog

struct MigrationProgressView: View {
    @EnvironmentObject var c: ConfigProvider
    @StateObject private var migrationManager = MigrationManager()
    let sourceLocation: StorageLocation
    let targetLocation: StorageLocation
    let sourceURL: URL?
    let targetURL: URL?
    let onDismiss: () -> Void

    @State private var processedFiles: [FileStatus] = []
    @State private var sourceFiles: [String] = []
    @State private var targetFiles: [String] = []
    @State private var errorMessage: String?
    @State private var migrationProgress = 0.0
    @State private var currentMigratingFile = ""
    @State private var showConfirmation = true // 用于显示确认对话框
    @State private var migrationCompleted = false // 添加新状态变量

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

    var body: some View {
        VStack(spacing: 16) {
            Text("数据迁移")
                .font(.title2)
                .fontWeight(.bold)

            GroupBox {
                // 源仓库
                RepositoryInfoView(
                    title: "源仓库",
                    location: sourceLocation,
                    url: sourceURL,
                    files: sourceFiles,
                    processedFiles: processedFiles
                )
            }

            Group {
                HStack {
                    Spacer()
                    Image(systemName: "arrow.down")
                        .foregroundColor(.secondary)
                        .imageScale(.large)
                        .font(.system(size: 32))
                    Spacer()
                }
            }

            GroupBox {
                // 目标仓库
                RepositoryInfoView(
                    title: "目标仓库",
                    location: targetLocation,
                    url: targetURL,
                    files: targetFiles,
                    processedFiles: processedFiles
                )
            }

            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    Text("⚠️ 重要提示：")
                        .font(.subheadline)
                        .foregroundColor(.orange)

                    Group {
                        Text("• 迁移时间取决于数据量大小，可能需要较长时间")
                        Text("• 如果源数据在iCloud中且有未下载的文件，需要等待下载完成")
                        Text("• 迁移过程中请勿关闭应用")
                        Text("• 取消迁移可能导致数据不完整")
                        Text("• 请确保目标位置有足够的存储空间")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }

            // 只在非确认状态下显示迁移状态
            if !showConfirmation {
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("迁移状态")
                            .font(.headline)
                            .foregroundColor(.primary)

                        if migrationCompleted {
                            Text("迁移已完成")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        } else if let errorMessage = errorMessage {
                            Text("迁移出现问题: \(errorMessage)")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        } else {
                            Text("迁移中...")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }

                        ProgressView(value: migrationProgress)
                            .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
            }

            if showConfirmation {
                // 确认对话框
                VStack(spacing: 16) {
                    Text("是否将现有数据迁移到新位置？")
                        .font(.headline)
                    Text("选择\"不迁移\"将在新位置创建空白仓库。")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        Button("迁移数据") {
                            showConfirmation = false
                            startMigration(shouldMigrate: true)
                        }
                        .buttonStyle(.borderedProminent)

                        Button("不迁移") {
                            showConfirmation = false
                            startMigration(shouldMigrate: false)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            } else {
                if errorMessage == nil {
                    if migrationCompleted {
                        Button("完成") {
                            onDismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("取消迁移") {
                            if let window = NSApp.keyWindow {
                                let alert = NSAlert()
                                alert.messageText = "确要取消迁移吗？"
                                alert.informativeText = "取消迁移可能会导致数据不完整，建议等待迁移完成。"
                                alert.alertStyle = .warning
                                alert.addButton(withTitle: "继续迁移")
                                alert.addButton(withTitle: "确定取消")

                                alert.beginSheetModal(for: window) { response in
                                    if response == .alertSecondButtonReturn {
                                        migrationManager.cancelMigration()
                                        onDismiss()
                                    }
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                    }
                } else {
                    HStack(spacing: 16) {
                        Button("重试") {
                            errorMessage = nil
                            showConfirmation = true
                        }
                        .buttonStyle(.borderedProminent)

                        Button("放弃") {
                            onDismiss()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .padding()
        .frame(width: 520)
        .onAppear {
            loadSourceFiles()
            loadTargetFiles()
        }
    }

    private func startMigration(shouldMigrate: Bool) {
        Task.detached(priority: .background) {
            do {
                if shouldMigrate {
                    guard let sourceRoot = await c.getStorageRoot() else {
                        throw MigrationError.sourceDirectoryNotFound
                    }
                    guard let targetRoot = await c.getStorageRoot(for: targetLocation) else {
                        throw MigrationError.targetDirectoryNotFound
                    }
                    
                    try await migrationManager.migrate(
                        from: sourceRoot,
                        to: targetRoot,
                        progressCallback: { progress, file in
                            Task { @MainActor in
                                self.migrationProgress = progress
                                self.currentMigratingFile = file
                                self.updateFileStatus(file)
                            }
                        },
                        downloadProgressCallback: { file, downloadStatus in
                            Task { @MainActor in
                                self.updateFileDownloadStatus(file, downloadStatus: downloadStatus)
                            }
                        },
                        verbose: true
                    )
                }
                
                // 更新存储位置
                await MainActor.run {
                    c.updateStorageLocation(targetLocation)
                    self.migrationCompleted = true
                    self.currentMigratingFile = "迁移完成"
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.updateFileStatus(self.currentMigratingFile, error: error.localizedDescription)
                }
            }
        }
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
                    downloadStatus: .local  // 初始状态默认为本地文件
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
                    downloadStatus: processedFiles[index].downloadStatus  // 保持原有的下载状态
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
                
                // 检查目标文件夹中是否存在该文件，如果存在则表示已完成
                if let targetURL = targetURL,
                   FileManager.default.fileExists(atPath: targetURL.appendingPathComponent(fileName).path) {
                    processedFiles[index] = FileStatus(
                        name: fileName, 
                        status: .completed,
                        downloadStatus: .local  // 完成后标记为本地文件
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
}
