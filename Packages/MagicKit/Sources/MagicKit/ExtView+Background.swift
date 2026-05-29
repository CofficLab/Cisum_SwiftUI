import SwiftUI

// MARK: - Magic Background Extensions

public extension View {
    /// Apply a MagicBackground style using the enum selector
    /// - Parameter style: The MagicBackgroundStyle to apply
    /// - Parameter opacity: Optional opacity value (default 1.0)
    /// - Returns: A view with the specified background applied
    ///
    /// Usage:
    /// ```swift
    /// Text("Hello").magicBackground(.ocean)
    /// Text("World").magicBackground(.frost, opacity: 0.7)
    /// ```
    func magicBackground(_ style: MagicBackgroundStyle, opacity: Double = 1.0) -> some View {
        self.background(style.view.opacity(opacity))
    }

    func inBackgroundFrost(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.frost.opacity(opacity))
    }

    func inBackgroundGradient(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.gradient.opacity(opacity))
    }

    func inBackgroundAurora(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.aurora.opacity(opacity))
    }

    func inBackgroundOcean(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.ocean.opacity(opacity))
    }

    func inBackgroundSunset(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.sunset.opacity(opacity))
    }

    func inBackgroundForest(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.forest.opacity(opacity))
    }

    func inBackgroundLavender(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.lavender.opacity(opacity))
    }

    func inBackgroundDesert(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.desert.opacity(opacity))
    }

    func inBackgroundMidnight(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.midnight.opacity(opacity))
    }

    func inBackgroundCherry(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.cherry.opacity(opacity))
    }

    func inBackgroundMint(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.mint.opacity(opacity))
    }

    func inBackgroundTwilight(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.twilight.opacity(opacity))
    }

    func inBackgroundRose(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.rose.opacity(opacity))
    }

    func inBackgroundEmerald(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.emerald.opacity(opacity))
    }

    func inBackgroundAmethyst(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.amethyst.opacity(opacity))
    }

    func inBackgroundCoral(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.coral.opacity(opacity))
    }

    func inBackgroundSlate(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.slate.opacity(opacity))
    }

    func inBackgroundSage(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.sage.opacity(opacity))
    }

    func inBackgroundDusk(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.dusk.opacity(opacity))
    }

    func inBackgroundSerenity(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.serenity.opacity(opacity))
    }

    func inBackgroundSunnyBeach(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.sunnyBeach.opacity(opacity))
    }

    func inBackgroundTropicalSunset(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.tropicalSunset.opacity(opacity))
    }

    func inBackgroundPalmBeach(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.palmBeach.opacity(opacity))
    }

    func inBackgroundCandyLand(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.candyLand.opacity(opacity))
    }

    func inBackgroundCrayonBox(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.crayonBox.opacity(opacity))
    }

    func inBackgroundToyBlocks(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.toyBlocks.opacity(opacity))
    }

    func inBackgroundBalloonParty(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.balloonParty.opacity(opacity))
    }

    func inBackgroundPaperPlanes(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.paperPlanes.opacity(opacity))
    }

    func inBackgroundColorRed(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.colorRed.opacity(opacity))
    }

    func inBackgroundColorBlue(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.colorBlue.opacity(opacity))
    }

    func inBackgroundColorGreen(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.colorGreen.opacity(opacity))
    }

    func inBackgroundColorYellow(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.colorYellow.opacity(opacity))
    }

    func inBackgroundColorPurple(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.colorPurple.opacity(opacity))
    }

    func inBackgroundColorOrange(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.colorOrange.opacity(opacity))
    }

    func inBackgroundColorPink(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.colorPink.opacity(opacity))
    }

    func inBackgroundColorBrown(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.colorBrown.opacity(opacity))
    }

    func inBackgroundColorGray(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.colorGray.opacity(opacity))
    }

    func inBackgroundColorTeal(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.colorTeal.opacity(opacity))
    }

    func inBackgroundCosmicDust(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.cosmicDust.opacity(opacity))
    }

    func inBackgroundGalaxySpiral(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.galaxySpiral.opacity(opacity))
    }

    func inBackgroundNebulaMist(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.nebulaMist.opacity(opacity))
    }

    func inBackgroundDarkMatter(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.darkMatter.opacity(opacity))
    }

    func inBackgroundCosmicPortal(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.cosmicPortal.opacity(opacity))
    }

    func inBackgroundMysticalForest(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.mysticalForest.opacity(opacity))
    }

    func inBackgroundEnchantedGrove(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.enchantedGrove.opacity(opacity))
    }

    func inBackgroundDeepForest(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.deepForest.opacity(opacity))
    }

    func inBackgroundWatermelon(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.watermelon.opacity(opacity))
    }

    func inBackgroundOrange(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.orange.opacity(opacity))
    }

    func inBackgroundBlueberry(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.blueberry.opacity(opacity))
    }

    func inBackgroundStrawberry(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.strawberry.opacity(opacity))
    }

    func inBackgroundKiwi(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.kiwi.opacity(opacity))
    }

    func inBackgroundVanillaMacaron(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.vanillaMacaron.opacity(opacity))
    }

    func inBackgroundRoseMacaron(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.roseMacaron.opacity(opacity))
    }

    func inBackgroundLavenderMacaron(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.lavenderMacaron.opacity(opacity))
    }

    func inBackgroundMintMacaron(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.mintMacaron.opacity(opacity))
    }

    func inBackgroundLemonMacaron(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.lemonMacaron.opacity(opacity))
    }

    func inBackgroundJazzNight(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.jazzNight.opacity(opacity))
    }

    func inBackgroundClassicalHarmony(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.classicalHarmony.opacity(opacity))
    }

    func inBackgroundRockStage(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.rockStage.opacity(opacity))
    }

    func inBackgroundElectronicBeats(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.electronicBeats.opacity(opacity))
    }

    func inBackgroundAcousticMorning(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.acousticMorning.opacity(opacity))
    }

    func inBackgroundDeepOceanCurrent(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.deepOceanCurrent.opacity(opacity))
    }

    func inBackgroundTropicalWaters(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.tropicalWaters.opacity(opacity))
    }

    func inBackgroundCoralReef(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.coralReef.opacity(opacity))
    }

    func inBackgroundMountainStream(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.mountainStream.opacity(opacity))
    }

    func inBackgroundCalmRiver(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.calmRiver.opacity(opacity))
    }

    func inBackgroundCascadingRiver(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.cascadingRiver.opacity(opacity))
    }

    func inBackgroundDawnSky(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.dawnSky.opacity(opacity))
    }

    func inBackgroundStormyHeaven(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.stormyHeaven.opacity(opacity))
    }

    func inBackgroundSunsetGlow(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.sunsetGlow.opacity(opacity))
    }

    func inBackgroundSnowPeak(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.snowPeak.opacity(opacity))
    }

    func inBackgroundGlacierIce(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.glacierIce.opacity(opacity))
    }

    func inBackgroundFrostMountain(_ opacity: Double = 1.0) -> some View {
        self.background(MagicBackground.frostMountain.opacity(opacity))
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("All Magic Backgrounds") {
        BackgroundPreviews()
            .frame(height: 750)
            .frame(width: 550)
    }

#endif
