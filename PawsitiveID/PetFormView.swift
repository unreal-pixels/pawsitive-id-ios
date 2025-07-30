//
//  PetFormView.swift
//  PawsitiveID
//
//  Created by Bi Nguyen on 7/17/25.
//

import CoreLocation
import PhotosUI
import SwiftUI

struct PetFormView: View {
    let onClose: (_ pet: PetData) -> Void
    @Binding var type: String
    @State private var isLoading = false
    @State private var petName: String = ""
    @State private var petType: AnimalType = .Cat
    @State private var petDescription: String = ""
    @State private var lastSeen: Date = Date()
    @State private var lastSeenLong: CLLocationDegrees?
    @State private var lastSeenLat: CLLocationDegrees?
    @State private var posterName: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var selectedPhoto: [PhotosPickerItem] = []
    @State private var photoData: [Data] = []
    @State private var showLocationPicker = false
    @State private var coordinateDisplayName = ""

    func isDisabled() -> Bool {
        if !email.isEmpty && !isValidEmail(email) {
            return true
        }

        if !phoneNumber.isEmpty && !isValidPhoneNumber(phoneNumber) {
            return true
        }

        return (type == "LOST" ? petName.isEmpty : false) || lastSeenLat == nil
            || lastSeenLong == nil
            || petDescription.isEmpty || posterName.isEmpty
            || (phoneNumber.isEmpty && email.isEmpty)
    }

    func getCoordinateName(coordinates: CLLocationCoordinate2D) {
        coordinateDisplayName = ""

        let geocoder = CLGeocoder()
        let location = CLLocation(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude
        )

        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                logIssue(
                    message: "Unable to get name from coordinates",
                    data: error
                )
                return
            }

