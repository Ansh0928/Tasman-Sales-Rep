import Foundation
#if canImport(UIKit)
import UIKit
#endif

struct SupabaseManager {
    static let projectURL = "https://erhrusojfeavsgmkqgmw.supabase.co"
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVyaHJ1c29qZmVhdnNnbWtxZ213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MjY1NDQ2MiwiZXhwIjoyMDg4MjMwNDYyfQ.cNzAy3-yI09hZqxf7TuvtZO-_lOejLRCAaPuxsWYCxM"
    static let tableName = "visit_entries"

    // #region agent log
    private static func _log(_ message: String, _ data: [String: Any] = [:], hypothesisId: String = "A") {
        let ts = Int(Date().timeIntervalSince1970 * 1000)
        var payload: [String: Any] = ["sessionId": "1d3879", "message": message, "timestamp": ts, "hypothesisId": hypothesisId]
        if !data.isEmpty { payload["data"] = data }
        guard let body = try? JSONSerialization.data(withJSONObject: payload),
              let url = URL(string: "http://127.0.0.1:7312/ingest/aea35456-621f-404e-a127-7aa9167cdf1e") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("1d3879", forHTTPHeaderField: "X-Debug-Session-Id")
        req.httpBody = body
        URLSession.shared.dataTask(with: req) { _, _, _ in }.resume()
    }
    // #endregion

    private static var deviceId: String {
        #if canImport(UIKit)
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        #else
        return Host.current().localizedName ?? UUID().uuidString
        #endif
    }

    /// Upload a visit entry to Supabase
    static func uploadEntry(_ entry: VisitEntry) async throws {
        // #region agent log
        _log("uploadEntry called", ["entryId": entry.id.uuidString], hypothesisId: "A")
        // #endregion
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
            // #region agent log
            _log("upload failed", ["statusCode": statusCode, "body": String(responseBody.prefix(200))], hypothesisId: "B")
            // #endregion
            print("Supabase upload failed [\(statusCode)]: \(responseBody)")
            throw NSError(
                domain: "SupabaseError",
                code: statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Upload failed with status \(statusCode): \(responseBody)"]
            )
        }
        // #region agent log
        _log("upload success", ["entryId": entry.id.uuidString], hypothesisId: "C")
        // #endregion
        print("Supabase upload success for \(entry.companyName)")
    }

    /// Upload any unsynced entries; call from MainActor to safely mutate models.
    /// Returns (syncedCount, lastErrorMessage) for UI to show actual failure.
    static func syncUnsyncedEntries(_ entries: [VisitEntry]) async -> (Int, String?) {
        let unsynced = entries.filter { !$0.isSynced }
        // #region agent log
        _log("syncUnsyncedEntries", ["total": entries.count, "unsyncedCount": unsynced.count], hypothesisId: "D")
        // #endregion
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
                // #region agent log
                _log("sync single entry failed", ["entryId": entry.id.uuidString, "error": error.localizedDescription], hypothesisId: "B")
                // #endregion
                print("Failed to sync entry \(entry.id): \(error.localizedDescription)")
            }
        }
        // #region agent log
        _log("syncUnsyncedEntries done", ["syncedCount": syncedCount], hypothesisId: "C")
        // #endregion
        return (syncedCount, lastError)
    }
}
