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
            title: trimmedTitle,
            note: note,
            status: status,
            createdAt: createdAt,
            dueAt: dueAt,
            tags: tags
        )
    }
}

// MARK: - Updates (Controlled Mutation)
public extension Task {
    private func ensureNotArchived() throws {
        guard status != .archived else {
            throw TaskError.taskIsArchived
        }
    }
    
    func updateTitle(_ newTitle: String) throws -> Task {
        try ensureNotArchived()

        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw TaskError.emptyTitle
        }

        let maxLength = 100
        guard trimmed.count <= maxLength else {
            throw TaskError.titleTooLong(max: maxLength)
        }

        var copy = self
        copy.title = trimmed
        return copy
    }
    
    func updateNote(_ newNote: String?) throws -> Task {
        try ensureNotArchived()
        
        var copy = self
        copy.note = newNote?.trimmingCharacters(in: .whitespacesAndNewlines)
        return copy
    }
    
    func updateDueAt(_ newDueAt: Date?) throws -> Task {
        try ensureNotArchived()
        
        if let newDueAt, newDueAt < createdAt {
            throw TaskError.invalidDueDate
        }
        
        var copy = self
        copy.dueAt = newDueAt
        return copy
    }
    
    func addTag(_ newTag: TaskTag) throws -> Task {
        try ensureNotArchived()
        
        var copy = self
        copy.tags.insert(newTag)
        return copy
    }
    
    func removeTag(_ oldTag: TaskTag) throws -> Task {
        try ensureNotArchived()
        
        var copy = self
        copy.tags.remove(oldTag)
        return copy
    }
    
    func updateStatus(to newStatus: TaskStatus) throws -> Task {
        if newStatus == status {
            return self
        }
        
        if status == .archived {
            throw TaskError.invalidStatusTransition(from: status, to: newStatus)
        }
        
        guard status.canTransition(to: newStatus) else {
            throw TaskError.invalidStatusTransition(from: status, to: newStatus)
        }
        
        var copy = self
        copy.status = newStatus
        return copy
    }
}
