//
//  ContentView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/16/25.
//

import SwiftUI

enum TabViews {
    case Home
    case LostPet
    case Pets
    case Account
}

struct ContentView: View {
    @State private var tabSelection: TabViews = .Home

    var body: some View {
        TabView(selection: $tabSelection) {
            HomeView(changeTab: { tab in
                tabSelection = tab
            })
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(TabViews.Home)
            LostPetView()
                .tabItem {
                    Label("Lost pet", systemImage: "sparkle.magnifyingglass")
                }
                .tag(TabViews.LostPet)
            NavigationView {
                FoundPetView()
                    .navigationTitle("Pets")
            }
            .tabItem {
                Label("Pets", systemImage: "pawprint.fill")
            }
            .tag(TabViews.Pets)
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
                .tag(TabViews.Account)
        }
    }
}

#Preview {
    ContentView()
}
