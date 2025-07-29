//
//  MapPetsView.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/18/25.
//

import GoogleMaps
import SwiftUI

var setLocationOnce = false

struct MapPetsView: UIViewRepresentable {
    @Binding var pets: [PetData]
    @Binding var filter: FilterType
    @StateObject var locationService = LocationService()

    func getCamera() -> GMSCameraPosition {
        return GMSCameraPosition.camera(
            withLatitude: locationService.lastLocation?.coordinate.latitude
                ?? 34.0549,
            longitude: locationService.lastLocation?.coordinate.longitude
                ?? -118.2426,
            zoom: 12.0
        )
    }

    func makeUIView(context: Self.Context) -> GMSMapView {
        setLocationOnce = false
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

        let petToUse = pets.filter {
            filter == .All
                ? true : $0.post_type == (filter == .Lost ? "LOST" : "FOUND")
        }
        
        mapView.clear()

        for pet in petToUse {
            let marker: GMSMarker = GMSMarker()
            let markerWidth = 50.0

            marker.position = CLLocationCoordinate2D(
                latitude: Double(pet.last_seen_lat) ?? 0,
                longitude: Double(pet.last_seen_long) ?? 0
            )

            marker.iconView = UIImageView(
                image: UIImage(systemName: "grid.circle")
            )

            do {
                let url = URL(string: pet.images.first ?? genericImage)
                let data = try? Data(contentsOf: url!)
                var image: UIImage?

                if let imageData = data {
                    image = UIImage(data: imageData)
                }

                if image != nil {
                    let uiImageView = UIImageView(
                        image: image
                    )

                    uiImageView.layer.cornerRadius = markerWidth / 2
                    uiImageView.layer.masksToBounds = true
                    uiImageView.layer.borderWidth = 0

                    marker.iconView = uiImageView
                }
            }

            marker.iconView?.tintColor = .blue
            marker.iconView?.frame = CGRectMake(0, 0, markerWidth, markerWidth)

            marker.title = pet.name
            marker.snippet = pet.description
            marker.map = mapView
        }
    }
}

#Preview {
    MapPetsView(
        pets: .constant([petInitiator]),
        filter: .constant(FilterType.All)
    )
}
