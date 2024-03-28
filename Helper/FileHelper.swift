import Foundation
import OSLog

#if os(macOS)
  import AppKit
#endif

class FileHelper {
  static func getSize(url: URL) -> Int {
    let resourceValues = try? url.resourceValues(forKeys: [.fileSizeKey])
    let size = resourceValues?.fileSize ?? 0
    print("File size: \(size) bytes")

    return size
  }

  static func showInFinder(url: URL) {
    #if os(macOS)
      NSWorkspace.shared.activateFileViewerSelecting([url])
    #endif
  }

  static func openFolder(url: URL) {
    #if os(macOS)
      NSWorkspace.shared.open(url)
    #endif
  }

  static func isAudioFile(url: URL) -> Bool {
    return ["mp3", "wav", "m4a"].contains(url.pathExtension.lowercased())
  }

  static func isAudioiCloudFile(url: URL) -> Bool {
    let ex = url.pathExtension.lowercased()

    os_log("\(Logger.isMain)🔧 FileHelper::isAudioiCloudFile -> \(ex)")

    return ex == "icloud" && isAudioFile(url: url.deletingPathExtension())
  }
}
