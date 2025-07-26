//
//  FoundPetView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/17/25.
//

import SwiftUI

struct FoundPetView: View {
    @State var foundPets: [FoundPetData] = []
    @State private var showingPet = false
    @State private var openedPet: FoundPetData = foundPetInitiator
    @State private var showCreate = false

    func performAPICall() async throws -> [FoundPetData] {
        let url = URL(
            string:
                "https://unrealpixels.app/api/pawsitive-id/found_pet.php"
        )!
        let (data, _) = try await URLSession.shared.data(from: url)
        let wrapper = try JSONDecoder().decode(FoundPetDataApi.self, from: data)
        return wrapper.data
    }

    func viewPet(pet: FoundPetData) {
        showingPet = true
        openedPet = pet
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
                Button(action: { viewPet(pet: pet) }) {
                    HStack {
                        AsyncImage(url: URL(string: pet.photo ?? genericImage))
                        { result in
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
            }
            .task {
                do {
                    foundPets = try await performAPICall()
                } catch {
                    foundPets = []
                }
            }
            .refreshable {}
            .sheet(isPresented: $showingPet) {
                FoundPetDetailsView(
                    onClose: {
                        showingPet = false
                    },
                    pet: $openedPet
                )
            }
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Report found pet") {
                    showCreate = true
                }
            }
        }
        .sheet(isPresented: $showCreate) {
            NavigationStack {
                FoundPetFormView(onClose: {pet in
                    foundPets.insert(pet, at: 0)
                    showCreate = false
                })
                .navigationBarTitle(
                    "Report found pet",
                    displayMode: .inline
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showCreate = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    FoundPetView()
}
