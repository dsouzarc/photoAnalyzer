//
//  PAMediaObject.swift
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

class PAMediaObject: Object {
    
    dynamic var localIdentifier: String
    dynamic var mediaType: PHAssetMediaType
    dynamic var mediaSubtype: PHAssetMediaSubtype
    dynamic var pixelWidth: Int
    dynamic var pixelHeight: Int
    dynamic var creationDate: Date
    dynamic var location: Location?
    dynamic var duration: TimeInterval
    dynamic var photoSizeMB: Double
    
    required init() {
        self.localIdentifier = "test_value"
        self.mediaType = PHAssetMediaType.image
        self.mediaSubtype = PHAssetMediaSubtype.photoLive
        self.pixelWidth = -1
        self.pixelHeight = -1
        self.creationDate = Date()
        self.location = Location()
        self.duration = TimeInterval(-1.0)
        self.photoSizeMB = -1.0
        super.init()
    }
    
    required convenience init(realm: RLMRealm, schema: RLMObjectSchema) {
        self.init()
    }
    
    required convenience init(value: Any, schema: RLMSchema) {
        self.init()
    }
    
    init(localIdentifier: String, mediaType: PHAssetMediaType, mediaSubtype: PHAssetMediaSubtype, pixelWidth: Int, pixelHeight: Int, creationDate: Date, location: CLLocation, duration: TimeInterval, photoSizeMB: Double) {
        self.localIdentifier = localIdentifier
        self.mediaType = mediaType
        self.mediaSubtype = mediaSubtype
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.creationDate = creationDate
        self.location = Location.createLocation(clLocation: location)
        self.duration = duration
        self.photoSizeMB = photoSizeMB
        
        super.init()
    }
    
    convenience init(mediaAsset: PHAsset, photoSizeMB: Double) {
        self.init(localIdentifier: mediaAsset.localIdentifier,
                  mediaType: mediaAsset.mediaType,
                  mediaSubtype: mediaAsset.mediaSubtypes,
                  pixelWidth: mediaAsset.pixelWidth,
                  pixelHeight: mediaAsset.pixelHeight,
                  creationDate: mediaAsset.creationDate!,
                  location: (mediaAsset.location != nil ? mediaAsset.location!: CLLocation.init()),
                  duration: mediaAsset.duration,
                  photoSizeMB: photoSizeMB)
        
    }
    
    override static func primaryKey() -> String {
        return "localIdentifier"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["mediaSubtype"]
    }

}
