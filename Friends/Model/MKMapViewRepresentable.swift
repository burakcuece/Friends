//
//  MKMapViewRepresentable.swift
//  Friends
//
//  Created by Burak Cüce on 25.05.22.
//

import SwiftUI
import MapKit

struct MKMapViewRepresentable: UIViewRepresentable {
    
    var userTrackingMode: Binding<MKUserTrackingMode>
    
    @EnvironmentObject private var mapViewContainer: MapViewContainer
    
    func makeUIView(context: UIViewRepresentableContext<MKMapViewRepresentable>) -> MKMapView {
        mapViewContainer.mapView.delegate = context.coordinator
        
        context.coordinator.followUserIfPossible()
        
        return mapViewContainer.mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: UIViewRepresentableContext<MKMapViewRepresentable>) {
        if mapView.userTrackingMode != userTrackingMode.wrappedValue {
            mapView.setUserTrackingMode(userTrackingMode.wrappedValue, animated: true)
        }
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        let coordinator = MapViewCoordinator(self)
        return coordinator
    }
    
    class MapViewCoordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        
        var control: MKMapViewRepresentable
        
        let locationManager = CLLocationManager()
        
        init(_ control: MKMapViewRepresentable) {
            self.control = control
            
            super.init()
            
            setupLocationManager()
        }
        
        func setupLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.pausesLocationUpdatesAutomatically = true
        }
        
        func followUserIfPossible() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                control.userTrackingMode.wrappedValue = .follow
            default:
                break
            }
        }
        
        
        private func present(_ alert: UIAlertController, animated: Bool = true, completion: (() -> Void)? = nil) {
            
            
            let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
            keyWindow?.rootViewController?.present(alert, animated: animated, completion: completion)
        }
        
        // MARK: MKMapViewDelegate
        
        func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
#if DEBUG
            print("\(type(of: self)).\(#function): userTrackingMode=", terminator: "")
            switch mode {
            case .follow:            print(".follow")
            case .followWithHeading: print(".followWithHeading")
            case .none:              print(".none")
            @unknown default:        print("@unknown")
            }
#endif
            
            if CLLocationManager.locationServicesEnabled() {
                switch mode {
                case .follow, .followWithHeading:
                    switch CLLocationManager.authorizationStatus() {
                    case .notDetermined:
                        locationManager.requestWhenInUseAuthorization()
                    case .restricted:
                        
                        let alert = UIAlertController(title: "Location Permission Restricted", message: "The app cannot access your location. This is possibly due to active restrictions such as parental controls being in place. Please disable or remove them and enable location permissions in settings.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                            
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        })
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        
                        present(alert)
                        
                        DispatchQueue.main.async {
                            self.control.userTrackingMode.wrappedValue = .none
                        }
                    case .denied:
                        let alert = UIAlertController(title: "Location Permission Denied", message: "Please enable location permissions in settings.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                            // Redirect to Settings app
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        })
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        present(alert)
                        
                        DispatchQueue.main.async {
                            self.control.userTrackingMode.wrappedValue = .none
                        }
                    default:
                        DispatchQueue.main.async {
                            self.control.userTrackingMode.wrappedValue = mode
                        }
                    }
                default:
                    DispatchQueue.main.async {
                        self.control.userTrackingMode.wrappedValue = mode
                    }
                }
            } else {
                let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services in settings.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                    // Redirect to Settings app
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alert)
                
                DispatchQueue.main.async {
                    self.control.userTrackingMode.wrappedValue = mode
                }
            }
        }
        
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            
#if DEBUG
            print("\(type(of: self)).\(#function): status=", terminator: "")
            switch status {
            case .notDetermined:       print(".notDetermined")
            case .restricted:          print(".restricted")
            case .denied:              print(".denied")
            case .authorizedAlways:    print(".authorizedAlways")
            case .authorizedWhenInUse: print(".authorizedWhenInUse")
            @unknown default:          print("@unknown")
            }
#endif
            
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                control.mapViewContainer.mapView.setUserTrackingMode(control.userTrackingMode.wrappedValue, animated: true)
            default:
                control.mapViewContainer.mapView.setUserTrackingMode(.none, animated: true)
            }
        }
        
    }
    
}
