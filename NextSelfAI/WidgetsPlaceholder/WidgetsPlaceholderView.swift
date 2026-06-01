import SwiftUI

struct WidgetsPlaceholderView: View {
    var body: some View {
        ZStack {
            PremiumBackground()
            VStack(alignment: .leading, spacing: 18) {
                SectionTitle(title: "WidgetKit Placeholder", subtitle: "NextSelf Score, streak, future-self message, and today's mission.")
                PremiumCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("NextSelf Score widget", systemImage: "gauge.with.dots.needle.bottom.50percent")
                        Label("Streak widget", systemImage: "flame.fill")
                        Label("Future-self message widget", systemImage: "quote.bubble.fill")
                        Label("Today's mission widget", systemImage: "target")
                    }
                    .foregroundStyle(.white)
                }
                Spacer()
            }
            .padding(18)
        }
    }
}
