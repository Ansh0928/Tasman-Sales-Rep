import Foundation
#if canImport(UIKit)
import UIKit
#endif

struct SupabaseManager {
    static let projectURL = SupabaseConfig.projectURL
    static let anonKey = SupabaseConfig.anonKey
    static let tableName = "visit_entries"

    private static var deviceId: String {
        #if canImport(UIKit)
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        #else
        return Host.current().localizedName ?? UUID().uuidString
        #endif
    }

    /// Upload a visit entry to Supabase
    static func uploadEntry(_ entry: VisitEntry) async throws {
        let urlString = "\(projectURL)/rest/v1/\(tableName)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let body: [String: Any] = [
            "id": entry.id.uuidString,
            "company_name": entry.companyName,
            "contact_person": entry.contactPerson,
            "latitude": entry.latitude,
            "longitude": entry.longitude,
            "notes": entry.notes,
            "visit_date": formatter.string(from: entry.date),
            "device_id": deviceId
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let responseBody = String(data: data, encoding: .utf8) ?? "no body"
            print("Supabase upload failed [\(statusCode)]: \(responseBody)")
            throw NSError(
                domain: "SupabaseError",
                code: statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Upload failed with status \(statusCode): \(responseBody)"]
            )
        }
        print("Supabase upload success for \(entry.companyName)")
    }

    /// Upload any unsynced entries; call from MainActor to safely mutate models.
    /// Returns (syncedCount, lastErrorMessage) for UI to show actual failure.
    static func syncUnsyncedEntries(_ entries: [VisitEntry]) async -> (Int, String?) {
        let unsynced = entries.filter { !$0.isSynced }
        var syncedCount = 0
        var lastError: String?
        for entry in unsynced {
            do {
                try await uploadEntry(entry)
                await MainActor.run {
                    entry.isSynced = true
                }
                syncedCount += 1
            } catch {
                lastError = error.localizedDescription
                print("Failed to sync entry \(entry.id): \(error.localizedDescription)")
            }
        }
        return (syncedCount, lastError)
    }
}
