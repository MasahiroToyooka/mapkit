//
//  LocationSearchController.swift
//  Maps_SwiftUI
//
//  Created by 豊岡正紘 on 2020/03/19.
//  Copyright © 2020 Masahiro Toyooka. All rights reserved.
//

import SwiftUI
import UIKit
import LBTATools
import MapKit
import Combine


class LocationSearchCell: LBTAListCell<MKMapItem> {
    
    override var item: MKMapItem! {
        didSet {
            nameLabel.text = item.name
            addressLabel.text = item.address()
        }
    }
    
    let nameLabel = UILabel(text: "name", font: .boldSystemFont(ofSize: 16))
    let addressLabel = UILabel(text: "address", font: .boldSystemFont(ofSize: 16))


    override func setupViews() {
        
        stack(nameLabel, addressLabel).withMargins(.allSides(16))
        addSeparatorView(leftPadding: 16)
    }
}

class LocationSearchController: LBTAListController<LocationSearchCell, MKMapItem> {
    
    var selectionHandler: ((MKMapItem) -> ())?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        let mapItem = self.items[indexPath.item]
        selectionHandler?(mapItem)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.becomeFirstResponder()
        
//        performLocalSearch()
        setupSearchBar()
    }
    
    let backIcon = UIButton(image: #imageLiteral(resourceName: "back_arrow"), tintColor: .black, target: self, action: #selector(handleBack)).withWidth(28)
    let searchTextField = IndentedTextField(placeholder: "ここで検索", padding: 12)
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    let navBarHeight: CGFloat = 66
    
    fileprivate func setupSearchBar() {
        let searchBar = UIView(backgroundColor: .clear)
        view.addSubview(searchBar)
        searchBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view
            .trailingAnchor, size: .init(width: 0, height: navBarHeight))
        
        searchBar.hstack(backIcon, searchTextField, spacing: 12).withMargins(.init(top: 0, left: 16, bottom: 16, right: 16))
        searchTextField.layer.borderWidth = 2
        searchTextField.layer.borderColor = UIColor.lightGray.cgColor
        searchTextField.layer.cornerRadius = 5
        
        setupSearchListener()
    }
    
    var listener: AnyCancellable!
    
    fileprivate func setupSearchListener() {
        listener = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] (_) in
                self?.performLocalSearch()
        }
//        listener.cancel()
    }

    fileprivate func performLocalSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
        let search = MKLocalSearch.init(request: request)
        
        search.start { (resp, err) in
            self.items = resp?.mapItems ?? []
        }
    }
}

extension LocationSearchController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: navBarHeight, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 70)
    }
}

struct LocationSearchController_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<LocationSearchController_Previews.ContainerView>) -> UIViewController {
            return LocationSearchController()
        }
        
        func updateUIViewController(_ uiViewController: LocationSearchController_Previews.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<LocationSearchController_Previews.ContainerView>) {
        }
    }
}
