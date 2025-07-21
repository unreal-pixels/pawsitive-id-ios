//
//  FoundPetView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/17/25.
//

import SwiftUI

struct FoundPetView: View {
    @State var foundPets: [FoundPetData] = []

    func performAPICall() async throws -> [FoundPetData] {
        let url = URL(
            string:
                "https://unrealpixels.app/api/pawsitive-id/found_pet.php"
        )!
        let (data, _) = try await URLSession.shared.data(from: url)
        let wrapper = try JSONDecoder().decode(FoundPetDataApi.self, from: data)
        return wrapper.data
    }

    var body: some View {
        VStack {
            GoogleMaps(pets: $foundPets)
                .containerRelativeFrame(
                    .vertical,
                    count: 100,
                    span: 50,
                    spacing: 0
                )
            List(foundPets) { pet in
                HStack {
                    AsyncImage(
                        url: URL(
                            string:
                                "https://hips.hearstapps.com/hmg-prod/images/dog-puppy-on-garden-royalty-free-image-1586966191.jpg"
                        )
                    ) { result in
                        result.image?
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100, alignment: .center)
                            .clipped()
                    }
                    .frame(width: 100, height: 100, alignment: .center)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(pet.name)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .padding([.bottom], 5)
                        Text(pet.description)
                            .font(.caption)
                            .italic()
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .task {
                do {
                    foundPets = try await performAPICall()
                } catch {
                    foundPets = []
                }
            }

        }
    }
}

#Preview {
    FoundPetView()
}
