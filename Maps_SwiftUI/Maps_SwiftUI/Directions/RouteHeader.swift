//
//  RouteHeader.swift
//  Maps_SwiftUI
//
//  Created by 豊岡正紘 on 2020/03/30.
//  Copyright © 2020 Masahiro Toyooka. All rights reserved.
//

import SwiftUI
import MapKit

class RouteHeader: UICollectionReusableView {
    
    let nameLabel = UILabel(text: "route name", font: .systemFont(ofSize: 16))
    let distanceLabel = UILabel(text: "distance", font: .systemFont(ofSize: 16))
    let estimatedTimeLabel = UILabel(text: "estimate", font: .systemFont(ofSize: 16))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        hstack(stack(nameLabel, distanceLabel, estimatedTimeLabel, spacing: 8), alignment: .center).withMargins(.allSides(16))
    }
    
    func setupHeaderInformation(route: MKRoute) {
        nameLabel.attributedText = generateAttributedString(title: "Route", description: route.name)
        
        let milesDistance = route.distance * 0.00062137
        
        let milesString = String(format: "%.2f mi", milesDistance)
        
        distanceLabel.attributedText = generateAttributedString(title: "Distance", description: milesString)
        
        var timeString = ""
        if route.expectedTravelTime > 3600 {
            let h = Int(route.expectedTravelTime / 60 / 60)
            let m = Int((route.expectedTravelTime.truncatingRemainder(dividingBy: 60 * 60)) / 60)
            timeString = String(format: "%d hr %d min", h, m)
        } else {
            let time = Int(route.expectedTravelTime / 60)
            timeString = String(format: "%d min", time)
        }

        estimatedTimeLabel.attributedText = generateAttributedString(title: "Est Time", description: timeString)
    }
    
    fileprivate func generateAttributedString(title: String, description: String) -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: title + ":  ", attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
        attributeString.append(.init(string: description, attributes: [.font: UIFont.systemFont(ofSize: 16)]))
        return attributeString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct RouteHeader_Previews: PreviewProvider {
    static var previews: some View {
        
        Container()
    }
    
    struct Container: UIViewRepresentable {
        
        func makeUIView(context: UIViewRepresentableContext<RouteHeader_Previews.Container>) -> UIView {
            RouteHeader()
        }
        
        func updateUIView(_ uiView: RouteHeader_Previews.Container.UIViewType, context: UIViewRepresentableContext<RouteHeader_Previews.Container>) {
        }
    }
}
