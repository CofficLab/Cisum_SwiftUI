import SwiftUI

/// An example view demonstrating the usage of setting components
public struct SettingExampleView: View {
    @State private var notifications = true
    @State private var theme = "System"
    @State private var volume: Double = 0.7
    @State private var developerMode = false
    @State private var quality = "High"
    @State private var libraryLocation = "iCloud"
    @State private var selectedInputDevice = "MacBook Air Microphone"
    @State private var selectedOutputDevice = "MacBook Air Speakers"
    @State private var selectedAudioTab = 0
    @State private var showingDeviceConfirmation = false
    @State private var pendingDevice: String?
    @State private var isPendingInput = false

    // For radio confirmation demo
    @State private var selectedDataMode = "Automatic"
    @State private var showingDataModeConfirmation = false
    @State private var pendingDataMode: String?

    // For sheet confirmation demo
    @State private var selectedQualityMode = "Standard"
    @State private var showingQualitySheet = false
    @State private var pendingQualityMode: String?

    private let version = "1.0.0"
    private let build = "100"

    private let inputDevices = [
        "MacBook Air Microphone",
        "iPhone Microphone",
    ]

    private let outputDevices = [
        "MacBook Air Speakers",
        "AirPods Pro",
        "External Speaker",
    ]

    private let dataModes = [
        "Automatic",
        "Manual",
        "Disabled",
    ]

    private let qualityModes = [
        "Standard",
        "High",
        "Ultra",
    ]

    private let qualityDescriptions = [
        "Standard": "Good quality with balanced performance",
        "High": "Better quality with higher resource usage",
        "Ultra": "Best quality with maximum resource usage",
    ]

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Radio Confirmation Demo Section
            MagicSettingSection(title: "Data Sync Mode", titleAlignment: .leading) {
                VStack(spacing: 0) {
                    ForEach(dataModes, id: \.self) { mode in
                        MagicSettingRow(
                            title: mode,
                            description: mode == "Automatic" ? "Automatically sync data when available" :
                                mode == "Manual" ? "Only sync data when manually triggered" :
                                "Disable all data synchronization",
                            icon: mode == "Automatic" ? .iconCloudUpload :
                                mode == "Manual" ? .iconArrowClockwise :
                                .iconCloudSlash,
                            action: {
                                if mode != selectedDataMode {
                                    pendingDataMode = mode
                                    showingDataModeConfirmation = true
                                }
                            }
                        ) {
                            if mode == selectedDataMode {
                                Image(systemName: .iconCheckmarkSimple)
                                    .foregroundColor(.accentColor)
                            }
                        }

                        if mode != dataModes.last {
                            Divider()
                        }
                    }
                }
            }
            .alert("Change Sync Mode", isPresented: $showingDataModeConfirmation) {
                Button("Cancel", role: .cancel) {
                    pendingDataMode = nil
                }
                Button("Change") {
                    if let mode = pendingDataMode {
                        selectedDataMode = mode
                    }
                    pendingDataMode = nil
                }
            } message: {
                if let mode = pendingDataMode {
                    Text("Changing to \(mode) mode will affect how your data is synchronized. Are you sure you want to continue?")
                }
            }

