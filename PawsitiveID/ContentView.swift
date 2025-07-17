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
                Text("Home")
            }
            Tab("Lost a pet", systemImage: "sparkle.magnifyingglass") {
                Text("Lost a pet")
            }
            Tab("Found a pet", systemImage: "pawprint.fill") {
                Text("Found a pet")
            }
            Tab("Account", systemImage: "person.fill") {
                Text("Found a pet")
            }
        }
    }
}

#Preview {
    ContentView()
}
