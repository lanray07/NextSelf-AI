import SwiftUI

struct DashboardView: View {
    @Environment(AppModel.self) private var appModel
    @State private var showChat = false
    @State private var showCheckIn = false
    @State private var showTimeline = false
    @State private var showMissions = false
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    SectionTitle(title: "Today", subtitle: "Your future self is waiting.")
                    Spacer()
                    Button {
                        showPaywall = true
                    } label: {
                        Image(systemName: appModel.subscriptionManager.isActive ? "crown.fill" : "crown")
                    }
                    .buttonStyle(.bordered)
                }

                PremiumCard {
                    HStack(spacing: 22) {
                        NextSelfScoreRing(score: appModel.nextSelfScore)
                        VStack(alignment: .leading, spacing: 12) {
                            StatRow(title: "Progress", value: "\(Int(appModel.transformationProgress * 100))%")
                            StatRow(title: "Current Streak", value: "\(appModel.streak) days")
                            StatRow(title: "Plan", value: appModel.subscriptionManager.selectedPlan.title)
                        }
                    }
                }

                FutureSelfCard(profile: appModel.futureSelf, message: appModel.futureMessage)

                PremiumCard {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(title: "Daily Missions", subtitle: "Small actions. Identity evidence.")
                        ForEach(appModel.missions.prefix(3)) { mission in
                            MissionCard(mission: mission) {
                                appModel.complete(mission)
                            }
                            Divider().background(.white.opacity(0.12))
                        }
                        Button("View All Missions") { showMissions = true }
                    }
                }

                PremiumCard {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionTitle(title: "AI Coaching Insight", subtitle: nil)
                        Text(appModel.coachingInsight)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    QuickAction(title: "Talk", symbol: "message.fill") { showChat = true }
                    QuickAction(title: "Voice", symbol: "waveform") { appModel.selectedTab = .journal }
                    QuickAction(title: "Check-In", symbol: "slider.horizontal.3") { showCheckIn = true }
                    QuickAction(title: "Timeline", symbol: "point.3.connected.trianglepath.dotted") { showTimeline = true }
                }

                UpgradeBanner { showPaywall = true }
            }
            .padding(18)
        }
        .navigationTitle("NextSelf")
        .sheet(isPresented: $showChat) { FutureSelfChatView() }
        .sheet(isPresented: $showCheckIn) { DailyCheckInView() }
        .sheet(isPresented: $showTimeline) { TimelineScreen() }
        .sheet(isPresented: $showMissions) { MissionsView() }
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }
}

struct StatRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.62))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct QuickAction: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.title2)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.12), in: Circle())
                Text(title)
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 110)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct MissionsView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()
                List {
                    ForEach(appModel.missions) { mission in
                        MissionCard(mission: mission) {
                            appModel.complete(mission)
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Daily Missions")
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}
