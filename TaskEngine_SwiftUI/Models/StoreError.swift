//
//  StoreError.swift
//  TaskEngine
//
//  Created by IntSur on 2026/1/9.
//

import Foundation

enum StoreError: Error, Equatable, LocalizedError {
    case taskNotFound(id: UUID)
    case taskAlreadyExists(id: UUID)
    
    var errorDescription: String? {
        switch self {
        case .taskNotFound:
            return "Task not found."
        case .taskAlreadyExists:
            return "Task already exists."
        }
    }
}
