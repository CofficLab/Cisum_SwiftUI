import Foundation

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

import LocalAuthentication
import Foundation
import OSLog

extension AppConfig {
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

    static func increseHeight(_ h: CGFloat, verbose: Bool = false) {
        #if os(macOS)
        if verbose {
            os_log("\(Logger.isMain)\(self.label)增加 Height=\(h)")
        }
        
        let window = NSApplication.shared.windows.first!
        var frame = window.frame
        let oldY = frame.origin.y
        let height = frame.size.height

        if verbose {
            os_log("\(Logger.isMain)\(self.label) 增加前 Y=\(oldY) height=\(height)")
        }

        frame.origin.y = oldY - h
        frame.size.height = height + h

        if verbose {
            os_log("\(Logger.isMain)\(self.label) 增加后 Y=\(frame.origin.y) height=\(frame.size.height)")
        }

        window.setFrame(frame, display: true)
        #endif
    }

    static func setHeight(_ h: CGFloat, verbose: Bool = false) {
        #if os(macOS)
        if verbose {
            os_log("\(Logger.isMain)\(self.label)设置Height=\(h)")
        }
        
        let window = NSApplication.shared.windows.first!
        var frame = window.frame
        let oldY = frame.origin.y
        let height = frame.size.height

        if verbose {
            os_log("\(Logger.isMain)\(self.label)设置前 Y=\(oldY) height=\(height)")
        }

        frame.origin.y = oldY + height - h
        frame.size.height = h

        if verbose {
            os_log("\(Logger.isMain)\(self.label)设置后 Y=\(frame.origin.y) height=\(frame.size.height)")
        }

        window.setFrame(frame, display: true)
        #endif
    }
}

// MARK: FACEID

extension AppConfig {
    static func isFaceIDAvailable() -> Bool {
        biometricType() == .faceID
    }
    
    static func biometricType() -> LABiometryType {
        let authContext = LAContext()
        if #available(iOS 11, *) {
            let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            
            return authContext.biometryType
        } else {
            return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
        }
    }
}

// MARK: HomeIndicator

extension AppConfig {
    static func hasHomeIndicator() -> Bool {
        #if os(iOS)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first?.safeAreaInsets.bottom ?? 0 > 0
        }
        #endif
        
        return false
    }
}
