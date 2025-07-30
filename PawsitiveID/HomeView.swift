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
                                .foregroundStyle(.white)
                                .padding([.leading], 20)
                                .shadow(radius: 10)
                            Text("furry friend")
                                .font(.system(size: 42))
                                .foregroundStyle(.white)
                                .padding([.leading], 20)
                                .padding([.bottom], 15)
                                .fontWeight(.bold)
                                .shadow(radius: 10)
                            HStack {
                                Spacer()
                                Button(action: {
                                    changeTab(.LostPet)
                                }) {
                                    Text(UserDefaults.standard.string(forKey: "lostPetId") != nil ? "My lost pet" : "Report lost pet")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .padding()
                                }.background(Color.orange)
                                    .clipShape(.buttonBorder)
                                Spacer()
                                Button(action: {
                                    changeTab(.Pets)
                                }) {
                                    Text("Find a found pet")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .padding()
                                }.background(
                                    Color(red: 0.2, green: 0.2, blue: 0.2)
                                )
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
                    .fontWeight(.bold)
                    .padding([.bottom], 15)
                ScrollView(.horizontal) {
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
                                .foregroundStyle(.white)
                                if reunitedPet.reunited_date != nil {
                                    Text(
                                        "Reunited on \(getFormattedDate(reunitedPet.reunited_date ?? ""))"
                                    )
                                    .font(.caption)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .italic()
                                    .foregroundStyle(.white)
                                }
                            }
                            .frame(
                                minWidth: 0,
                                maxWidth: 170,
                                alignment: .leading
                            )
                            .padding([.vertical], 5)
                            .padding([.horizontal], 15)
                            .background(.gray.opacity(0.7))
                        }
                        .padding([.trailing], 10)
                    }
                }
                .task {
                    do {
                        reunitedPets = try await getReunitedPets()
                    } catch {
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
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView(changeTab: { tab in })
}
