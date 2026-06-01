import Foundation

protocol FutureSelfService {
    func persona(for profile: UserProfile?) async -> FutureSelfProfile
    func message(for profile: UserProfile?) async -> String
    func milestoneReflection(day: Int, profile: UserProfile?) async -> String
}

protocol CoachingService {
    func reply(to message: String, profile: UserProfile?) async -> String
}

protocol ReflectionService {
    func summarize(transcript: String) async -> String
}

protocol TransformationInsightService {
    func insight(checkIn: DailyCheckIn?) async -> String
}

protocol MissionGenerationService {
    func missions(for profile: UserProfile?) async -> [Mission]
}

protocol ComebackPlanService {
    func comebackPlan(afterBrokenStreak streak: Int) async -> String
}

struct MockAIService: FutureSelfService, CoachingService, ReflectionService, TransformationInsightService, MissionGenerationService, ComebackPlanService {
    static let shared = MockAIService()
    let systemPrompt = "You are NextSelf AI, a personal growth and transformation coach. Help users build habits, improve consistency, strengthen resilience, and become the future version of themselves. Do not provide medical advice, therapy, diagnosis, or crisis intervention."

    func persona(for profile: UserProfile?) async -> FutureSelfProfile {
        FutureSelfProfile(
            avatarType: "Electric Future Self",
            level: 5,
            identityDescription: profile?.futureIdentity.isEmpty == false ? profile!.futureIdentity : "Calm under pressure, consistent in action, and aligned with the person you are becoming."
        )
    }

    func message(for profile: UserProfile?) async -> String {
        "Your future self is waiting. Do the next clear thing today, then let consistency compound."
    }

    func milestoneReflection(day: Int, profile: UserProfile?) async -> String {
        "Day \(day): you are no longer proving you can start. You are becoming someone who returns, refines, and keeps promises with patience."
    }

    func reply(to message: String, profile: UserProfile?) async -> String {
        let goal = profile?.futureIdentity.isEmpty == false ? profile!.futureIdentity : "your future identity"
        return "I hear you. Bring it back to \(goal): what is the smallest disciplined action you can complete in the next 10 minutes? This is growth support, not medical or crisis care; professional support may be appropriate if this feels unsafe or overwhelming."
    }

    func summarize(transcript: String) async -> String {
        guard transcript.isEmpty == false else { return "No transcript yet. Record a reflection to reveal themes." }
        return "You are noticing patterns, naming friction, and building evidence that change is possible through repeated action."
    }

    func insight(checkIn: DailyCheckIn?) async -> String {
        "Protect the next hour. Choose one mission, reduce friction, and treat completion as identity evidence."
    }

    func missions(for profile: UserProfile?) async -> [Mission] {
        [
            Mission(title: "Ten-minute focused movement", category: .exercise, xp: 30, difficulty: "Easy"),
            Mission(title: "Write one future-self paragraph", category: .journaling, xp: 25, difficulty: "Easy"),
            Mission(title: "One distraction-free focus sprint", category: .focus, xp: 40, difficulty: "Medium"),
            Mission(title: "Hydrate before caffeine", category: .hydration, xp: 15, difficulty: "Easy")
        ]
    }

    func comebackPlan(afterBrokenStreak streak: Int) async -> String {
        "Reset without drama: one easy mission today, one environmental fix tonight, one honest reflection. A broken streak is information, not identity."
    }
}

struct RemoteAIService: FutureSelfService, CoachingService, ReflectionService, TransformationInsightService, MissionGenerationService, ComebackPlanService {
    let endpoint = URL(string: "https://YOUR_BACKEND_URL.com/nextself-ai")!

    func persona(for profile: UserProfile?) async -> FutureSelfProfile {
        await MockAIService.shared.persona(for: profile)
    }

    func message(for profile: UserProfile?) async -> String {
        await MockAIService.shared.message(for: profile)
    }

    func milestoneReflection(day: Int, profile: UserProfile?) async -> String {
        await MockAIService.shared.milestoneReflection(day: day, profile: profile)
    }

    func reply(to message: String, profile: UserProfile?) async -> String {
        await MockAIService.shared.reply(to: message, profile: profile)
    }

    func summarize(transcript: String) async -> String {
        await MockAIService.shared.summarize(transcript: transcript)
    }

    func insight(checkIn: DailyCheckIn?) async -> String {
        await MockAIService.shared.insight(checkIn: checkIn)
    }

    func missions(for profile: UserProfile?) async -> [Mission] {
        await MockAIService.shared.missions(for: profile)
    }

    func comebackPlan(afterBrokenStreak streak: Int) async -> String {
        await MockAIService.shared.comebackPlan(afterBrokenStreak: streak)
    }
}
