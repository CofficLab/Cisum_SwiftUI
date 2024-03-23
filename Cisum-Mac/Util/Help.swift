import Foundation

func isAudioFile(url: URL) -> Bool {
    return ["mp3", "wav", "m4a"].contains(url.pathExtension.lowercased())
}

func isAudioiCloudFile(url: URL) -> Bool {
    let ex = url.pathExtension.lowercased()
    
    return ex == "icloud" && isAudioFile(url: url.deletingPathExtension())
}
