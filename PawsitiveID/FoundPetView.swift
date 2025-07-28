//
//  FoundPetView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/17/25.
//

import SwiftUI

enum FilterType {
    case Lost
    case Found
    case All
}

struct FoundPetView: View {
    @State var pets: [PetData] = []
    @State private var showingPet = false
    @State private var openedPet: PetData = petInitiator
    @State private var showCreate = false
    @State private var filterView: FilterType = .Lost

    func performAPICall() async throws -> [PetData] {
        let url = URL(
            string:
                "https://unrealpixels.app/api/pawsitive-id/pet.php"
        )!
        let (data, _) = try await URLSession.shared.data(from: url)
        let wrapper = try JSONDecoder().decode(PetDataApi.self, from: data)
        return wrapper.data
    }

    func viewPet(pet: PetData) {
        showingPet = true
        openedPet = pet
    }

    // would be nice to filter map too.
    // But struggling with filtering binding array, could do it from Map itself?
    func filterPets(_ pet: PetData) -> Bool {
        return filterView == .All
            ? true : pet.post_type == (filterView == .Lost ? "LOST" : "FOUND")
    }

    var body: some View {
        VStack {
            MapPetsView(pets: $pets)
                .containerRelativeFrame(
                    .vertical,
                    count: 100,
                    span: 50,
                    spacing: 0
                )
            Picker("Filter", selection: $filterView) {
                Text("Lost").tag(FilterType.Lost)
                Text("Found").tag(FilterType.Found)
                Text("All").tag(FilterType.All)
            }
            .pickerStyle(.segmented)
            .padding(10)
            List(pets.filter { filterPets($0) }) { pet in
                Button(action: { viewPet(pet: pet) }) {
                    PetListCardView(pet: .constant(pet))
                        .foregroundStyle(.black)
                }
            }
            .task {
                do {
                    pets = try await performAPICall()
                } catch {
                    pets = []
                }
            }
            .refreshable {}
            .sheet(isPresented: $showingPet) {
                NavigationStack {
                    PetDetailsView(pet: $openedPet)
                        .navigationBarTitle(
                            openedPet.name,
                            displayMode: .inline
                        )
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Close") {
                                    showingPet = false
                                }
                            }
                        }
                }
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
                PetFormView(
                    onClose: { pet in
                        pets.insert(pet, at: 0)
                        showCreate = false
                    },
                    type: .constant("FOUND")
                )
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
