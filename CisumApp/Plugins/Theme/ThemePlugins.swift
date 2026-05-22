import CisumUI
import Foundation

actor ThemeCisumPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 118 }

    let title = "Cisum"
    let description = "Cisum 默认主题"
    let iconName = "circle.hexagonpath.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: CisumChromeTheme.cisum, editorThemeId: "cisum")]
    }
}

actor ThemeMidnightPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 119 }

    let title = "午夜幽蓝"
    let description = "夜间听歌主题"
    let iconName = "moon.stars.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: CisumChromeTheme.midnight, editorThemeId: "midnight")]
    }
}

actor ThemeAuroraPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 120 }

    let title = "极光紫"
    let description = "沉浸式播放主题"
    let iconName = "sparkles"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: CisumChromeTheme.aurora, editorThemeId: "aurora")]
    }
}

actor ThemeNebulaPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 121 }

    let title = "星云粉"
    let description = "柔和暖色主题"
    let iconName = "cloud.moon.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: CisumChromeTheme.nebula, editorThemeId: "nebula")]
    }
}

actor ThemeForestPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 122 }

    let title = "森林绿"
    let description = "长时间听书主题"
    let iconName = "leaf.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: CisumChromeTheme.forest, editorThemeId: "forest")]
    }
}

actor ThemeOceanPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 123 }

    let title = "海洋蓝"
    let description = "清爽蓝青主题"
    let iconName = "water.waves"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: CisumChromeTheme.ocean, editorThemeId: "ocean")]
    }
}

actor ThemeSunsetPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 124 }

    let title = "日落橙"
    let description = "暖色点缀主题"
    let iconName = "sunset.fill"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: CisumChromeTheme.sunset, editorThemeId: "sunset")]
    }
}

actor ThemeMonoPlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 125 }

    let title = "黑白高对比"
    let description = "可读性优先主题"
    let iconName = "circle.lefthalf.filled"

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: CisumChromeTheme.mono, editorThemeId: "mono")]
    }
}
