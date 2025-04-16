import SwiftUI
import PRAppLaunchKit

struct GeneralCommandView: View {

    @Binding var scheme: Scheme
    @State private var command = ""
    @State private var parameters: [(name: String, value: String)] = Array(repeating: ("", ""), count: 4)
    @Binding var isInstalled: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section() {
                Picker("scheme", selection: $scheme) {
                    ForEach(Scheme.allCases, id: \.self) { Text($0.rawValue) }
                }
            }

            Section("Deep-Link Command") {
                TextField("Enter command", text: $command)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            
            Section("Parameters") {
                ForEach(0..<4) { index in
                    HStack {
                        TextField("Name", text: $parameters[index].name)
                            .containerRelativeFrame(.horizontal, count: 100, span: 30, spacing: 0)
                            .minimumScaleFactor(0.5)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        Divider()
                        
                        TextField("Value", text: $parameters[index].value, axis: .vertical)
                            .lineLimit(1...3)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                }
            }
            
            Section {
                HStack {
                    Spacer()
                    Button(isInstalled ? "Open" : "Install") {
                        launchApp()
                    }
                    .disabled(command.isEmpty)
                    Spacer()
                }
            }
        }
        .navigationTitle("Generic Command")
    }
    
    private func launchApp() {
        var args: [String: String] = [:]
        
        for param in parameters where !param.name.isEmpty {
            args[param.name] = param.value
        }
        
        PRAppLaunchKit.defaultAppLaunch().launchApp(withCommand: command, urlParameters: args)
    }
}

#Preview {
    GeneralCommandView(scheme: .constant(.pressreader), isInstalled: .constant(true))
}
