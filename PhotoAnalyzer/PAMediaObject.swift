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
    
    dynamic var localIdentifier: String = ""
    dynamic var mediaType: PHAssetMediaType = PHAssetMediaType.image
    dynamic var mediaSubtype: PHAssetMediaSubtype = PHAssetMediaSubtype.photoLive
    dynamic var pixelWidth: Int = -1
    dynamic var pixelHeight: Int = -1
    dynamic var creationDate: Date = Date()
    dynamic var location: Location? = Location()
    dynamic var duration: TimeInterval = TimeInterval(-1.0)
    dynamic var photoSizeMB: Double = -1.0
    
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
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
