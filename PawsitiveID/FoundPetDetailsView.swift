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

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        LabeledContent("Name", value: pet.name)
                        LabeledContent("Description", value: pet.description)
                        LabeledContent(
                            "Animal type",
                            value: getPetType(type: pet.animal_type)
                        )
                    } header: {
                        Text("Pet info")
                    }
                    Section {
                        LabeledContent("Date", value: pet.last_seen_date)
                        Button(action: {
                            // TODO: open Google Map view to see where
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
                        if pet.found_by_email != nil {
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
                        if pet.found_by_phone != nil {
                            Button(action: {
                                let url = URL(string: "tel://\(pet.found_by_phone ?? "")")!
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
        }
    }
}

#Preview {
    @Previewable @State var pet = foundPetInitiator
    FoundPetDetailsView(onClose: {}, pet: $pet)
}
