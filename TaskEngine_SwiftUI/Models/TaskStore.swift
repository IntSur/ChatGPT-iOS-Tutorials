//
//  TaskStore.swift
//  TaskEngine
//
//  Created by IntSur on 2026/1/9.
//

import Foundation
import Combine

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [Task] = []
    @Published private(set) var lastPersistenceError: String?
    private var didBootstrap = false
    private var pendingSaveTask: _Concurrency.Task<Void, Never>?
    private let repo: TaskRepository

    init(tasks: [Task] = [], repo: TaskRepository = FileTaskRepository()) {
        self.tasks = tasks
        self.repo = repo
    }
    
    /// Loads tasks from disk once per app launch.
    func bootstrapIfNeeded() async {
        guard !didBootstrap else { return }
        didBootstrap = true

        // Load off the main actor, then assign on the main actor (this type is @MainActor).
        let loaded: [Task] = await _Concurrency.Task.detached(priority: .utility) {
            await (try? self.repo.load()) ?? []
        }.value

        self.tasks = loaded
    }
    
    ///In this way, you will force the last modification to be written to the disk before "user switches to the background/system recycling".
    func flushNow() async {
        let snapshot = self.tasks

        pendingSaveTask?.cancel()
        pendingSaveTask = nil

        do {
            try await _Concurrency.Task.detached(priority: .utility) {
                try await self.repo.save(snapshot)
            }.value
            self.lastPersistenceError = nil
        } catch {
            self.lastPersistenceError = String(describing: error)
        }
    }

    /// Debounced background save to avoid writing on every small change.
    private func scheduleSave() {
        let snapshot = self.tasks

        pendingSaveTask?.cancel()
        pendingSaveTask = _Concurrency.Task.detached(priority: .utility) { [snapshot] in
            do {
                try await _Concurrency.Task.sleep(nanoseconds: 300_000_000)
                try await self.repo.save(snapshot)
                await MainActor.run { self.lastPersistenceError = nil }
            } catch {
                await MainActor.run { self.lastPersistenceError = String(describing: error) }
            }
        }
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
        scheduleSave()
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
        scheduleSave()
    }
    
    func update(_ task: Task) throws {
        guard let index = tasks.firstIndex(where: { $0.id == task.id}) else {
            throw StoreError.taskNotFound(id: task.id)
        }
        tasks[index] = task
        scheduleSave()
    }
    
    func tasks(with status: TaskStatus) -> [Task] {
        tasks.filter { $0.status == status }
    }
    
    func tasks(containing tag: TaskTag) -> [Task] {
        tasks.filter { $0.tags.contains(tag) }
    }
    
    func replaceAll(with tasks: [Task]) {
        self.tasks = tasks
        scheduleSave()
    }
    
    /// Simulates an async “remote create” (network/IO) and then writes back to the store safely.
    /// - Note: Heavy work is done off the main actor; store mutation happens on the main actor.
    func addAfterDelay(title: String, delayMilliseconds: UInt64 = 6_000) async throws -> Task {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1) Background work (simulate network/IO). This runs off the main actor.
        let finalTitle = try await _Concurrency.Task.detached(priority: .background) {
            try await _Concurrency.Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
            return trimmed
        }.value

        // 2) Back on MainActor: create domain object + write to store
        let task = try Task.create(title: finalTitle)
        try add(task)
        return task
    }
    
    // MARK: - Apply (store-driven updates)
    private func applyInternal(id: UUID, _ transform: (Task) throws -> Task) throws -> Task {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            throw StoreError.taskNotFound(id: id)
        }

        let current = tasks[index]
        let updated = try transform(current)
        tasks[index] = updated
        scheduleSave()
        return updated
    }

    
    @discardableResult
    func apply(id: UUID, _ transform: (Task) throws -> Task) throws -> Task {
        try applyInternal(id: id, transform)
    }
    
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
