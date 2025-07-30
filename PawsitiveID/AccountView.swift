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
            ZStack {
                Image("AccountBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 425, alignment: .center)
                    .clipped()
                VStack {
                    Circle()
                        .foregroundStyle(.gray)
                        .frame(width: 140, height: 140)
                        .overlay {
                            Image(systemName: "pawprint.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .foregroundStyle(.white)
                        }
                        .padding([.bottom], 20)
                    Text("Guest User")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .shadow(radius: 10)
                    Text("Not logged in")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .italic()
                        .foregroundStyle(.white)
                        .shadow(radius: 10)
                }
                .padding([.top], 100)
            }
            .frame(height: 350)
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
            .padding([.top], 30)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AccountView()
}
