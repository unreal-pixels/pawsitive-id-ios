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
                .containerRelativeFrame(.vertical, count: 100, span: 50, spacing: 0)
            NavigationView {
                List(foundPets) { pet in
                    HStack {
                        Text(pet.name)
                    }
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
}

#Preview {
    FoundPetView()
}