            // Sheet Confirmation Demo Section
            MagicSettingSection(title: "Processing Quality", titleAlignment: .center) {
                VStack(spacing: 0) {
                    ForEach(qualityModes, id: \.self) { mode in
                        MagicSettingRow(
                            title: mode,
                            description: qualityDescriptions[mode],
                            icon: mode == "Standard" ? .iconSpeedometer :
                                mode == "High" ? .iconSpeedometerMedium :
                                .iconSpeedometerHigh,
                            action: {
                                if mode != selectedQualityMode {
                                    pendingQualityMode = mode
                                    showingQualitySheet = true
                                }
                            }
                        ) {
                            if mode == selectedQualityMode {
                                Image(systemName: .iconCheckmarkSimple)
                                    .foregroundColor(.accentColor)
                            }
                        }

                        if mode != qualityModes.last {
                            Divider()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingQualitySheet) {
                QualityConfirmationView(
                    selectedMode: $selectedQualityMode,
                    pendingMode: pendingQualityMode ?? "",
                    isPresented: $showingQualitySheet
                )
            }

            MagicSettingSection(title: "Audio Devices", titleAlignment: .leading) {
                VStack(spacing: 16) {
                    // Tab Picker
                    Picker("Audio Device Type", selection: $selectedAudioTab) {
                        Text("Output").tag(0)
                        Text("Input").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()

                    // Content based on selected tab
                    Group {
                        if selectedAudioTab == 0 {
                            // Output Devices
                            VStack(spacing: 0) {
                                ForEach(outputDevices, id: \.self) { device in
                                    MagicSettingRow(
                                        title: device,
                                        icon: .iconAudioOutput,
                                        action: {
                                            if device != selectedOutputDevice {
                                                pendingDevice = device
                                                isPendingInput = false
                                                showingDeviceConfirmation = true
                                            }
                                        }
                                    ) {
                                        if device == selectedOutputDevice {
                                            Image(systemName: .iconCheckmarkSimple)
                                                .foregroundColor(.accentColor)
                                        }
                                    }

                                    if device != outputDevices.last {
                                        Divider()
                                    }
                                }
                            }
                        } else {
                            // Input Devices
                            VStack(spacing: 0) {
                                ForEach(inputDevices, id: \.self) { device in
                                    MagicSettingRow(
                                        title: device,
                                        icon: .iconAudioInput,
                                        action: {
                                            if device != selectedInputDevice {
                                                pendingDevice = device
                                                isPendingInput = true
                                                showingDeviceConfirmation = true
                                            }
                                        }
                                    ) {
                                        if device == selectedInputDevice {
                                            Image(systemName: .iconCheckmarkSimple)
                                                .foregroundColor(.accentColor)
                                        }
                                    }

                                    if device != inputDevices.last {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                    .animation(.default, value: selectedAudioTab)
                }
            }

            MagicSettingSection(title: "Media Library Location", titleAlignment: .trailing) {
                VStack(spacing: 0) {
                    MagicSettingPicker(
                        title: "Store Media Files",
                        description: "Choose where to store your media files",
                        icon: .iconMusicLibrary,
                        options: ["iCloud", "Local"],
                        selection: $libraryLocation
                    ) { location in
                        switch location {
                        case "iCloud":
                            return "iCloud Drive"
                        case "Local":
                            return "App Storage"
                        default:
                            return location
                        }
                    }

                    Divider()

                    if libraryLocation == "iCloud" {
                        MagicSettingRow(
                            title: "iCloud Drive",
                            description: "Store media files in iCloud Drive for access across all your devices. Make sure you have enough iCloud storage space.",
                            icon: .iconCloudFill
                        ) {
                            EmptyView()
                        }
                    } else {
                        MagicSettingRow(
                            title: "App Storage",
                            description: "Store media files locally in the app. Files will be removed if you delete the app.",
                            icon: .iconFolder
                        ) {
                            EmptyView()
                        }
                    }
                }
            }

            MagicSettingSection(title: "General", titleAlignment: .leading) {
                VStack(spacing: 0) {
                    MagicSettingToggle(
                        title: "Enable Notifications",
                        description: "Show notifications when new updates are available",
                        icon: .iconNotificationSetting,
                        isOn: $notifications
                    )

                    Divider()

                    MagicSettingPicker(
                        title: "Theme",
                        description: "Choose your preferred app theme",
                        icon: .iconThemeSetting,
                        options: ["System", "Light", "Dark"],
                        selection: $theme
                    ) { $0 }

                    Divider()

                    MagicSettingSlider(
                        title: "Volume",
                        description: "Adjust the default playback volume",
                        icon: .iconVolumeSetting,
                        value: $volume,
                        range: 0 ... 1,
                        step: 0.1
                    )
                }
            }

            MagicSettingSection(title: "Advanced", titleAlignment: .center) {
                VStack(spacing: 0) {
                    MagicSettingToggle(
                        title: "Developer Mode",
                        description: "Enable advanced features and debugging tools",
                        icon: .iconDeveloperSetting,
                        isOn: $developerMode
                    )

                    Divider()

                    MagicSettingPicker(
                        title: "Quality",
                        description: "Set the audio quality for playback",
                        icon: .iconQualitySetting,
                        options: ["Low", "Medium", "High"],
                        selection: $quality
                    ) { $0 }
                }
            }

            MagicSettingSection(title: "Custom Row Examples", titleAlignment: .leading) {
                VStack(spacing: 0) {
                    // Basic row with text
                    MagicSettingRow(
                        title: "Status",
                        description: "Current application status",
                        icon: .iconStatusSetting
                    ) {
                        Text("Running")
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Row with button
                    MagicSettingRow(
                        title: "Cache",
                        description: "Clear temporary files to free up space",
                        icon: .iconCacheSetting
                    ) {
                        Button("Clear Cache") {
                            // Action
                        }
                    }

                    Divider()

                    // Row with indicator
                    MagicSettingRow(
                        title: "Connection",
                        description: "Server connection status",
                        icon: .iconConnectionSetting
                    ) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            Text("Connected")
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    // Row with multiple actions
                    MagicSettingRow(
                        title: "Account",
                        description: "Manage your account settings",
                        icon: .iconAccountSetting
                    ) {
                        HStack(spacing: 12) {
                            Button("Edit") {
                                // Action
                            }
                            Button("Sign Out") {
                                // Action
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
            }

            MagicSettingSection(title: "About", titleAlignment: .center) {
                VStack(spacing: 0) {
                    MagicSettingRow(
                        title: "Version",
                        description: "Current application version",
                        icon: .iconVersionInfo
                    ) {
                        Text("\(version) (\(build))")
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    MagicSettingRow(
                        title: "Copyright",
                        description: "© 2024 Your Company. All rights reserved.",
                        icon: .iconInfo
                    ) {
                        EmptyView()
                    }
                }
            }
        }
        .padding()
        .alert("Change Audio Device", isPresented: $showingDeviceConfirmation) {
            Button("Cancel", role: .cancel) {
                pendingDevice = nil
            }
            Button("Change") {
                if let device = pendingDevice {
                    if isPendingInput {
                        selectedInputDevice = device
                    } else {
                        selectedOutputDevice = device
                    }
                }
                pendingDevice = nil
            }
        } message: {
            if let device = pendingDevice {
                Text("Are you sure you want to switch to \(device)?")
            }
        }
        .infinite()
        .inScrollView()
    }
}

struct QualityConfirmationView: View {
    @Binding var selectedMode: String
    let pendingMode: String
    @Binding var isPresented: Bool

    @State private var isProcessing = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: pendingMode == "Ultra" ? .iconSpeedometerHigh : .iconSpeedometerMedium)
                .font(.system(size: 40))
                .foregroundColor(.accentColor)

            Text("Change Quality Mode")
                .font(.headline)

            Text("You are about to change the quality mode to \(pendingMode). This will affect:")
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                Label("Processing speed", systemImage: .iconClock)
                Label("Resource usage", systemImage: .iconChart)
                Label("Output quality", systemImage: .iconStar)
            }
            .padding()

            if isProcessing {
                ProgressView()
                    .padding()
            } else {
                HStack(spacing: 16) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .keyboardShortcut(.escape)

                    Button("Change") {
                        isProcessing = true
                        // Simulate some processing
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            selectedMode = pendingMode
                            isProcessing = false
                            isPresented = false
                        }
                    }
                    .keyboardShortcut(.return)
                }
                .padding()
            }
        }
        .padding()
    }
}

// MARK: - Preview Provider

#if DEBUG && os(macOS)
#Preview("Setting - macOS") {
    SettingExampleView()
        .frame(height: 600)
}
#endif

#if DEBUG && os(iOS)
#Preview("Setting - iPhone") {
    SettingExampleView()
}
#endif
