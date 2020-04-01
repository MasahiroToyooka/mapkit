
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
import JGProgressHUD

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
        
        setupShowRouteButton()
    }
    
    fileprivate func setupShowRouteButton() {
        
        let showRouteButton = UIButton(title: "ルート検索", titleColor: .black, font: .boldSystemFont(ofSize: 18), backgroundColor: .white, target: self, action: #selector(handleShowRoute))
        view.addSubview(showRouteButton)
        showRouteButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .allSides(16), size: .init(width: 0, height: 50))
    }
    
    @objc func handleShowRoute() {
        let routesControoler = RoutesController()
        routesControoler.route = cuurentlyShowingRoute
        
        routesControoler.items = self.cuurentlyShowingRoute?.steps.filter {!$0.instructions.isEmpty} ?? []
        present(routesControoler, animated: true)
    }
    
    class RouteStepCell: LBTAListCell<MKRoute.Step> {
        
        override var item: MKRoute.Step! {
            didSet {
                nameLabel.text = item.instructions
                let milesConversion = item.distance * 0.00062137
                distanceLabel.text = String(format: "%.2f mi", milesConversion)            }
        }
        
        let nameLabel = UILabel(text: "name", numberOfLines: 0)
        let distanceLabel = UILabel(text: "distance", textAlignment: .right)
        
        override func setupViews() {
            hstack(nameLabel, distanceLabel.withWidth(80)).withMargins(.allSides(16))
            
            addSeparatorView(leadingAnchor: nameLabel.leadingAnchor)
        }
    }
    

    
    class RoutesController: LBTAListHeaderController<RouteStepCell, MKRoute.Step, RouteHeader>, UICollectionViewDelegateFlowLayout {
        
        var route: MKRoute!
        
        override func setupHeader(_ header: RouteHeader) {
            header.setupHeaderInformation(route: route)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return .init(width: 0, height: 120)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return .init(width: view.frame.width, height: 70)
        }
    }
    
    fileprivate func requestForDirections() {
        
        let request = MKDirections.Request()
//        request.requestsAlternateRoutes = true
//        request.transportType = .walking
        
        request.source = startMapItem
        request.destination = endMapItem
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "検索中..."
        hud.show(in: view)
        
        let directions = MKDirections(request: request)
        directions.calculate { (resp, err) in
            hud.dismiss()
            if let error = err {
                print("Failed to find routing info:", error)
                return
            }
            
            if let firstRoute = resp?.routes.first {
                self.mapView.addOverlay(firstRoute.polyline)
            }
            self.cuurentlyShowingRoute = resp?.routes.first
        }
    }
    
    var cuurentlyShowingRoute: MKRoute?
    
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
        endTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChangeEndLocation)))

        navigationController?.navigationBar.isHidden = true
    }
    
    var startMapItem: MKMapItem?
    var endMapItem: MKMapItem?
    
    @objc func handleChangeStartLocation() {
        let vc = LocationSearchController()
        vc.selectionHandler = { [weak self] mapItem in
            self?.startTextField.text = mapItem.name
            self?.startMapItem = mapItem
            self?.refreshMap()
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshMap() {
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        if let mapItem = startMapItem {
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapItem.placemark.coordinate
            annotation.title = mapItem.name
            self.mapView.addAnnotation(annotation)
            self.mapView.showAnnotations(mapView.annotations, animated: false)
        }
        
        if let mapItem = endMapItem {
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapItem.placemark.coordinate
            annotation.title = mapItem.name
            self.mapView.addAnnotation(annotation)
        }
        
        requestForDirections()
        self.mapView.showAnnotations(mapView.annotations, animated: false)
    }
    
    @objc func handleChangeEndLocation() {
        let vc = LocationSearchController()
        vc.selectionHandler = { [weak self] mapItem in
            self?.endTextField.text = mapItem.name
            
            self?.endMapItem = mapItem
            self?.refreshMap()
        }
        
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

