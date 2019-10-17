//
//  YLPBusiness+MKAnnotation.swift
//  ios-code-challenge
//
//  Created by Ryan Novak on 2019-10-12.
//  Copyright © 2019 Dustin Lange. All rights reserved.
//

import Foundation
import MapKit

extension YLPBusiness: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(coordinates["latitude"]?.doubleValue ?? 0, coordinates["longitude"]?.doubleValue ?? 0)
    }
    
    public var title: String? {
        get {
            return name
        }
    }
}
