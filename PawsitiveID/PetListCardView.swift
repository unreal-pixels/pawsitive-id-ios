//
//  PetListCardView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/28/25.
//

import SwiftUI

struct PetListCardView: View {
    @Binding var pet: PetData
    
    var body: some View {
        HStack {
            AsyncImage(
                url: URL(string: pet.images.first ?? genericImage)
            ) { result in
                result.image?
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: 100,
                        height: 100,
                        alignment: .center
                    )
                    .clipped()
            }
            .frame(width: 100, height: 100, alignment: .center)
            VStack(alignment: .leading, spacing: 0) {
                Text(pet.name)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("Text"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                Text("\(pet.post_type == "FOUND" ? "Found" : "Lost" ) on \(getFormattedDate(pet.last_seen_date))")
                    .font(.caption)
                    .foregroundStyle(Color("TextSmall"))
                    .italic()
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding([.bottom], 10)
                Text(pet.description)
                    .font(.callout)
                    .foregroundStyle(Color("TextSmall"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    @Previewable @State var pet = petInitiator
    PetListCardView(pet: $pet)
}
