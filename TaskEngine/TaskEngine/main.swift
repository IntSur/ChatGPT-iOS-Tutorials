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

print("\n=== Day 3 Update & Transition Demo ===")

func runUpdate(_ name: String, _ block: () throws -> Task) {
    do {
        let task = try block()
        print("[\(name)] ✅ success -> status=\(task.status.rawValue), title=\(task.title)")
    } catch {
        print("[\(name)] ❌ failed -> \(error)")
    }
}

do {
    var task = try Task.create(title: "Day 3 base task", tags: [tagWork])
    
    task = try task.updateTitle("new title")
    print("---Task title has been updated: \(task)")
    
    task = try task.updateNote("this is a new title")
    print("---Task note has been updated: \(task)")
    
    task = try task.updateStatus(to: .archived)
    print("---Task status has been updated: \(task)")
    
    runUpdate("---edit archived title") {
        try task.updateTitle("Should fail")
    }
} catch {
    print("Unexpected setup failure:", error)
}
