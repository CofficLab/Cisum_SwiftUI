import SwiftUI

/// A toggle setting component
public struct MagicSettingToggle: View {
    let title: String
    let description: String?
    let icon: String?
    @Binding var isOn: Bool

    public init(
        title: String,
        description: String? = nil,
        icon: String? = nil,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self._isOn = isOn
    }

    public var body: some View {
        MagicSettingRow(title: title, description: description, icon: icon) {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
        }
    }
}

// MARK: - Preview

#if DEBUG
    #Preview {
        VStack(spacing: 0) {
            MagicSettingToggle(
                title: "Enable Feature",
                description: "Turn this on to enable the awesome feature",
                icon: "star",
                isOn: .constant(true)
            )

            Divider()

            MagicSettingToggle(
                title: "Simple Toggle",
                icon: "bell",
                isOn: .constant(false)
            )
        }
        .padding()
        .frame(width: 400)
    }
#endif
