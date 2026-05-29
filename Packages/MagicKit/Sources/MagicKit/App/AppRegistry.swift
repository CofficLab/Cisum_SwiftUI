import SwiftUI

/// 常见应用注册表
/// 维护了常见应用的 bundleId、系统图标（SF Symbols）和真实图标支持
public enum AppRegistry: String, CaseIterable {
    // MARK: - Developer Tools

    /// Xcode
    case xcode
    /// VS Code
    case vscode
    /// Cursor
    case cursor
    /// Trae
    case trae
    /// Antigravity
    case antigravity
    /// GitHub Desktop
    case githubDesktop
    /// Kiro
    case kiro
    /// IntelliJ IDEA
    case intelliJIDEA
    /// WebStorm
    case webStorm
    /// PyCharm
    case pyCharm
    /// Android Studio
    case androidStudio
    /// Visual Studio
    case visualStudio
    /// iTerm2
    case iTerm2
    /// Warp
    case warp

    // MARK: - Browsers

    /// Safari
    case safari
    /// Chrome
    case chrome
    /// Firefox
    case firefox
    /// Edge
    case edge
    /// Arc
    case arc
    /// Brave
    case brave
    /// Opera
    case opera
    /// Vivaldi
    case vivaldi

    // MARK: - Communication

    /// Messages (iMessage)
    case messages
    /// Mail
    case mail
    /// Slack
    case slack
    /// Discord
    case discord
    /// Telegram
    case telegram
    /// WhatsApp
    case whatsapp
    /// Zoom
    case zoom
    /// Microsoft Teams
    case teams
    /// FaceTime
    case facetime
    /// Skype
    case skype

    // MARK: - Productivity

    /// Notes
    case notes
    /// Reminders
    case reminders
    /// Calendar
    case calendar
    /// Contacts
    case contacts
    /// Preview
    case preview
    /// TextEdit
    case textEdit
    /// Stickies
    case stickies
    /// Calculator
    case calculator
    /// Dictionary
    case dictionary
    /// System Preferences/Settings
    case systemSettings

    // MARK: - Creative & Design

    /// Sketch
    case sketch
    /// Figma
    case figma
    /// Adobe Photoshop
    case photoshop
    /// Adobe Illustrator
    case illustrator
    /// Adobe After Effects
    case afterEffects
    /// Adobe Premiere Pro
    case premierePro
    /// Affinity Designer
    case affinityDesigner
    /// Affinity Photo
    case affinityPhoto
    /// Pixelmator Pro
    case pixelmatorPro

    // MARK: - Music & Video

    /// Music
    case music
    /// TV
    case tv
    /// Podcasts
    case podcasts
    /// News
    case news
    /// Books
    case books
    /// Spotify
    case spotify
    /// VLC
    case vlc
    /// IINA
    case iina
    /// QuickTime Player
    case quicktimePlayer

    // MARK: - Utilities

    /// Finder
    case finder
    /// Terminal
    case terminal
    /// Activity Monitor
    case activityMonitor
    /// Console
    case console
    /// Disk Utility
    case diskUtility
    /// Keychain Access
    case keychainAccess
    /// System Information
    case systemInformation
    /// Voice Memos
    case voiceMemos

    // MARK: - Cloud & Storage

    /// iCloud Drive
    case icloudDrive
    /// Dropbox
    case dropbox
    /// Google Drive
    case googleDrive
    /// OneDrive
    case onedrive
    /// Box
    case box

    // MARK: - Social

    /// Twitter/X
    case twitter
    /// Reddit
    case reddit
    /// LinkedIn
    case linkedin
    /// WeChat
    case wechat
    /// QQ
    case qq

    // MARK: - Games

    /// Steam
    case steam
    /// Epic Games
    case epicGames
    /// Battle.net
    case battleNet

    // MARK: - Other

    /// App Store
    case appStore
    /// Photos
    case photos
    /// Maps
    case maps
    /// Weather
    case weather
    /// Clock
    case clock
    /// Home
    case home
    /// Wallet
    case wallet
    /// Stocks
    case stocks
    /// Shortcuts
    case shortcuts
    /// Files (iOS)
    case files

    // MARK: - Third-party Apps

