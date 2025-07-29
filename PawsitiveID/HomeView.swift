//
//  HomeView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/17/25.
//

import SwiftUI

struct HomeView: View {
    @State var reunitedPets: [PetData] = []
    @State var showingPet = false
    @State var openedPet: PetData = petInitiator
    @State var isLoading = true
    func viewPet(pet: PetData) {
        openedPet = pet
        showingPet = true
    }

    func getReunitedPets() async throws -> [PetData] {
        isLoading = true
        let url = URL(
            string:
                "https://unrealpixels.app/api/pawsitive-id/pet.php?reunited=true"
        )!
        let (data, _) = try await URLSession.shared.data(from: url)
        let wrapper = try JSONDecoder().decode(PetDataApi.self, from: data)
        isLoading = false
        return wrapper.data
    }
    var body: some View {
//        randomize pictures on load
        VStack {
            HStack {
                Image("WelcomeBanner0")
                    .resizable()
                    .frame(
                        width: .infinity,
                        height: 300,
                    ).aspectRatio(contentMode: .fit)
                    .clipped()
                    .overlay(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            Text("Reunite with your")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding([.leading], 10)
                                .shadow(radius: 10)
                            Text("furry friend")
                                .font(.title)
                                .foregroundStyle(.white)
                                .padding([.leading], 10)
                                .fontWeight(.bold)
                                .shadow(radius: 10)
                            HStack {
                                Button(action: {}) {
                                    Text("Report a lost pet")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .padding()
                                }.background(Color.orange)
                                    .clipShape(.buttonBorder)

                                Button(action: {}) {
                                    Text("Find a found pet")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .padding()
                                }.background(
                                    Color(red: 0.2, green: 0.2, blue: 0.2)
                                )
                                .clipShape(.buttonBorder)
                            }.padding([.horizontal, .bottom], 10)

                        }
                    }
            }.padding([.horizontal], 10)
            List {
                Section(
                    header: Text(
                        reunitedPets.isEmpty ? "" : "Reunited Pets"
                    )
                ) {
                    ForEach(reunitedPets, id: \.self) { reunitedPet in
                        Button(action: { viewPet(pet: reunitedPet) }) {
                            PetListCardView(pet: .constant(reunitedPet))
                                .foregroundStyle(.black)
                        }
                    }
                }
            }.task {
                do {
                    reunitedPets = try await getReunitedPets()
                } catch {
                    reunitedPets = []
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var pet = petInitiator
    HomeView(reunitedPets: [pet])
}
