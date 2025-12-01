import Foundation
import SwiftData

@Model
final class CommandPreset {
    // MARK: - Nested Types
    private struct ParameterDTO: Codable {
        let name: String
        let value: String
    }

    // MARK: - Properties
    var id: UUID
    var name: String
    var command: String
    var parametersJSON: String
    var updatedAt: Date

    // MARK: - Init
    init(
        id: UUID = UUID(),
        name: String,
        command: String,
        parameters: [(name: String, value: String)],
        updatedAt: Date = Date()
    ) {
        self.id = id
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
        self.command = command
        self.parametersJSON = CommandPreset.encode(parameters: parameters)
        self.updatedAt = timestamp
    }

    private static func encode(parameters: [(name: String, value: String)]) -> String {
        let encoder = JSONEncoder()
        let dto = parameters.map { ParameterDTO(name: $0.name, value: $0.value) }
        let data = (try? encoder.encode(dto)) ?? Data()

        return String(data: data, encoding: .utf8) ?? "[]"
    }

    private static func decode(parametersJSON: String) -> [(name: String, value: String)] {
        guard let data = parametersJSON.data(using: .utf8) else {

            return []
        }

        let decoder = JSONDecoder()
        let dto = (try? decoder.decode([ParameterDTO].self, from: data)) ?? []

        return dto.map { ($0.name, $0.value) }
    }
}