    /// Notion
    case notion
    /// Obsidian
    case obsidian
    /// Bear
    case bear
    /// Things3
    case things3
    /// Todoist
    case todoist
    /// 1Password
    case onepassword
    /// Raycast
    case raycast
    /// Alfred
    case alfred
    /// Bartender
    case bartender
    /// CleanMyMac
    case cleanMyMac
    /// Magnet
    case magnet
    /// Rectangle
    case rectangle

    // MARK: - Properties

    /// 获取应用程序的 Bundle ID
    public var bundleId: String? {
        switch self {
        // Developer Tools
        case .xcode:
            return "com.apple.dt.Xcode"
        case .vscode:
            return "com.microsoft.VSCode"
        case .cursor:
            return "com.todesktop.230313mzl4w4u92"
        case .trae:
            return "com.trae.app"
        case .antigravity:
            return "com.google.antigravity"
        case .githubDesktop:
            return "com.github.GitHubClient"
        case .kiro:
            return "dev.kiro.desktop"
        case .intelliJIDEA:
            return "com.jetbrains.intellij"
        case .webStorm:
            return "com.jetbrains.WebStorm"
        case .pyCharm:
            return "com.jetbrains.PyCharm"
        case .androidStudio:
            return "com.google.android.studio"
        case .visualStudio:
            return "com.microsoft.VisualStudio"
        case .iTerm2:
            return "com.googlecode.iterm2"
        case .warp:
            return "dev.warp.Warp-Stable"

        // Browsers
        case .safari:
            return "com.apple.Safari"
        case .chrome:
            return "com.google.Chrome"
        case .firefox:
            return "org.mozilla.firefox"
        case .edge:
            return "com.microsoft.edgemac"
        case .arc:
            return "company.thebrowser.Browser"
        case .brave:
            return "com.brave.Browser"
        case .opera:
            return "com.operasoftware.Opera"
        case .vivaldi:
            return "com.vivaldi.Vivaldi"

        // Communication
        case .messages:
            return "com.apple.MobileSMS"
        case .mail:
            return "com.apple.mail"
        case .slack:
            return "com.tinyspeck.slackmacgap"
        case .discord:
            return "com.hnc.Discord"
        case .telegram:
            return "ru.keepcoder.Telegram"
        case .whatsapp:
            return "net.whatsapp.WhatsApp"
        case .zoom:
            return "us.zoom.xos"
        case .teams:
            return "com.microsoft.teams2"
        case .facetime:
            return "com.apple.FaceTime"
        case .skype:
            return "com.skype.skype"

        // Productivity
        case .notes:
            return "com.apple.Notes"
        case .reminders:
            return "com.apple.reminders"
        case .calendar:
            return "com.apple.iCal"
        case .contacts:
            return "com.apple.AddressBook"
        case .preview:
            return "com.apple.Preview"
        case .textEdit:
            return "com.apple.TextEdit"
        case .stickies:
            return "com.apple.Stickies"
        case .calculator:
            return "com.apple.calculator"
        case .dictionary:
            return "com.apple.Dictionary"
        case .systemSettings:
            return "com.apple.systempreferences"

        // Creative & Design
        case .sketch:
            return "com.bohemiancoding.sketch3"
        case .figma:
            return "com.figma.Desktop"
        case .photoshop:
            return "com.adobe.Photoshop"
        case .illustrator:
            return "com.adobe.Illustrator"
        case .afterEffects:
            return "com.adobe.AfterEffects"
        case .premierePro:
            return "com.adobe.PremierePro"
        case .affinityDesigner:
            return "com.seriflabs.affinitydesigner2"
        case .affinityPhoto:
            return "com.seriflabs.affinityphoto2"
        case .pixelmatorPro:
            return "com.pixelmatorteam.pixelmator.x"

        // Music & Video
        case .music:
            return "com.apple.Music"
        case .tv:
            return "com.apple.TV"
        case .podcasts:
            return "com.apple.podcasts"
        case .news:
            return "com.apple.News"
        case .books:
            return "com.apple.iBooks"
        case .spotify:
            return "com.spotify.client"
        case .vlc:
            return "org.videolan.vlc"
        case .iina:
            return "com.colliderli.iina"
        case .quicktimePlayer:
            return "com.apple.QuickTimePlayerX"

        // Utilities
        case .finder:
            return "com.apple.finder"
        case .terminal:
            return "com.apple.Terminal"
        case .activityMonitor:
            return "com.apple.ActivityMonitor"
        case .console:
            return "com.apple.Console"
        case .diskUtility:
            return "com.apple.DiskUtility"
        case .keychainAccess:
            return "com.apple.keychainaccess"
        case .systemInformation:
            return "com.apple.SystemInfo"
        case .voiceMemos:
            return "com.apple.VoiceMemos"

        // Cloud & Storage
        case .icloudDrive:
            return "com.apple.CloudDocsUI"
        case .dropbox:
            return "com.getdropbox.dropbox"
        case .googleDrive:
            return "com.google.GoogleDrive"
        case .onedrive:
            return "com.microsoft.OneDrive-mac"
        case .box:
            return "com.box.desktop"

        // Social
        case .twitter:
            return "com.twitter.twitter-mac"
        case .reddit:
            return "com.reddit.Reddit"
        case .linkedin:
            return "com.linkedin.mac.viewer"
        case .wechat:
            return "com.tencent.xinWeChat"
        case .qq:
            return "com.tencent.qq"

        // Games
        case .steam:
            return "com.valvesoftware.steam"
        case .epicGames:
            return "com.epicgames.EpicGamesLauncher"
        case .battleNet:
            return "com.blizzard.launcher"

        // Other
        case .appStore:
            return "com.apple.AppStore"
        case .photos:
            return "com.apple.Photos"
        case .maps:
            return "com.apple.Maps"
        case .weather:
            return "com.apple.weather"
        case .clock:
            return "com.apple.mobiletimer"
        case .home:
            return "com.apple.Home"
        case .wallet:
            return "com.apple.Passbook"
        case .stocks:
            return "com.apple.stocks"
        case .shortcuts:
            return "com.apple.shortcuts"
        case .files:
            return "com.apple.DocumentsApp"

        // Third-party Apps
        case .notion:
            return "notion.id"
        case .obsidian:
            return "md.obsidian"
        case .bear:
            return "net.shinyfrog.bear"
        case .things3:
            return "com.culturedcode.ThingsMac"
        case .todoist:
            return "com.todoist.mac"
        case .onepassword:
            return "com.agilebits.onepassword7"
        case .raycast:
            return "com.raycast.macos"
        case .alfred:
            return "com.runningwithcrayons.Alfred"
        case .bartender:
            return "com.surteesstudios.Bartender"
        case .cleanMyMac:
            return "com.macpaw.CleanMyMac4"
        case .magnet:
            return "com.crowdcafe.windowmagnet"
        case .rectangle:
            return "com.rectangleapp.Rectangle"
        }
    }

