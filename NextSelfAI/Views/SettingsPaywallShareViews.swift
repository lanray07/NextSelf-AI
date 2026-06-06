import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(AppModel.self) private var appModel
    @State private var showPaywall = false
    @State private var showHabitBuilder = false
    @State private var showReport = false
    @State private var notificationsEnabled = true
    @State private var voiceEnabled = true

    var body: some View {
        List {
            Section("Account") {
                Button("Subscription: \(appModel.subscriptionManager.selectedPlan.title)") { showPaywall = true }
                Button("Export Progress Report") { showReport = true }
                Button("Delete All Data", role: .destructive) { }
            }

            Section("Coaching") {
                Text("Style: \(appModel.profile.coachingStyle.capitalized)")
                Button("Habit Builder") { showHabitBuilder = true }
            }

            Section("Preferences") {
                Toggle("Voice Settings", isOn: $voiceEnabled)
                Toggle("Notifications", isOn: $notificationsEnabled)
                Button("Request Local Notifications") {
                    Task {
                        await appModel.notificationService.requestAuthorization()
                        appModel.notificationService.scheduleDailyMissionReminder()
                    }
                }
                Text("Theme: Obsidian Electric")
            }

            Section("Legal") {
                NavigationLink("Privacy Policy") { LegalTextView(title: "Privacy Policy", bodyText: LegalCopy.privacy) }
                NavigationLink("Terms of Use") { LegalTextView(title: "Terms of Use", bodyText: LegalCopy.terms) }
                NavigationLink("Wellness Disclaimer") { LegalTextView(title: "Wellness Disclaimer", bodyText: "NextSelf AI is a wellness and personal growth tool only. It is not therapy, medical advice, diagnosis, addiction treatment, crisis intervention, or a replacement for professional healthcare.") }
            }

            Section("Platform Placeholders") {
                NavigationLink("Widgets") { WidgetsPlaceholderView() }
                NavigationLink("Apple Watch") { WatchPlaceholderView() }
            }
        }
        .scrollContentBackground(.hidden)
        .background(PremiumBackground())
        .navigationTitle("Settings")
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .sheet(isPresented: $showHabitBuilder) { HabitBuilderView() }
        .sheet(isPresented: $showReport) {
            ShareSheet(items: [ProgressReportExporter.pdfReport(appModel: appModel)])
        }
    }
}

struct PaywallView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()
                ScrollView {
                    VStack(spacing: 18) {
                        SectionTitle(title: "Become NextSelf Elite", subtitle: "Unlimited AI coaching, voice journaling, analytics, premium themes, future-self conversations, avatars, and reports.")

                        PlanCard(plan: .free, features: ["Limited missions", "Basic journaling", "Limited AI messages"])
                        PlanCard(plan: .premiumMonthly, features: ["Unlimited AI coaching", "Voice journaling", "Future-self conversations", "Transformation analytics"])
                        PlanCard(plan: .premiumYearly, features: ["Best value Premium", "Progress reports", "Premium themes", "All Premium features"])
                        PlanCard(plan: .eliteMonthly, features: ["Advanced coaching personalities", "Deep transformation reports", "Premium avatars", "Exclusive themes"])

                        VStack(spacing: 8) {
                            Text("Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel in your Apple ID subscriptions settings.")
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white.opacity(0.68))
                            Link("Privacy Policy", destination: URL(string: "https://github.com/lanray07/NextSelf-AI/blob/main/PRIVACY.md")!)
                            Link("Terms of Use (EULA)", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        }
                        .font(.footnote.weight(.semibold))
                        .tint(.yellow)
                        .padding(.top, 4)
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Upgrade")
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}

enum LegalCopy {
    static let privacy = """
    NextSelf AI stores the reflections, goals, check-ins, missions, progress scores, and preferences you enter so the app can provide journaling, coaching, analytics, and personalization.

    Voice journaling may request microphone and speech recognition access so you can record and transcribe reflections. You can manage these permissions in iOS Settings.

    We do not sell your personal information or share it with advertisers. The app is designed as a local-first wellness and personal growth tool.

    Full privacy policy:
    https://github.com/lanray07/NextSelf-AI/blob/main/PRIVACY.md
    """

    static let terms = """
    NextSelf AI uses Apple's standard Terms of Use (EULA):
    https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

    Auto-renewable subscriptions unlock premium coaching, analytics, journaling, reports, avatars, and themes. Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. You can manage or cancel subscriptions in your Apple ID account settings.

    NextSelf AI is a wellness and personal growth tool only. It does not provide therapy, diagnosis, medical advice, addiction treatment, crisis intervention, or professional healthcare.
    """
}

struct PlanCard: View {
    @Environment(AppModel.self) private var appModel
    let plan: SubscriptionPlan
    let features: [String]

    var body: some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(plan.title)
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        Text(plan.price)
                            .foregroundStyle(.yellow)
                    }
                    Spacer()
                    Button("Choose") {
                        Task { await appModel.subscriptionManager.purchase(plan) }
                    }
                    .buttonStyle(.borderedProminent)
                }
                ForEach(features, id: \.self) { feature in
                    Label(feature, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.78))
                }
            }
        }
    }
}

