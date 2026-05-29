import SwiftUI

/// A picker setting component
public struct MagicSettingPicker<T: Hashable>: View {
    let title: String
    let description: String?
    let icon: String?
    let options: [T]
    let optionToString: (T) -> String
    @Binding var selection: T

    public init(
        title: String,
        description: String? = nil,
        icon: String? = nil,
        options: [T],
        selection: Binding<T>,
        optionToString: @escaping (T) -> String
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.options = options
        self._selection = selection
        self.optionToString = optionToString
    }

    public var body: some View {
        MagicSettingRow(title: title, description: description, icon: icon) {
            Picker("", selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(optionToString(option))
                        .tag(option)
                }
            }
            .labelsHidden()
            .frame(width: 200)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        MagicSettingPicker(
            title: "Theme",
            description: "Choose your preferred app theme",
            icon: "paintbrush",
            options: ["System", "Light", "Dark"],
            selection: .constant("System")
        ) { $0 }

        Divider()

        MagicSettingPicker(
            title: "Quality",
            icon: "dial.high",
            options: ["Low", "Medium", "High"],
            selection: .constant("High")
        ) { $0 }
    }
    .padding()
}
#endif
