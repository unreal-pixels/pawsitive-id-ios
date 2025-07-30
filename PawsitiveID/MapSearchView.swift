//
//  MapSearchView.swift
//  PawsitiveID
//
//  Created by Bi Nguyen on 7/25/25.
//

import GoogleMaps
import MapKit
import SwiftUI

var setLocationOnceSearch = false

class MapSearch: UIViewController, GMSMapViewDelegate {
    var onChange: ((_ coordinates: CLLocationCoordinate2D) -> Void)?
    private var coordinate: CLLocationCoordinate2D?
    private var mapView = GMSMapView.init()
    private var lastLatLong = ""

    override func viewDidLoad() {
        setLocationOnceSearch = false
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

        if onChange != nil {
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
            withLatitude: presetLat ?? lat,
            longitude: presetLong ?? long,
            zoom: 12.0
        )

        if presetLat != nil && presetLong != nil {
            let newLatLong = "\(presetLat ?? 0)~\(presetLong ?? 0)"

            if lastLatLong != newLatLong {
                self.coordinate = CLLocationCoordinate2D(
                    latitude: presetLat!,
                    longitude: presetLong!
                )

                mapView.clear()
                let marker = GMSMarker(position: coordinate!)
                marker.map = mapView
                mapView.animate(to: camera)
            }
        }

        if !setLocationOnceSearch && userLocation {
            setLocationOnceSearch = true
            mapView.animate(to: camera)
            mapView.isMyLocationEnabled = true
        } else if !userLocation {
            mapView.camera = camera
        }
    }
}

struct MapSearchViewRep: UIViewControllerRepresentable {
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

struct MapSearchView: View {
    let onChange: (_ coordinates: CLLocationCoordinate2D) -> Void
    @Binding var presetLat: CLLocationDegrees?
    @Binding var presetLong: CLLocationDegrees?
    @State var searchField = ""

    func performSearch() {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchField
        let search = MKLocalSearch(request: searchRequest)

        search.start { response, error in
            if let error = error {
                logIssue(message: "Got error searching map", data: error)
                return
            }

            guard let response = response else {
                logIssue(message: "Got no response searching map", data: error)
                return
            }

            if response.mapItems.first != nil {
                onChange(response.mapItems.first!.placemark.coordinate)
                presetLat =
                    response.mapItems.first!.placemark.coordinate.latitude
                presetLong =
                    response.mapItems.first!.placemark.coordinate.longitude
            }
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .topTrailing) {
                TextField("Search locations", text: $searchField)
                    .padding()
                    .background(.white)
                    .cornerRadius(30)
                    .onSubmit {
                        if !searchField.isEmpty {
                            performSearch()
                        }
                    }
                    .shadow(
                        color: Color.gray.opacity(0.5),
                        radius: CGFloat(7),
                        x: CGFloat(3),
                        y: CGFloat(3)
                    )

                Button(action: {
                    performSearch()
                }) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .resizable()
                        .frame(width: 38, height: 38)
                        .foregroundColor(.blue)
                        .padding(3)
                }
                .disabled(searchField.isEmpty)
                .offset(x: -5, y: 5)  // Adjust offset to position the button
            }
            .padding([.top], 20)
            .padding([.horizontal], 20)
            .zIndex(10)
            MapSearchViewRep(
                onChange: onChange,
                presetLat: $presetLat,
                presetLong: $presetLong
            )
        }
    }
}

#Preview {
    MapSearchView(
        onChange: { coordinates in },
        presetLat: .constant(nil),
        presetLong: .constant(nil)
    )
}
