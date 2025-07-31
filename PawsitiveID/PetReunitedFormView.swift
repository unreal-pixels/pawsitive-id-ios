//
//  PetReunitedFormView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/30/25.
//

import PhotosUI
import SwiftUI

struct PetReunitedFormView: View {
    let onClose: () -> Void
    @Binding var pet: PetData
    @State private var isLoading = false
    @State private var petName: String = ""
    @State private var petDescription: String = ""
    @State private var reunitedDate: Date = Date()
    @State private var selectedPhoto: [PhotosPickerItem] = []
    @State private var photoData: [Data] = []
    @State private var showPhotoPicker = false

    func isDisabled() -> Bool {
        return petName.isEmpty
            || petDescription.isEmpty || selectedPhoto.isEmpty
    }

    func submitForm() {
        isLoading = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-d"
        let date = dateFormatter.string(from: reunitedDate)
        var photoStrings: [String] = []

        var data: [String: Any] = [
            "name": petName,
            "reunited_description": petDescription,
            "reunited_date": date,
            "reunited": true,
        ]

        photoData.forEach { photo in
            photoStrings.append(
                resizeImage(photo: photo) ?? ""
            )
        }

        data["reunited_images"] = photoStrings

        do {
            let payload = try JSONSerialization.data(
                withJSONObject: data,
                options: []
            )

            let url = URL(
                string:
                    "https://unrealpixels.app/api/pawsitive-id/pet.php?id=\(pet.id)"
            )!
            var request = URLRequest(url: url)
            request.setValue(
                "application/json; charset=utf-8",
                forHTTPHeaderField: "Content-Type"
            )
            request.httpMethod = "PUT"
            request.httpBody = payload
            let session = URLSession.shared.dataTask(with: request) {
                data,
                response,
                error in
                if error != nil || data == nil {
                    logIssue(message: "Failed to PUT reunited pet", data: error)
                    isLoading = false
                    return
                }

                isLoading = false
                onClose()
            }
            session.resume()

        } catch {
            logIssue(message: "Failed to submit reunited pet", data: error)
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
                        TextField("Name", text: $petName)
                            .foregroundStyle(Color("Text"))
                        TextField(
                            "Share your story",
                            text: $petDescription,
                            axis: .vertical
                        )
                        .foregroundStyle(Color("Text"))
                        .lineLimit(3...)

                        DatePicker(
                            "Reunited on",
                            selection: $reunitedDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .foregroundStyle(Color("Text"))
                        Button(action: {
                            showPhotoPicker = true
                        }) {
                            if !photoData.isEmpty {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(photoData, id: \.self) {
                                            photo in
                                            Image(
                                                uiImage: UIImage(data: photo)!
                                            )
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 150)
                                            .clipped()
                                            .padding([.leading, .trailing], 10)
                                        }
                                    }
                                    .onTapGesture(perform: {
                                        showPhotoPicker = true
                                    })
                                }
                            } else {
                                Rectangle()
                                    .frame(width: 150, height: 150)
                                    .foregroundStyle(Color("Background"))
                                    .overlay {
                                        VStack {
                                            Image(systemName: "photo.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 50)
                                                .foregroundStyle(
                                                    Color("Accent")
                                                )
                                                .padding([.bottom], 5)
                                            Text("Add photos")
                                                .font(.callout)
                                                .foregroundStyle(Color("Text"))
                                        }
                                    }
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        Button(action: submitForm) {
                            Text("Save")
                        }
                        .foregroundStyle(Color("TextOnColor"))
                        .disabled(isDisabled())
                        Spacer()
                    }
                    .listRowBackground(Color("ActionPrimary"))
                }
                .photosPicker(
                    isPresented: $showPhotoPicker,
                    selection: $selectedPhoto,
                    maxSelectionCount: 4,
                    matching: .images
                ).onChange(of: selectedPhoto) { _, selectedPhoto in
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
                .scrollContentBackground(.hidden)
                .background(Color("Background"))
            }
            .onAppear {
                petName = pet.name
            }
        }
    }
}

#Preview {
    @Previewable @State var pet = petInitiator
    PetReunitedFormView(onClose: {}, pet: $pet)
}
