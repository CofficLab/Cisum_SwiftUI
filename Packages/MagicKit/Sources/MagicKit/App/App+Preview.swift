#if DEBUG
    import SwiftUI

    // MARK: - App Registry Preview View

    struct AppRegistryPreviewView: View {
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("App Name")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.headline)
                        Text("System Icon")
                            .frame(width: 100, alignment: .center)
                            .font(.headline)
                        Text("Real Icon")
                            .frame(width: 120, alignment: .center)
                            .font(.headline)
                    }
                    .padding(.horizontal)

                    Divider()

                    // App List
                    ForEach(AppRegistry.allCases, id: \.self) { app in
                        AppRegistryRowView(app: app)
                    }
                }
                .padding()
            }
            .frame(minWidth: 500, minHeight: 600)
        }
    }

    // MARK: - App Registry Row View

    struct AppRegistryRowView: View {
        let app: AppRegistry

        var body: some View {
            HStack(spacing: 12) {
                // App Name
                Text(app.displayName)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 13))

                // System Icon
                VStack(spacing: 4) {
                    Image(systemName: app.systemIcon)
                        .frame(width: 32, height: 32)
                    Text("SF Symbol")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 100, alignment: .center)

                // Real Icon
                VStack(spacing: 4) {
                    #if os(macOS)
                    if app.isInstalled, let nsImage = app.icon(useRealIcon: true) as? NSImage {
                        Image(nsImage: nsImage)
                            .resizable()
                            .frame(width: 32, height: 32)
                        Text("Installed")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "questionmark.app")
                            .frame(width: 32, height: 32)
                            .foregroundColor(.secondary)
                        Text("Not Installed")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    #else
                    Image(systemName: app.systemIcon)
                        .frame(width: 32, height: 32)
                    Text("iOS - N/A")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    #endif
                }
                .frame(width: 120, alignment: .center)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

            Divider()
        }
    }

    // MARK: - Preview

    #Preview("App Registry") {
        AppRegistryPreviewView()
    }
#endif
