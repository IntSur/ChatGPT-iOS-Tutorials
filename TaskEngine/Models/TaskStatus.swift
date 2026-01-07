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
