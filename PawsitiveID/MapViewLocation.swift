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
    @Binding var imageUrl: String
    @StateObject var locationService = LocationService()

    func getCamera() -> GMSCameraPosition {
        return GMSCameraPosition.camera(
            withLatitude: Double(lat) ?? 1,
            longitude: Double(long) ?? 1,
            zoom: 18.0
        )
    }

    func makeUIView(context: Self.Context) -> GMSMapView {
        setLocationOnceMapView = false
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
        let markerWidth = 60.0

        marker.position = CLLocationCoordinate2D(
            latitude: Double(lat) ?? 1,
            longitude: Double(long) ?? 1
        )

        marker.iconView = UIImageView(
            image: UIImage(systemName: "grid.circle")
        )

        do {
            let url = URL(string: imageUrl)
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
        marker.map = mapView
    }
}

#Preview {
    MapViewLocation(
        type: .constant("CAT"),
        lat: .constant("34.0549"),
        long: .constant("-118.2426"),
        imageUrl: .constant(genericImage)
    )
}
