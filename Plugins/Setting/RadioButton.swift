import Foundation
import MagicKit
import MagicUI
import SwiftUI

struct RadioButton: View {
    @State private var isHovering = false
    let title: String
    let description: String
    let url: URL?
    let isSelected: Binding<Bool>
    let trailing: (() -> AnyView)?
    let showURL: Bool
    let isEnabled: Bool
    let disabledReason: String?

    init(
        text: String,
        description: String,
        url: URL?,
        isSelected: Binding<Bool>,
        trailing: (() -> AnyView)? = nil,
        showURL: Bool = false,
        isEnabled: Bool = true,
        disabledReason: String? = nil
    ) {
        self.title = text
        self.description = description
        self.url = url
        self.isSelected = isSelected
        self.trailing = trailing
        self.showURL = showURL
        self.isEnabled = isEnabled
        self.disabledReason = disabledReason
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: isSelected.wrappedValue ? "circle.inset.filled" : "circle")
                    .foregroundColor(isSelected.wrappedValue ? .accentColor : .secondary)
                    .imageScale(.medium)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(title)
                                .font(.headline)

                            Spacer()

                            if let trailing {
                                trailing()
                            }
                        }
                        .padding(.bottom)

                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if showURL {
                            HStack {
                                Text(url?.path ?? "未设置路径")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(nil)
                                Spacer()

                                if let url = url {
                                    BtnOpenFolder(url: url).labelStyle(.iconOnly)
                                }
                            }
                            .padding(8)
                            .background(MagicBackground.deepPurple.opacity(0.2))
                            .cornerRadius(6)
                        }

                        if !isEnabled, let reason = disabledReason {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .imageScale(.small)
                                Text(reason)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if isEnabled {
                    isSelected.wrappedValue = true
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primary)
                    .opacity(isEnabled && isHovering ? 0.05 : 0.0001)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(isEnabled ? 0.1 : 0.05), lineWidth: 1)
                    )
            )
            .opacity(isEnabled ? 1 : 0.5)
            .onHover { hovering in
                isHovering = isEnabled ? hovering : false
            }
        }
    }
}
