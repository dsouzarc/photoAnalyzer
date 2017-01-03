//
//  DeleteAllPhotosViewController.swift
//  PhotoAnalyzer
//
//  Created by Ryan D'souza on 12/26/16.
//  Copyright © 2016 Ryan D'souza. All rights reserved.
//

import Foundation
import Photos


class DeleteAllPhotosViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var allPhotosTableView: UITableView!
    
    let mainTableViewCellIdentifier: String = "mainTableViewCellIdentifier"
    
    var allPhotos = [PHAsset]()
    
    
    override func viewDidLoad() {
        
        self.allPhotosTableView.delegate = self
        self.allPhotosTableView.dataSource = self
        
        
        let fet2 = PHFetchOptions()
        fet2.includeHiddenAssets = true
        fet2.includeAllBurstAssets = true
        //fet2.includeAssetSourceTypes = PHAssetSourceType.typeUserLibrary
        let fetchResults2 = PHAsset.fetchAssets(with: fet2)
        print(fetchResults2)
        var totalImages = 0
        for fetchIndex in 0 ... fetchResults2.count - 1 {
            let item: PHAsset = fetchResults2.object(at: fetchIndex)
            
            print("Date: \(item.creationDate) isHidden: \(item.isHidden)")
            totalImages += 1
        }
        print("Total: \(totalImages)")

    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("CALLED")
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 60;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: mainTableViewCellIdentifier, for: indexPath)
        
        cell.textLabel?.text = "Testing"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
}



