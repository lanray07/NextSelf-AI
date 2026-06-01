import SwiftUI

struct WatchPlaceholderView: View {
    var body: some View {
        ZStack {
            PremiumBackground()
            VStack(alignment: .leading, spacing: 18) {
                SectionTitle(title: "Apple Watch Placeholder", subtitle: "Reminders, quick check-in, streak tracking, and future-self notifications.")
                PremiumCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Quick check-in", systemImage: "slider.horizontal.3")
                        Label("Streak glance", systemImage: "flame.fill")
                        Label("Mission reminders", systemImage: "bell.fill")
                        Label("Future-self notifications", systemImage: "person.crop.circle.badge.sparkles")
                    }
                    .foregroundStyle(.white)
                }
                Spacer()
            }
            .padding(18)
        }
    }
}
