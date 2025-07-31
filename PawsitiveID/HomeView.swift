//
//  HomeView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/17/25.
//

import SwiftUI

struct HomeView: View {
    let changeTab: (_ tab: TabViews) -> Void
    @State var reunitedPets: [PetData] = []
    @State var showingPet = false
    @State var openedPet: PetData = petInitiator
    @State var isLoading = true
    @State var imageIndex = 0

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
        VStack {
            HStack {
                Image("WelcomeBanner\(imageIndex)")
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .containerRelativeFrame(
                        .vertical,
                        count: 100,
                        span: 60,
                        spacing: 0
                    )
                    .clipped()
                    .overlay(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Reunite with your")
                                .font(.system(size: 32))
                                .fontWeight(.bold)
                                .foregroundStyle(Color("TextOnColor"))
                                .padding([.leading], 20)
                                .shadow(radius: 10)
                            Text("furry friend")
                                .font(.system(size: 42))
                                .foregroundStyle(Color("TextOnColor"))
                                .padding([.leading], 20)
                                .padding([.bottom], 15)
                                .fontWeight(.bold)
                                .shadow(radius: 10)
                            HStack {
                                Spacer()
                                Button(action: {
                                    changeTab(.LostPet)
                                }) {
                                    Text(
                                        UserDefaults.standard.string(
                                            forKey: "lostPetId"
                                        ) != nil
                                            ? "My lost pet" : "Report lost pet"
                                    )
                                    .foregroundColor(Color("TextOnColor"))
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .padding()
                                }.background(Color("ActionPrimary"))
                                    .clipShape(.buttonBorder)
                                Spacer()
                                Button(action: {
                                    changeTab(.Pets)
                                }) {
                                    Text("View found pets")
                                        .foregroundColor(Color("TextOnColor"))
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .padding()
                                }.background(Color("ActionSecondary"))
                                    .clipShape(.buttonBorder)
                                Spacer()
                            }
                            .padding([.bottom], 15)
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                    }
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(reunitedPets.count == 0 ? "" : "Success stories")
                    .font(.system(size: 28))
                    .foregroundStyle(Color("Accent"))
                    .fontWeight(.bold)
                    .padding([.bottom], 15)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(reunitedPets, id: \.self) { reunitedPet in
                            ZStack(alignment: .bottom) {
                                Button(action: { viewPet(pet: reunitedPet) }) {
                                    AsyncImage(
                                        url: URL(
                                            string: reunitedPet.reunited_images
                                                .first ?? genericImage
                                        )
                                    ) { result in
                                        result.image?
                                            .resizable()
                                            .scaledToFill()
                                            .frame(
                                                width: 200,
                                                height: 200,
                                                alignment: .center
                                            )
                                            .clipped()
                                    }
                                    .frame(
                                        width: 200,
                                        height: 200,
                                        alignment: .center
                                    )
                                }
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(
                                        !reunitedPet.name.isEmpty
                                            ? reunitedPet.name : "Reunited pet"
                                    )
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .padding([.bottom], 3)
                                    .truncationMode(.tail)
                                    .foregroundStyle(Color("TextOnColor"))
                                    if reunitedPet.reunited_date != nil {
                                        Text(
                                            "Reunited on \(getFormattedDate(reunitedPet.reunited_date ?? ""))"
                                        )
                                        .font(.caption)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .italic()
                                        .foregroundStyle(Color("TextOnColor"))
                                    }
                                }
                                .frame(
                                    minWidth: 0,
                                    maxWidth: 170,
                                    alignment: .leading
                                )
                                .padding([.vertical], 5)
                                .padding([.horizontal], 15)
                                .background(Color("Accent").opacity(0.8))
                            }
                            .padding([.trailing], 10)
                        }
                    }
                }
                .task {
                    do {
                        reunitedPets = try await getReunitedPets()
                    } catch {
                        isLoading = false
                        reunitedPets = []
                    }
                }
            }
            .padding(10)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            Spacer()
        }
        .onAppear {
            imageIndex = Int.random(in: 0...5)
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingPet) { [openedPet] in
            NavigationStack {
                PetReunitedDetailsView(pet: $openedPet)
                    .navigationBarTitle(
                        openedPet.name,
                        displayMode: .inline
                    )
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Close") {
                                showingPet = false
                            }
                            .foregroundStyle(Color("Link"))
                        }
                    }
            }
        }
        .background(Color("Background"))
    }
}

#Preview {
    HomeView(changeTab: { tab in })
}