    /// 获取系统图标（SF Symbols）
    public var systemIcon: String {
        switch self {
        // Developer Tools
        case .xcode:
            return .iconXcode
        case .vscode, .cursor, .trae, .antigravity, .intelliJIDEA, .webStorm, .pyCharm, .androidStudio, .visualStudio, .kiro:
            return .iconCode
        case .githubDesktop:
            return .iconCode
        case .iTerm2:
            return .iconAppleTerminal
        case .warp:
            return .iconAppleTerminal

        // Browsers
        case .safari:
            return .iconSafari
        case .chrome, .edge, .arc, .brave, .opera, .vivaldi:
            return .iconGlobe
        case .firefox:
            return .iconGlobe

        // Communication
        case .messages:
            return .iconMessages
        case .mail:
            return .iconMail
        case .slack:
            return .iconMessage
        case .discord:
            return .iconMessage
        case .telegram, .whatsapp:
            return .iconMessage
        case .zoom, .teams, .facetime, .skype:
            return .iconVideoCall

        // Productivity
        case .notes:
            return .iconNotes
        case .reminders:
            return .iconReminders
        case .calendar:
            return .iconCalendar
        case .contacts:
            return .iconContacts
        case .preview:
            return .iconPreview
        case .textEdit:
            return .iconTextEdit
        case .stickies:
            return .iconDocument
        case .calculator:
            return .iconCalculator
        case .dictionary:
            return .iconDocument
        case .systemSettings:
            return .iconSettings

        // Creative & Design
        case .sketch, .figma, .photoshop, .illustrator, .afterEffects, .premierePro, .affinityDesigner, .affinityPhoto, .pixelmatorPro:
            return .iconCreativity

        // Music & Video
        case .music:
            return .iconMusic
        case .tv:
            return .iconFilm
        case .podcasts:
            return .iconAudioDocument
        case .news:
            return .iconDocument
        case .books:
            return .iconDocument
        case .spotify:
            return .iconMusic
        case .vlc, .iina, .quicktimePlayer:
            return .iconVideoDocument

        // Utilities
        case .finder:
            return .iconFinder
        case .terminal, .iTerm2, .warp:
            return .iconTerminal
        case .activityMonitor:
            return .iconChart
        case .console:
            return .iconConsole
        case .diskUtility:
            return .iconFolder
        case .keychainAccess:
            return .iconPasswords
        case .systemInformation:
            return .iconInfo
        case .voiceMemos:
            return .iconAudioDocument

        // Cloud & Storage
        case .icloudDrive, .dropbox, .googleDrive, .onedrive, .box:
            return .iconCloud

        // Social
        case .twitter, .reddit, .linkedin, .wechat, .qq:
            return .iconMessage

        // Games
        case .steam, .epicGames, .battleNet:
            return .iconGame

        // Other
        case .appStore:
            return .iconAppStore
        case .photos:
            return .iconPhotos
        case .maps:
            return .iconMaps
        case .weather:
            return .iconWeather
        case .clock:
            return .iconClock
        case .home:
            return .iconHome
        case .wallet:
            return .iconWallet
        case .stocks:
            return .iconStocks
        case .shortcuts:
            return .iconShortcuts
        case .files:
            return .iconFolder

        // Third-party Apps
        case .notion, .obsidian, .bear:
            return .iconNotes
        case .things3, .todoist:
            return .iconReminder
        case .onepassword:
            return .iconPasswords
        case .raycast, .alfred:
            return .iconSearch
        case .bartender:
            return .iconSettings
        case .cleanMyMac:
            return .iconTrash
        case .magnet, .rectangle:
            return .iconSquare
        }
    }

