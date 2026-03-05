//
//  ContentView.swift
//  Tasman-Sales-Rep
//
//  Created by Tasman Star Seafood  on 4/3/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NewEntryView()
                .tabItem {
                    Label("New Visit", systemImage: "plus.circle.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
