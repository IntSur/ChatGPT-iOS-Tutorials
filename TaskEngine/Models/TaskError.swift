//
//  TaskError.swift
//  TaskEngine
//
//  Created by IntSur on 2026/1/7.
//

import Foundation

/// Domain errors for Task Engine (we'll use them from Day 2).
public enum TaskError: Error, Equatable {
    case emptyTitle
    case titleTooLong(max: Int)
    case invalidDueDate
    case taskIsArchived
    case invalidStatusTransition(from: TaskStatus, to: TaskStatus)
}