    /// 获取应用显示名称
    public var displayName: String {
        switch self {
        // Developer Tools
        case .xcode:
            return "Xcode"
        case .vscode:
            return "Visual Studio Code"
        case .cursor:
            return "Cursor"
        case .trae:
            return "Trae"
        case .antigravity:
            return "Antigravity"
        case .githubDesktop:
            return "GitHub Desktop"
        case .kiro:
            return "Kiro"
        case .intelliJIDEA:
            return "IntelliJ IDEA"
        case .webStorm:
            return "WebStorm"
        case .pyCharm:
            return "PyCharm"
        case .androidStudio:
            return "Android Studio"
        case .visualStudio:
            return "Visual Studio"
        case .iTerm2:
            return "iTerm2"
        case .warp:
            return "Warp"

        // Browsers
        case .safari:
            return "Safari"
        case .chrome:
            return "Google Chrome"
        case .firefox:
            return "Firefox"
        case .edge:
            return "Microsoft Edge"
        case .arc:
            return "Arc"
        case .brave:
            return "Brave"
        case .opera:
            return "Opera"
        case .vivaldi:
            return "Vivaldi"

        // Communication
        case .messages:
            return "Messages"
        case .mail:
            return "Mail"
        case .slack:
            return "Slack"
        case .discord:
            return "Discord"
        case .telegram:
            return "Telegram"
        case .whatsapp:
            return "WhatsApp"
        case .zoom:
            return "Zoom"
        case .teams:
            return "Microsoft Teams"
        case .facetime:
            return "FaceTime"
        case .skype:
            return "Skype"

        // Productivity
        case .notes:
            return "Notes"
        case .reminders:
            return "Reminders"
        case .calendar:
            return "Calendar"
        case .contacts:
            return "Contacts"
        case .preview:
            return "Preview"
        case .textEdit:
            return "TextEdit"
        case .stickies:
            return "Stickies"
        case .calculator:
            return "Calculator"
        case .dictionary:
            return "Dictionary"
        case .systemSettings:
            return "System Settings"

        // Creative & Design
        case .sketch:
            return "Sketch"
        case .figma:
            return "Figma"
        case .photoshop:
            return "Adobe Photoshop"
        case .illustrator:
            return "Adobe Illustrator"
        case .afterEffects:
            return "Adobe After Effects"
        case .premierePro:
            return "Adobe Premiere Pro"
        case .affinityDesigner:
            return "Affinity Designer"
        case .affinityPhoto:
            return "Affinity Photo"
        case .pixelmatorPro:
            return "Pixelmator Pro"

        // Music & Video
        case .music:
            return "Music"
        case .tv:
            return "TV"
        case .podcasts:
            return "Podcasts"
        case .news:
            return "News"
        case .books:
            return "Books"
        case .spotify:
            return "Spotify"
        case .vlc:
            return "VLC"
        case .iina:
            return "IINA"
        case .quicktimePlayer:
            return "QuickTime Player"

        // Utilities
        case .finder:
            return "Finder"
        case .terminal:
            return "Terminal"
        case .activityMonitor:
            return "Activity Monitor"
        case .console:
            return "Console"
        case .diskUtility:
            return "Disk Utility"
        case .keychainAccess:
            return "Keychain Access"
        case .systemInformation:
            return "System Information"
        case .voiceMemos:
            return "Voice Memos"

        // Cloud & Storage
        case .icloudDrive:
            return "iCloud Drive"
        case .dropbox:
            return "Dropbox"
        case .googleDrive:
            return "Google Drive"
        case .onedrive:
            return "OneDrive"
        case .box:
            return "Box"

        // Social
        case .twitter:
            return "X (Twitter)"
        case .reddit:
            return "Reddit"
        case .linkedin:
            return "LinkedIn"
        case .wechat:
            return "WeChat"
        case .qq:
            return "QQ"

        // Games
        case .steam:
            return "Steam"
        case .epicGames:
            return "Epic Games"
        case .battleNet:
            return "Battle.net"

        // Other
        case .appStore:
            return "App Store"
        case .photos:
            return "Photos"
        case .maps:
            return "Maps"
        case .weather:
            return "Weather"
        case .clock:
            return "Clock"
        case .home:
            return "Home"
        case .wallet:
            return "Wallet"
        case .stocks:
            return "Stocks"
        case .shortcuts:
            return "Shortcuts"
        case .files:
            return "Files"

        // Third-party Apps
        case .notion:
            return "Notion"
        case .obsidian:
            return "Obsidian"
        case .bear:
            return "Bear"
        case .things3:
            return "Things 3"
        case .todoist:
            return "Todoist"
        case .onepassword:
            return "1Password"
        case .raycast:
            return "Raycast"
        case .alfred:
            return "Alfred"
        case .bartender:
            return "Bartender"
        case .cleanMyMac:
            return "CleanMyMac"
        case .magnet:
            return "Magnet"
        case .rectangle:
            return "Rectangle"
        }
    }

