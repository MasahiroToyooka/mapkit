
//
//  DirectionsController.swift
//  Maps_SwiftUI
//
//  Created by 豊岡正紘 on 2020/03/16.
//  Copyright © 2020 Masahiro Toyooka. All rights reserved.
//

import UIKit
import MapKit
import LBTATools
import SwiftUI

class DirectionsController: UIViewController, MKMapViewDelegate{
     
    let mapView = MKMapView()
    let navBar = UIView(backgroundColor: #colorLiteral(red: 0.257361412, green: 0.5245243907, blue: 0.9635449052, alpha: 1))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.delegate = self
        setupRegionForMap()
        
        setupNavBarUI()
        mapView.anchor(top: navBar.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)

        mapView.showsUserLocation = true
        setupStartEndDummyAnnotations()
        requestForDirections()
    }
    
    fileprivate func setupStartEndDummyAnnotations() {
        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = .init(latitude: 35.691574, longitude: 139.704647)
        startAnnotation.title = "Start"
        
        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = .init(latitude: 35.4437, longitude: 139.638)
        endAnnotation.title = "End"
        
        mapView.addAnnotation(startAnnotation)
        mapView.addAnnotation(endAnnotation)
        
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    fileprivate func requestForDirections() {
        
        let request = MKDirections.Request()
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let startPlacemark = MKPlacemark(coordinate: .init(latitude: 35.691574, longitude: 139.704647))
        request.source = .init(placemark: startPlacemark)
        
        let endPlacemark = MKPlacemark(coordinate: .init(latitude: 35.4437, longitude: 139.638))
        request.destination = .init(placemark: endPlacemark)
        
        let directions = MKDirections(request: request)
        directions.calculate { (resp, err) in
            if let error = err {
                print("Failed to find routing info:", error)
                return
            }
            resp?.routes.forEach({ (route) in
                self.mapView.addOverlay(route.polyline)
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }
    
    let startTextField = IndentedTextField(placeholder: "start", padding: 12, cornerRadius: 5)
    let endTextField = IndentedTextField(placeholder: "end", padding: 12, cornerRadius: 5)
    
    let textfield = UITextField(backgroundColor: .red)
    fileprivate func setupNavBarUI() {
        navBar.setupShadow(opacity: 0.5, radius: 5 )
        view.addSubview(navBar)
        
        navBar.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -120, right: 0))
        
        startTextField.attributedPlaceholder = .init(string: "Start", attributes: [.foregroundColor : UIColor.init(white: 1, alpha: 0.7)])
        endTextField.attributedPlaceholder = .init(string: "End", attributes: [.foregroundColor : UIColor.init(white: 1, alpha: 0.7)])
        [startTextField, endTextField].forEach { (tf) in
            tf.backgroundColor = .init(white: 1, alpha: 0.2)
            tf.textColor = .white
        }
        
        let containerView = UIView(backgroundColor: .clear)
        navBar.addSubview(containerView)
        containerView.fillSuperviewSafeAreaLayoutGuide()
        
        let startImageView = UIImageView(image: #imageLiteral(resourceName: "start_location_circles"), contentMode: .scaleAspectFit)
        startImageView.constrainWidth(20)
        
        let endImageView = UIImageView(image: #imageLiteral(resourceName: "annotation_icon").withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        endImageView.constrainWidth(20)
        endImageView.tintColor = .white

        containerView.stack(
            containerView.hstack(startImageView, startTextField, spacing: 16),
            containerView.hstack(endImageView, endTextField, spacing: 16),
            spacing: 20,
            distribution: .fillEqually
        ).withMargins(.init(top: 0, left: 12, bottom: 12, right: 12))
        
        startTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChangeStartLocation)))
        
        navigationController?.navigationBar.isHidden = true
    }
    
    @objc func handleChangeStartLocation() {
        let vc = UIViewController()
        vc.view.backgroundColor = .yellow
        
        let button = UIButton(title: "back", titleColor: .black, font: .boldSystemFont(ofSize: 14), backgroundColor: .clear, target: self, action: #selector(handleBack))
        vc.view.addSubview(button)
        button.fillSuperview()
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupRegionForMap() {
        let coordinate = CLLocationCoordinate2D(latitude: 35.362222, longitude: 138.731388)
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

struct DirectionsPreview: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
            .environment(\.colorScheme, .light)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<DirectionsPreview.ContainerView>) -> UIViewController {
            return UINavigationController(rootViewController: DirectionsController())
        }
        
        func updateUIViewController(_ uiViewController: DirectionsPreview.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<DirectionsPreview.ContainerView>) {
        }
    }
}

