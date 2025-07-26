//
//  MapViewLocation.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/25/25.
//

import GoogleMaps
import SwiftUI

var setLocationOnceMapView = false

struct MapViewLocation: UIViewRepresentable {
    @Binding var type: String
    @Binding var lat: String
    @Binding var long: String
    @StateObject var locationService = LocationService()

    func getCamera() -> GMSCameraPosition {
        return GMSCameraPosition.camera(
            withLatitude: Double(lat) ?? 1,
            longitude: Double(long) ?? 1,
            zoom: 18.0
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
        if locationService.lastLocation?.coordinate != nil
            && !setLocationOnceMapView
        {
            setLocationOnce = true
            mapView.camera = getCamera()
            mapView.isMyLocationEnabled = true
        }

        let marker: GMSMarker = GMSMarker()

        marker.position = CLLocationCoordinate2D(
            latitude: Double(lat) ?? 1,
            longitude: Double(long) ?? 1
        )

        switch type {
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
        marker.iconView?.frame = CGRectMake(0, 0, 50, 50)
        marker.map = mapView
    }
}

#Preview {
    MapViewLocation(type: .constant("CAT"), lat: .constant("34.0549"), long: .constant("-118.2426"))
}
