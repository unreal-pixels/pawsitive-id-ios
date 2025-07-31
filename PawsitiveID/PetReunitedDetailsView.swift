//
//  PetReunitedDetailsView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/29/25.
//

import SwiftUI

struct PetReunitedDetailsView: View {
    @Binding var pet: PetData
    @State var photoIndex = 0

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                AsyncImage(
                    url: URL(
                        string: pet.reunited_images.count > photoIndex
                            ? pet.reunited_images[photoIndex] : ""
                    )
                ) { result in
                    result.image?
                        .resizable()
                        .scaledToFill()
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .top
                        )
                        .containerRelativeFrame(
                            .vertical,
                            count: 100,
                            span: 40,
                            spacing: 0
                        )
                        .clipped()
                }.gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onEnded({ value in

                            if value.translation.width < 0 {
                                photoIndex += 1
                                if photoIndex > pet.reunited_images.count - 1 {
                                    photoIndex = 0
                                }
                            }

                            if value.translation.width > 0 {
                                photoIndex -= 1
                                if photoIndex < 0 {
                                    photoIndex =
                                        pet.reunited_images.count == 0
                                        ? 0 : pet.reunited_images.count - 1
                                }

                            }
                        })
                )
                HStack {
                    HStack {
                        ForEach(0...pet.reunited_images.count - 1, id: \.self) {
                            count in
                            let isActive = count == photoIndex
                            Circle()
                                .frame(
                                    width: isActive ? 10 : 8,
                                    height: isActive ? 10 : 8
                                )
                                .padding([.horizontal], 2)
                                .foregroundColor(
                                    isActive
                                        ? Color("TextSmall")
                                        : Color("TextSmall").opacity(0.8)
                                )
                        }
                    }.padding([.vertical], 3)
                        .padding([.horizontal], 6).background(
                            Color("Background")
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }.padding([.bottom], 10)
            }
            VStack(alignment: .leading, spacing: 0) {
                Image("Quote")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, alignment: .center)
                    .clipped()
                    .padding([.leading], 10)
                ScrollView(.vertical) {
                    Text(pet.reunited_description ?? "")
                        .font(.body)
                        .foregroundStyle(Color("Text"))
                }
                .padding(20)
                .padding([.leading], 40)
                .containerRelativeFrame(
                    .vertical,
                    count: 100,
                    span: 50,
                    spacing: 0
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
        }
        .background(Color("Background"))
    }
}

#Preview {
    @Previewable @State var pet = petInitiator
    PetReunitedDetailsView(pet: $pet)
}
