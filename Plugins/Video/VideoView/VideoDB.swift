import Foundation
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers
import MagicKit
import MagicUI

struct VideoDB: View, @preconcurrency SuperLog {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var message: MessageProvider
    @EnvironmentObject var db: AudioRecordDB

    @State var treeView = false

    @Query(AudioModel.descriptorAll, animation: .default) var audios: [AudioModel]

    static let emoji = "🐘"

    var dropping: Bool { app.isDropping }

    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Self.i)")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VideoGrid().frame(maxHeight: .infinity)
        }
        .fileImporter(
            isPresented: $app.isImporting,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true,
            onCompletion: { result in
                switch result {
                case let .success(urls):
                    copy(urls)
                case let .failure(error):
                    os_log(.error, "导入文件失败Error: \(error.localizedDescription)")
                }
            }
        )
    }
}

// MARK: 操作

extension VideoDB {
    func copy(_ files: [URL]) {

    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
