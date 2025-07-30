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
                        .foregroundStyle(Color("Accent"))
                        .frame(width: 140, height: 140)
                        .overlay {
                            Image(systemName: "pawprint.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .foregroundStyle(Color("TextOnColor"))
                        }
                        .padding([.bottom], 20)
                    Text("Guest User")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color("TextOnColor"))
                        .shadow(radius: 10)
                    Text("Not logged in")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .italic()
                        .foregroundStyle(Color("TextOnColor"))
                        .shadow(radius: 10)
                }
                .padding([.top], 100)
            }
            .frame(height: 350)
            List {
                Section(
                    header: Text("User account").foregroundStyle(
                        Color("TextSmall")
                    )
                ) {
                    Button(action: {}) {
                        Text("Log in")
                            .foregroundStyle(Color("Link"))
                    }
                    Button(action: {}) {
                        Text("Create account")
                            .foregroundStyle(Color("Link"))
                    }
                }
                Section(
                    header: Text("System").foregroundStyle(Color("TextSmall"))
                ) {
                    LabeledContent("Version", value: appVersion ?? "?")
                        .foregroundStyle(Color("Text"))
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
                        .foregroundStyle(Color("Link"))
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
                        .foregroundStyle(Color("Link"))
                    }
                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "lostPetId")
                    }) {
                        Text("Reset app")
                            .foregroundStyle(Color("Danger"))
                    }
                }
            }
            .padding([.top], 30)
        }
        .scrollContentBackground(.hidden)
        .background(Color("Background"))
        .ignoresSafeArea()
    }
}

#Preview {
    AccountView()
}
