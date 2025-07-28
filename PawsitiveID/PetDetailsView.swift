//
//  PetDetailsView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/24/25.
//

import SwiftUI

struct PetDetailsView: View {
    @Binding var pet: PetData
    @State private var isLoading = false
    @State private var showingPetLocation = false
    @State private var showCommentCreate = false
    @State private var newComment = ""

    private func foundMode() -> Bool {
        return pet.post_type == "FOUND"
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

            print(payload.base64EncodedString())

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

    var body: some View {
        if isLoading {
            ProgressView()
        } else {
            VStack {
                Form {
                    if !pet.images.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(pet.images, id: \.self) { photo in
                                    AsyncImage(url: URL(string: photo)) {
                                        result in
                                        result.image?
                                            .resizable()
                                            .scaledToFill()
                                            .frame(
                                                width: 280,
                                                height: 250,
                                                alignment: .center
                                            )
                                            .clipped()
                                    }
                                }
                            }
                        }
                    }
                    Section {
                        LabeledContent("Name", value: pet.name)
                        LabeledContent("Description", value: pet.description)
                        LabeledContent(
                            "Animal type",
                            value: getPetType(type: pet.animal_type)
                        )
                    } header: {
                        Text("Animal info")
                    }
                    Section {
                        LabeledContent(
                            "Date",
                            value: getFormattedDate(pet.last_seen_date)
                        )
                        Button(action: {
                            showingPetLocation = true
                        }) {
                            HStack {
                                Text("View location")
                                Spacer()
                                Image(systemName: "map.fill")
                            }
                        }
                    } header: {
                        Text("Last seen")
                    }
                    Section {
                        LabeledContent("Name", value: pet.post_by_name)
                        if pet.post_by_email != nil && pet.post_by_email != "" {
                            Button(action: {
                                let coded =
                                    "mailto:\(pet.post_by_email ?? "")?subject=\(foundMode() ? "Found" : "Lost") pet \(pet.name)&body=Question about the posted pet \(pet.name) [\(pet.id)]."

                                if let escaped = coded.addingPercentEncoding(
                                    withAllowedCharacters: .urlQueryAllowed
                                ),
                                    let emailURL = URL(string: escaped),
                                    UIApplication.shared.canOpenURL(emailURL)
                                {
                                    UIApplication.shared.open(emailURL)
                                }
                            }) {
                                HStack {
                                    Text("Email about pet")
                                    Spacer()
                                    Image(systemName: "envelope.fill")
                                }
                            }
                        }
                        if pet.post_by_phone != nil && pet.post_by_phone != "" {
                            Button(action: {
                                let url = URL(
                                    string: "tel://\(pet.post_by_phone ?? "")"
                                )!
                                UIApplication.shared.open(url)
                            }) {
                                HStack {
                                    Text("Call about pet")
                                    Spacer()
                                    Image(systemName: "phone.circle.fill")
                                }
                            }
                        }
                    } header: {
                        Text(foundMode() ? "Found by" : "Owner details")
                    }
                    Section {
                        ForEach(pet.chats, id: \.self) { chat in
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .top, spacing: 0) {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundStyle(.gray)
                                        .frame(width: 40, height: 40)
                                        .padding([.trailing], 10)
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Guest")
                                            .font(.headline)
                                            .padding([.bottom], 5)
                                        Text(getFormattedDateTime(chat.created_at))
                                            .font(.caption)
                                            .italic()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.bottom], 10)
                                }
                                Text(chat.message)
                                    .font(.callout)
                            }
                        }
                        Button(action: {
                            newComment = ""
                            showCommentCreate = true
                        }) {
                            Text("Post a comment")
                        }
                    } header: {
                        Text("Comments")
                    }
                }
            }
            .sheet(isPresented: $showingPetLocation) {
                NavigationStack {
                    VStack {
                        MapViewLocation(
                            type: $pet.animal_type,
                            lat: $pet.last_seen_lat,
                            long: $pet.last_seen_long,
                            imageUrl: .constant(pet.images.first ?? genericImage)
                        )
                    }
                    .navigationBarTitle(
                        "\(pet.name) last seen location",
                        displayMode: .inline
                    )
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Close") {
                                showingPetLocation = false
                            }
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
        }
    }
}

#Preview {
    @Previewable @State var pet = petInitiator
    PetDetailsView(pet: $pet)
}
