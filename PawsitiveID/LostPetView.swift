//
//  LostPetView.swift
//  PawsitiveID
//
//  Created by Bi Nguyen on 7/26/25.
//

import SwiftUI

struct LostPetView: View {
    @State private var isLoading = true
    @State private var myLostPet: LostPetData?
    func startView() {
        isLoading = true
        let lostPetId = UserDefaults.standard.string(forKey: "lostPetId")
        if lostPetId != nil {
            do {
                let url = URL(
                    string:
                        "https://unrealpixels.app/api/pawsitive-id/lost_pet.php?id=\(lostPetId ?? "")"
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
                            LostPetDataApiSingle.self,
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
        VStack{
            if isLoading {
                ProgressView()
            } else if myLostPet != nil {
                LostPetDetailsView()
            } else {
                LostPetFormView(onClose: {startView()})
            }
        }.onAppear {
            startView()
        }
    }

}

#Preview {
    LostPetView()
}
