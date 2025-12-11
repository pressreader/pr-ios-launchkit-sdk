import Foundation
import SwiftData

@Model
final class CommandPreset {
    // MARK: - Properties
    @Attribute(.unique) var name: String
    var command: String
    var parametersJSON: String
    var updatedAt: Date

    // MARK: - Init
    init(
        name: String,
        command: String,
        parameters: [(name: String, value: String)],
        updatedAt: Date = Date()
    ) {
        self.name = name
        self.command = command
        self.parametersJSON = CommandPreset.encode(parameters: parameters)
        self.updatedAt = updatedAt
    }

    // MARK: - Methods
    func parameterTuples(limit: Int) -> [(name: String, value: String)] {
        let decoded = CommandPreset.decode(parametersJSON: parametersJSON)

        if decoded.count >= limit {
            return Array(decoded.prefix(limit))
        }

        let padding = Array(repeating: ("", ""), count: max(0, limit - decoded.count))

        return decoded + padding
    }

    func update(
        command: String,
        parameters: [(name: String, value: String)],
        timestamp: Date
    ) {
        self.update(command: command,
                    parametersJSON: CommandPreset.encode(parameters: parameters),
                    timestamp: timestamp)
    }

    func update(
        command: String,
        parametersJSON: String,
        timestamp: Date
    ) {
        self.command = command
        self.parametersJSON = parametersJSON
        self.updatedAt = timestamp
    }
    
    private static func encode(parameters: [(name: String, value: String)]) -> String {
        CommandParameterDTO.encode(parameters.map { CommandParameterDTO(name: $0.name, value: $0.value) })
    }

    private static func decode(parametersJSON: String) -> [(name: String, value: String)] {
        CommandParameterDTO.decode(parametersJSON).map { ($0.name, $0.value) }
    }
}
