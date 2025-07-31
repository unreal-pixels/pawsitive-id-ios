//
//  AppDelegate.swift
//  PawsitiveID
//
//  Created by David Bradshaw on 7/18/25.
//

import Foundation
import GoogleMaps
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        GMSServices.provideAPIKey("GOOGLE_MAPS_API_KEY")

        return true
    }
}
