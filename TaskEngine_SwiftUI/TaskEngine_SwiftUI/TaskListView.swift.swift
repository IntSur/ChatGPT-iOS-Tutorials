//
//  TaskListView.swift.swift
//  TaskEngine_SwiftUI
//
//  Created by IntSur on 2026/1/10.
//

import SwiftUI

enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case pending = "Pending"
    case completed = "Completed"
    case archived = "Archived"

    var id: String { rawValue }
}

struct TaskListView: View {
    @EnvironmentObject var store: TaskStore

    @State private var newTitle: String = ""
    @State private var filter: TaskFilter = .all
    @State private var errorMessage: String?

    private var filteredTasks: [Task] {
        switch filter {
        case .all: return store.tasks
        case .pending: return store.tasks(with: .pending)
        case .completed: return store.tasks(with: .completed)
        case .archived: return store.tasks(with: .archived)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Add bar
                HStack {
                    TextField("New task title", text: $newTitle)
                        .textFieldStyle(.roundedBorder)

                    Button("Add") { addTask() }
                        .buttonStyle(.borderedProminent)
                        .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)

                // Filter
                Picker("Filter", selection: $filter) {
                    ForEach(TaskFilter.allCases) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // List
                List {
                    ForEach(filteredTasks, id: \.id) { task in
                        TaskRow(
                            task: task,
                            onToggle: { toggleStatus(task) },
                            onArchive: { archive(task) }
                        )
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Task Engine")
            .alert("Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func addTask() {
        do {
            let title = newTitle
            let task = try Task.create(title: title)
            try store.add(task)  // 你 Day 5A+ 里 add 是 throws
            newTitle = ""
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Something went wrong."
        }
    }

    private func toggleStatus(_ task: Task) {
        do {
            let next: TaskStatus = (task.status == .pending) ? .completed : .pending
            _ = try store.apply(id: task.id) { try $0.updateStatus(to: next) }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Something went wrong."
        }
    }

    private func archive(_ task: Task) {
        do {
            _ = try store.apply(id: task.id) { try $0.updateStatus(to: .archived) }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Something went wrong."
        }
    }

    private func delete(at offsets: IndexSet) {
        // 注意：filteredTasks 可能不是 store.tasks 原顺序，所以这里按 id 删除最安全
        let ids = offsets.map { filteredTasks[$0].id }
        do {
            for id in ids {
                try store.remove(id: id)
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Something went wrong."
        }
    }
}

private struct TaskRow: View {
    let task: Task
    let onToggle: () -> Void
    let onArchive: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)

                Text(task.status.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                onToggle()
            } label: {
                Image(systemName: task.status == .completed ? "arrow.uturn.left" : "checkmark")
            }
            .buttonStyle(.borderless)

            Button(role: .destructive) {
                onArchive()
            } label: {
                Image(systemName: "archivebox")
            }
            .buttonStyle(.borderless)
            .disabled(task.status == .archived)
        }
    }
}
