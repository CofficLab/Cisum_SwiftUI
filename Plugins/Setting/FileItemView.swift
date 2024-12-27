import SwiftUI
import MagicKit
import MagicUI

@MainActor
class FileItemViewModel: ObservableObject {
    @Published private(set) var downloadStatus: FileStatus.DownloadStatus?
    private let statusChecker = DirectoryStatusChecker()
    private let url: URL
    
    init(url: URL) {
        self.url = url
        self.downloadStatus = .checking
    }
    
    func checkStatus() async {
        downloadStatus = await statusChecker.checkItemStatus(url) { _, status in
            Task { @MainActor in
                withAnimation {
                    self.downloadStatus = status
                }
            }
        }
    }
}

struct FileItemView: View {
    let file: String
    let fileStatus: FileStatus?
    let rootURL: URL
    
    @StateObject private var viewModel: FileItemViewModel
    
    init(file: String, fileStatus: FileStatus?, rootURL: URL) {
        self.file = file
        self.fileStatus = fileStatus
        self.rootURL = rootURL
        let fileURL = rootURL.appendingPathComponent(file)
        _viewModel = StateObject(wrappedValue: FileItemViewModel(url: fileURL))
    }
    
    var body: some View {
        HStack {
            statusIcon
            fileName
            Spacer()
            // 添加状态描述
            if let status = viewModel.downloadStatus {
                Text(status.description)
                    .font(.caption)
                    .foregroundColor(status.color)
                    .transition(.opacity)
            }
        }
        .padding(.vertical, 2)
        .background(
            fileStatus?.status == .processing ? 
                Color.accentColor.opacity(0.1) : 
                Color.clear
        )
        .cornerRadius(4)
        .task {
            await viewModel.checkStatus()
        }
    }
    
    private var statusIcon: some View {
        Group {
            if let status = viewModel.downloadStatus {
                Image(systemName: status.icon)
                    .foregroundColor(status.color)
                    .if(fileStatus?.status == .processing) { view in
                        view.rotationEffect(.degrees(360))
                            .animation(
                                .linear(duration: 1.0)
                                .repeatForever(autoreverses: false),
                                value: fileStatus?.status
                            )
                    }
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.downloadStatus)
    }
    
    private var fileName: some View {
        Text(file)
            .font(.caption)
            .foregroundColor(
                fileStatus?.status == .processing ? .primary : .secondary
            )
    }
}
