import SwiftUI

#if DEBUG
    /// Preview of all MagicBackground styles
    struct BackgroundPreviews: View {
        var body: some View {
            VStack(spacing: 40) {
                // Basic Backgrounds Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Basic Backgrounds")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    VStack(spacing: 15) {
                        Text("Frost")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundFrost()

                        Text("Gradient")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundGradient()

                        Text("Aurora")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundAurora()
                    }
                }

                // Nature Backgrounds Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Nature Backgrounds")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    VStack(spacing: 15) {
                        Text("Ocean")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundOcean()

                        Text("Forest")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundForest()

                        Text("Sunset")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundSunset()

                        Text("Mountain")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundSnowPeak()
                    }
                }

                // Color Backgrounds Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Color Backgrounds")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    VStack(spacing: 15) {
                        Text("Lavender")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundLavender()

                        Text("Rose")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundRose()

                        Text("Mint")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundMint()

                        Text("Coral")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundCoral()
                    }
                }

                // Cosmic Backgrounds Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Cosmic Backgrounds")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    VStack(spacing: 15) {
                        Text("Cosmic Dust")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundCosmicDust()

                        Text("Galaxy Spiral")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundGalaxySpiral()

                        Text("Nebula")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundNebulaMist()
                    }
                }

                // Food Backgrounds Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Food Backgrounds")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    VStack(spacing: 15) {
                        Text("Watermelon")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundWatermelon()

                        Text("Strawberry")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundStrawberry()

                        Text("Orange")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundOrange()

                        Text("Blueberry")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundBlueberry()
                    }
                }

                // Beach Backgrounds Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Beach Backgrounds")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    VStack(spacing: 15) {
                        Text("Sunny Beach")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundSunnyBeach()

                        Text("Tropical Sunset")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundTropicalSunset()

                        Text("Palm Beach")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundPalmBeach()
                    }
                }

                // Childhood Backgrounds Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Childhood Backgrounds")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    VStack(spacing: 15) {
                        Text("Candy Land")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundCandyLand()

                        Text("Balloon Party")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundBalloonParty()

                        Text("Toy Blocks")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundToyBlocks()
                    }
                }

                // Music Backgrounds Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Music Backgrounds")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    VStack(spacing: 15) {
                        Text("Jazz Night")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundJazzNight()

                        Text("Classical Harmony")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundClassicalHarmony()

                        Text("Rock Stage")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .inBackgroundRockStage()
                    }
                }
            }
            .p4()
            .inScrollView()
            .frame(height: 750)
            .frame(width: 550)
        }
    }

    #if DEBUG
    #Preview("All Magic Backgrounds") {
        BackgroundPreviews()
            .frame(height: 750)
            .frame(width: 550)
    }
    #endif

#endif
