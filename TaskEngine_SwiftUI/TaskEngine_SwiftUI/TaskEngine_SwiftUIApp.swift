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
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environmentObject(store)
                .task { await store.bootstrapIfNeeded() }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .background {
                        _Concurrency.Task { await store.flushNow() }
                    }
                }
        }
    }
}
