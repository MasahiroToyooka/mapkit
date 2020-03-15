//
//  MKMapItem+address.swift
//  Maps_SwiftUI
//
//  Created by 豊岡正紘 on 2020/03/12.
//  Copyright © 2020 Masahiro Toyooka. All rights reserved.
//

import MapKit


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
