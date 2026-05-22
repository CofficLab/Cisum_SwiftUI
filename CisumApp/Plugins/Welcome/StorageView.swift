import CisumUI
import MagicKit
import OSLog
import SwiftUI

struct StorageView: View, SuperLog {
    nonisolated static let emoji = "🍴"
    static let verbose = true

    @EnvironmentObject var cloudManager: CloudProvider
    @EnvironmentObject var a: AppProvider

    @State private var tempStorageLocation: StorageLocation

    private var c = Config.self

    init() {
        _tempStorageLocation = State(initialValue: StorageLocation.icloud)
    }

    var body: some View {
        MagicSettingSection(title: String(localized: "Media Storage Location", table: "Welcome"), titleAlignment: .center) {
            VStack(spacing: 12) {
                MagicSettingRow(
                    title: String(localized: "iCloud Drive", table: "Welcome"),
                    description: String(localized: "Files stored in iCloud\nAccessible on other devices\nEnsure sufficient iCloud storage", table: "Welcome"),
                    icon: .cisumIconCloud,
                    action: {
                        if cloudManager.isSignedIn == true && c.getStorageLocation() != .icloud {
                            tempStorageLocation = .icloud
                        }
                    }
                ) {
                    HStack {
                        if tempStorageLocation == .icloud {
                            Image(systemName: .cisumIconCheckmarkSimple)
                                .foregroundColor(.accentColor)
                        } else {
                            Text("Recommended", tableName: "Welcome").font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .opacity(cloudManager.isSignedIn == true ? 1 : 0.5)
                .disabled(cloudManager.isSignedIn != true)

                if cloudManager.isSignedIn != true {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .imageScale(.small)
                        Text("Sign in to iCloud in System Settings to use this option", tableName: "Welcome")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 32)
                    .padding(.bottom, 8)
                }

                Divider()

                MagicSettingRow(
                    title: String(localized: "App Local Storage", table: "Welcome"),
                    description: String(localized: "Stored within the app, data will be lost if app is deleted", table: "Welcome"),
                    icon: .cisumIconFolder,
                    action: {
                        tempStorageLocation = .local
                    }
                ) {
                    HStack {
                        if tempStorageLocation == .local {
                            Image(systemName: .cisumIconCheckmarkSimple)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .onAppear(perform: onAppear)
            .onDisappear(perform: onDisappear)
        }
    }

    // MARK: - 自动设置存储位置

    private func autoSetStorageLocation() {
        // 如果已经有存储位置设置，则使用现有设置
        if let currentLocation = c.getStorageLocation() {
            tempStorageLocation = currentLocation
            return
        }
    }
}

// MARK: - Events Handling

extension StorageView {
    func onDisappear() {
        c.updateStorageLocation(tempStorageLocation)
    }

    func onAppear() {
        autoSetStorageLocation()
    }
}

// MARK: - Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
