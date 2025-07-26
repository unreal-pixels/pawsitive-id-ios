//
//  FoundPetDetailsView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/24/25.
//

import SwiftUI

struct FoundPetDetailsView: View {
    let onClose: () -> Void
    @Binding var pet: FoundPetData
    @State private var showingPetLocation = false

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    AsyncImage(url: URL(string: pet.photo ?? genericImage)) {
                        result in
                        result.image?
                            .resizable()
                            .scaledToFill()
                            .frame(
                                maxWidth: .infinity,
                                alignment: .center
                            )
                            .clipped()
                    }
                    Section {
                        LabeledContent("Name", value: pet.name)
                        LabeledContent("Description", value: pet.description)
                        LabeledContent(
                            "Animal type",
                            value: getPetType(type: pet.animal_type)
                        )
                    } header: {
                        Text("Animal info")
                    }
                    Section {
                        LabeledContent("Date", value: getFormattedDate(pet.last_seen_date))
                        Button(action: {
                            showingPetLocation = true
                        }) {
                            HStack {
                                Text("View location")
                                Spacer()
                                Image(systemName: "map.fill")
                            }
                        }
                    } header: {
                        Text("Last seen")
                    }
                    Section {
                        LabeledContent("Name", value: pet.found_by_name)
                        if pet.found_by_email != nil && pet.found_by_email != "" {
                            Button(action: {
                                let coded =
                                    "mailto:\(pet.found_by_email ?? "")?subject=Found pet \(pet.name)&body=Question about the posted pet \(pet.name) [\(pet.id)]."

                                if let escaped = coded.addingPercentEncoding(
                                    withAllowedCharacters: .urlQueryAllowed
                                ),
                                    let emailURL = URL(string: escaped),
                                    UIApplication.shared.canOpenURL(emailURL)
                                {
                                    UIApplication.shared.open(emailURL)
                                }
                            }) {
                                HStack {
                                    Text("Email about pet")
                                    Spacer()
                                    Image(systemName: "envelope.fill")
                                }
                            }
                        }
                        if pet.found_by_phone != nil && pet.found_by_phone != "" {
                            Button(action: {
                                let url = URL(
                                    string: "tel://\(pet.found_by_phone ?? "")"
                                )!
                                UIApplication.shared.open(url)
                            }) {
                                HStack {
                                    Text("Call about pet")
                                    Spacer()
                                    Image(systemName: "phone.circle.fill")
                                }
                            }
                        }
                    } header: {
                        Text("Found by")
                    }
                }
            }
            .navigationBarTitle(pet.name, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        onClose()
                    }
                }
            }
            .sheet(isPresented: $showingPetLocation) {
                NavigationStack {
                    VStack {
                        MapViewLocation(
                            type: $pet.animal_type,
                            lat: $pet.last_seen_lat,
                            long: $pet.last_seen_long,
                        )
                    }
                    .navigationBarTitle(
                        "\(pet.name) last seen location",
                        displayMode: .inline
                    )
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Close") {
                                showingPetLocation = false
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var pet = foundPetInitiator
    FoundPetDetailsView(onClose: {}, pet: $pet)
}
