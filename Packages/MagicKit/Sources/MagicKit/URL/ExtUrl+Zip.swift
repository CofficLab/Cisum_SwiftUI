import Foundation
import ZIPFoundation
import SwiftUI

public extension URL {
    /// Compresses the current file or directory into a zip file using ZIPFoundation.
    ///
    /// - Parameter destination: The destination URL for the zip file. If nil, creates a zip file in the same directory.
    /// - Returns: The URL of the created zip file.
    /// - Throws: An error if the compression fails.
    func compress(to destination: URL? = nil) throws -> URL {
        let fileManager = FileManager()
        let destinationURL = destination ?? self.deletingPathExtension().appendingPathExtension("zip")
        try fileManager.zipItem(at: self, to: destinationURL, shouldKeepParent: false, compressionMethod: .deflate)
        return destinationURL
    }

    /// Unzips the current zip file to the specified destination.
    ///
    /// - Parameter destination: The destination URL for the unzipped files. If nil, creates a folder in the same directory.
    /// - Returns: The URL of the destination directory.
    /// - Throws: An error if the decompression fails.
    func unzip(to destination: URL? = nil) throws -> URL {
        let fileManager = FileManager()
        let destinationURL = destination ?? self.deletingPathExtension()
        try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)
        try fileManager.unzipItem(at: self, to: destinationURL)
        return destinationURL
    }
}

#if DEBUG
struct URLZipExtension_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button("Compress Test File") {
                let fileManager = FileManager()
                let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let testFile = docsDir.appendingPathComponent("test.txt")
                
                // Create a test file
                try? "This is a test file".write(to: testFile, atomically: true, encoding: .utf8)
                
                do {
                    let zipFile = try testFile.compress()
                    print("File compressed to: \(zipFile.path)")
                } catch {
                    print("Compression failed: \(error)")
                }
            }
            
            Button("Unzip Test File") {
                let fileManager = FileManager()
                let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let testFile = docsDir.appendingPathComponent("test.txt")
                let zipFile = docsDir.appendingPathComponent("test.zip")
                
                // Create a test file and compress it
                try? "This is a test file".write(to: testFile, atomically: true, encoding: .utf8)
                try? testFile.compress(to: zipFile)
                
                do {
                    let unzippedDir = try zipFile.unzip()
                    print("File unzipped to: \(unzippedDir.path)")
                } catch {
                    print("Decompression failed: \(error)")
                }
            }
        }
        .padding()
    }
}
#endif
