//
//  PlacesController.swift
//  Maps_SwiftUI
//
//  Created by 豊岡正紘 on 2020/03/31.
//  Copyright © 2020 Masahiro Toyooka. All rights reserved.
//

import SwiftUI
import LBTATools
import MapKit
import GooglePlaces

class PlacesController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.fillSuperview()
        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager.delegate = self
        
        requestForLocationAuthorization()
    }
    
    let client = GMSPlacesClient()
    
    fileprivate func findNearbyPlaces() {
        client.currentPlace { [weak self] (likelihoodList, err) in
            if let err = err {
                print("Failed to find current place:", err)
                return
            }
            
            likelihoodList?.likelihoods.forEach({  (likelihood) in
                
                let place = likelihood.place
                
                let annotation = PlaceAnnotation(place: place)
                annotation.title = place.name
                annotation.coordinate = place.coordinate
                
                self?.mapView.addAnnotation(annotation)
            })
            
            self?.mapView.showAnnotations(self?.mapView.annotations ?? [], animated: false)
        }
    }
    
    class PlaceAnnotation: MKPointAnnotation {
        let place: GMSPlace
        
        init(place: GMSPlace) {
            self.place = place
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is PlaceAnnotation) { return nil}
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
        
//        annotationView.canShowCallout = true
        
        if let placeAnnotation = annotation as? PlaceAnnotation {
            let types = placeAnnotation.place.types
            
            if let firstType = types?.first {
                if firstType == "bar" {
                    annotationView.image = #imageLiteral(resourceName: "tourist")
                } else if firstType == "restaurant" {
                    annotationView.image = #imageLiteral(resourceName: "restaurant")
                } else {
                    annotationView.image = #imageLiteral(resourceName: "bar")
                }
            }
        }
        return annotationView
    }
    
    var currentCustomCallout: UIView?
    
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            currentCustomCallout?.removeFromSuperview()
            
            let customCalloutContainer = UIView(backgroundColor: .white)
            
    //        customCalloutContainer.frame = .init(x: 0, y: 0, width: 100, height: 200)
            
            view.addSubview(customCalloutContainer)
            
            customCalloutContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let widthAnchor = customCalloutContainer.widthAnchor.constraint(equalToConstant: 100)
            widthAnchor.isActive = true
            let heightAnchor = customCalloutContainer.heightAnchor.constraint(equalToConstant: 200)
            heightAnchor.isActive = true
            customCalloutContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            customCalloutContainer.bottomAnchor.constraint(equalTo: view.topAnchor).isActive = true
            
            customCalloutContainer.layer.borderWidth = 2
            customCalloutContainer.layer.borderColor = UIColor.darkGray.cgColor
            
            customCalloutContainer.setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .darkGray)
            customCalloutContainer.layer.cornerRadius = 5
            
            currentCustomCallout = customCalloutContainer
            
            // load the spinner
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = .darkGray
            spinner.startAnimating()
            customCalloutContainer.addSubview(spinner)
            spinner.fillSuperview()
            
            // look up our photo
            
            guard let placeId = (view.annotation as? PlaceAnnotation)?.place.placeID else { return }
            
            client.lookUpPhotos(forPlaceID: placeId) { [weak self] (metadatalist, err) in
                if let err = err {
                    print("Error when looking up photos:", err)
                    return
                }
                
                guard let firstPhotoMetadata = metadatalist?.results.first else { return }
                
                self?.client.loadPlacePhoto(firstPhotoMetadata) { (image, err) in
                    if let err = err {
                        print("Failed to load photo for place:", err)
                        return
                    }
                    
                    guard let image = image else { return }
                    
                    if image.size.width > image.size.height {
                        // w1/h1 = w2/h2
                        let newWidth: CGFloat = 300
                        let newHeight = newWidth / image.size.width * image.size.height
                        widthAnchor.constant = newWidth
                        heightAnchor.constant = newHeight
                    } else {
                        let newHeight: CGFloat = 200
                        let newWidth = newHeight / image.size.height * image.size.width
                        widthAnchor.constant = newWidth
                        heightAnchor.constant = newHeight
                    }
                    
                    // how do i put it into the red view
                    let imageView = UIImageView(image: image, contentMode: .scaleAspectFill)
                    customCalloutContainer.addSubview(imageView)
                    imageView.layer.cornerRadius = 5
                    imageView.fillSuperview()
                    
                    // label
                    let labelContainer = UIView(backgroundColor: .white)
                    let nameLabel = UILabel(text: (view.annotation as? PlaceAnnotation)?.place.name, textAlignment: .center)
                    labelContainer.stack(nameLabel)
                    customCalloutContainer.stack(UIView(), labelContainer.withHeight(30))
                }
            }
        }
    
    fileprivate func requestForLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: first.coordinate, span: span)
        mapView.setRegion(region, animated: false)
        
        findNearbyPlaces()
    }
}

struct PlacesController_Previews: PreviewProvider {
    static var previews: some View {
        Container().edgesIgnoringSafeArea(.all)
    }
    
    struct Container: UIViewControllerRepresentable {
        func makeUIViewController(context: UIViewControllerRepresentableContext<PlacesController_Previews.Container>) -> UIViewController {
            PlacesController()
        }
        
        func updateUIViewController(_ uiViewController: PlacesController_Previews.Container.UIViewControllerType, context: UIViewControllerRepresentableContext<PlacesController_Previews.Container>) {
            
        }
    }
}
