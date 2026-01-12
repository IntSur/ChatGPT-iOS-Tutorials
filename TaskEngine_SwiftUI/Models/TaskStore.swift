//
//  TaskStore.swift
//  TaskEngine
//
//  Created by IntSur on 2026/1/9.
//

import Foundation
import Combine

final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [Task] = []
    
    init(tasks: [Task] = []) {
        self.tasks = tasks
    }
}

extension TaskStore {
    var sortedTasks: [Task] {
        tasks.sorted { $0.createdAt < $1.createdAt }
    }
    
    func add(_ task: Task) throws {
        guard tasks.contains(where: { $0.id == task.id }) == false else {
            throw StoreError.taskAlreadyExists(id: task.id)
        }
        
        tasks.append(task)
    }
    
    func get(id: UUID) -> Task? {
        tasks.first { $0.id == id }
    }
    
    func require(id: UUID) throws -> Task {
        guard let task = get(id: id) else {
            throw StoreError.taskNotFound(id: id)
        }
        return task
    }
    
    func remove(id: UUID) throws {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            throw StoreError.taskNotFound(id: id)
        }
        tasks.remove(at: index)
    }
    
    func update(_ task: Task) throws {
        guard let index = tasks.firstIndex(where: { $0.id == task.id}) else {
            throw StoreError.taskNotFound(id: task.id)
        }
        tasks[index] = task
    }
    
    func tasks(with status: TaskStatus) -> [Task] {
        tasks.filter { $0.status == status }
    }
    
    func tasks(containing tag: TaskTag) -> [Task] {
        tasks.filter { $0.tags.contains(tag) }
    }
    
    // MARK: - Apply (store-driven updates)

    private func applyInternal(id: UUID, _ transform: (Task) throws -> Task) throws -> Task {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            throw StoreError.taskNotFound(id: id)
        }

        let current = tasks[index]
        let updated = try transform(current)
        tasks[index] = updated
        return updated
    }

    @MainActor
    @discardableResult
    func apply(id: UUID, _ transform: (Task) throws -> Task) throws -> Task {
        try applyInternal(id: id, transform)
    }
    
    @MainActor
    @discardableResult
    func apply(id: UUID, _ transforms: ((Task) throws -> Task)...) throws -> Task {
        try applyInternal(id: id) { current in
            var task = current
            for transform in transforms {
                task = try transform(task)
            }
            return task
        }
    }
}
