import SwiftUI

struct FutureSelfEngineView: View {
    @Environment(AppModel.self) private var appModel
    @State private var showChat = false
    @State private var day = 30
    @State private var reflection = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                FutureSelfCard(profile: appModel.futureSelf, message: appModel.futureMessage)

                PremiumCard {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(title: "Future Self Engine", subtitle: "Milestone reflections, encouragement, progress reviews, and identity alignment.")
                        Picker("Reflection", selection: $day) {
                            Text("Day 30").tag(30)
                            Text("Day 90").tag(90)
                            Text("Future Advice").tag(365)
                        }
                        .pickerStyle(.segmented)
                        Button {
                            Task { reflection = await appModel.ai.milestoneReflection(day: day, profile: appModel.profile) }
                        } label: {
                            Label("Generate Reflection", systemImage: "sparkles")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        if reflection.isEmpty == false {
                            Text(reflection)
                                .foregroundStyle(.white.opacity(0.75))
                        }
                    }
                }

                IdentityLevelsView(level: appModel.futureSelf.level)

                Button {
                    showChat = true
                } label: {
                    Label("Talk To Future Self", systemImage: "message.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(18)
        }
        .navigationTitle("Future Self")
        .sheet(isPresented: $showChat) { FutureSelfChatView() }
    }
}

struct FutureSelfChatView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""

    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()
                VStack(spacing: 12) {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(appModel.chat) { message in
                                ChatBubble(message: message)
                            }
                        }
                        .padding()
                    }
                    HStack {
                        TextField("Ask your future self", text: $text)
                            .textFieldStyle(.roundedBorder)
                        Button {
                            let outgoing = text
                            text = ""
                            Task { await appModel.sendFutureSelfMessage(outgoing) }
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Future Conversation")
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        Text(message.content)
            .padding(14)
            .foregroundStyle(.white)
            .background(message.role == "user" ? .blue.opacity(0.55) : .white.opacity(0.10), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .frame(maxWidth: .infinity, alignment: message.role == "user" ? .trailing : .leading)
    }
}

struct IdentityLevelsView: View {
    let level: Int
    let levels = [(1, "Observer"), (5, "Builder"), (10, "Disciplined"), (20, "Focused"), (35, "Ascending"), (50, "NextSelf Elite")]

    var body: some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(title: "Identity Levels", subtitle: "Unlock themes, avatar upgrades, and achievements.")
                ForEach(levels, id: \.0) { target, title in
                    HStack {
                        Image(systemName: level >= target ? "lock.open.fill" : "lock.fill")
                            .foregroundStyle(level >= target ? .yellow : .white.opacity(0.4))
                        Text("Level \(target)")
                            .foregroundStyle(.white.opacity(0.7))
                        Text(title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
            }
        }
    }
}
