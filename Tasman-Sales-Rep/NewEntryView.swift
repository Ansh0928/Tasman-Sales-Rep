import SwiftUI
import SwiftData
import MapKit
#if canImport(UIKit)
import UIKit
#endif

struct NewEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var locationManager = LocationManager()
    @State private var companyName = ""
    @State private var contactPerson = ""
    @State private var notes = ""
    @State private var showingSaved = false
    @State private var savedCompanyName = ""
    @State private var pinPosition: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            Form {
                Section("Visit Details") {
                    TextField("Company Name", text: $companyName)
                        .textContentType(.organizationName)

                    TextField("Contact Person", text: $contactPerson)
                        .textContentType(.name)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }

                Section("Date & Time") {
                    HStack {
                        Image(systemName: "calendar")
                        Text(Date(), format: .dateTime.day().month().year().hour().minute())
                    }
                    .foregroundStyle(.secondary)
                }

                Section {
                    if let pin = pinPosition {
                        Map(position: $cameraPosition, interactionModes: [.pan, .zoom]) {
                            Marker("Visit Location", coordinate: pin)
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onTapGesture { }

                        Text("Lat: \(pin.latitude, specifier: "%.5f"), Lng: \(pin.longitude, specifier: "%.5f")")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button {
                            locationManager.requestLocation()
                        } label: {
                            Label("Refresh My Location", systemImage: "location.fill")
                        }
                    } else if !locationManager.isAuthorized {
                        Label("Location permission required", systemImage: "location.slash")
                            .foregroundStyle(.red)
                        Button("Grant Permission") {
                            locationManager.requestPermission()
                        }
                    } else if let error = locationManager.locationError {
                        Label("Location could not be determined", systemImage: "location.slash")
                            .foregroundStyle(.red)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button {
                            locationManager.locationError = nil
                            locationManager.requestLocation()
                        } label: {
                            Label("Retry Location", systemImage: "arrow.clockwise")
                        }
                    } else {
                        HStack {
                            ProgressView()
                            Text("Getting location...")
                        }
                        Button {
                            locationManager.requestLocation()
                        } label: {
                            Label("Retry Location", systemImage: "arrow.clockwise")
                        }
                    }
                } header: {
                    Text("Location")
                } footer: {
                    Text("Your GPS pin is captured automatically so admin can verify your visit.")
                }

                Section {
                    Button {
                        saveEntry()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Save Visit", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .disabled(companyName.isEmpty || contactPerson.isEmpty || pinPosition == nil)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New Visit")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        dismissKeyboard()
                    }
                }
            }
            .onAppear {
                locationManager.requestPermission()
            }
            .onChange(of: locationManager.locationObtained) {
                if locationManager.locationObtained {
                    let coord = CLLocationCoordinate2D(
                        latitude: locationManager.latitude,
                        longitude: locationManager.longitude
                    )
                    pinPosition = coord
                    cameraPosition = .region(MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    ))
                }
            }
            .alert("Visit Saved!", isPresented: $showingSaved) {
                Button("OK") { }
            } message: {
                Text("Your visit to \(savedCompanyName) has been logged.")
            }
        }
    }

    private func dismissKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }

    private func saveEntry() {
        guard let pin = pinPosition else { return }
        let entry = VisitEntry(
            companyName: companyName,
            contactPerson: contactPerson,
            latitude: pin.latitude,
            longitude: pin.longitude,
            notes: notes
        )
        modelContext.insert(entry)
        savedCompanyName = companyName
        showingSaved = true

        // Sync to Supabase in background
        Task { @MainActor in
            do {
                try await SupabaseManager.uploadEntry(entry)
                entry.isSynced = true
                try? modelContext.save()
            } catch {
                print("Sync failed, will retry later: \(error.localizedDescription)")
            }
        }

        // Reset form
        companyName = ""
        contactPerson = ""
        notes = ""
    }
}

#Preview {
    NewEntryView()
        .modelContainer(for: VisitEntry.self, inMemory: true)
}
