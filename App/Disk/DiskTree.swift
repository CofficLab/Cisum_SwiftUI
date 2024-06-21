import Foundation
import SwiftUI

struct DiskTree: Hashable, Identifiable, CustomStringConvertible, FileBox {
    var id: Self { self }
    var url: URL
    var name: String
    var children: [DiskTree]? = nil
    var index: Int = 0
    
    var description: String {
        switch children {
        case nil:
            return "📄 \(name)"
        case let .some(children):
            return children.isEmpty ? "📂 \(name)" : "📁 \(name)"
        }
    }
    
    static func fromURL(_ url: URL) -> DiskTree {
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey, .isDirectoryKey], options: .skipsHiddenFiles)
            var subdirectories = contents.filter { $0.hasDirectoryPath }
            var files = contents.filter { !$0.hasDirectoryPath }
            
            // Sort subdirectories and files by name
            subdirectories.sort { $0.lastPathComponent < $1.lastPathComponent }
            files.sort { $0.lastPathComponent < $1.lastPathComponent }
            
            var children: [DiskTree] = []
            
            for subdirectory in subdirectories {
                let subdirectoryTree = DiskTree.fromURL(subdirectory)
                children.append(subdirectoryTree)
            }
            
            for file in files {
                let fileTree = DiskTree(url: file, name: file.lastPathComponent, children: nil)
                children.append(fileTree)
            }
            
            return DiskTree(url: url, name: url.lastPathComponent, children: children.isEmpty ? nil : children)
        } catch {
            // Handle error
            return DiskTree(url: url, name: url.lastPathComponent, children: nil)
        }
    }
}

// MARK: Next

extension DiskTree {
    func next() -> DiskTree? {
        guard let parent = self.parent, let siblings = parent.children, siblings.count > self.index + 1 else {
            return nil
        }
        
        return siblings[self.index + 1]
    }
}

// MARK: Parent

extension DiskTree {
    var parent: DiskTree? {
        guard let parentURL = self.url.deletingLastPathComponent() as URL? else {
            return nil
        }
        
        return DiskTree.fromURL(parentURL)
    }
}

// MARK: Tramsform

extension DiskTree {
    func toPlayAsset() -> PlayAsset {
        PlayAsset(url: self.url)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
