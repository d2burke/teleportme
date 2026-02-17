import SwiftUI

// MARK: - Trip Vibes View

/// A 3×3 grid of signal tiles where users tap to cycle intensity (off → low → medium → high → off).
/// Pre-loaded from the user's persistent heading, adjustable for each specific trip.
struct TripVibesView: View {
    @Binding var signalWeights: [CompassSignal: Double]
    let onContinue: () -> Void
    var onBack: (() -> Void)?

    @State private var previousHeadingName = ""
    @State private var headingShifting = false
    @State private var appearedSignals: Set<CompassSignal> = []

    private var heading: Heading {
        HeadingEngine.heading(from: signalWeights)
    }

    private var activeCount: Int {
        signalWeights.filter { $0.value > 0 }.count
    }

    private var canContinue: Bool {
        activeCount >= 2
    }

    var body: some View {
        ZStack {
            TeleportTheme.Colors.background
                .ignoresSafeArea()

            // Ambient glow
            if canContinue {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [heading.topSignals.first?.color.opacity(0.08) ?? .clear, .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(y: -100)
                    .blur(radius: 60)
                    .animation(.easeInOut(duration: 1), value: heading.name)
            }

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    if let onBack {
                        Button(action: onBack) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)
                        }
                        .padding(.bottom, 12)
                    }

                    Text("Trip Vibes")
                        .font(TeleportTheme.Typography.title(24))
                        .foregroundStyle(.white)

                    Text("Tap signals to set intensity. Your heading updates live.")
                        .font(.system(size: 13))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, TeleportTheme.Spacing.lg)
                .padding(.top, TeleportTheme.Spacing.md)

                Spacer().frame(height: TeleportTheme.Spacing.lg)

                // Signal Grid — 3×3 (8 signals + 1 decorative/empty slot)
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                    spacing: 10
                ) {
                    ForEach(Array(CompassSignal.allCases.enumerated()), id: \.element) { index, signal in
                        SignalTile(
                            signal: signal,
                            level: signalWeights[signal] ?? 0,
                            onTap: { cycleSignal(signal) }
                        )
                        .opacity(appearedSignals.contains(signal) ? 1 : 0)
                        .offset(y: appearedSignals.contains(signal) ? 0 : 16)
                        .onAppear {
                            withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.04)) {
                                _ = appearedSignals.insert(signal)
                            }
                        }
                    }
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)

                Spacer().frame(height: TeleportTheme.Spacing.md)

                // Heading shifting indicator
                if headingShifting {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(heading.topSignals.first?.color ?? .white)
                            .frame(width: 6, height: 6)
                            .shadow(color: heading.topSignals.first?.color.opacity(0.4) ?? .clear, radius: 4)

                        Text("Heading shifting...")
                            .font(.system(size: 11))
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(heading.topSignals.first?.color.opacity(0.06) ?? .clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(heading.topSignals.first?.color.opacity(0.12) ?? .clear, lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                // Live heading preview
                if canContinue {
                    HeadingBadge(
                        heading: heading,
                        subtitle: previousHeadingName.isEmpty ? "Based on your vibes" : "Updated for this trip"
                    )
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                    .padding(.top, headingShifting ? 8 : TeleportTheme.Spacing.md)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .id(heading.name) // force re-render on heading change
                }

                Spacer()

                // CTA Button
                Button(action: onContinue) {
                    Text("Now the real stuff →")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Group {
                                if canContinue {
                                    LinearGradient(
                                        colors: [
                                            heading.topSignals.first?.color ?? TeleportTheme.Colors.accent,
                                            (heading.topSignals.first?.color ?? TeleportTheme.Colors.accent).opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                } else {
                                    Color.white.opacity(0.06)
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.large))
                        .shadow(
                            color: canContinue ? (heading.topSignals.first?.color.opacity(0.25) ?? .clear) : .clear,
                            radius: 12,
                            y: 6
                        )
                }
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.3)
                .padding(.horizontal, TeleportTheme.Spacing.xl)
                .padding(.bottom, TeleportTheme.Spacing.xxl)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: canContinue)
        .animation(.easeInOut(duration: 0.3), value: headingShifting)
        .onChange(of: heading.name) { oldValue, newValue in
            if !oldValue.isEmpty && oldValue != newValue {
                withAnimation {
                    headingShifting = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        headingShifting = false
                    }
                }
            }
            previousHeadingName = newValue
        }
    }

    private func cycleSignal(_ signal: CompassSignal) {
        let current = signalWeights[signal] ?? 0
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            if current >= 3 {
                signalWeights[signal] = 0
            } else {
                signalWeights[signal] = current + 1
            }
        }
    }
}

// MARK: - Signal Tile

/// A single signal tile in the 3×3 grid. Shows emoji, label, and 3 intensity dots.
struct SignalTile: View {
    let signal: CompassSignal
    let level: Double
    let onTap: () -> Void

    private var isActive: Bool { level > 0 }
    private var isStrong: Bool { level >= 3 }
    private var intLevel: Int { Int(level) }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 6) {
                        Text(signal.emoji)
                            .font(.system(size: 24))

                        Text(signal.shortLabel)
                            .font(.system(size: 11, weight: isActive ? .bold : .medium))
                            .foregroundStyle(isActive ? signal.color : TeleportTheme.Colors.textTertiary)

                        // Intensity dots
                        HStack(spacing: 3) {
                            ForEach(0..<3, id: \.self) { dot in
                                Circle()
                                    .fill(intLevel > dot ? signal.color : Color.white.opacity(0.08))
                                    .frame(width: 5, height: 5)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Strong indicator dot
                    if isStrong {
                        Circle()
                            .fill(signal.color)
                            .frame(width: 6, height: 6)
                            .offset(x: -4, y: 4)
                    }
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium + 4)
                    .fill(isActive ? signal.color.opacity(0.05) : Color.white.opacity(0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium + 4)
                            .stroke(
                                isActive ? signal.color.opacity(0.25) : Color.white.opacity(0.04),
                                lineWidth: 1.5
                            )
                    )
            )
            .opacity(isActive ? 1 : 0.7)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: level)
    }
}

// MARK: - Heading Badge

/// Shows the computed heading personality with emoji, name, and top signal pills.
struct HeadingBadge: View {
    let heading: Heading
    var subtitle: String = "Your heading"

    var body: some View {
        HStack(spacing: 12) {
            Text(heading.emoji)
                .font(.system(size: 26))

            VStack(alignment: .leading, spacing: 2) {
                Text(heading.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(hex: heading.color))

                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(TeleportTheme.Colors.textTertiary)
            }

            Spacer()

            // Top signal pills
            HStack(spacing: 4) {
                ForEach(heading.topSignals, id: \.self) { signal in
                    Text(signal.emoji)
                        .font(.system(size: 13))
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 9)
                                .fill(signal.color.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 9)
                                        .stroke(signal.color.opacity(0.15), lineWidth: 1)
                                )
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: TeleportTheme.Radius.card)
                .fill(Color.white.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: TeleportTheme.Radius.card)
                        .stroke(Color.white.opacity(0.04), lineWidth: 1)
                )
        )
    }
}

#Preview {
    TripVibesView(
        signalWeights: .constant([
            .climate: 3,
            .food: 2,
            .nightlife: 2,
        ]),
        onContinue: {},
        onBack: {}
    )
}
