//
//  AccountView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/17/25.
//

import SwiftUI

struct AccountView: View {
    var body: some View {
        let appVersion =
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 140)
                .clipShape(Circle())
                .overlay(Circle().stroke(.black, lineWidth: 2))
                .foregroundStyle(.gray)
                .padding([.bottom], 20)
            Text("Guest User")
                .font(.title)
                .fontWeight(.bold)
            Text("Not logged in")
                .font(.subheadline)
                .italic()
            List {
                Section(header: Text("User account")) {
                    Button(action: {}) {
                        Text("Log in")
                            .foregroundStyle(.blue)
                    }
                    Button(action: {}) {
                        Text("Create account")
                            .foregroundStyle(.blue)
                    }
                }
                Section(header: Text("System")) {
                    LabeledContent("Version", value: appVersion ?? "?")
                    Button(action: {
                        let url = URL(
                            string:
                                "https://www.unrealpixels.com/privacy-policy.txt"
                        )
                        UIApplication.shared.open(url!)
                    }) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "safari.fill")
                        }
                        .foregroundStyle(.blue)
                    }
                    Button(action: {
                        let url = URL(string: "https://www.pawsitiveid.com")
                        UIApplication.shared.open(url!)
                    }) {
                        HStack {
                            Text("Website")
                            Spacer()
                            Image(systemName: "safari.fill")
                        }
                        .foregroundStyle(.blue)
                    }
                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "lostPetId")
                    }) {
                        Text("Reset app")
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding([.vertical], 20)
            Spacer()
        }
        .padding([.top], 40)
    }
}

#Preview {
    AccountView()
}