    #if os(macOS)
    /// 检查应用是否已安装
    public var isInstalled: Bool {
        guard let bundleId = bundleId else { return false }
        return NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) != nil
    }

    /// 获取应用的真实图标（如果已安装）
    /// - Parameter useRealIcon: 是否使用真实应用图标，默认为 true
    /// - Returns: NSImage 或 String（SF Symbol 名称）
    public func icon(useRealIcon: Bool = true) -> Any {
        if useRealIcon, isInstalled, let bundleId = bundleId {
            if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
                return NSWorkspace.shared.icon(forFile: appURL.path)
            }
        }
        // 返回系统图标（SF Symbol 名称）
        return systemIcon
    }

    /// 获取 SwiftUI Image 类型的图标
    /// - Parameter useRealIcon: 是否使用真实应用图标
    /// - Returns: SwiftUI Image
    public func iconImage(useRealIcon: Bool = false) -> Image {
        let iconValue = icon(useRealIcon: useRealIcon)

        if let nsImage = iconValue as? NSImage {
            return Image(nsImage: nsImage)
        } else if let iconName = iconValue as? String {
            return Image(systemName: iconName)
        }

        return Image(systemName: .iconApp)
    }

    #else
    /// iOS 获取 Image 类型的图标
    /// - Parameter useRealIcon: iOS 上暂不支持真实图标，此参数被忽略
    /// - Returns: SwiftUI Image
    public func iconImage(useRealIcon: Bool = false) -> Image {
        return Image(systemName: systemIcon)
    }
    #endif
}

// MARK: - Icon Constants (if not already defined in String extension)

private extension String {
    // Game icon (if not defined elsewhere)
    static let iconGame = "gamecontroller"
    static let iconApp = "app"
}

#if DEBUG
// MARK: - Preview

#Preview("App Registry") {
    AppRegistryPreviewView()
        .frame(height: 600)
}
#endif
