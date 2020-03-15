//
//  LocationsCarouselController.swift
//  Maps_SwiftUI
//
//  Created by 豊岡正紘 on 2020/03/12.
//  Copyright © 2020 Masahiro Toyooka. All rights reserved.
//

import UIKit
import LBTATools
import MapKit

class LocationCell: LBTAListCell<MKMapItem> {
    
    override var item: MKMapItem! {
        didSet {
            label.text = item.name
            addressLabel.text = item.address()
        }
    }
    
    let label = UILabel(text: "Location", font: .boldSystemFont(ofSize: 16))
    let addressLabel = UILabel(text: "Address", numberOfLines: 0)
    
    override func setupViews() {
        backgroundColor = .white
        
        setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .black)
        layer.cornerRadius = 5
//
//        // apply hstack first and alignment center for vertical aligment
        hstack(stack(label, addressLabel, spacing: 12).withMargins(.allSides(16)),
               alignment: .center)
    }
}

class LocationsCarouselController: LBTAListController<LocationCell, MKMapItem> {
    
    weak var mainController: MainController?
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let annotations = mainController?.mapView.annotations
//
//        annotations?.forEach({ (annotation) in
//            guard let customAnnotation = annotation as? MainController.CustomMapItemAnnotation else { return }
//            if customAnnotation.mapItem?.name == self.items[indexPath.item].name {
//                mainController?.mapView.selectAnnotation(annotation, animated: true)
//            }
//        })
//
//        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(self.items[indexPath.item].name)
        
        let annotations = mainController?.mapView.annotations
        
        annotations?.forEach({ (annotation) in
            if annotation.title == items[indexPath.item].name {
                mainController?.mapView.selectAnnotation(annotation, animated: true)
            }
        })
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
//        let placemark1 = MKPlacemark(coordinate: .init(latitude: 10, longitude: 55))
//        let placemark2 = MKPlacemark(coordinate: .init(latitude: 10, longitude: 55))
//        let placemark3 = MKPlacemark(coordinate: .init(latitude: 10, longitude: 55))
//
//        let dummyMapItem1 = MKMapItem(placemark: placemark1)
//        let dummyMapItem2 = MKMapItem(placemark: placemark2)
//        let dummyMapItem3 = MKMapItem(placemark: placemark3)
//
//        dummyMapItem1.name = "Dummy location for example"
//        dummyMapItem2.name = "Dummy location for example"
//        dummyMapItem3.name = "Dummy location for example"
//
//        self.items = [dummyMapItem1, dummyMapItem2, dummyMapItem3]
    }
}

extension LocationsCarouselController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width - 64, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
}