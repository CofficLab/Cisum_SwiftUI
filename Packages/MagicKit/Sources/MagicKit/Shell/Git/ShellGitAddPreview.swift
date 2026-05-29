#if DEBUG && os(macOS)
    import SwiftUI

    struct ShellGitAddPreview: View {
        @State private var status: String = ""
        @State private var stagedFiles: [String] = []
        @State private var unstagedFiles: [String] = []
        @State private var error: String?

        var body: some View {
            VStack(spacing: 16) {
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Repository Status")
                            .font(.headline)

                        Text(status)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)

                        if !stagedFiles.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Staged Files")
                                    .font(.headline)

                                ForEach(stagedFiles, id: \.self) { file in
                                    HStack {
                                        Text(file)
                                        Spacer()
                                        Button("Unstage") {
                                            do {
                                                try ShellGit.reset([file], at: nil)
                                                refreshStatus()
                                            } catch {
                                                self.error = error.localizedDescription
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        if !unstagedFiles.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Unstaged Files")
                                    .font(.headline)

                                ForEach(unstagedFiles, id: \.self) { file in
                                    HStack {
                                        Text(file)
                                        Spacer()
                                        Button("Stage") {
                                            do {
                                                try ShellGit.add([file], at: nil)
                                                refreshStatus()
                                            } catch {
                                                self.error = error.localizedDescription
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .task {
                refreshStatus()
            }
        }

        private func refreshStatus() {
            do {
                status = try ShellGit.status(at: nil)
                stagedFiles = try ShellGit.stagedFiles(at: nil)
                unstagedFiles = try ShellGit.unstagedFiles(at: nil)
                error = nil
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    #Preview("ShellGit+Add Demo") {
        ShellGitAddPreview()
    }

#endif
