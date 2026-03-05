//
//  Tasman_Sales_RepApp.swift
//  Tasman-Sales-Rep
//
//  Created by Tasman Star Seafood  on 4/3/2026.
//

import SwiftUI
import SwiftData

@main
struct Tasman_Sales_RepApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: VisitEntry.self)
    }
}
