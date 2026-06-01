import SwiftData
import SwiftUI

struct VoiceJournalView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext
    @State private var speech = SpeechRecognitionService()
    @State private var recorder = VoiceRecordingService()
    @State private var waveform = WaveformAnimationManager()
    @State private var editableTranscript = ""
    @State private var summary = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SectionTitle(title: "Voice Journal", subtitle: "Record thoughts, wins, setbacks, and growth moments.")

                PremiumCard {
                    VStack(spacing: 16) {
                        VoiceWaveformView(samples: waveform.samples, isActive: recorder.isRecording && recorder.isPaused == false)
                            .task(id: recorder.isRecording) {
                                while recorder.isRecording {
                                    waveform.refresh()
                                    try? await Task.sleep(for: .milliseconds(420))
                                }
                            }
                        HStack(spacing: 12) {
                            Button {
                                recorder.isRecording ? recorder.stop() : recorder.start()
                                if recorder.isRecording {
                                    speech.mockTranscribe()
                                    editableTranscript = speech.transcript
                                }
                            } label: {
                                Label(recorder.isRecording ? "Stop" : "Record", systemImage: recorder.isRecording ? "stop.fill" : "mic.fill")
                            }
                            .buttonStyle(.borderedProminent)

                            Button(recorder.isPaused ? "Resume" : "Pause") {
                                recorder.isPaused ? recorder.resume() : recorder.pause()
                            }
                            .buttonStyle(.bordered)
                            .disabled(recorder.isRecording == false)
                        }
                    }
                }

                PremiumCard {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionTitle(title: "Live Transcript", subtitle: nil)
                        TextEditor(text: $editableTranscript)
                            .frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        Button {
                            Task {
                                await appModel.saveJournal(editableTranscript)
                                if let journal = appModel.journalEntries.last {
                                    modelContext.insert(journal)
                                }
                                if let transcript = appModel.transcripts.last {
                                    modelContext.insert(transcript)
                                }
                                summary = await appModel.ai.summarize(transcript: editableTranscript)
                            }
                        } label: {
                            Label("Save Reflection", systemImage: "doc.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                if summary.isEmpty == false {
                    PremiumCard {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionTitle(title: "AI Reflection Summary", subtitle: nil)
                            Text(summary)
                                .foregroundStyle(.white.opacity(0.75))
                        }
                    }
                }
            }
            .padding(18)
        }
        .navigationTitle("Voice")
        .task {
            await speech.requestAuthorization()
        }
    }
}
