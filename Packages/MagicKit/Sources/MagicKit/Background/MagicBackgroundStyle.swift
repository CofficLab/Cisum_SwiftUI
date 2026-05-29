import SwiftUI

/// Defines all available MagicBackground styles for type-safe selection
public enum MagicBackgroundStyle {
    case frost, gradient, aurora, ocean, sunset, forest, lavender, desert, midnight
    case cherry, mint, twilight, rose, emerald, amethyst, coral, slate, sage
    case dusk, serenity, sunnyBeach, tropicalSunset, palmBeach, candyLand
    case crayonBox, toyBlocks, balloonParty, paperPlanes
    case colorRed, colorBlue, colorGreen, colorYellow, colorPurple, colorOrange
    case colorPink, colorBrown, colorGray, colorTeal
    case cosmicDust, galaxySpiral, nebulaMist, darkMatter, cosmicPortal
    case mysticalForest, enchantedGrove, deepForest
    case watermelon, blueberry, strawberry, kiwi
    case vanillaMacaron, roseMacaron, lavenderMacaron, mintMacaron, lemonMacaron
    case jazzNight, classicalHarmony, rockStage, electronicBeats, acousticMorning
    case deepOceanCurrent, tropicalWaters, coralReef, mountainStream, calmRiver, cascadingRiver
    case dawnSky, stormyHeaven, sunsetGlow, snowPeak, glacierIce, frostMountain

    @ViewBuilder
    var view: some View {
        switch self {
        case .frost: MagicBackground.frost
        case .gradient: MagicBackground.gradient
        case .aurora: MagicBackground.aurora
        case .ocean: MagicBackground.ocean
        case .sunset: MagicBackground.sunset
        case .forest: MagicBackground.forest
        case .lavender: MagicBackground.lavender
        case .desert: MagicBackground.desert
        case .midnight: MagicBackground.midnight
        case .cherry: MagicBackground.cherry
        case .mint: MagicBackground.mint
        case .twilight: MagicBackground.twilight
        case .rose: MagicBackground.rose
        case .emerald: MagicBackground.emerald
        case .amethyst: MagicBackground.amethyst
        case .coral: MagicBackground.coral
        case .slate: MagicBackground.slate
        case .sage: MagicBackground.sage
        case .dusk: MagicBackground.dusk
        case .serenity: MagicBackground.serenity
        case .sunnyBeach: MagicBackground.sunnyBeach
        case .tropicalSunset: MagicBackground.tropicalSunset
        case .palmBeach: MagicBackground.palmBeach
        case .candyLand: MagicBackground.candyLand
        case .crayonBox: MagicBackground.crayonBox
        case .toyBlocks: MagicBackground.toyBlocks
        case .balloonParty: MagicBackground.balloonParty
        case .paperPlanes: MagicBackground.paperPlanes
        case .colorRed: MagicBackground.colorRed
        case .colorBlue: MagicBackground.colorBlue
        case .colorGreen: MagicBackground.colorGreen
        case .colorYellow: MagicBackground.colorYellow
        case .colorPurple: MagicBackground.colorPurple
        case .colorOrange: MagicBackground.colorOrange
        case .colorPink: MagicBackground.colorPink
        case .colorBrown: MagicBackground.colorBrown
        case .colorGray: MagicBackground.colorGray
        case .colorTeal: MagicBackground.colorTeal
        case .cosmicDust: MagicBackground.cosmicDust
        case .galaxySpiral: MagicBackground.galaxySpiral
        case .nebulaMist: MagicBackground.nebulaMist
        case .darkMatter: MagicBackground.darkMatter
        case .cosmicPortal: MagicBackground.cosmicPortal
        case .mysticalForest: MagicBackground.mysticalForest
        case .enchantedGrove: MagicBackground.enchantedGrove
        case .deepForest: MagicBackground.deepForest
        case .watermelon: MagicBackground.watermelon
        case .blueberry: MagicBackground.blueberry
        case .strawberry: MagicBackground.strawberry
        case .kiwi: MagicBackground.kiwi
        case .vanillaMacaron: MagicBackground.vanillaMacaron
        case .roseMacaron: MagicBackground.roseMacaron
        case .lavenderMacaron: MagicBackground.lavenderMacaron
        case .mintMacaron: MagicBackground.mintMacaron
        case .lemonMacaron: MagicBackground.lemonMacaron
        case .jazzNight: MagicBackground.jazzNight
        case .classicalHarmony: MagicBackground.classicalHarmony
        case .rockStage: MagicBackground.rockStage
        case .electronicBeats: MagicBackground.electronicBeats
        case .acousticMorning: MagicBackground.acousticMorning
        case .deepOceanCurrent: MagicBackground.deepOceanCurrent
        case .tropicalWaters: MagicBackground.tropicalWaters
        case .coralReef: MagicBackground.coralReef
        case .mountainStream: MagicBackground.mountainStream
        case .calmRiver: MagicBackground.calmRiver
        case .cascadingRiver: MagicBackground.cascadingRiver
        case .dawnSky: MagicBackground.dawnSky
        case .stormyHeaven: MagicBackground.stormyHeaven
        case .sunsetGlow: MagicBackground.sunsetGlow
        case .snowPeak: MagicBackground.snowPeak
        case .glacierIce: MagicBackground.glacierIce
        case .frostMountain: MagicBackground.frostMountain
        }
    }
}
