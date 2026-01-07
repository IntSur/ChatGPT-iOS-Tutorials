//
//  Task.swift
//  TaskEngine
//
//  Created by IntSur on 2026/1/7.
//

import Foundation

public struct Task: Identifiable, Hashable, Codable {
    public let id: UUID
    
    // Content
    public var title: String
    public var note: String?
    
    // State
    public var status: TaskStatus
    
    // Time
    public var createdAt: Date
    public var dueAt: Date?
    
    // Organization
    public var tags: Set<TaskTag>
    
    private init(id: UUID = UUID(), title: String, note: String? = nil, status: TaskStatus = .pending, createdAt: Date = Date(), dueAt: Date? = nil, tags: Set<TaskTag> = []) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.note = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.status = status
        self.createdAt = createdAt
        self.dueAt = dueAt
        self.tags = tags
    }
}

// MARK: - Convenience
public extension Task {
    var isOverdue: Bool {
        guard status == .pending, let dueAt else { return false }
        return dueAt < Date()
    }
}

// MARK: - Factory Method
public extension Task {
    static func create(
        title: String,
        note: String? = nil,
        status: TaskStatus = .pending,
        createdAt: Date = Date(),
        dueAt: Date? = nil,
        tags: Set<TaskTag> = []
    ) throws -> Task {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            throw TaskError.emptyTitle
        }
        
        let maxLength = 100
        
        if trimmedTitle.count > maxLength {
            throw TaskError.titleTooLong(max: maxLength)
        }
        
        if let dueAt, dueAt < createdAt {
            throw TaskError.invalidDueDate
        }
        
        return Task(
            title: title,
            note: note,
            status: status,
            createdAt: createdAt,
            dueAt: dueAt,
            tags: tags
        )
    }
}