            if let placemarks = placemarks, let placemark = placemarks.first {
                var list = [
                    placemark.name ?? "", placemark.locality ?? "",
                    placemark.administrativeArea ?? "",
                ]
                list = list.filter { return !$0.isEmpty }
                coordinateDisplayName = list.joined(separator: ", ")
            }
        }
    }

    func submitForm() {
        isLoading = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-d"
        let date = dateFormatter.string(from: lastSeen)
        var photoStrings: [String] = []
        let animalType = getPetApiName(type: petType)

        var data: [String: Any] = [
            "name": petName.isEmpty
                ? "Found \(getPetType(type: animalType))" : petName,
            "post_type": type,
            "animal_type": animalType,
            "description": petDescription,
            "last_seen_date": date,
            "last_seen_long": lastSeenLong ?? 1,
            "last_seen_lat": lastSeenLat ?? 1,
            "post_by_name": posterName,
            "post_by_phone": phoneNumber,
            "post_by_email": email,
        ]

        photoData.forEach { photo in
            let width: CGFloat = 512
            let uiImage = UIImage(data: photo)!
            let scale = width / uiImage.size.width
            let newHeight = uiImage.size.height * scale
            UIGraphicsBeginImageContext(CGSizeMake(width, newHeight))
            uiImage.draw(in: CGRectMake(0, 0, width, newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            photoStrings.append(
                "data:image/png;base64,"
                    + (newImage?.pngData()?.base64EncodedString() ?? "")
            )
        }

        data["images"] = photoStrings

        do {
            let payload = try JSONSerialization.data(
                withJSONObject: data,
                options: []
            )

            let url = URL(
                string: "https://unrealpixels.app/api/pawsitive-id/pet.php"
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
                    isLoading = false
                    return
                }

                do {
                    let lostPetData = try JSONDecoder().decode(
                        PetDataApiSingle.self,
                        from: data!
                    )
                    isLoading = false
                    onClose(lostPetData.data)

                } catch {
                    logIssue(message: "Lost pet failed to decode", data: error)
                    isLoading = false
                    return
                }
            }
            session.resume()

        } catch {
            logIssue(message: "Failed to submit lost pet", data: error)
            isLoading = false
        }
    }

    var body: some View {
        if isLoading {
            LoadingView()
        } else {
            HStack {
                Form {
                    Section(
                        header: Text("Pet Info").foregroundStyle(
                            Color("TextSmall")
                        )
                    ) {
                        TextField(
                            "Name\(type == "FOUND" ? " (optional)" : "")",
                            text: $petName
                        )
                        .foregroundStyle(Color("Text"))
                        Picker("Pet type", selection: $petType) {
                            Text("Cat").tag(AnimalType.Cat)
                            Text("Dog").tag(AnimalType.Dog)
                            Text("Rabbit").tag(AnimalType.Rabbit)
                            Text("Bird").tag(AnimalType.Bird)
                            Text("Other").tag(AnimalType.Other)
                        }
                        .foregroundStyle(Color("Text"))
                        TextField(
                            "Pet description",
                            text: $petDescription,
                            axis: .vertical
                        )
                        .foregroundStyle(Color("Text"))
                        .lineLimit(3...)

                        DatePicker(
                            "Last seen",
                            selection: $lastSeen,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .foregroundStyle(Color("Text"))
                        Button(action: {
                            showLocationPicker = true
                        }) {
                            VStack(alignment: .leading) {
                                Text("Select location")
                                    .foregroundStyle(Color("Link"))
                                if !coordinateDisplayName.isEmpty {
                                    Text(coordinateDisplayName)
                                        .padding([.top], 5)
                                        .font(.callout)
                                        .foregroundStyle(Color("Text"))
                                } else if lastSeenLat != nil
                                    && lastSeenLong != nil
                                {
                                    Text(
                                        "\(lastSeenLat ?? 1), \(lastSeenLong ?? 1)"
                                    ).foregroundStyle(Color("Text"))
                                }
                            }
                        }
                        PhotosPicker(
                            "Select photos",
                            selection: $selectedPhoto,
                            matching: .images
                        )
                        .onChange(of: selectedPhoto) { _, selectedPhoto in
                            selectedPhoto.forEach { photo in
                                Task {
                                    photoData.removeAll()

                                    if let data =
                                        try? await photo
                                        .loadTransferable(type: Data.self)
                                    {
                                        photoData.append(data)
                                    }
                                }
                            }
                        }
                        .foregroundStyle(Color("Link"))
                        if !photoData.isEmpty {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(photoData, id: \.self) { photo in
                                        Image(uiImage: UIImage(data: photo)!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 150)
                                            .clipped()
                                            .padding([.leading, .trailing], 10)
                                    }
                                }
                            }
                        }
                    }

                    Section(
                        header: Text(
                            type == "FOUND" ? "Found by" : "Owner details"
                        ).foregroundStyle(Color("TextSmall"))
                    ) {
                        TextField("Name", text: $posterName)
                            .foregroundStyle(Color("Text"))
                        TextField("Email Address", text: $email)
                            .textContentType(
                                .emailAddress
                            ).keyboardType(.emailAddress).autocapitalization(
                                .none
                            )
                            .foregroundStyle(Color("Text"))
                        TextField("Phone Number", text: $phoneNumber)
                            .textContentType(.telephoneNumber).keyboardType(
                                .phonePad
                            )
                            .foregroundStyle(Color("Text"))
                    }
                    HStack {
                        Spacer()
                        Button(action: submitForm) {
                            Text("Submit")
                        }
                        .foregroundStyle(Color("TextOnColor"))
                        .disabled(isDisabled())
                        Spacer()
                    }
                    .listRowBackground(Color("ActionPrimary"))
                }
            }
            .sheet(isPresented: $showLocationPicker) {
                NavigationStack {
                    VStack {
                        MapSearchView(
                            onChange: { coordinates in
                                lastSeenLat = coordinates.latitude
                                lastSeenLong = coordinates.longitude
                                getCoordinateName(coordinates: coordinates)
                            },
                            presetLat: $lastSeenLat,
                            presetLong: $lastSeenLong,
                        )
                    }
                    .navigationBarTitle(
                        "Select a location",
                        displayMode: .inline,
                    )
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Close") {
                                showLocationPicker = false
                            }
                            .foregroundStyle(Color("Link"))
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("Background"))
        }
    }
}

#Preview {
    PetFormView(onClose: { pet in }, type: .constant("FOUND"))
}
