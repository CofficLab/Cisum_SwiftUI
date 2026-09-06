import SwiftUI

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

/// 播放导航失败时显示的持久错误面板，直到用户明确关闭。
struct ControlButtonsErrorView: View {
    let error: ControlButtonsError
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.22)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(error.title)
                        .font(.title3.weight(.semibold))
                    Spacer()
                    Image(systemName: "xmark.octagon.fill")
                        .foregroundStyle(.red)
                }

                Text(error.message)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                HStack {
                    Button("Copy error") {
                        #if os(macOS)
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(error.message, forType: .string)
                        #elseif os(iOS)
                        UIPasteboard.general.string = error.message
                        #endif
                    }
                    Spacer()
                    Button("Close", action: dismiss)
                        .keyboardShortcut(.defaultAction)
                }
            }
            .padding(24)
            .frame(minWidth: 320, maxWidth: 560)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
            .shadow(radius: 20)
            .padding(24)
        }
        .zIndex(1)
    }
}
