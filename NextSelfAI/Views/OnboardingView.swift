import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext
    @State private var currentIdentity = ""
    @State private var futureIdentity = ""
    @State private var selectedPriorities: Set<Priority> = [.health, .discipline, .focus]
    @State private var style: CoachingStyle = .supportive
    @State private var minutesPerDay = 20
    @State private var isGenerating = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("NextSelf AI")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Meet the person you're becoming.")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.blue)
                    Text("Your future self is waiting.")
                        .foregroundStyle(.white.opacity(0.7))
                }

                PremiumCard {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionTitle(title: "Identity Setup", subtitle: "Most apps track habits. NextSelf transforms identity.")
                        TextField("Describe who you are today", text: $currentIdentity, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                        TextField("Describe the future identity you want", text: $futureIdentity, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                PremiumCard {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(title: "Priorities", subtitle: nil)
                        FlowLayout(items: Priority.allCases) { priority in
                            ToggleChip(title: priority.title, isOn: selectedPriorities.contains(priority)) {
                                if selectedPriorities.contains(priority) {
                                    selectedPriorities.remove(priority)
                                } else {
                                    selectedPriorities.insert(priority)
                                }
                            }
                        }
                    }
                }

                PremiumCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Picker("Coaching Style", selection: $style) {
                            ForEach(CoachingStyle.allCases) { style in
                                Text(style.title).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)

                        Stepper("\(minutesPerDay) minutes per day", value: $minutesPerDay, in: 5...120, step: 5)
                            .foregroundStyle(.white)
                    }
                }

                Button {
                    Task {
                        isGenerating = true
                        await appModel.completeOnboarding(current: currentIdentity, future: futureIdentity, priorities: selectedPriorities, style: style, minutes: minutesPerDay)
                        modelContext.insert(appModel.profile)
                        modelContext.insert(appModel.futureSelf)
                        modelContext.insert(appModel.subscriptionState)
                        appModel.missions.forEach { modelContext.insert($0) }
                        isGenerating = false
                    }
                } label: {
                    Label(isGenerating ? "Generating Plan" : "Generate My NextSelf", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGenerating)

                WellnessDisclaimerView()
            }
            .padding(22)
        }
    }
}

struct ToggleChip: View {
    let title: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isOn ? .black : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isOn ? .yellow : .white.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct FlowLayout<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                content(item)
            }
        }
    }
}

struct WellnessDisclaimerView: View {
    var body: some View {
        Text("NextSelf AI is a wellness and personal growth tool only. It is not therapy, medical advice, addiction treatment, diagnosis, crisis support, or a replacement for professional healthcare. Professional support may be appropriate in some situations.")
            .font(.footnote)
            .foregroundStyle(.white.opacity(0.58))
    }
}
