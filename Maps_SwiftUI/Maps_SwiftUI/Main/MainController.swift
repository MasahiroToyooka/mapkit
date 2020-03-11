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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.fillSuperview()
        
        setupRegionForMap()
        performLocalSearch()
//        setupAnnotationsForMap()
    }
    
    fileprivate func performLocalSearch() {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "apple"
        request.region = mapView.region
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { (resp, err) in
            if let err = err {
                print("failed local search",err)
                return
            }
            resp?.mapItems.forEach({ (mapItem) in
                print(mapItem.placemark.subThoroughfare ?? "")
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
            })
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
    
    fileprivate func setupRegionForMap() {
        let coordinate = CLLocationCoordinate2D(latitude: 35.609687, longitude: 139.667391)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    fileprivate func setupAnnotationsForMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 35.609687, longitude: 139.667391)
        annotation.title = "Title aaaaaaa"
        annotation.subtitle = "subtitleaaaaaaa"
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(self.mapView.annotations, animated: true)
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
