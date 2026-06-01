import SwiftData
import SwiftUI

@main
struct NextSelfAIApp: App {
    @State private var appModel = AppModel()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            FutureSelfProfile.self,
            Mission.self,
            JournalEntry.self,
            VoiceTranscript.self,
            DailyCheckIn.self,
            TransformationMilestone.self,
            NextSelfScore.self,
            SubscriptionState.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appModel)
                .task {
                    await appModel.bootstrap()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
