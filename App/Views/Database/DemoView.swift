import SwiftUI

struct DemoView: View {
    @State var handler = CloudDocumentsHandler()

    var documentURL = AppConfig.documentsDir
    
    var body: some View {
        List {
            Group {
                Button("Create File in Documents") {
                    Task.detached {
                        let hander = self.handler
                        let fileURL = documentURL.appending(path: "hello.txt")
                        do {
                            try await hander.write(targetURL: fileURL, data: "hello world".data(using: .utf8)!)
                        } catch {
                            print(error)
                        }
                    }
                }
                Button("Read Hello world from Documents") {
                    Task {
                        let hander = self.handler
                        let fileURL = documentURL.appending(path: "hello.txt")
                        do {
                            let data = try await hander.read(url: fileURL)
                            print(String(data: data, encoding: .utf8) ?? "nil")
                        } catch {
                            print(error)
                        }
                    }
                }
                Button("Read File & Monitor") {
                    Task {
                        let hander = self.handler
                        let fileURL = documentURL.appending(path: "hello.txt")
                        print(fileURL)
                        do {
                            let data = try await hander.read(url: fileURL)
                            print(String(data: data, encoding: .utf8) ?? "nil")
                        } catch {
                            print(error)
                        }
                        await hander.startMonitoringFile(at: fileURL)
                    }
                }
                Button("Stop Monitor") {
                    Task {
                        let hander = self.handler
                        let fileURL = documentURL.appending(path: "hello.txt")
                        await hander.stopMonitoringFile(at: fileURL)
                    }
                }
                Button("Monitor Directory") {
                    Task {
                        let hander = self.handler
                        await hander.startMonitoringFile(at: documentURL)
                    }
                }
                Button("Stop Monitor Directory") {
                    Task {
                        let hander = self.handler
                        await hander.stopMonitoringFile(at: documentURL)
                    }
                }
            }
            Button("Get Document File List") {
                Task {
                    let query = ItemQuery()
                    for await items in query.searchMetadataItems() {
                        items.forEach {
                            print($0.fileName ?? ""
//                                  ":",
//                                  $0.isDirectory,
//                                  $0.url ?? "url"
//                                  $0.directoryURL ?? "dirURL",
//                                  $0.contentType ?? "type",
//                                  "placeHolder:", $0.isPlaceholder,
//                                  "isDownloading:", $0.isDownloading,
//                                  "progress:", $0.downloadProgress,
//                                  "upLoaded:", $0.uploaded
                            )
                        }
                    }
                }
            }
            Button("Get StartWith H and in Root") {
                Task {
                    print("start")
                    let query = ItemQuery()
                    let containerIdentifier = "iCloud.yueyi.demo.1"
                    guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) else {
                        return
                    }
                    let predicateFormat = "((%K BEGINSWITH[cd] 'h') AND (%K BEGINSWITH %@)) AND (%K.pathComponents.@count == %d)"
                    let predicate = NSPredicate(format: predicateFormat,
                                                NSMetadataItemFSNameKey,
                                                NSMetadataItemPathKey,
                                                containerURL.path,
                                                NSMetadataItemPathKey,
                                                containerURL.pathComponents.count + 1)
                    for await items in query.searchMetadataItems(predicate: predicate, scopes: [NSMetadataQueryUbiquitousDataScope]).throttle(for: .seconds(1), latest: true) {
                        items.forEach {
                            print($0.fileName ?? "")
                        }
                    }
                }
            }
        }.onAppear {
//            Task {
//                let query = ItemQuery()
//                for await items in query.searchMetadataItems() {
//                    items.forEach {
//                        print($0.fileName ?? ""
////                                  ":",
////                                  $0.isDirectory,
////                                  $0.url ?? "url"
////                                  $0.directoryURL ?? "dirURL",
////                                  $0.contentType ?? "type",
////                                  "placeHolder:", $0.isPlaceholder,
////                                  "isDownloading:", $0.isDownloading,
////                                  "progress:", $0.downloadProgress,
////                                  "upLoaded:", $0.uploaded
//                        )
//                    }
//                }
//            }
        }
    }
}

#Preview {
    DemoView()
}
