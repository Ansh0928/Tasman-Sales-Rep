import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \VisitEntry.date, order: .reverse) private var entries: [VisitEntry]
    @Environment(\.modelContext) private var modelContext
    @State private var isSyncing = false
    @State private var syncErrorMessage: String?

    private var unsyncedCount: Int {
        entries.filter { !$0.isSynced }.count
    }

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Visits Yet",
                        systemImage: "clipboard",
                        description: Text("Your logged visits will appear here.")
                    )
                } else {
                    List {
                        if unsyncedCount > 0 {
                            Section {
                                if let msg = syncErrorMessage {
                                    Text(msg)
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                }
                                Button {
                                    syncErrorMessage = nil
                                    syncAll()
                                } label: {
                                    HStack {
                                        if isSyncing {
                                            ProgressView()
                                                .padding(.trailing, 4)
                                            Text("Syncing...")
                                        } else {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                            Text("Sync \(unsyncedCount) pending visit\(unsyncedCount == 1 ? "" : "s")")
                                        }
                                    }
                                }
                                .disabled(isSyncing)
                            }
                        }

                        Section("Visits") {
                            ForEach(entries) { entry in
                                NavigationLink(destination: EntryDetailView(entry: entry)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(entry.companyName)
                                                .font(.headline)

                                            Text(entry.contactPerson)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)

                                            Text(entry.date, format: .dateTime.day().month().year().hour().minute())
                                                .font(.caption)
                                                .foregroundStyle(.tertiary)
                                        }

                                        Spacer()

                                        Image(systemName: entry.isSynced ? "checkmark.icloud.fill" : "icloud.slash")
                                            .foregroundStyle(entry.isSynced ? .green : .orange)
                                            .font(.caption)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .onDelete(perform: deleteEntries)
                        }
                    }
                }
            }
            .navigationTitle("Visit History")
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
    }

    private func syncAll() {
        syncErrorMessage = nil
        isSyncing = true
        let pendingBeforeSync = unsyncedCount
        Task { @MainActor in
            let (syncedCount, lastError) = await SupabaseManager.syncUnsyncedEntries(entries)
            try? modelContext.save()
            if syncedCount < pendingBeforeSync && pendingBeforeSync > 0 {
                syncErrorMessage = lastError ?? "Some visits could not sync. Check connection and try again."
            }
            isSyncing = false
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: VisitEntry.self, inMemory: true)
}