struct HabitBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var habits = ["Sleep", "Hydration", "Exercise", "Reading", "Meditation", "Learning"]
    @State private var newHabit = ""

    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()
                List {
                    ForEach(habits, id: \.self) { habit in
                        Label(habit, systemImage: "circle.dashed")
                            .listRowBackground(Color.clear)
                    }
                    HStack {
                        TextField("Custom habit", text: $newHabit)
                        Button("Add") {
                            guard newHabit.isEmpty == false else { return }
                            habits.append(newHabit)
                            newHabit = ""
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Habit Builder")
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}

struct ComebackEngineView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss
    @State private var plan = ""

    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()
                VStack(alignment: .leading, spacing: 18) {
                    SectionTitle(title: "Comeback Engine", subtitle: "A broken streak is information, not identity.")
                    PremiumCard {
                        Text(plan.isEmpty ? "Generate a reset plan when consistency breaks." : plan)
                            .foregroundStyle(.white.opacity(0.78))
                    }
                    Button {
                        Task { plan = await appModel.ai.comebackPlan(afterBrokenStreak: appModel.streak) }
                    } label: {
                        Label("Generate Comeback Plan", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .padding(18)
            }
            .navigationTitle("Comeback")
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}

struct ShareCardsView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss
    @State private var showShare = false

    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()
                VStack(spacing: 18) {
                    ShareCardPreview(score: appModel.nextSelfScore, message: appModel.futureMessage)
                    Button {
                        showShare = true
                    } label: {
                        Label("Share Transformation Card", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .padding(18)
            }
            .navigationTitle("Share")
            .toolbar { Button("Done") { dismiss() } }
            .sheet(isPresented: $showShare) {
                ShareSheet(items: ["NextSelf Score: \(appModel.nextSelfScore). \(appModel.futureMessage)"])
            }
        }
    }
}

struct ShareCardPreview: View {
    let score: Int
    let message: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [.black, .blue.opacity(0.7), .purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(alignment: .leading, spacing: 12) {
                Text("NextSelf AI")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.yellow)
                Text("\(score)")
                    .font(.system(size: 76, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(message)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Text("Meet the person you're becoming.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.72))
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(0.8, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .blue.opacity(0.24), radius: 28, y: 18)
    }
}

struct LegalTextView: View {
    let title: String
    let bodyText: String

    var body: some View {
        ZStack {
            PremiumBackground()
            ScrollView {
                Text(bodyText)
                    .foregroundStyle(.white.opacity(0.75))
                    .padding()
            }
        }
        .navigationTitle(title)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

@MainActor
enum ProgressReportExporter {
    static func pdfReport(appModel: AppModel) -> URL {
        let url = FileManager.default.temporaryDirectory.appending(path: "NextSelf-Progress-Report.pdf")
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        try? renderer.writePDF(to: url) { context in
            context.beginPage()
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.darkGray
            ]
            "NextSelf AI Progress Report".draw(at: CGPoint(x: 48, y: 48), withAttributes: titleAttributes)
            textReport(appModel: appModel).draw(in: CGRect(x: 48, y: 100, width: 516, height: 620), withAttributes: bodyAttributes)
        }
        return url
    }

    static func textReport(appModel: AppModel) -> String {
        """
        Score: \(appModel.nextSelfScore)
        Streak: \(appModel.streak)
        Completed Missions: \(appModel.completedMissionCount)
        Future Self: \(appModel.futureSelf.identityDescription)

        Disclaimer: NextSelf AI is a wellness and personal growth tool only, not therapy, medical advice, diagnosis, crisis support, addiction treatment, or a healthcare replacement.
        """
    }
}
