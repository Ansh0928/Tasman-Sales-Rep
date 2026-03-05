import SwiftUI
import MapKit

struct EntryDetailView: View {
    let entry: VisitEntry

    var body: some View {
        List {
            Section("Visit Details") {
                LabeledContent("Company", value: entry.companyName)
                LabeledContent("Contact", value: entry.contactPerson)
                LabeledContent("Date") {
                    Text(entry.date, format: .dateTime.day().month().year().hour().minute())
                }
            }

            if !entry.notes.isEmpty {
                Section("Notes") {
                    Text(entry.notes)
                }
            }

            Section("Location") {
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: entry.latitude,
                        longitude: entry.longitude
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                ))) {
                    Marker(entry.companyName, coordinate: CLLocationCoordinate2D(
                        latitude: entry.latitude,
                        longitude: entry.longitude
                    ))
                }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Text("Lat: \(entry.latitude, specifier: "%.5f"), Lng: \(entry.longitude, specifier: "%.5f")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(entry.companyName)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
