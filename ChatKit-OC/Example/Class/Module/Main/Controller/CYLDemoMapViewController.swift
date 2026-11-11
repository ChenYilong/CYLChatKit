//
//  CYLDemoMapViewController.swift
//  ChatKit-OC
//
//  Translated from Objective-C (CYLDemoMapViewController.h/.m).
//

import UIKit
import MapKit
import CoreLocation

@objc(CYLDemoMapViewController)
final class CYLDemoMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var location: CLLocation?
    private var locationManager: CLLocationManager?

    init(location: CLLocation?) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    static func initWithLocation(_ location: CLLocation?) -> CYLDemoMapViewController {
        let mapViewController = CYLDemoMapViewController(location: nil)
        mapViewController.location = location
        return mapViewController
    }

    // MARK: - UIViewController Life

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Create the location manager.
        let locationManager = CLLocationManager()
        self.locationManager = locationManager
        // 2. Set the delegate.
        locationManager.delegate = self
        // 3. Accuracy.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 4. Ask for the permission: only in the foreground, or also in the background. Request only one of them;
        // asking for both in the order foreground, background makes the system ask for the first one at the first launch
        // and for the second one only at the next launch.
        locationManager.requestWhenInUseAuthorization()
        // 6. Update the user location.
        locationManager.startUpdatingLocation()
    }
}
