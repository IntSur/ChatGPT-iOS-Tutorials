//
//  StoreError.swift
//  TaskEngine
//
//  Created by IntSur on 2026/1/9.
//

import Foundation

enum StoreError: Error, Equatable {
    case taskNotFound(id: UUID)
    case taskAlreadyExists(id: UUID)
}
