//
//  TaskError.swift
//  TaskEngine
//
//  Created by IntSur on 2026/1/7.
//

import Foundation

/// Domain errors for Task Engine (we'll use them from Day 2).
public enum TaskError: Error, Equatable, LocalizedError {
    case emptyTitle
    case titleTooLong(max: Int)
    case invalidDueDate
    case taskIsArchived
    case invalidStatusTransition(from: TaskStatus, to: TaskStatus)
    
    public var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Title can’t be empty."
        case .titleTooLong(let max):
            return "Title can’t exceed \(max) characters."
        case .invalidDueDate:
            return "Due date is invalid."
        case .taskIsArchived:
            return "This task is archived and can’t be edited."
        case .invalidStatusTransition(let from, let to):
            return "Can’t change status from \(from.rawValue) to \(to.rawValue)."
        }
    }
}
