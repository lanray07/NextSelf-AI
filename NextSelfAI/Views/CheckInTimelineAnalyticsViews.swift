import Charts
import SwiftData
import SwiftUI

struct DailyCheckInView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var mood = 0.6
    @State private var energy = 0.6
    @State private var confidence = 0.6
    @State private var focus = 0.6
    @State private var stress = 0.4
    @State private var sleep = 0.6

    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()
                ScrollView {
                    VStack(spacing: 18) {
                        SectionTitle(title: "Daily Check-In", subtitle: "Mood, energy, focus, stress, confidence, and sleep quality.")
                        CheckSlider(title: "Mood", value: $mood)
                        CheckSlider(title: "Energy", value: $energy)
                        CheckSlider(title: "Confidence", value: $confidence)
                        CheckSlider(title: "Focus", value: $focus)
                        CheckSlider(title: "Stress", value: $stress)
                        CheckSlider(title: "Sleep Quality", value: $sleep)
                        Button {
                            Task {
                                let checkIn = DailyCheckIn(mood: mood, energy: energy, confidence: confidence, focus: focus, stress: stress, sleepQuality: sleep)
                                await appModel.submitCheckIn(checkIn)
                                modelContext.insert(checkIn)
                                dismiss()
                            }
                        } label: {
                            Label("Generate Insight", systemImage: "sparkles")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Check-In")
            .toolbar { Button("Cancel") { dismiss() } }
        }
    }
}

struct CheckSlider: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        PremiumCard {
            VStack(alignment: .leading) {
                HStack {
                    Text(title).foregroundStyle(.white).font(.headline)
                    Spacer()
                    Text("\(Int(value * 100))%").foregroundStyle(.blue).font(.subheadline.bold())
                }
                Slider(value: $value)
            }
        }
    }
}

struct TimelineScreen: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        SectionTitle(title: "Transformation Timeline", subtitle: "Milestones, streaks, journal highlights, and completed missions.")
                        PremiumCard {
                            TransformationTimelineView(milestones: appModel.milestones)
                        }
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Timeline")
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}

struct AnalyticsDashboardView: View {
    @Environment(AppModel.self) private var appModel
    @State private var showShare = false
    @State private var showComeback = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                SectionTitle(title: "Transformation Analytics", subtitle: "Trends without turning your life into a spreadsheet.")
                AnalyticsChartCard(points: appModel.trendPoints())

                PremiumCard {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(title: "Habit Consistency", subtitle: nil)
                        StatRow(title: "Strongest Habit", value: "Focus")
                        StatRow(title: "Weakest Habit", value: "Sleep Routine")
                        StatRow(title: "Growth Velocity", value: "+18%")
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    QuickAction(title: "Share Card", symbol: "square.and.arrow.up") { showShare = true }
                    QuickAction(title: "Comeback", symbol: "arrow.counterclockwise.circle") { showComeback = true }
                }
            }
            .padding(18)
        }
        .navigationTitle("Growth")
        .sheet(isPresented: $showShare) { ShareCardsView() }
        .sheet(isPresented: $showComeback) { ComebackEngineView() }
    }
}
