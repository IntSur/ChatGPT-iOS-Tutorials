//
//  main.swift
//  TaskEngine
//
//  Created by IntSur on 2026/1/7.
//

import Foundation

print("TaskEngine booted 🚀")

let tagWork = TaskTag(name: "Work")
let tagHealth = TaskTag(name: "Health")

print("\n=== Day 2 Error Handling Demo (do/catch) ===")

func runCase(_ name: String, _ block: () throws -> Task) {
    do {
        let task = try block()
        print("[\(name)] ✅ success -> \(task.title)")
    } catch {
        print("[\(name)] ❌ failed -> \(error)")
    }
}

// 1) Empty title
runCase("emptyTitle") {
    try Task.create(title: "   ")
}

// 2) Title too long
runCase("titleTooLong") {
    try Task.create(title: String(repeating: "A", count: 101))
}

// 3) Invalid due date (dueAt < createdAt)
runCase("invalidDueDate") {
    let createdAt = Date()
    let dueAt = createdAt.addingTimeInterval(-60)
    return try Task.create(title: "Bad due date", createdAt: createdAt, dueAt: dueAt)
}

