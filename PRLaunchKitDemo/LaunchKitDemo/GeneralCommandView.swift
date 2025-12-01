import SwiftUI
import SwiftData
import PRAppLaunchKit

struct GeneralCommandView: View {
    // MARK: - Public Properties
    @Binding var scheme: Scheme
    @Binding var isInstalled: Bool

    // MARK: - Private Properties
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\CommandPreset.updatedAt, order: .reverse)]) private var presets: [CommandPreset]
    @State private var command = ""
    @State private var parameters: [(name: String, value: String)] = Array(repeating: ("", ""), count: Self.parameterLimit)
    @State private var selectedPresetID: UUID?
    @State private var isPresentingSaveSheet = false
    @State private var pendingPresetName = ""
    @State private var isShowingSaveError = false
    @State private var saveErrorMessage = ""
    private static let parameterLimit = 4

    var body: some View {
        Form {
            Section {
                Picker("Scheme", selection: self.$scheme) {
                    ForEach(Scheme.allCases, id: \.self) { scheme in
                        Text(scheme.rawValue)
                    }
                }
            }

            Section("Saved Presets") {
                if self.presets.isEmpty {
                    Text("No presets saved yet")
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Preset", selection: self.$selectedPresetID) {
                        Text("Select preset")
                            .tag(UUID?.none)

                        ForEach(self.presets, id: \.id) { preset in
                            Text(preset.name)
                                .tag(Optional(preset.id))
                        }
                    }
                }

                Button("Save Current") {
                    self.startSavingPreset()
                }
                .disabled(self.command.isEmpty)
            }

            Section("Deep-Link Command") {
                TextField("Enter command", text: self.$command)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }

            Section("Parameters") {
                ForEach(0..<Self.parameterLimit, id: \.self) { index in
                    HStack {
                        TextField("Name", text: self.$parameters[index].name)
                            .containerRelativeFrame(.horizontal, count: 100, span: 30, spacing: 0)
                            .minimumScaleFactor(0.5)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        Divider()

                        TextField("Value", text: self.$parameters[index].value, axis: .vertical)
                            .lineLimit(1...3)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                }
            }

            Section {
                HStack {
                    Spacer()

                    Button(self.isInstalled ? "Open" : "Install") {
                        self.launchApp()
                    }
                    .disabled(self.command.isEmpty)

                    Spacer()
                }
            }
        }
        .navigationTitle("Generic Command")
        .onChange(of: self.selectedPresetID) { _, newValue in
            self.loadPresetIfNeeded(id: newValue)
        }
        .sheet(isPresented: self.$isPresentingSaveSheet) {
            NavigationStack {
                Form {
                    TextField("Preset Name", text: self.$pendingPresetName)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                .navigationTitle("Save Preset")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            self.isPresentingSaveSheet = false
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            self.persistPreset()
                        }
                        .disabled(self.pendingPresetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
        .alert("Unable to Save", isPresented: self.$isShowingSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(self.saveErrorMessage)
        }
    }

    // MARK: - Private Methods
    private func startSavingPreset() {
        self.pendingPresetName = self.command
        self.isPresentingSaveSheet = true
    }

    private func persistPreset() {
        let trimmedName = self.pendingPresetName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {

            return
        }

        let parameterPayload = self.parameters
            .map { (name: $0.name.trimmingCharacters(in: .whitespacesAndNewlines), value: $0.value) }
            .filter { !$0.name.isEmpty || !$0.value.isEmpty }
        let timestamp = Date()

        if let existingPreset = self.presets.first(where: { $0.name.compare(trimmedName, options: .caseInsensitive) == .orderedSame }) {
            existingPreset.update(
                command: self.command,
                parameters: parameterPayload,
                timestamp: timestamp
            )
            self.selectedPresetID = existingPreset.id
        } else {
            let preset = CommandPreset(
                name: trimmedName,
                command: self.command,
                parameters: parameterPayload,
                updatedAt: timestamp
            )
            self.modelContext.insert(preset)
            self.selectedPresetID = preset.id
        }

        do {
            try self.modelContext.save()
            self.isPresentingSaveSheet = false
        } catch {
            self.saveErrorMessage = error.localizedDescription
            self.isShowingSaveError = true
        }
    }

    private func loadPresetIfNeeded(id: UUID?) {
        guard let presetID = id,
              let preset = self.presets.first(where: { $0.id == presetID }) else {

            return
        }

        self.load(preset: preset)
    }

    private func load(preset: CommandPreset) {
        self.command = preset.command

        self.parameters = preset.parameterTuples(limit: Self.parameterLimit)
    }

    private func launchApp() {
        var args: [String: String] = [:]

        for param in self.parameters where !param.name.isEmpty {
            args[param.name] = param.value
        }

        PRAppLaunchKit.defaultAppLaunch().launchApp(withCommand: self.command, urlParameters: args)
    }
}

#Preview {
    GeneralCommandView(scheme: .constant(.pressreader), isInstalled: .constant(true))
        .modelContainer(for: CommandPreset.self, inMemory: true)
}
