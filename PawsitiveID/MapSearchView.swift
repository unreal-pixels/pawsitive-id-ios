//
//  MapSearchView.swift
//  PawsitiveID
//
//  Created by Bi Nguyen on 7/25/25.
//

import GoogleMaps
import SwiftUI

var setLocationOnceSearch = false

class MapSearch: UIViewController, GMSMapViewDelegate {
    var onChange: ((_ coordinates: CLLocationCoordinate2D) -> Void)?
    private var coordinate: CLLocationCoordinate2D?
    private var mapView = GMSMapView.init()

    override func viewDidLoad() {
        let options = GMSMapViewOptions()
        options.frame = CGRect.zero
        mapView = GMSMapView.init(options: options)
        mapView.delegate = self

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

        self.view = mapView
    }

    func mapView(
        _ mapView: GMSMapView,
        didTapAt coordinate: CLLocationCoordinate2D
    ) {
        mapView.clear()
        
        if (onChange != nil) {
            onChange!(coordinate)
        }
        
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
    }

    func setupData(
        onChange: @escaping ((_ coordinates: CLLocationCoordinate2D) -> Void),
        coordinate: CLLocationCoordinate2D?
    ) {
        self.onChange = onChange
        self.coordinate = coordinate
    }

    func updateData(
        lat: CLLocationDegrees,
        long: CLLocationDegrees,
        userLocation: Bool,
        presetLat: CLLocationDegrees?,
        presetLong: CLLocationDegrees?,
    ) {

        let camera = GMSCameraPosition.camera(
            withLatitude: lat,
            longitude: long,
            zoom: 12.0
        )

        if !setLocationOnceSearch && userLocation {
            setLocationOnceSearch = true
            mapView.animate(to: camera)
            mapView.isMyLocationEnabled = true
        } else if !userLocation {
            mapView.camera = camera
        }
    }
}

struct MapSearchView: UIViewControllerRepresentable {
    let onChange: (_ coordinates: CLLocationCoordinate2D) -> Void
    @Binding var presetLat: CLLocationDegrees?
    @Binding var presetLong: CLLocationDegrees?
    @StateObject var locationService = LocationService()
    typealias UIViewControllerType = MapSearch

    func getCamera() -> GMSCameraPosition {
        return GMSCameraPosition.camera(
            withLatitude: locationService.lastLocation?.coordinate.latitude
                ?? 34.0549,
            longitude: locationService.lastLocation?.coordinate.longitude
                ?? -118.2426,
            zoom: 12.0
        )
    }

    func trySettingLocation(view: MapSearch) {
        view.updateData(
            lat: locationService.lastLocation?.coordinate.latitude
                ?? 34.0549,
            long: locationService.lastLocation?.coordinate.longitude
                ?? -118.2426,
            userLocation: locationService.lastLocation?.coordinate.latitude
                != nil,
            presetLat: presetLat,
            presetLong: presetLong,
        )
    }

    func makeUIViewController(context: Context) -> MapSearch {
        let view = MapSearch()
        trySettingLocation(view: view)
        view.setupData(
            onChange: onChange,
            coordinate: (presetLat == nil || presetLong == nil)
                ? nil
                : CLLocationCoordinate2D(
                    latitude: presetLat!,
                    longitude: presetLong!
                )
        )
        return view
    }

    func updateUIViewController(_ uiViewController: MapSearch, context: Context)
    {
        trySettingLocation(view: uiViewController)
    }
}

#Preview {
    MapSearchView(
        onChange: { coordinates in },
        presetLat: .constant(nil),
        presetLong: .constant(nil)
    )
}
