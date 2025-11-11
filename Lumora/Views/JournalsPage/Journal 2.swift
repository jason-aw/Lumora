//
//  Journal 2.swift
//  Lumora
//
//  Created by Arshia on 7/11/2025.
//

import SwiftUI
import PhotosUI
import AVFoundation
import UIKit

// MARK: - Compose ViewModel

@Observable
final class ComposeViewModel {
    // Core fields
    var title: String = ""
    var bodyText: String = ""
    var date: Date = Date()

    // Preserve ID when editing
    var originalID: UUID? = nil

    // Formatting (applies to the whole body text)
    enum BodyStyle: String, CaseIterable { case body, large }
    var bodyStyle: BodyStyle = .body
    var isBold: Bool = false

    // Attachments
    var image: UIImage?
    var audioURL: URL?
    var isRecording: Bool = false
    var level: Float = 0 // 0...1 for a simple meter

    // Pickers
    var showPhotoPicker: Bool = false
    var showCamera: Bool = false

    // Audio
    private var recorder: AudioRecorder?

    // Derived snippet
    var snippet: String {
        if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return title
        }
        let firstLine = bodyText.split(separator: "\n").first.map(String.init) ?? ""
        return firstLine.isEmpty ? "New entry" : firstLine
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        recorder = AudioRecorder()
        do {
            let url = try recorder!.start()
            isRecording = true
            audioURL = url
            recorder?.onMetering = { [weak self] power in
                guard let self else { return }
                let normalized = max(0, min(1, (power + 50) / 50))
                self.level = normalized
            }
        } catch {
            print("Audio start error: \(error)")
            recorder = nil
        }
    }

    private func stopRecording() {
        recorder?.stop()
        isRecording = false
        level = 0
    }

    func makeEntry() -> JournalEntry {
        JournalEntry(
            id: originalID ?? UUID(),
            date: date,
            snippet: snippet,
            fullText: bodyText
        )
    }
}

// MARK: - Main Compose Screen

struct JournalComposeView: View {
    @State private var model = ComposeViewModel()

    // Callback when user saves (not used on-screen anymore; keep for parent to call if needed)
    let onSave: (JournalEntry) -> Void
    var onCancel: (() -> Void)? = nil

    init(onSave: @escaping (JournalEntry) -> Void, onCancel: (() -> Void)? = nil) {
        self.onSave = onSave
        self.onCancel = onCancel
    }

    // Prefill initializer for editing an existing entry
    init(entry: JournalEntry, onSave: @escaping (JournalEntry) -> Void, onCancel: (() -> Void)? = nil) {
        self.onSave = onSave
        self.onCancel = onCancel
        // Seed state
        let seeded = ComposeViewModel()
        seeded.originalID = entry.id
        seeded.date = entry.date
        seeded.title = entry.snippet
        seeded.bodyText = entry.fullText
        _model = State(initialValue: seeded)
    }

    var body: some View {
        VStack(spacing: 0) {
            // No top bar

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    dateRow

                    // Title (single placeholder only)
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Title",
                                  text: $model.title,
                                  prompt: Text("Title").foregroundColor(.white.opacity(0.35)))
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                            .tint(.white)
                            .submitLabel(.done)

                        // Keep ONLY this divider under the title
                        GlassDivider()
                    }
                    .padding(.top, 8)

