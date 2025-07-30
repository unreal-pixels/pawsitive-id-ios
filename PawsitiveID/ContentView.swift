//
//  ContentView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/16/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            Tab("Lost pet", systemImage: "sparkle.magnifyingglass") {
                LostPetView()
            }
            Tab("Pets", systemImage: "pawprint.fill") {
                NavigationView {
                    FoundPetView()
                        .navigationTitle("Pets")
                }
            }
            Tab("Account", systemImage: "person.fill") {
                AccountView()
            }
        }
    }
}

#Preview {
    ContentView()
}
