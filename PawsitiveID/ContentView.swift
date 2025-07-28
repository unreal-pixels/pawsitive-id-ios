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
                NavigationView {
                    HomeView()
                        .navigationTitle("Home")
                }
            }
            Tab("Lost pet", systemImage: "sparkle.magnifyingglass") {
                NavigationView {
                    LostPetView()
                        .navigationTitle("Lost pet")
                }
            }
            Tab("Pets", systemImage: "pawprint.fill") {
                NavigationView {
                    FoundPetView()
                        .navigationTitle("Pets")
                }
            }
            Tab("Account", systemImage: "person.fill") {
                NavigationView {
                    AccountView()
                        .navigationTitle("Account")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