                    // Body text
                    VStack(alignment: .leading, spacing: 8) {
                        // Removed the extra divider here to avoid two lines
                        TextEditor(text: $model.bodyText)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 220)
                            .font(bodyFont)
                            .foregroundColor(.white.opacity(0.9))
                            .overlay(alignment: .topLeading) {
                                if model.bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Text("Start writing...")
                                        .foregroundColor(.white.opacity(0.35))
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                        .allowsHitTesting(false)
                                }
                            }
                    }

                    // Attachments preview (optional)
                    attachmentsPreview

                    // Live meter while recording (optional visual feedback)
                    if model.isRecording {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recording...")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                            MeterView(level: model.level)
                                .frame(height: 22)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 120) // space for bottom bar
            }

            bottomAccessoryBar
        }
        .background(Color("backgroundColor").ignoresSafeArea())
        .photosPicker(isPresented: $model.showPhotoPicker, selection: .constant(nil))
        .sheet(isPresented: $model.showPhotoPicker) {
            PhotoPicker(image: $model.image)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $model.showCamera) {
            CameraPicker(image: $model.image)
                .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top) {
            // Optional: a minimal top control bar for cancel/save when presented as a sheet
            HStack {
                Button("Cancel") { onCancel?() }
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                Button("Save") {
                    onSave(model.makeEntry())
                }
                .font(.system(.headline, design: .default))
                .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color("backgroundColor").opacity(0.9))
        }
    }

    // Decide the size explicitly.
    private var bodyFont: Font {
        let size: CGFloat = (model.bodyStyle == .large) ? 20 : 17
        return model.isBold ? .system(size: size, weight: .semibold) : .system(size: size)
    }

    // MARK: - Date Row

    private var dateRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "calendar.badge.clock")
                .foregroundColor(.white.opacity(0.9))
            DatePicker("", selection: $model.date, displayedComponents: .date)
                .labelsHidden()
                .tint(.white)
                .colorScheme(.dark)
        }
        .font(.system(size: 16, weight: .semibold))
        .foregroundColor(.white.opacity(0.9))
        .padding(.top, 8)
    }

    // MARK: - Attachments Preview

    @ViewBuilder
    private var attachmentsPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let image = model.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(GlassStroke(cornerRadius: 16))
                    .background(GlassBackground(cornerRadius: 16))
            }

            if let url = model.audioURL {
                HStack(spacing: 12) {
                    Image(systemName: "waveform.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 28))
                    Text(url.lastPathComponent)
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                    Spacer()
                    Button(role: .destructive) {
                        model.audioURL = nil
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(14)
                .background(GlassBackground(cornerRadius: 14))
                .overlay(GlassStroke(cornerRadius: 14))
            }
        }
    }

    // MARK: - Bottom Accessory Bar (Liquid Glass, compact 3-icon pill)

    private var bottomAccessoryBar: some View {
        VStack(spacing: 10) {
            Spacer(minLength: 0)

            GeometryReader { geo in
                // Narrower width to match your screenshot
                let baseWidth: CGFloat = 220
                let width = min(max(baseWidth, geo.size.width * 0.52), 260)
                let height: CGFloat = 46
                let radius: CGFloat = 18

                ZStack {
                    // Color tuned to match the date row/your screenshot: darker neutral glass
                    GlassBackground(cornerRadius: radius, tint: Color.white.opacity(0.05))
                        .frame(width: width, height: height)
                        .overlay(GlassStroke(cornerRadius: radius))

                    HStack(spacing: 24) {
                        Button { model.showPhotoPicker = true } label: {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .accessibilityLabel("Add photo")
                        }
                        Button { model.showCamera = true } label: {
                            Image(systemName: "camera")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .accessibilityLabel("Take photo")
                        }
                        Button { model.toggleRecording() } label: {
                            ZStack {
                                Image(systemName: "waveform")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                if model.isRecording {
                                    Circle()
                                        .fill(Color.red.opacity(0.95))
                                        .frame(width: 6, height: 6)
                                        .offset(x: 10, y: -8)
                                }
                            }
                        }
                        .accessibilityLabel(model.isRecording ? "Stop recording" : "Start recording")
                    }
                    .frame(width: width, height: height)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .frame(height: 66) // container height
            .padding(.bottom, 18)
        }
        .background(Color.clear.ignoresSafeArea(edges: .bottom))
    }
}

// MARK: - Liquid Glass Building Blocks

private struct GlassBackground: View {
    var cornerRadius: CGFloat = 24
    // Dark neutral tint; closer to the date row feel
    var tint: Color = Color.white.opacity(0.05)

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(tint)
            )
            .overlay(
                // very subtle highlight
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(LinearGradient(colors: [
                        Color.white.opacity(0.15),
                        Color.white.opacity(0.04)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.6)
                    .blendMode(.plusLighter)
            )
            .shadow(color: Color.black.opacity(0.22), radius: 9, x: 0, y: 5)
    }
}

private struct GlassStroke: View {
    var cornerRadius: CGFloat = 24
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(Color.white.opacity(0.09), lineWidth: 0.8)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.26), lineWidth: 0.45)
                    .blendMode(.overlay)
            )
            .allowsHitTesting(false)
    }
}

private struct GlassDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.18),
                        Color.white.opacity(0.08),
                        Color.white.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 1)
            .background(Color.white.opacity(0.03))
            .overlay(
                Rectangle()
                    .fill(Color.black.opacity(0.18))
                    .frame(height: 0.5)
                    .offset(y: 0.5)
                    .blendMode(.overlay)
            )
    }
}

// MARK: - Level Meter

private struct MeterView: View {
    let level: Float // 0...1

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let barCount = 12
            let gap: CGFloat = 2
            let barWidth = (width - CGFloat(barCount - 1) * gap) / CGFloat(barCount)
            let activeBars = Int(round(level * Float(barCount)))

            HStack(alignment: .center, spacing: gap) {
                ForEach(0..<barCount, id: \.self) { i in
                    let h = height * CGFloat(Double(i + 1) / Double(barCount))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < activeBars ? Color.green.opacity(0.95) : Color.white.opacity(0.25))
                        .frame(width: barWidth, height: h)
                        .animation(.easeOut(duration: 0.12), value: activeBars)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }
}

// MARK: - Photo Picker

private struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { object, _ in
                DispatchQueue.main.async {
                    self.parent.image = object as? UIImage
                }
            }
        }
    }
}

// MARK: - Camera Picker

private struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Audio Recorder

private final class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    private var recorder: AVAudioRecorder?
    private var displayLink: CADisplayLink?
    var onMetering: ((Float) -> Void)?

    func start() throws -> URL {
        try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try AVAudioSession.sharedInstance().setActive(true)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("memo-\(UUID().uuidString).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.isMeteringEnabled = true
        recorder?.delegate = self
        recorder?.record()

        startMetering()
        return url
    }

    func stop() {
        recorder?.stop()
        stopMetering()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func startMetering() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopMetering() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick() {
        recorder?.updateMeters()
        let power = recorder?.averagePower(forChannel: 0) ?? -160
        onMetering?(power)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color("backgroundColor").ignoresSafeArea()
        JournalComposeView(onSave: { entry in
            print("Saved entry: \(entry)")
        })
    }
}

