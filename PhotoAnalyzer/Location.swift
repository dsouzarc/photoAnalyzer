//
//  Location.swift
//  PhotoAnalyzer
//
//  Created by Ryan D'souza on 1/11/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

import UIKit
import Photos
import Foundation
import RealmSwift
import Realm

class Location: Object {
    
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    
    static func createLocation(clLocation: CLLocation) -> Location {
        let location: Location = Location()
        location.latitude = clLocation.coordinate.latitude
        location.longitude = clLocation.coordinate.longitude
        return location
    }
}
