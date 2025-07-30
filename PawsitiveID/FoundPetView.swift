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
    @State var isLoading = true
    @State var pets: [PetData] = []
    @State private var showingPet = false
    @State private var openedPet: PetData = petInitiator
    @State private var showCreate = false
    @State private var filterView: FilterType = .All
    @State private var errorHappened = false

    func removeOpenPet() {
        let index = pets.firstIndex(where: { pet in
            return pet.id == openedPet.id
        })

        if index != nil {
            pets.remove(at: index!)
        }
    }

    func performAPICall() async throws -> [PetData] {
        errorHappened = false
        isLoading = true
        let url = URL(
            string:
                "https://unrealpixels.app/api/pawsitive-id/pet.php"
        )!
        let (data, _) = try await URLSession.shared.data(from: url)
        let wrapper = try JSONDecoder().decode(PetDataApi.self, from: data)

        isLoading = false
        return wrapper.data
    }

    func viewPet(pet: PetData) {
        openedPet = pet
        showingPet = true
    }

    // would be nice to filter map too.
    // But struggling with filtering binding array, could do it from Map itself?
    func filterPets(_ pet: PetData) -> Bool {
        return filterView == .All
            ? true : pet.post_type == (filterView == .Lost ? "LOST" : "FOUND")
    }

    var body: some View {
        VStack {
            MapPetsView(pets: $pets, filter: $filterView)
                .containerRelativeFrame(
                    .vertical,
                    count: 100,
                    span: 50,
                    spacing: 0
                )
            Picker("Filter", selection: $filterView) {
                Text("All").tag(FilterType.All)
                Text("Lost").tag(FilterType.Lost)
                Text("Found").tag(FilterType.Found)
            }
            .pickerStyle(.segmented)
            .padding(10)
            List(pets.filter { filterPets($0) }) { pet in
                Button(action: { viewPet(pet: pet) }) {
                    PetListCardView(pet: .constant(pet))
                        .foregroundStyle(.black)
                }
            }
            .overlay(
                Group {
                    if pets.filter({ filterPets($0) }).isEmpty {
                        if (errorHappened) {
                            Text("An error occurred")
                                .italic()
                        } else {
                            Text(
                                "No\(filterView == .All ? "" : (filterView == .Lost ? " lost" : " found")) pets have been reported."
                            )
                            .italic()
                        }
                    }
                }
            )
            .task {
                do {
                    pets = try await performAPICall()
                    errorHappened = false
                } catch {
                    isLoading = false
                    errorHappened = true
                    pets = []
                }
            }
            .refreshable {
                do {
                    pets = try await performAPICall()
                    errorHappened = false
                } catch {
                    isLoading = false
                    errorHappened = true
                    pets = []
                }
            }
            .overlay(alignment: .topLeading) {
                if isLoading {
                    ZStack {
                        Color.white
                            .ignoresSafeArea()
                        LoadingView()
                    }
                    .zIndex(2)
                }
            }
            .sheet(isPresented: $showingPet) { [openedPet] in
                NavigationStack {
                    PetDetailsView(
                        onClose: { reason in
                            if reason == "DELETE" {
                                removeOpenPet()
                            }

                            showingPet = false
                        },
                        pet: $openedPet
                    )
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
