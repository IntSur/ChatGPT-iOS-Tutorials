//
//  TaskRepository.swift
//  TaskEngine_SwiftUI
//
//  Created by IntSur on 2026/1/12.
//

import Foundation

protocol TaskRepository {
    func load() throws -> [Task]
    func save(_ tasks: [Task]) throws
}

struct FileTaskRepository: TaskRepository {
    func load() throws -> [Task] { try TaskPersistence.load() }
    func save(_ tasks: [Task]) throws { try TaskPersistence.save(tasks) }
}
