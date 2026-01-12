//
//  TaskEngine_SwiftUIApp.swift
//  TaskEngine_SwiftUI
//
//  Created by IntSur on 2026/1/10.
//

import SwiftUI

@main
struct TaskEngine_SwiftUIApp: App {
    @StateObject private var store = TaskStore()
    
    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environmentObject(store)
        }
    }
}
