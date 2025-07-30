//
//  MyLostPetView.swift
//  PawsitiveID
//
//  Created by Bi Nguyen on 7/28/25.
//

import MapKit
import SwiftUI

struct ShelterInfo: Hashable {
    let name: String
    let phone: String
}

struct MyLostPetView: View {
    let onClose: () -> Void
    @Binding var pet: PetData
    @State var isLoading = true
    @State var foundPets: [PetData] = []
    @State var showingPet = false
    @State var deleteConfirmation = false
    @State var openedPet: PetData = petInitiator
    @State private var shelterData: [ShelterInfo] = []

    func removeOpenPet() {
        let index = foundPets.firstIndex(where: { foundPet in
            return foundPet.id == openedPet.id
        })

        if index != nil {
            foundPets.remove(at: index!)
        }
    }

    func viewPet(foundPet: PetData) {
        openedPet = foundPet
        showingPet = true
    }

    func performSearch() {
        shelterData = []
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "Pet Shelter"

        let searchRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: Double(pet.last_seen_lat) ?? 34.0549,
                longitude: Double(pet.last_seen_long) ?? -118.2426
            ),
            latitudinalMeters: 10000,
            longitudinalMeters: 10000
        )

        searchRequest.region = searchRegion

        let search = MKLocalSearch(request: searchRequest)

        search.start { response, error in
            if let error = error {
                logIssue(
                    message: "Got error searching for shelters",
                    data: error
                )
                return
            }

            guard let response = response else {
                logIssue(
                    message: "Got no response searching for shelters",
                    data: error
                )
                return
            }

            for item in response.mapItems {
                if !(item.phoneNumber ?? "").isEmpty
                    && !(item.name ?? "").isEmpty
                {
                    let index = shelterData.firstIndex(where: { pushedItem in
                        return pushedItem.name == item.name
                    })

                    if index == nil {
                        shelterData.append(
                            ShelterInfo(
                                name: (item.name ?? "").trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                ),
                                phone: item.phoneNumber ?? ""
                            )
                        )
                    }
                }

                if shelterData.count >= 5 {
                    break
                }
            }
        }
    }

    func getFoundPets() async throws -> [PetData] {
        isLoading = true

        performSearch()

        let url = URL(
            string:
                "https://unrealpixels.app/api/pawsitive-id/pet.php"
        )!
        let (data, _) = try await URLSession.shared.data(from: url)
        let wrapper = try JSONDecoder().decode(PetDataApi.self, from: data)
        isLoading = false
        return wrapper.data.filter { foundPet in
            return foundPet.post_type == "FOUND"
                && foundPet.animal_type == pet.animal_type
        }
    }

    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: URL(string: pet.images.first ?? genericImage)) {
                    result in
                    result.image?
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: 100,
                            height: 100,
                            alignment: .center
                        )
                        .clipped()
                        .clipShape(.circle)
                }
                VStack(alignment: .leading) {
                    Text(pet.name).fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .padding([.top], 5)
                    Text(getFormattedDate(pet.last_seen_date)).font(.caption)
                        .italic()
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    Spacer()
                    Text(pet.description)
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .truncationMode(.tail)
                    Spacer()
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
            }
            .frame(height: 100)
            .padding([.leading], 20)
            .padding([.vertical], 10)

            List {
                Section(
                    header: Text(
                        shelterData.isEmpty ? "" : "Nearby Animal Shelters"
                    )
                ) {
                    ForEach(shelterData, id: \.self) { data in
                        Button(action: {
                            let url = URL(
                                string: "tel://\(data.phone)"
                            )!
                            UIApplication.shared.open(url)
                        }) {
                            HStack {
                                Text(data.name).foregroundStyle(.black)
                                Spacer()
                                Image(systemName: "phone.fill")
                                    .foregroundStyle(.blue)
                                    .padding([.leading])
                            }
                        }

                    }
                }
                Section(
                    header: Text(foundPets.isEmpty ? "" : "Recently found pets")
                ) {
                    ForEach(foundPets, id: \.self) { foundPet in
                        Button(action: { viewPet(foundPet: foundPet) }) {
                            PetListCardView(pet: .constant(foundPet))
                                .foregroundStyle(.black)
                        }
                    }
                }
                Section {
                    Button(action: {
                        markReunitedPet(
                            id: pet.id,
                            callback: {
                                onClose()
                            }
                        )
                    }) {
                        Text("Pet reunited")
                            .foregroundStyle(.blue)
                    }
                    Button(action: {
                        deleteConfirmation = true
                    }) {
                        Text("Delete")
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Actions")
                }

            }
            .task {
                do {
                    foundPets = try await getFoundPets()
                } catch {
                    foundPets = []
                }
            }
            .refreshable {
                do {
                    foundPets = try await getFoundPets()
                } catch {
                    foundPets = []
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
        .confirmationDialog("Delete?", isPresented: $deleteConfirmation) {
            Button("Yes", role: .destructive) {
                deleteConfirmation = false
                deletePet(
                    id: pet.id,
                    callback: {
                        onClose()
                    }
                )
            }
            Button("No", role: .cancel) {
                deleteConfirmation = false
            }
        } message: {
            Text("Are you sure you want to delete this post?")
        }
    }
}

#Preview {
    @Previewable @State var pet = petInitiator
    MyLostPetView(onClose: {}, pet: $pet)
}
