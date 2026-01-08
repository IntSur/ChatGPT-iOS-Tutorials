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

// MARK: - COW, ARC
print("\n=== Mini Lab 1: Array COW ===")

func bufferAddress(_ array: [Int]) -> String {
    array.withUnsafeBufferPointer { buf in
        if let base = buf.baseAddress {
            return String(describing: base)
        } else {
            return "nil"
        }
    }
}

var a = Array(0..<5)
var b = a  // 语义：复制；底层：大概率共享同一缓冲区（COW）

print("a buffer:", bufferAddress(a))
print("b buffer:", bufferAddress(b), " (after b = a)")

// 读操作：不会触发复制
print("a[0] =", a[0], " b[0] =", b[0])
print("a buffer:", bufferAddress(a))
print("b buffer:", bufferAddress(b), " (after read)")

// 写操作：如果共享，会触发复制（b 的 buffer 会变）
b[0] = 999
print("After b[0] = 999")
print("a buffer:", bufferAddress(a), " a =", a)
print("b buffer:", bufferAddress(b), " b =", b)

print("\n=== Mini Lab 2: String COW (best-effort) ===")

func stringStorageAddress(_ s: String) -> String {
    // 尽量拿到连续存储的 baseAddress（如果不可用就返回 "n/a"）
    if let addr = s.utf8.withContiguousStorageIfAvailable({ buf -> UnsafePointer<UInt8>? in
        return buf.baseAddress
    }) {
        return String(describing: addr)
    }
    return "n/a"
}

var s1 = String(repeating: "A", count: 20)
var s2 = s1

print("s1 addr:", stringStorageAddress(s1))
print("s2 addr:", stringStorageAddress(s2), " (after s2 = s1)")

// 修改 s2（可能触发 COW）
s2.append("B")

print("After s2.append(\"B\")")
print("s1 addr:", stringStorageAddress(s1), " s1 =", s1)
print("s2 addr:", stringStorageAddress(s2), " s2 =", s2)

print("\n=== Mini Lab 3: ARC (deinit) ===")

final class Box {
    let name: String
    init(_ name: String) {
        self.name = name
        print("init -> \(name)")
    }
    deinit {
        print("deinit -> \(name)")
    }
}

do {
    var x: Box? = Box("X")   // init
    var y = x               // 引用计数 +1（同一个对象）
    print("x and y point to same instance")

    x = nil                 // 引用计数 -1（对象还活着，因为 y 还在）
    print("x = nil")
    print("class still alive")

    y = nil                 // 引用计数归零 -> deinit
    print("y = nil (object should deinit above)")
}

print("after scope")
