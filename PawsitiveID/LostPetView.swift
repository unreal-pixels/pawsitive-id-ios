//
//  LostPetView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/17/25.
//

import PhotosUI
import SwiftUI

struct LostPetView: View {
    @State private var petName: String = ""
    @State private var petType: AnimalType = .Cat
    @State private var petDescription: String = ""
    @State private var lastSeen: Date = Date()
    @State private var lastSeenLong: String = ""
    @State private var lastSeenLat: String = ""
    @State private var ownerName: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var selectedPhoto: [PhotosPickerItem] = []
    @State private var photoData: [Data] = []

    func isDisabled() -> Bool {
        if !email.isEmpty && !isValidEmail(email)
            || !isValidPhoneNumber(phoneNumber)
        {
            return true
        }

        return petName.isEmpty || petDescription.isEmpty || ownerName.isEmpty
            || (phoneNumber.isEmpty && email.isEmpty)
    }

    func submitForm() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-d"
        let date = dateFormatter.string(from: lastSeen)

        var data: [String: Any] = [
            "name": petName, "animal_type": getPetApiName(type: petType),
            "description": petDescription, "last_seen_date": date,
            "last_seen_long": 1, "last_seen_lat": 1,
            "owner_name": ownerName, "owner_phone": phoneNumber,
            "owner_email": email,
        ]

        if photoData.first != nil {
            let width: CGFloat = 512
            let uiImage = UIImage(data: photoData.first!)!
            let scale = width / uiImage.size.width
            let newHeight = uiImage.size.height * scale
            UIGraphicsBeginImageContext(CGSizeMake(width, newHeight))
            uiImage.draw(in: CGRectMake(0, 0, width, newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            data["photo"] =
                "data:image/png;base64,"
                + (newImage?.pngData()?.base64EncodedString() ?? "")
        }

        do {
            let payload = try JSONSerialization.data(
                withJSONObject: data,
                options: []
            )

            let url = URL(
                string: "https://unrealpixels.app/api/pawsitive-id/lost_pet.php"
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
                    logIssue(message: "Failed to POST lost pet", data: error)
                    return
                }

                do {
                    let lostPetData = try JSONDecoder().decode(
                        LostPetDataApiSingle.self,
                        from: data!
                    )
                    UserDefaults.standard.set(
                        lostPetData.data.id,
                        forKey: "lostPetId"
                    )
                } catch {
                    logIssue(message: "Lost pet failed to decode", data: error)
                    return
                }
            }
            session.resume()

        } catch {
            print("failed")
        }
    }

    var body: some View {
        HStack {
            Form {
                Section(header: Text("Pet Information")) {
                    TextField("Name", text: $petName)
                    Picker("Pet type", selection: $petType) {
                        Text("Cat").tag(AnimalType.Cat)
                        Text("Dog").tag(AnimalType.Dog)
                        Text("Rabbit").tag(AnimalType.Rabbit)
                        Text("Bird").tag(AnimalType.Bird)
                        Text("Other").tag(AnimalType.Other)
                    }
                    ZStack(alignment: .leading) {
                        if petDescription.isEmpty {
                            VStack {
                                Text("Pet description...")
                                    .padding(.top, 10)
                                    .opacity(0.2)
                            }
                        }

                        VStack {
                            TextEditor(text: $petDescription)
                                .opacity(petDescription.isEmpty ? 0.85 : 1)
                        }
                    }
                    DatePicker(
                        "Last seen",
                        selection: $lastSeen,
                        in: ...lastSeen,
                        displayedComponents: .date
                    ).datePickerStyle(.compact)
                    PhotosPicker(
                        "Select photo",
                        selection: $selectedPhoto,
                        maxSelectionCount: 1,
                        matching: .images
                    ).onChange(of: selectedPhoto) { _, selectedPhoto in
                        photoData.removeAll()
                        selectedPhoto.forEach { photo in
                            Task {
                                if let data =
                                    try? await photo
                                    .loadTransferable(type: Data.self)
                                {
                                    photoData.append(data)
                                }
                            }
                        }
                    }
                    ForEach(photoData, id: \.self) { photo in
                        Image(uiImage: UIImage(data: photo)!)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 150)
                    }
                }

                Section(header: Text("Owner Information")) {
                    TextField("Name", text: $ownerName)
                    TextField("Email Address", text: $email).textContentType(
                        .emailAddress
                    ).keyboardType(.emailAddress).autocapitalization(.none)
                    TextField("Phone Number", text: $phoneNumber)
                        .textContentType(.telephoneNumber).keyboardType(
                            .phonePad
                        )
                }
                HStack {
                    Spacer()
                    Button(action: submitForm) {
                        Text("Submit")
                    }.disabled(isDisabled())
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    LostPetView()
}
