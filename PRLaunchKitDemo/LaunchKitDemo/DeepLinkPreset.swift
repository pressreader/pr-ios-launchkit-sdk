//
//  DeepLinkPreset.swift
//  LaunchKitDemo
//
//  Created by Vitali Bounine on 2025-12-11.
//  Copyright © 2025 PressReader. All rights reserved.
//

import Foundation

struct Preset: Decodable {
    // MARK: - Properties
    let name: String
    let command: String
    let parameters: [(name: String, value: String)]

    // We still decode from the same JSON structure where "parameters"
    // is an array of objects: [{"name": "...", "value": "..."}]
    private enum CodingKeys: String, CodingKey {
        case name
        case command
        case parameters
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.command = try container.decode(String.self, forKey: .command)
        let dtos = try container.decode([CommandParameterDTO].self, forKey: .parameters)
        self.parameters = dtos.map { (name: $0.name, value: $0.value) }
    }
}

extension CommandPreset {
    convenience init(from preset: Preset, timestamp: Date) {
        self.init(
            name: preset.name,
            command: preset.command,
            parameters: preset.parameters,
            updatedAt: timestamp
        )
    }
    
    func update(from preset: Preset, timestamp: Date) {
        self.update(command: preset.command, parameters: preset.parameters, timestamp: timestamp)
    }
}
