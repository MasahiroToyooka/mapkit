//
//  MainController.swift
//  Maps_SwiftUI
//
//  Created by 豊岡正紘 on 2020/03/11.
//  Copyright © 2020 Masahiro Toyooka. All rights reserved.
//

import UIKit
import MapKit
import LBTATools

extension MainController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
        annotationView.canShowCallout = true
//        annotationView.image = #imageLiteral(resourceName: "pin")
        return annotationView
    }
}

class MainController: UIViewController {
    
    let mapView = MKMapView()
    let searchTextField = UITextField(placeholder: "ここで検索")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.fillSuperview()
        
        setupRegionForMap()
        performLocalSearch()
//        setupAnnotationsForMap()
        setupSearchUI()
        setupLocationCarousel()
    }
    
    let locationsController = LocationsCarouselController(scrollDirection: .horizontal)
    
    fileprivate func setupLocationCarousel() {
        let locationView = locationsController.view!
        view.addSubview(locationView)
        locationView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: 150))
        
    }
    
    fileprivate func setupSearchUI() {
        let whiteContainer = UIView(backgroundColor: .white)
        
        view.addSubview(whiteContainer)
        whiteContainer.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: 50))
        
        whiteContainer.stack(searchTextField).withMargins(.allSides(16))
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { (_) in
                self.performLocalSearch()
        }
    }
    
    fileprivate func performLocalSearch() {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
        request.region = mapView.region
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { (resp, err) in
            if let err = err {
                print("failed local search",err)
                return
            }
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            resp?.mapItems.forEach({ (mapItem) in
                print(mapItem.address())
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
            })
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
    
    fileprivate func setupRegionForMap() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    fileprivate func setupAnnotationsForMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        annotation.title = "Title aaaaaaa"
        annotation.subtitle = "subtitleaaaaaaa"
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
}

extension MKMapItem {
    func address() -> String {
        //位置情報
        let administrativeArea = placemark.administrativeArea == nil ? "" : placemark.administrativeArea!
        let locality = placemark.locality == nil ? "" : placemark.locality!
        let subLocality = placemark.subLocality == nil ? "" : placemark.subLocality!
        let thoroughfare = placemark.thoroughfare == nil ? "" : placemark.thoroughfare!
        let subThoroughfare = placemark.subThoroughfare == nil ? "" : placemark.subThoroughfare!
        let placeName = !thoroughfare.contains( subLocality ) ? subLocality : thoroughfare

        //住所
        let address = administrativeArea + locality + placeName + subThoroughfare
        return address
    }
}
// SwiftUI

import SwiftUI

struct MainPreview: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        func makeUIViewController(context: UIViewControllerRepresentableContext<MainPreview.ContainerView>) -> MainController {
            return MainController()
        }
        
        func updateUIViewController(_ uiViewController: MainController, context: UIViewControllerRepresentableContext<MainPreview.ContainerView>) {
        }
        
        typealias UIViewControllerType = MainController
    }
}
