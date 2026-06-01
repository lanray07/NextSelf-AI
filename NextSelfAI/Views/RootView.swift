import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        ZStack {
            PremiumBackground()
            if appModel.isOnboarded {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MainTabView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        TabView(selection: Binding(get: { appModel.selectedTab }, set: { appModel.selectedTab = $0 })) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    destination(for: tab)
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.symbol)
                }
                .tag(tab)
            }
        }
        .tint(.blue)
    }

    @ViewBuilder
    private func destination(for tab: AppTab) -> some View {
        switch tab {
        case .dashboard: DashboardView()
        case .futureSelf: FutureSelfEngineView()
        case .journal: VoiceJournalView()
        case .analytics: AnalyticsDashboardView()
        case .settings: SettingsView()
        }
    }
}
