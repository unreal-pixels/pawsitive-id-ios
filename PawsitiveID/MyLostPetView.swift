//
//  MyLostPetView.swift
//  PawsitiveID
//
//  Created by Bi Nguyen on 7/28/25.
//

import SwiftUI

struct ShelterInfo: Hashable {
    let name: String
    let phone: String
}

struct MyLostPetView: View {
    @Binding var pet: PetData
    @State var foundPets: [PetData] = []
    @State var showingPet = false
    @State var openedPet: PetData = petInitiator
    private let shelterData: [ShelterInfo] = [
        ShelterInfo(name: "Pets in Need", phone: "6504965971"),
        ShelterInfo(
            name: "Friends of The Alameda Animal Shelter",
            phone: "5103378565"
        ),
        ShelterInfo(
            name: "County of Santa Clara Animal Services",
            phone: "4086863900"
        ),
        ShelterInfo(
            name: "East County Animal Shelter",
            phone: "9258037040"
        ),
        ShelterInfo(name: "Hayward Animal Shelter", phone: "5102937200"),
    ]
    
    func viewPet(foundPet: PetData) {
        openedPet = foundPet
        showingPet = true
    }

    func getFoundPets() async throws -> [PetData] {
        let url = URL(
            string:
                "https://unrealpixels.app/api/pawsitive-id/pet.php"
        )!
        let (data, _) = try await URLSession.shared.data(from: url)
        let wrapper = try JSONDecoder().decode(PetDataApi.self, from: data)
        return wrapper.data.filter { foundPet in return foundPet.post_type == "FOUND" && foundPet.animal_type == pet.animal_type }
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
                Section(header: Text("Nearby Animal Shelters")) {
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
                                Image(systemName: "phone.fill").foregroundStyle(
                                    .blue
                                ).padding([.leading])
                            }
                        }

                    }
                }
                Section(header: Text("Recently found pets")) {
                    ForEach(foundPets, id: \.self) { foundPet in
                        Button(action: { viewPet(foundPet: foundPet) }) {
                            PetListCardView(pet: .constant(foundPet))
                                .foregroundStyle(.black)
                        }
                    }
                }

            }.task {
                do {
                    foundPets = try await getFoundPets()
                } catch {
                    foundPets = []
                }
            }
        }
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
    }
}

#Preview {
    @Previewable @State var pet = petInitiator
    MyLostPetView(pet: $pet)
}
