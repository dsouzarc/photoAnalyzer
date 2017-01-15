//
//  MainViewController.swift
//  PhotoAnalyzer
//
//  Created by Ryan D'souza on 1/11/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

import Darwin
import UIKit
import RealmSwift
import Photos
import MRProgress

class MainViewController: UIViewController {
    
    static let KB_TO_MB: Double = 1024.0 * 1024.0
    
    let realmDB: Realm!
    
    var progressView: MRProgressOverlayView?
    
    required init(coder: NSCoder) {
        
        self.realmDB = MainViewController.getDefaultRealmDB()
        super.init(coder: coder)!
    }
    
    static func getDefaultRealmDB() -> Realm {
        do {
            return try Realm()
        } catch _ {
            let defaultPath: URL = Realm.Configuration.defaultConfiguration.fileURL!
            try! FileManager.default.removeItem(at: defaultPath)
            return try! Realm()
        }
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
        
        switch PHPhotoLibrary.authorizationStatus() {
            
            case PHAuthorizationStatus.authorized:
                self.addAllPhotosToDB()
                break
        
            case PHAuthorizationStatus.denied, PHAuthorizationStatus.notDetermined, PHAuthorizationStatus.restricted:
                self.getPhotosPermission()
                break
        }
    }
    
    func addAllPhotosToDB() {
        DispatchQueue.global(qos: .userInitiated).async {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.includeHiddenAssets = true
            fetchOptions.includeAllBurstAssets = true
            
            let fetchResults: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: fetchOptions)
            let totalImages: Int = fetchResults.count
            var finishedCount: Int = 0
            var errorCount: Int = 0
            
            DispatchQueue.main.async {
                let totalImagesString: String = NumberFormatter.localizedString(from: NSNumber(value: totalImages), number: NumberFormatter.Style.decimal)
                
                self.progressView = MRProgressOverlayView.showOverlayAdded(to: self.view, title: "Analyzing \(totalImagesString) pictures and videos", mode: MRProgressOverlayViewMode.determinateCircular, animated: true)!
            }
            
            let realmDB = MainViewController.getDefaultRealmDB()
            realmDB.beginWrite()
            realmDB.deleteAll()
            
            let imageManager = PHImageManager.default()
            let photoOptions: PHImageRequestOptions = self.getImageRequestOptions()
            let videoOptions: PHVideoRequestOptions = self.getVideoRequestOptions()
            
            //Refresh progress view for every 1% done (minimum is to update every photo)
            let refreshInterval: Int = Int(ceil(Double(totalImages) * 0.01))
            
            var queuedMedias: [PAMediaObject] = [PAMediaObject]()
            
            fetchResults.enumerateObjects({(item: PHAsset!, count: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in

                autoreleasepool {
                    
                    if(item.mediaType == PHAssetMediaType.video || item.mediaType == PHAssetMediaType.audio || item.mediaType == PHAssetMediaType.unknown) {
                        imageManager.requestAVAsset(forVideo: item, options: videoOptions, resultHandler: {(avAsset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) -> Void in
                            
                            //Media size
                            let urlAsset: AVURLAsset? = avAsset as? AVURLAsset
                            let resources: URLResourceValues? = try! urlAsset?.url.resourceValues(forKeys:[URLResourceKey.totalFileSizeKey, URLResourceKey.totalFileAllocatedSizeKey])
                            
                            if let actualResources = resources {
                                
                                if let fileSize: Int = actualResources.totalFileSize,
                                    let fileAllocatedSize: Int = actualResources.totalFileAllocatedSize {
                                    
                                    let largestSize: Int = fileSize >= fileAllocatedSize ? fileSize : fileAllocatedSize
                                    let largestSizeMB: Double = Double(Double(largestSize) / MainViewController.KB_TO_MB)
                                    
                                    let mediaObject: PAMediaObject = PAMediaObject.init(mediaAsset: item, photoSizeMB: largestSizeMB)
                                    queuedMedias.append(mediaObject)
                                    finishedCount += 1
                                } else {
                                    errorCount += 1
                                }
                            } else {
                                errorCount += 1
                            }
                        })
                    }
                        
                    else if(item.mediaType == PHAssetMediaType.image) {
                        imageManager.requestImageData(for: item, options: photoOptions, resultHandler: {(data: Data?, identificador: String?, imageOrientation: UIImageOrientation, info: [AnyHashable: Any]?) -> Void in
                            
                            //Get the size of the image in MB
                            let imageSize: Double = Double(data!.count) / MainViewController.KB_TO_MB
                            let mediaObject: PAMediaObject = PAMediaObject.init(mediaAsset: item, photoSizeMB: imageSize)
                            
                            finishedCount += 1
                            //queuedMedias.append(mediaObject)
                            realmDB.add(mediaObject)
                            if(finishedCount % refreshInterval == 0) {
                                DispatchQueue.main.async {
                                    self.progressView?.setProgress(Float(finishedCount) / Float(totalImages), animated: true)
                                }
                            }
                        })
                    }
                    
                    else {
                        print("OTHER TYPE HERE: \(item.mediaType.rawValue)")
                        errorCount += 1
                    }
                }
            })
            
            //Wait until we have almost everything
            print("GOT HERE TO WAIT")
            while(Swift.abs(totalImages - (errorCount + finishedCount)) >= 10) {
                //La dee la dee la
                print("WAITING. TOTAL: \(totalImages)\tERROR COUNT: \(errorCount)\tFINISHED: \(finishedCount)\tDIFF: \(Swift.abs(totalImages - (errorCount + finishedCount)))")
            }
            
            print("DONE WAITING")
            
            //Save and commit the video objects
            realmDB.add(queuedMedias)
            queuedMedias.removeAll()
            try! realmDB.commitWrite()
            
            print("JUST FINISHED WRITING!!")
            
            //Update the progress view
            DispatchQueue.main.sync {
                self.progressView?.mode = MRProgressOverlayViewMode.checkmark
                //let circularProgressView: MRCircularProgressView = self.progressView?.modeView as! MRCircularProgressView
                //circularProgressView.valueLabel.text = "\(finishedCount) / \(totalImages)"
                
                //Wait for a bit and then hide it
                DispatchQueue.global(qos: .userInitiated).async {
                    usleep(500000)
                    DispatchQueue.main.sync {
                        self.progressView?.hide(true)
                        
                        let allPhotos = self.realmDB.objects(PAMediaObject)
                        print("Finished \(finishedCount) out of \(totalImages)\tError Count\(errorCount)\tRealm has: \(allPhotos.count)")
                    }
                }
            }
        }
    }
    
    func getVideoRequestOptions() -> PHVideoRequestOptions {
        let videoOptions: PHVideoRequestOptions = PHVideoRequestOptions.init()
        videoOptions.deliveryMode = PHVideoRequestOptionsDeliveryMode.highQualityFormat
        videoOptions.isNetworkAccessAllowed = true
        videoOptions.version = PHVideoRequestOptionsVersion.original
        return videoOptions
    }
    
    func getImageRequestOptions() -> PHImageRequestOptions {
        let photoOptions = PHImageRequestOptions.init()
        photoOptions.isSynchronous = true
        photoOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        photoOptions.isNetworkAccessAllowed = true
        photoOptions.resizeMode = PHImageRequestOptionsResizeMode.none
        photoOptions.version = PHImageRequestOptionsVersion.original
        return photoOptions
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
                        self.addAllPhotosToDB()
                    }
                }
        }, cancelled: {
            results in
            print("Cancelled")
        });
    }
}
