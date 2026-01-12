//
//  TaskPersistence.swift
//  TaskEngine_SwiftUI
//
//  Created by IntSur on 2026/1/12.
//

import Foundation

enum TaskPersistenceError: Error {
    case fileNotFound
}

struct TaskPersistence {
    // Documents/TaskEngine/tasks.json
    private static var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("TaskEngine").appendingPathComponent("tasks.json")
    }

    /// Load tasks from disk. If file doesn't exist, return empty list.
    static func load() throws -> [Task] {
        let url = fileURL

        // First launch: no file yet
        guard FileManager.default.fileExists(atPath: url.path) else {
            return []
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Task].self, from: data)
    }

    /// Save tasks to disk (atomic write).
    static func save(_ tasks: [Task]) throws {
        let url = fileURL
        let dir = url.deletingLastPathComponent()

        // Ensure directory exists
        try FileManager.default.createDirectory(
            at: dir,
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(tasks)
        try data.write(to: url, options: [.atomic])
    }
}
