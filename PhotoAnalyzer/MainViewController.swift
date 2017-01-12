//
//  MainViewController.swift
//  PhotoAnalyzer
//
//  Created by Ryan D'souza on 1/11/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

import UIKit
import RealmSwift
import Photos
import MRProgress

class MainViewController: UIViewController {
    
    static let KB_TO_MB: Double = 1024.0 * 1024.0
    
    let realmDB: Realm!
    
    var progressView: MRProgressOverlayView?
    
    required init(coder: NSCoder) {
        
        do {
            try self.realmDB = Realm()
        } catch _ {
            let defaultPath: URL = Realm.Configuration.defaultConfiguration.fileURL!
            try! FileManager.default.removeItem(at: defaultPath)
            try! self.realmDB = Realm()
        }
        
        super.init(coder: coder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func viewAllPhotosAction(_ sender: Any) {
        let swipeToDeleteStoryBoard = UIStoryboard.init(name: "Deletion", bundle: nil)
        let swipeToDeleteVC = swipeToDeleteStoryBoard.instantiateInitialViewController()
        
        self.view.window?.rootViewController  = swipeToDeleteVC;

    }
    
    @IBAction func refreshMediaButton(_ sender: Any) {
        
        self.getPhotosPermission()
        self.progressView = MRProgressOverlayView.showOverlayAdded(to: self.view, title: "Analyzing your media", mode: MRProgressOverlayViewMode.determinateCircular, animated: true)!
        let circularProgressView: MRCircularProgressView = self.progressView?.modeView as! MRCircularProgressView
        
        self.realmDB.beginWrite()
        self.realmDB.deleteAll()
        
        let imageManager = PHImageManager.default()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = true
        fetchOptions.includeAllBurstAssets = true
        
        let photoOptions = PHImageRequestOptions.init()
        photoOptions.isSynchronous = true
        photoOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        photoOptions.isNetworkAccessAllowed = true
        photoOptions.resizeMode = PHImageRequestOptionsResizeMode.none
        photoOptions.version = PHImageRequestOptionsVersion.original
        
        let videoOptions: PHVideoRequestOptions = PHVideoRequestOptions.init()
        videoOptions.deliveryMode = PHVideoRequestOptionsDeliveryMode.highQualityFormat
        videoOptions.isNetworkAccessAllowed = true
        videoOptions.version = PHVideoRequestOptionsVersion.original
        
        let fetchResults = PHAsset.fetchAssets(with: fetchOptions)
        let totalImages = fetchResults.count
        var finishedCount: Int = 0
        
        var queuedMedias: [PAMediaObject] = [PAMediaObject]()
        
        fetchResults.enumerateObjects({(item: PHAsset!, count: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            
            autoreleasepool {
                
                if(item.mediaType == PHAssetMediaType.video || item.mediaType == PHAssetMediaType.audio || item.mediaType == PHAssetMediaType.unknown) {
                    imageManager.requestAVAsset(forVideo: item, options: nil, resultHandler: {(avAsset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) -> Void in
                        
                        //Media size
                        let urlAsset: AVURLAsset = avAsset as! AVURLAsset
                        let resources: URLResourceValues = try! urlAsset.url.resourceValues(forKeys:[URLResourceKey.totalFileSizeKey, URLResourceKey.totalFileAllocatedSizeKey])
                        
                        //Get the largest attribute and convert it to MB
                        var fileSize: Double = Double(resources.totalFileSize! > resources.totalFileAllocatedSize! ? resources.totalFileSize! : resources.totalFileAllocatedSize!)
                        fileSize = fileSize / MainViewController.KB_TO_MB
                        
                        let mediaObject: PAMediaObject = PAMediaObject.init(mediaAsset: item, photoSizeMB: fileSize)
                        queuedMedias.append(mediaObject)
                        finishedCount += 1
                        
                        self.progressView?.setProgress(Float(finishedCount / totalImages), animated: true)
                        circularProgressView.valueLabel.text = "\(finishedCount) / \(totalImages)"
                    })
                }
                
                else if(item.mediaType == PHAssetMediaType.image) {
                    imageManager.requestImageData(for: item, options: photoOptions, resultHandler: {(data: Data?, identificador: String?, imageOrientation: UIImageOrientation, info: [AnyHashable: Any]?) -> Void in
                        
                        //Get the size of the image in MB
                        let imageSize: Double = Double(data!.count) / MainViewController.KB_TO_MB
                        let mediaObject: PAMediaObject = PAMediaObject.init(mediaAsset: item, photoSizeMB: imageSize)
                        
                        finishedCount += 1
                        self.realmDB.add(mediaObject)
                        
                        self.progressView?.setProgress(Float(finishedCount / totalImages), animated: true)
                        circularProgressView.valueLabel.text = "\(finishedCount) / \(totalImages)"
                    })
                }
            }
        })
        
        //Wait
        while(finishedCount != totalImages) {
            //La dee la dee laaaa
        }
        
        self.realmDB.add(queuedMedias)
        queuedMedias.removeAll()
        
        self.progressView?.setProgress(1.0, animated: true)
        try! self.realmDB.commitWrite()
        var allPhotos = self.realmDB.objects(PAMediaObject)
        print("Finished \(finishedCount) out of \(totalImages)\tRealm has: \(allPhotos.count)")

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getPhotosPermission() {
        let singlePscope = PermissionScope()
        singlePscope.addPermission(PhotosPermission(), message: "So that we can analyze your photos")
        singlePscope.show(
            { finished, results in
                for result: PermissionResult in results {
                    if result.type == PermissionType.photos && result.status == PermissionStatus.authorized {
                    }
                }
        }, cancelled: {
            results in
            print("Cancelled")
        });
    }
}
