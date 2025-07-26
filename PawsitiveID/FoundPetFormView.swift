//
//  FoundPetFormView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/26/25.
//

import PhotosUI
import SwiftUI

struct FoundPetFormView: View {
    let onClose: (_ pet: FoundPetData) -> Void
    @State private var isLoading = false
    @State private var petName: String = ""
    @State private var petType: AnimalType = .Cat
    @State private var petDescription: String = ""
    @State private var lastSeen: Date = Date()
    @State private var lastSeenLong: String = ""
    @State private var lastSeenLat: String = ""
    @State private var foundByName: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var selectedPhoto: [PhotosPickerItem] = []
    @State private var photoData: [Data] = []

    func isDisabled() -> Bool {
        if !phoneNumber.isEmpty && !isValidPhoneNumber(phoneNumber) {
            return true
        }

        if !email.isEmpty && !isValidEmail(email) {
            return true
        }

        return petName.isEmpty || petDescription.isEmpty
            || foundByName.isEmpty
            || (phoneNumber.isEmpty && email.isEmpty)
    }

    func submitForm() {
        isLoading = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-d"
        let date = dateFormatter.string(from: lastSeen)

        var data: [String: Any] = [
            "name": petName, "animal_type": getPetApiName(type: petType),
            "description": petDescription, "last_seen_date": date,
            "last_seen_long": 1, "last_seen_lat": 1,
            "found_by_name": foundByName, "found_by_phone": phoneNumber,
            "found_by_email": email,
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
                string:
                    "https://unrealpixels.app/api/pawsitive-id/found_pet.php"
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
                    logIssue(
                        message: "Failed to POST found pet",
                        data: error
                    )
                    isLoading = false
                    return
                }

                do {
                    let foundPetData = try JSONDecoder().decode(
                        FoundPetDataApiSingle.self,
                        from: data!
                    )
                    isLoading = false
                    onClose(foundPetData.data)
                } catch {
                    logIssue(
                        message: "Found pet failed to decode",
                        data: error
                    )
                    isLoading = false
                    return
                }
            }
            session.resume()

        } catch {
            logIssue(
                message: "Failed to submit found pet",
                data: error
            )

            isLoading = false
        }
    }

    var body: some View {
        HStack {
            Form {
                Section(header: Text("Animal info")) {
                    TextField("Name", text: $petName)
                    Picker("Pet type", selection: $petType) {
                        Text("Cat").tag(AnimalType.Cat)
                        Text("Dog").tag(AnimalType.Dog)
                        Text("Rabbit").tag(AnimalType.Rabbit)
                        Text("Bird").tag(AnimalType.Bird)
                        Text("Other").tag(AnimalType.Other)
                    }
                    TextField(
                        "Pet description...",
                        text: $petDescription,
                        axis: .vertical
                    )
                    .lineLimit(3...)
                    DatePicker(
                        "Last seen",
                        selection: $lastSeen,
                        in: ...Date(),
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

                Section(header: Text("Found by")) {
                    TextField("Name", text: $foundByName)
                    TextField("Email Address", text: $email)
                        .textContentType(
                            .emailAddress
                        ).keyboardType(.emailAddress).autocapitalization(
                            .none
                        )
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
    FoundPetFormView(onClose: { pet in })
}
