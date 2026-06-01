import Foundation
import SwiftData

enum Priority: String, CaseIterable, Identifiable, Codable {
    case health, confidence, discipline, productivity, recovery, focus, career, relationships, learning, finances
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum CoachingStyle: String, CaseIterable, Identifiable, Codable {
    case supportive, motivational, direct, disciplined, executive
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum MissionCategory: String, CaseIterable, Codable {
    case exercise, reading, focus, hydration, journaling, sleep, social, learning, custom
}

enum SubscriptionPlan: String, CaseIterable, Identifiable, Codable {
    case free, premiumMonthly, premiumYearly, eliteMonthly
    var id: String { rawValue }
    var title: String {
        switch self {
        case .free: "Free"
        case .premiumMonthly: "Premium Monthly"
        case .premiumYearly: "Premium Yearly"
        case .eliteMonthly: "Elite Monthly"
        }
    }
    var price: String {
        switch self {
        case .free: "Limited"
        case .premiumMonthly: "£9.99"
        case .premiumYearly: "£79.99"
        case .eliteMonthly: "£19.99"
        }
    }
}

@Model
final class UserProfile {
    var id: UUID
    var currentIdentity: String
    var futureIdentity: String
    var coachingStyle: String
    var priorities: [String]
    var minutesPerDay: Int
    var createdAt: Date

    init(currentIdentity: String = "", futureIdentity: String = "", coachingStyle: CoachingStyle = .supportive, priorities: [Priority] = [], minutesPerDay: Int = 20) {
        self.id = UUID()
        self.currentIdentity = currentIdentity
        self.futureIdentity = futureIdentity
        self.coachingStyle = coachingStyle.rawValue
        self.priorities = priorities.map(\.rawValue)
        self.minutesPerDay = minutesPerDay
        self.createdAt = .now
    }
}

@Model
final class FutureSelfProfile {
    var id: UUID
    var avatarType: String
    var level: Int
    var identityDescription: String
    var createdAt: Date

    init(avatarType: String = "Obsidian", level: Int = 1, identityDescription: String = "A focused, resilient future self.") {
        self.id = UUID()
        self.avatarType = avatarType
        self.level = level
        self.identityDescription = identityDescription
        self.createdAt = .now
    }
}

@Model
final class Mission {
    var id: UUID
    var title: String
    var category: String
    var xp: Int
    var difficulty: String
    var completed: Bool
    var createdAt: Date

    init(title: String, category: MissionCategory, xp: Int, difficulty: String = "Medium", completed: Bool = false, createdAt: Date = .now) {
        self.id = UUID()
        self.title = title
        self.category = category.rawValue
        self.xp = xp
        self.difficulty = difficulty
        self.completed = completed
        self.createdAt = createdAt
    }
}

@Model
final class JournalEntry {
    var id: UUID
    var content: String
    var aiSummary: String
    var createdAt: Date

    init(content: String, aiSummary: String = "", createdAt: Date = .now) {
        self.id = UUID()
        self.content = content
        self.aiSummary = aiSummary
        self.createdAt = createdAt
    }
}

@Model
final class VoiceTranscript {
    var id: UUID
    var transcript: String
    var reflection: String
    var createdAt: Date

    init(transcript: String = "", reflection: String = "", createdAt: Date = .now) {
        self.id = UUID()
        self.transcript = transcript
        self.reflection = reflection
        self.createdAt = createdAt
    }
}

@Model
final class DailyCheckIn {
    var id: UUID
    var mood: Double
    var energy: Double
    var confidence: Double
    var focus: Double
    var stress: Double
    var sleepQuality: Double
    var insight: String
    var createdAt: Date

    init(mood: Double = 0.6, energy: Double = 0.6, confidence: Double = 0.6, focus: Double = 0.6, stress: Double = 0.4, sleepQuality: Double = 0.6, insight: String = "") {
        self.id = UUID()
        self.mood = mood
        self.energy = energy
        self.confidence = confidence
        self.focus = focus
        self.stress = stress
        self.sleepQuality = sleepQuality
        self.insight = insight
        self.createdAt = .now
    }
}

@Model
final class TransformationMilestone {
    var id: UUID
    var title: String
    var milestoneDescription: String
    var unlockedAt: Date

    init(title: String, description: String, unlockedAt: Date = .now) {
        self.id = UUID()
        self.title = title
        self.milestoneDescription = description
        self.unlockedAt = unlockedAt
    }
}

@Model
final class NextSelfScore {
    var id: UUID
    var score: Int
    var createdAt: Date

    init(score: Int = 42, createdAt: Date = .now) {
        self.id = UUID()
        self.score = score
        self.createdAt = createdAt
    }
}

@Model
final class SubscriptionState {
    var id: UUID
    var plan: String
    var isActive: Bool

    init(plan: SubscriptionPlan = .free, isActive: Bool = false) {
        self.id = UUID()
        self.plan = plan.rawValue
        self.isActive = isActive
    }
}

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let role: String
    let content: String
}

struct TrendPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Int
}
