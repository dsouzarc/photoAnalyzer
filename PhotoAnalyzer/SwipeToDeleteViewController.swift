//
//  SwipeToDeleteViewController.swift
//  PhotoAnalyzer
//
//  Created by Ryan D'souza on 12/21/16.
//  Copyright © 2016 Ryan D'souza. All rights reserved.
//

import Foundation
import Photos


class SwipeToDeleteViewController: ViewController {
    
    func getPhotosPermission() {
        let singlePscope = PermissionScope()
        singlePscope.addPermission(PhotosPermission(), message: "So that we can analyze your photos")
        singlePscope.show(
            { finished, results in
                for result: PermissionResult in results {
                    if result.type == PermissionType.photos && result.status == PermissionStatus.authorized {
                        self.getPhotos()
                    }
                }
            }, cancelled: {
                results in
                    print("Cancelled")
            }
        );
    }
    
    func getPhotos() {
        var photoManager = PHPhotoLibrary.shared()
        
        let assets = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: nil)
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = true
        fetchOptions.includeAllBurstAssets = true
        fetchOptions.includeAssetSourceTypes = PHAssetSourceType.typeUserLibrary
        
        let fetchResults = PHAssetCollection.fetchMoments(with: fetchOptions)
        
        //For moments
        var totalImages = 0
        
        for fetchIndex in 0 ... fetchResults.count - 1 {
            let item: PHAssetCollection = fetchResults.object(at: fetchIndex)
            print("Type: \(item.assetCollectionType) on \(item.startDate) to \(item.endDate)")
            print("Size: \(item.estimatedAssetCount)")
            totalImages += item.estimatedAssetCount
            
        }
        print("Total: \(totalImages)")
        
        
        let fet2 = PHFetchOptions()
        fet2.includeHiddenAssets = true
        fet2.includeAllBurstAssets = true
        //fet2.includeAssetSourceTypes = PHAssetSourceType.typeUserLibrary
        let fetchResults2 = PHAsset.fetchAssets(with: fet2)
        print(fetchResults2)
        totalImages = 0
        
        let photoOptions = PHImageRequestOptions.init()
        photoOptions.isSynchronous = true
        photoOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        photoOptions.isNetworkAccessAllowed = true
        photoOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        photoOptions.version = PHImageRequestOptionsVersion.original
        
        
        for fetchIndex in 0 ... fetchResults2.count - 1 {
            let item: PHAsset = fetchResults2.object(at: fetchIndex)
            
            PHImageManager.default().requestImageData(for: item, options: photoOptions, resultHandler: {(data: Data?, identificador: String?, orientaciomImage: UIImageOrientation, info: [AnyHashable: Any]?) -> Void in
                //transform into image
            
            //Get bytes size of image
            var imageSize = Float(data!.count)
            
                //Transform into Megabytes
                imageSize = imageSize/(1024*1024)
                print("HERE: Date: \(item.creationDate!) isHidden: \(item.isHidden)\tSIZE: \(imageSize)")
            })
    
            totalImages += 1
        }
        print("Total: \(totalImages)")
        
        //let fetchResults = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [PHAsset.camera], options: nil)
        
        //PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: fetchOptions)
        /*
         print("RESULT: \(fetchResults.count)")
         print(fetchResults.firstObject)
         
         for fetchIndex in 0 ... fetchResults.count - 1 {
         var item: PHAssetCollection = fetchResults.object(at: fetchIndex)
         print("Type: \(item.assetCollectionType) on \(item.startDate) to \(item.endDate)")
         }
         
         print("RESULT: \(fetchResults.count)")
         */
        
        
        
        //PHAssetCollection.fetchMoments(with: )
        
        
        var imageManager = PHImageManager.default()
        
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPhotosPermission()
        
        
        /*let vc = BSImagePickerViewController()
         
         bs_presentImagePickerController(vc, animated: true,
         select: { (asset: PHAsset) -> Void in
         // User selected an asset.
         // Do something with it, start upload perhaps?
         }, deselect: { (asset: PHAsset) -> Void in
         // User deselected an assets.
         // Do something, cancel upload?
         }, cancel: { (assets: [PHAsset]) -> Void in
         // User cancelled. And this where the assets currently selected.
         }, finish: { (assets: [PHAsset]) -> Void in
         // User finished with these assets
         }, completion: nil)
         */
        
    }
}

