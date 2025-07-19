//
//  GoogleMaps.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/18/25.
//

import GoogleMaps
import SwiftUI

struct GoogleMaps: UIViewRepresentable {
    @Binding var pets: [FoundPetData]
    @StateObject var locationService = LocationService()
    @State var setLocationOnce = false

    func getCamera() -> GMSCameraPosition {
        return GMSCameraPosition.camera(
            withLatitude: locationService.lastLocation?.coordinate.latitude
                ?? 34.0549,
            longitude: locationService.lastLocation?.coordinate.longitude
                ?? 118.2426,
            zoom: 14.0
        )
    }

    func makeUIView(context: Self.Context) -> GMSMapView {
        let mapView = GMSMapView.map(
            withFrame: CGRect.zero,
            camera: getCamera()
        )

        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Self.Context) {
        if locationService.lastLocation?.coordinate != nil && !setLocationOnce {
            setLocationOnce = true
            mapView.camera = getCamera()
            mapView.isMyLocationEnabled = true
        }

        for pet in pets {
            let marker: GMSMarker = GMSMarker()
            
            marker.position = CLLocationCoordinate2D(
                latitude: Double(pet.last_seen_lat) ?? 0,
                longitude: Double(pet.last_seen_long) ?? 0
            )

            switch pet.animal_type {
            case "DOG":
                marker.iconView = UIImageView(image: UIImage(systemName: "dog.circle"))
            case "CAT":
                marker.iconView = UIImageView(image: UIImage(systemName: "cat.circle"))
            case "RABBIT":
                marker.iconView = UIImageView(image: UIImage(systemName: "hare.circle"))
            default:
                marker.iconView = UIImageView(image: UIImage(systemName: "grid.circle"))
            }
            
            marker.iconView?.tintColor = .red
            // TODO: Resize to better size. And fix issue with rendering multiple markers
            
            marker.title = pet.name
            marker.snippet = pet.description
            marker.map = mapView
        }
    }
}

#Preview {
    GoogleMaps(pets: .constant([]))
}
