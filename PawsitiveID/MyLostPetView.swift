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
    @State var showCommentCreate = false
    @State var newComment = ""
    @State var showingReunitedAction = false
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
    
    private func saveComment() {
        showCommentCreate = false
        isLoading = true

        let data: [String: Any] = [
            "message": newComment,
            "type": pet.post_type,
            "post_id": Int(pet.id) ?? 0,
        ]

        do {
            let payload = try JSONSerialization.data(
                withJSONObject: data,
                options: []
            )

            let url = URL(
                string: "https://unrealpixels.app/api/pawsitive-id/chat.php"
            )!
            var request = URLRequest(url: url)
            request.setValue(
                "application/json; charset=utf-8",
                forHTTPHeaderField: "Content-Type"
            )
            request.httpMethod = "POST"
            request.httpBody = payload
            let session = URLSession.shared.dataTask(with: request) {
                data,
                response,
                error in
                if error != nil || data == nil {
                    logIssue(message: "Failed to POST pet chat", data: error)
                    isLoading = false
                    return
                }

                do {
                    let chatData = try JSONDecoder().decode(
                        ChatItemApiSingle.self,
                        from: data!
                    )

                    pet.chats.insert(chatData.data, at: 0)
                    isLoading = false
                } catch {
                    logIssue(message: "Failed to decode pet chat", data: error)
                    isLoading = false
                }
            }
            session.resume()

        } catch {
            logIssue(message: "Failed to submit pet chat", data: error)
            isLoading = false
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
                        .foregroundStyle(Color("Text"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .padding([.top], 5)
                    Text(getFormattedDate(pet.last_seen_date))
                        .font(.caption)
                        .foregroundStyle(Color("Text"))
                        .italic()
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    Spacer()
                    Text(pet.description)
                        .font(.caption)
                        .foregroundStyle(Color("TextSmall"))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .truncationMode(.tail)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
            }
            .frame(height: 100)
            .padding([.leading], 20)
            .padding([.vertical], 10)

            List {
                Section(
                    header: Text(
                        shelterData.isEmpty ? "" : "Nearby Animal Shelters"
                    ).foregroundStyle(Color("TextSmall"))
                ) {
                    ForEach(shelterData, id: \.self) { data in
                        Button(action: {
                            let url = URL(
                                string: "tel://\(data.phone)"
                            )!
                            UIApplication.shared.open(url)
                        }) {
                            HStack {
                                Text(data.name)
                                    .foregroundStyle(Color("Text"))
                                Spacer()
                                Image(systemName: "phone.fill")
                                    .foregroundStyle(Color("Link"))
                                    .padding([.leading])
                            }
                        }

                    }
                }
                Section {
                    ForEach(pet.chats, id: \.self) { chat in
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .top, spacing: 0) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundStyle(Color("Accent"))
                                    .frame(width: 40, height: 40)
                                    .padding([.trailing], 10)
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Guest")
                                        .font(.headline)
                                        .foregroundStyle(Color("Text"))
                                        .padding([.bottom], 5)
                                    Text(
                                        getFormattedDateTime(
                                            chat.created_at
                                        )
                                    )
                                    .foregroundStyle(Color("TextSmall"))
                                    .font(.caption)
                                    .italic()
                                }
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                                .padding([.bottom], 10)
                            }
                            Text(chat.message)
                                .foregroundStyle(Color("Text"))
                                .font(.callout)
                        }
                    }
                    Button(action: {
                        newComment = ""
                        showCommentCreate = true
                    }) {
                        Text("Post a comment")
                    }
                    .foregroundStyle(Color("Link"))
                } header: {
                    Text("Comments").foregroundStyle(Color("TextSmall"))
                }
                Section(
                    header: Text(foundPets.isEmpty ? "" : "Recently found pets")
                        .foregroundStyle(Color("TextSmall"))
                ) {
                    ForEach(foundPets, id: \.self) { foundPet in
                        Button(action: { viewPet(foundPet: foundPet) }) {
                            PetListCardView(pet: .constant(foundPet))
                        }
                    }
                }
                Section {
                    Button(action: {
                        showingReunitedAction = true
                    }) {
                        Text("Pet reunited")
                            .foregroundStyle(Color("Link"))
                    }
                    Button(action: {
                        deleteConfirmation = true
                    }) {
                        Text("Delete")
                            .foregroundStyle(Color("Danger"))
                    }
                } header: {
                    Text("Actions").foregroundStyle(Color("TextSmall"))
                }

            }
            .task {
                do {
                    foundPets = try await getFoundPets()
                } catch {
                    isLoading = false
                    foundPets = []
                }
            }
            .refreshable {
                do {
                    foundPets = try await getFoundPets()
                } catch {
                    isLoading = false
                    foundPets = []
                }
            }
            .overlay(alignment: .topLeading) {
                if isLoading {
                    ZStack {
                        Color(Color("Background"))
                            .ignoresSafeArea()
                        LoadingView()
                    }
                    .zIndex(2)
                }
            }
        }
        .sheet(isPresented: $showingReunitedAction) {
            NavigationStack {
                PetReunitedFormView(onClose: {
                    onClose()
                }, pet: $pet)
                .navigationBarTitle(
                    "Reunited with \(pet.name)",
                    displayMode: .inline
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            showingReunitedAction = false
                        }
                        .foregroundStyle(Color("Link"))
                    }
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
                        .foregroundStyle(Color("Link"))
                    }
                }
            }
        }
        .alert(
            Text("Post a new comment"),
            isPresented: $showCommentCreate
        ) {
            Button("Cancel", role: .cancel) {
                showCommentCreate = false
            }
            Button("Post") {
                saveComment()
            }
            TextField("Comment", text: $newComment)
        } message: {
            Text("Include any useful info to help get \(pet.name) home!")
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
        .scrollContentBackground(.hidden)
        .background(Color("Background"))
    }
}

#Preview {
    @Previewable @State var pet = petInitiator
    MyLostPetView(onClose: {}, pet: $pet)
}
