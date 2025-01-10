import MagicKit

import SwiftUI

protocol SuperSetting {
}

extension SuperSetting {
    @MainActor func makeSettingView<Content: View, Trailing: View>(
        title: String,
        @ViewBuilder content: () -> Content,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(title).font(.headline)
                        Spacer()
                        trailing()
                    }
                    content().font(.footnote)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(10)
        }
        .background(MagicBackground.aurora.opacity(0.1))
    }
    
    @MainActor func makeSettingView<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        makeSettingView(title: title, content: content) {
            EmptyView()
        }
    }
}
