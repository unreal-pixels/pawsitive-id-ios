//
//  LostPetView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/17/25.
//

import SwiftUI

enum AnimalType {
    case Dog
    case Cat
    case Rabbit
    case Bird
    case Other
}

struct LostPetView: View {
    @State private var petName: String = ""
    @State private var petType: AnimalType = .Cat
    @State private var petDescription: String = ""
    @State private var lastSeen: Date = Date()
    @State private var ownerName: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""

    func isDisabled() -> Bool {
        if !email.isEmpty && !isValidEmail(email) {
            return true
        }

        return petName.isEmpty || petDescription.isEmpty || ownerName.isEmpty
            || (phoneNumber.isEmpty && email.isEmpty)
    }

    var body: some View {

        Spacer()
        HStack {
            Spacer()
            Form {
                Section(header: Text("Pet Information")) {
                    TextField("Name", text: $petName)
                    Picker("Pet type", selection: $petType) {
                        Text("Cat").tag(AnimalType.Cat)
                        Text("Dog").tag(AnimalType.Dog)
                        Text("Rabbit").tag(AnimalType.Rabbit)
                        Text("Bird").tag(AnimalType.Bird)
                        Text("Other").tag(AnimalType.Other)
                    }
                    ZStack(alignment: .leading) {
                        if petDescription.isEmpty {
                            VStack {
                                Text("Pet description...")
                                    .padding(.top, 10)
                                    .opacity(0.2)
                                Spacer()
                            }
                        }

                        VStack {
                            TextEditor(text: $petDescription)
                                .opacity(petDescription.isEmpty ? 0.85 : 1)
                            Spacer()
                        }
                    }
                    DatePicker(
                        "Last seen",
                        selection: $lastSeen,
                        in: ...lastSeen,
                        displayedComponents: .date
                    ).datePickerStyle(.compact)
                }

                Section(header: Text("Owner Information")) {
                    TextField("Name", text: $ownerName)
                    TextField("Email Address", text: $email).textContentType(
                        .emailAddress
                    ).keyboardType(.emailAddress).autocapitalization(.none)
                    TextField("Phone Number", text: $phoneNumber)
                        .textContentType(.telephoneNumber).keyboardType(
                            .phonePad
                        )
                }
                HStack {
                    Spacer()
                    Button("Submit") {

                    }.disabled(isDisabled())
                    Spacer()
                }

            }
            Spacer()

        }
        Spacer()

    }
}

#Preview {
    LostPetView()
}
