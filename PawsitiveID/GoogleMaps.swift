//
//  GoogleMaps.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/18/25.
//

import GoogleMaps
import SwiftUI

var setLocationOnce = false

struct GoogleMaps: UIViewRepresentable {
    @Binding var pets: [FoundPetData]
    @StateObject var locationService = LocationService()

    func getCamera() -> GMSCameraPosition {
        return GMSCameraPosition.camera(
            withLatitude: locationService.lastLocation?.coordinate.latitude
                ?? 34.0549,
            longitude: locationService.lastLocation?.coordinate.longitude
                ?? 118.2426,
            zoom: 12.0
        )
    }

    func makeUIView(context: Self.Context) -> GMSMapView {
        let options = GMSMapViewOptions()
        options.camera = getCamera()
        options.frame = CGRect.zero
        let mapView = GMSMapView.init(options: options)

        do {
            if let styleURL = Bundle.main.url(
                forResource: "MapStyles",
                withExtension: "json"
            ) {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                logIssue(
                    message: "GoogleMaps: unable to get map styles",
                    data: nil
                )
            }
        } catch {
            logIssue(
                message: "GoogleMaps: unable to load map styles",
                data: error
            )
        }

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
                marker.iconView = UIImageView(
                    image: UIImage(systemName: "dog.circle")
                )
            case "CAT":
                marker.iconView = UIImageView(
                    image: UIImage(systemName: "cat.circle")
                )
            case "RABBIT":
                marker.iconView = UIImageView(
                    image: UIImage(systemName: "hare.circle")
                )
            case "BIRD":
                marker.iconView = UIImageView(
                    image: UIImage(systemName: "bird.circle")
                )
            default:
                marker.iconView = UIImageView(
                    image: UIImage(systemName: "grid.circle")
                )
            }

            marker.iconView?.tintColor = .blue
            marker.iconView?.frame = CGRectMake(0, 0, 40, 40)

            marker.title = pet.name
            marker.snippet = pet.description
            marker.map = mapView
        }
    }
}

#Preview {
    GoogleMaps(pets: .constant([]))
}
