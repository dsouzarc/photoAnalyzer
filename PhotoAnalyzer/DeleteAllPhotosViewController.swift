//
//  DeleteAllPhotosViewController.swift
//  PhotoAnalyzer
//
//  Created by Ryan D'souza on 12/26/16.
//  Copyright © 2016 Ryan D'souza. All rights reserved.
//

import Foundation
import Photos
import MRProgress
import RealmSwift

let mainTableViewCellIdentifier: String = "mainTableViewCellIdentifier"


class DeleteAllPhotosViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var allPhotosTableView: UITableView!
    
    let realmDBInstance: Realm
    let photoManager: PHImageManager
    let photoFetchOptions: PHFetchOptions
    
    var allPhotos: Results<PAMediaObject>?
    
    var progressView: MRProgressOverlayView?
    
    
    required init?(coder aDecoder: NSCoder) {
        
        self.photoManager = PHImageManager.default()
        self.realmDBInstance = RealmDBManager.getRealmDBInstance()
        self.allPhotos = RealmDBManager.getAllPhotosOrderedBySize(realmDB: self.realmDBInstance)
        
        self.photoFetchOptions = PHFetchOptions()
        self.photoFetchOptions.includeHiddenAssets = true
        self.photoFetchOptions.includeAllBurstAssets = true
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        self.allPhotosTableView.delegate = self
        self.allPhotosTableView.dataSource = self
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allPhotos!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: mainTableViewCellIdentifier, for: indexPath)
        
        if cell.tag != 0 {
            self.photoManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        let photo: PAMediaObject = self.allPhotos![indexPath.row]
        
        cell.textLabel?.text = "\(photo.creationDate)"
        
        let fetchResults: PHFetchResult<PHAsset> = PHAsset.fetchAssets(withLocalIdentifiers: [photo.localIdentifier], options: self.photoFetchOptions)
        
        let actualAsset: PHAsset? = fetchResults.firstObject
        
        let imageRequestID: PHImageRequestID = self.photoManager.requestImage(for: actualAsset!, targetSize: CGSize.init(width: 100.0, height: 100.0), contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: {(image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            
            if let destinationCell = tableView.cellForRow(at: indexPath) {
                destinationCell.imageView?.image = image
            }
        });
        
        cell.tag = Int(imageRequestID)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
