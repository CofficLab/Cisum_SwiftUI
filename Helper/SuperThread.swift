import Foundation

protocol SuperThread {
    
}

extension SuperThread {
    var main: DispatchQueue {
        .main
    }
    
    var bg: DispatchQueue {
        .global()
    }
    
    var background: DispatchQueue {
        .global(qos: .background)
    }
    
    var f: FileManager {
        FileManager.default
    }
    
    func makeQueue(name: String) -> DispatchQueue {
        DispatchQueue(label: name, qos: .background)
    }
}

extension SuperThread {
    var threadName: String {
        "\(Thread.isMainThread ? "[🔥]" : "")"
    }
}
