import Charts
import SwiftUI

struct PremiumBackground: View {
    var body: some View {
        LinearGradient(colors: [.black, Color(red: 0.03, green: 0.04, blue: 0.09), Color(red: 0.08, green: 0.02, blue: 0.14)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .overlay {
                RadialGradient(colors: [Color.blue.opacity(0.28), .clear], center: .topTrailing, startRadius: 40, endRadius: 420)
                    .ignoresSafeArea()
            }
    }
}

struct PremiumCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(LinearGradient(colors: [.white.opacity(0.28), .blue.opacity(0.38), .purple.opacity(0.24)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
            .shadow(color: .blue.opacity(0.18), radius: 28, x: 0, y: 16)
    }
}

struct SectionTitle: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.white)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.68))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FutureSelfCard: View {
    let profile: FutureSelfProfile
    let message: String

    var body: some View {
        PremiumCard {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AngularGradient(colors: [.blue, .purple, .yellow, .blue], center: .center))
                    Image(systemName: "person.crop.circle.badge.sparkles")
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                }
                .frame(width: 88, height: 88)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Future Self")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.yellow)
                    Text(profile.identityDescription)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.72))
                    Text("Level \(profile.level) • \(profile.avatarType)")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}

struct NextSelfScoreRing: View {
    let score: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.10), lineWidth: 16)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(LinearGradient(colors: [.blue, .purple, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("NextSelf Score")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
        .frame(width: 170, height: 170)
        .accessibilityLabel("NextSelf Score \(score)")
    }
}

struct MissionCard: View {
    let mission: Mission
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: mission.completed ? "checkmark.seal.fill" : "target")
                    .font(.title2)
                    .foregroundStyle(mission.completed ? .green : .blue)
                    .frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 5) {
                    Text(mission.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("\(mission.category.capitalized) • \(mission.difficulty) • \(mission.xp) XP")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.62))
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct VoiceWaveformView: View {
    let samples: [Double]
    let isActive: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(Array(samples.enumerated()), id: \.offset) { _, sample in
                Capsule()
                    .fill(LinearGradient(colors: [.blue, .purple, .yellow.opacity(0.9)], startPoint: .bottom, endPoint: .top))
                    .frame(width: 5, height: max(10, sample * (isActive ? 110 : 70)))
                    .animation(.spring(response: 0.35, dampingFraction: 0.72), value: sample)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 130)
    }
}

struct TransformationTimelineView: View {
    let milestones: [TransformationMilestone]

    var body: some View {
        VStack(spacing: 14) {
            ForEach(milestones) { milestone in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(.blue)
                        .frame(width: 12, height: 12)
                        .padding(.top, 5)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(milestone.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(milestone.milestoneDescription)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.68))
                    }
                    Spacer()
                }
            }
        }
    }
}

struct AnalyticsChartCard: View {
    let points: [TrendPoint]

    var body: some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "Growth Velocity", subtitle: "NextSelf Score trend")
                Chart(points) { point in
                    LineMark(x: .value("Day", point.day), y: .value("Score", point.value))
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)
                    AreaMark(x: .value("Day", point.day), y: .value("Score", point.value))
                        .foregroundStyle(.blue.opacity(0.18))
                        .interpolationMethod(.catmullRom)
                }
                .chartYScale(domain: 0...100)
                .frame(height: 220)
            }
        }
    }
}

struct UpgradeBanner: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Unlock Elite transformation")
                        .font(.headline)
                    Text("Unlimited AI coaching, voice journaling, reports, avatars, and themes.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.white)
            .padding()
            .background(LinearGradient(colors: [.purple.opacity(0.72), .blue.opacity(0.6)], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
