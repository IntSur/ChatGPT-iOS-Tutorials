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

// MARK: - COW, ARC Lab codes
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


// MARK: - MemoryLayout of struct
///Task 值语义更新的开销主要是 88B 的固定拷贝；
///String/Set 等大数据通过 COW 延迟复制；
///旧值不可达后，其堆存储由 ARC 释放/复用。
print("\n=== Mini Lab: MemoryLayout of Task & fields ===")

func dumpLayout<T>(_ type: T.Type, _ name: String) {
    print("\(name): size=\(MemoryLayout<T>.size), stride=\(MemoryLayout<T>.stride), alignment=\(MemoryLayout<T>.alignment)")
}

// 你自己的类型
dumpLayout(Task.self, "Task")

// Task 常见字段类型
dumpLayout(UUID.self, "UUID")
dumpLayout(Date.self, "Date")
dumpLayout(String.self, "String")
dumpLayout(Set<TaskTag>.self, "Set<TaskTag>")

// 一些基本类型
dumpLayout(Int.self, "Int")
dumpLayout(Double.self, "Double")

print("\n=== Mini Lab: Task size stays constant ===")
let short = try Task.create(title: "Hi")
let long = try Task.create(title: String(repeating: "A", count: 99))

print("Task stride (bytes):", MemoryLayout<Task>.stride)
print("short title count:", short.title.count)
print("long title count:", long.title.count)
print("Task stride is the same regardless of title length.")


print("\n=== Day 4 Transition Matrix ===")

func testTransition(from: TaskStatus, to: TaskStatus) {
    do {
        let task = try Task.create(title: "Matrix", status: from)
        let updated = try task.updateStatus(to: to)

        if updated.status == task.status {
            print("[\(from) -> \(to)] ⚪️ no-op (same state)")
        } else {
            print("[\(from) -> \(to)] ✅ allowed")
        }
    } catch {
        print("[\(from) -> \(to)] ❌ rejected -> \(error)")
    }
}

for from in TaskStatus.allCases {
    for to in TaskStatus.allCases {
        testTransition(from: from, to: to)
    }
}
