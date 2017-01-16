//
//  RealmDBManager.swift
//  PhotoAnalyzer
//
//  Created by Ryan D'souza on 1/16/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDBManager {
    
    public static func getRealmDBInstance() -> Realm {
        do {
            return try Realm()
        } catch _ {
            let defaultPath: URL = Realm.Configuration.defaultConfiguration.fileURL!
            try! FileManager.default.removeItem(at: defaultPath)
            return try! Realm()
        }
    }
    
    public static func getAllPhotosOrderedBySize(realmDB: Realm) -> Results<PAMediaObject> {
        let results: Results<PAMediaObject> = realmDB.objects(PAMediaObject.self).sorted(byProperty: "photoSizeMB", ascending: false)
        return results;
    }
    
}
