import Foundation
import SwiftData

@Model
final class VisitEntry {
    var id: UUID
    var date: Date
    var companyName: String
    var contactPerson: String
    var latitude: Double
    var longitude: Double
    var notes: String
    var isSynced: Bool

    init(
        companyName: String,
        contactPerson: String,
        latitude: Double,
        longitude: Double,
        notes: String = ""
    ) {
        self.id = UUID()
        self.date = Date()
        self.companyName = companyName
        self.contactPerson = contactPerson
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
        self.isSynced = false
    }
}
