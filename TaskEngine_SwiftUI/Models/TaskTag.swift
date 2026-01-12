//
//  TaskTag.swift
//  TaskEngine
//
//  Created by IntSur on 2026/1/7.
//

import Foundation

/// Lightweight tag model.
/// Value type, identifiable, codable for persistence later.
public struct TaskTag: Identifiable, Hashable, Codable {
    public let id: UUID
    public var name: String
    
    public init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
