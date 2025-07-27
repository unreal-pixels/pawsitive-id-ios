//
//  PetDetailsView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/24/25.
//

import SwiftUI

struct PetDetailsView: View {
    @Binding var pet: PetData
    @State private var showingPetLocation = false

    private func foundMode() -> Bool {
        return pet.post_type == "FOUND"
    }

    var body: some View {
        VStack {
            Form {
                if !pet.images.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(pet.images, id: \.self) { photo in
                                AsyncImage(url: URL(string: photo)) { result in
                                    result.image?
                                        .resizable()
                                        .scaledToFill()
                                        .frame(
                                            width: 280,
                                            alignment: .center
                                        )
                                        .clipped()
                                }
                            }
                        }
                    }
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
                    LabeledContent(
                        "Date",
                        value: getFormattedDate(pet.last_seen_date)
                    )
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
                    LabeledContent("Name", value: pet.post_by_name)
                    if pet.post_by_email != nil && pet.post_by_email != "" {
                        Button(action: {
                            let coded =
                                "mailto:\(pet.post_by_email ?? "")?subject=\(foundMode() ? "Found" : "Lost") pet \(pet.name)&body=Question about the posted pet \(pet.name) [\(pet.id)]."

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
                    if pet.post_by_phone != nil && pet.post_by_phone != "" {
                        Button(action: {
                            let url = URL(
                                string: "tel://\(pet.post_by_phone ?? "")"
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
                    Text(foundMode() ? "Found by" : "Owner details")
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

#Preview {
    @Previewable @State var pet = petInitiator
    PetDetailsView(pet: $pet)
}
