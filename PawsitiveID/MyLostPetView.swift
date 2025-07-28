//
//  MyLostPetView.swift
//  PawsitiveID
//
//  Created by Bi Nguyen on 7/28/25.
//

import SwiftUI

struct ShelterInfo: Hashable {
    let name: String
    let phone: String
}

struct MyLostPetView: View {
    @Binding var pet: PetData
    private let shelterData: [ShelterInfo] = [
        ShelterInfo(name: "Pets in Need", phone: "(650) 496-5971"),
        ShelterInfo(name: "Friends of The Alameda Animal Shelter", phone: "(510) 337-8565"),
        ShelterInfo(name: "County of Santa Clara Animal Services", phone: "(408) 686-3900"),
        ShelterInfo(name: "East County Animal Shelter", phone: "(925) 803-7040"),
        ShelterInfo(name: "Hayward Animal Shelter", phone: "(510) 293-7200")
    ]
    
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
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .padding([.top], 5)
                    Text(getFormattedDate(pet.last_seen_date)).font(.caption)
                        .italic()
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    Spacer()
                    Text(pet.description)
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .truncationMode(.tail)
                    Spacer()
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
            }
            .frame(height: 100)
            .padding([.leading], 20)
            .padding([.vertical], 10)

            List {
                Section(header: Text("Nearby Animal Shelters")) {
                    ForEach(shelterData, id: \.self){data in
                        Button(action: {}){
                            HStack {
                                Text(data.name).foregroundStyle(.black)
                                Spacer()
                                Image(systemName: "phone.fill" ).foregroundStyle(.blue).padding([.leading])
                            }
                        }
                        
                    }
                }
            }
            
            List {
                Section(header: Text("Recently found pets")){
                    Image(systemName: "cat.fill")
                }
            }
        }
        Spacer()
    }
}

#Preview {
    @Previewable @State var pet = petInitiator
    MyLostPetView(pet: $pet)
}
