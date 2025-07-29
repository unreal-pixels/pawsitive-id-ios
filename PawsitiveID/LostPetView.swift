//
//  LostPetView.swift
//  PawsitiveID
//
//  Created by Bi Nguyen on 7/26/25.
//

import SwiftUI

struct LostPetView: View {
    @State private var isLoading = true
    @State private var myLostPet: PetData = petInitiator

    func startView() {
        isLoading = true
        let lostPetId = UserDefaults.standard.string(forKey: "lostPetId")
        if lostPetId != nil {
            do {
                let url = URL(
                    string:
                        "https://unrealpixels.app/api/pawsitive-id/pet.php?id=\(lostPetId ?? "")"
                )!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let session = URLSession.shared.dataTask(with: request) {
                    data,
                    response,
                    error in
                    if error != nil || data == nil {
                        logIssue(message: "Failed to GET lost pet", data: error)
                        isLoading = false
                        return
                    }

                    do {
                        myLostPet = try JSONDecoder().decode(
                            PetDataApiSingle.self,
                            from: data!
                        ).data
                        isLoading = false

                    } catch {
                        logIssue(
                            message: "Lost pet failed to decode",
                            data: error
                        )
                        isLoading = false
                        return
                    }
                }
                session.resume()

            }
        } else {
            isLoading = false
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    LoadingView()
                } else if myLostPet.id != "0" {
                    MyLostPetView(pet: $myLostPet)
                } else {
                    PetFormView(
                        onClose: { pet in
                            UserDefaults.standard.set(
                                pet.id,
                                forKey: "lostPetId"
                            )

                            startView()
                        },
                        type: .constant("LOST")
                    )
                }
            }.onAppear {
                startView()
            }.navigationTitle( isLoading ? "Lost Pet" : myLostPet.id != "0" ? "My Lost Pet" : "Report lost pet")
        }
    }

}

#Preview {
    LostPetView()
}
