//
//  PetReunitedDetailsView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/29/25.
//

import SwiftUI

struct PetReunitedDetailsView: View {
    @Binding var pet: PetData

    var body: some View {
        VStack {
            Form {
                if !pet.reunited_images.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(pet.reunited_images, id: \.self) { photo in
                                AsyncImage(url: URL(string: photo)) {
                                    result in
                                    result.image?
                                        .resizable()
                                        .scaledToFill()
                                        .frame(
                                            width: 280,
                                            height: 250,
                                            alignment: .center
                                        )
                                        .clipped()
                                }
                            }
                        }
                    }
                }
                Section {
                    LabeledContent(
                        "Name",
                        value: pet.name.isEmpty ? "Reunited pet" : pet.name
                    )
                    LabeledContent(
                        "Animal type",
                        value: getPetType(type: pet.animal_type)
                    )
                    if pet.reunited_date != nil {
                        LabeledContent(
                            "Date",
                            value: getFormattedDate(pet.reunited_date ?? "")
                        )
                    }
                    if pet.reunited_description != nil {
                        Text(pet.reunited_description ?? "")
                    }
                } header: {
                    Text("Reunited pet").foregroundStyle(Color("TextSmall"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("Background"))
        }
    }
}

#Preview {
    @Previewable @State var pet = petInitiator
    PetReunitedDetailsView(pet: $pet)
}
