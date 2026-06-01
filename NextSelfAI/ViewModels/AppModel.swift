import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    var selectedTab: AppTab = .dashboard
    var isOnboarded = false
    var profile = UserProfile()
    var futureSelf = FutureSelfProfile()
    var missions: [Mission] = []
    var journalEntries: [JournalEntry] = []
    var transcripts: [VoiceTranscript] = []
    var checkIns: [DailyCheckIn] = []
    var milestones: [TransformationMilestone] = []
    var scores: [NextSelfScore] = []
    var subscriptionState = SubscriptionState()
    var futureMessage = ""
    var coachingInsight = ""
    var chat: [ChatMessage] = [
        ChatMessage(role: "future", content: "Meet the person you're becoming. What do we need to move today?")
    ]
    var isLoading = false
    var errorMessage: String?

    let ai = MockAIService.shared
    let subscriptionManager = SubscriptionManager()
    let notificationService = NotificationService()

    var nextSelfScore: Int {
        scores.last?.score ?? 42
    }

    var completedMissionCount: Int {
        missions.filter(\.completed).count
    }

    var streak: Int {
        max(1, completedMissionCount)
    }

    var transformationProgress: Double {
        guard missions.isEmpty == false else { return 0.28 }
        return Double(completedMissionCount) / Double(missions.count)
    }

    func bootstrap() async {
        isLoading = true
        defer { isLoading = false }
        futureSelf = await ai.persona(for: profile)
        futureMessage = await ai.message(for: profile)
        coachingInsight = await ai.insight(checkIn: checkIns.last)
        missions = await ai.missions(for: profile)
        scores = [
            NextSelfScore(score: 42, createdAt: Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now),
            NextSelfScore(score: 47, createdAt: Calendar.current.date(byAdding: .day, value: -5, to: .now) ?? .now),
            NextSelfScore(score: 51, createdAt: Calendar.current.date(byAdding: .day, value: -4, to: .now) ?? .now),
            NextSelfScore(score: 58, createdAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now),
            NextSelfScore(score: 61, createdAt: Calendar.current.date(byAdding: .day, value: -2, to: .now) ?? .now),
            NextSelfScore(score: 67, createdAt: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now),
            NextSelfScore(score: 72)
        ]
        milestones = [
            TransformationMilestone(title: "Identity Declared", description: "You named the future self you are becoming."),
            TransformationMilestone(title: "First Mission", description: "The transformation began with one completed promise.")
        ]
        await subscriptionManager.loadProducts()
    }

    func completeOnboarding(current: String, future: String, priorities: Set<Priority>, style: CoachingStyle, minutes: Int) async {
        profile = UserProfile(currentIdentity: current, futureIdentity: future, coachingStyle: style, priorities: Array(priorities), minutesPerDay: minutes)
        futureSelf = await ai.persona(for: profile)
        futureMessage = await ai.message(for: profile)
        missions = await ai.missions(for: profile)
        isOnboarded = true
    }

    func complete(_ mission: Mission) {
        mission.completed.toggle()
        let gained = mission.completed ? mission.xp / 2 : -mission.xp / 2
        scores.append(NextSelfScore(score: min(100, max(0, nextSelfScore + gained))))
        if mission.completed {
            milestones.append(TransformationMilestone(title: "Mission Complete", description: mission.title))
        }
    }

    func sendFutureSelfMessage(_ text: String) async {
        guard text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else { return }
        chat.append(ChatMessage(role: "user", content: text))
        let response = await ai.reply(to: text, profile: profile)
        chat.append(ChatMessage(role: "future", content: response))
    }

    func saveJournal(_ text: String) async {
        let summary = await ai.summarize(transcript: text)
        journalEntries.append(JournalEntry(content: text, aiSummary: summary))
        transcripts.append(VoiceTranscript(transcript: text, reflection: summary))
    }

    func submitCheckIn(_ checkIn: DailyCheckIn) async {
        checkIn.insight = await ai.insight(checkIn: checkIn)
        checkIns.append(checkIn)
        coachingInsight = checkIn.insight
    }

    func trendPoints() -> [TrendPoint] {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return scores.map { TrendPoint(day: formatter.string(from: $0.createdAt), value: $0.score) }
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard, futureSelf, journal, analytics, settings
    var id: String { rawValue }
    var title: String {
        switch self {
        case .dashboard: "Today"
        case .futureSelf: "Future"
        case .journal: "Voice"
        case .analytics: "Growth"
        case .settings: "Settings"
        }
    }
    var symbol: String {
        switch self {
        case .dashboard: "sparkles"
        case .futureSelf: "person.crop.circle.badge.sparkles"
        case .journal: "waveform"
        case .analytics: "chart.xyaxis.line"
        case .settings: "gearshape"
        }
    }
}
