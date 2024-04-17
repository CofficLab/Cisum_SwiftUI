#if os(macOS)
import AppKit
#endif
import Foundation
import OSLog

class DeviceConfig {
    static var label = "🧲 DeviceConfig::"
}

// MARK: 窗口

extension DeviceConfig {
    static func getWindowHeight() -> CGFloat {
        #if os(macOS)
        let window = NSApplication.shared.windows.first!
        let frame = window.frame
        let height = frame.size.height

        return height
        #else
        return 0
        #endif
    }

    static func increseHeight(_ h: CGFloat) {
        #if os(macOS)
        os_log("\(Logger.isMain)\(self.label)增加 Height=\(h)")
        let window = NSApplication.shared.windows.first!
        var frame = window.frame
        let oldY = frame.origin.y
        let height = frame.size.height
        
        os_log("\(Logger.isMain)\(self.label) 增加前 Y=\(oldY) height=\(height)")

        frame.origin.y = oldY - h
        frame.size.height = height + h
        
        os_log("\(Logger.isMain)\(self.label) 增加后 Y=\(frame.origin.y) height=\(frame.size.height)")

        window.setFrame(frame, display: true)
        #endif
    }
    
    static func setHeight(_ h: CGFloat) {
        #if os(macOS)
        os_log("\(Logger.isMain)\(self.label)设置Height=\(h)")
        let window = NSApplication.shared.windows.first!
        var frame = window.frame
        let oldY = frame.origin.y
        let height = frame.size.height
        
        os_log("\(Logger.isMain)\(self.label)设置前 Y=\(oldY) height=\(height)")

        frame.origin.y = oldY + height - h
        frame.size.height = h
        
        os_log("\(Logger.isMain)\(self.label)设置后 Y=\(frame.origin.y) height=\(frame.size.height)")

        window.setFrame(frame, display: true)
        #endif
    }
}
