//
//  TaskStatus.swift
//  TaskEngine
//
//  Created by IntSur on 2026/1/7.
//

import Foundation

/// Task lifecycle state (pure business state)
public enum TaskStatus: String, Codable, CaseIterable {
    case pending
    case completed
    case archived
}

extension TaskStatus {
    func canTransition(to next: TaskStatus) -> Bool {
        switch (self, next) {
        case (.pending, .archived),
             (.pending, .completed),
             (.completed, .archived),
             (.completed, .pending):
            return true;
        default:
            return false;
        }
    }
}
