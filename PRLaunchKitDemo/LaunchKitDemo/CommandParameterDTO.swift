import Foundation

struct CommandParameterDTO: Codable, Hashable {
    public let name: String
    public let value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

extension CommandParameterDTO {
    static func encode(_ parameters: [CommandParameterDTO]) -> String {
        let encoder = JSONEncoder()
        let data = (try? encoder.encode(parameters)) ?? Data()
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    static func decode(_ json: String) -> [CommandParameterDTO] {
        guard let data = json.data(using: .utf8) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([CommandParameterDTO].self, from: data)) ?? []
    }
}
