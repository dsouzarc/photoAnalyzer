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

class DeleteAllPhotosViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var allPhotosTableView: UITableView!
    
    let mainTableViewCellIdentifier: String = "mainTableViewCellIdentifier"
    
    var allPhotos = [PHAsset]()
    var progressView: MRProgressOverlayView?
    
    override func viewDidLoad() {
        
        self.allPhotosTableView.delegate = self
        self.allPhotosTableView.dataSource = self
        
        if self.allPhotos.isEmpty {
            self.progressView = MRProgressOverlayView.showOverlayAdded(to: self.view, title: "Analyzing your photos", mode: MRProgressOverlayViewMode.determinateCircular, animated: true)
            
        }
        

        
        
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: mainTableViewCellIdentifier, for: indexPath)
        
        cell.textLabel?.text = "Testing"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MEMORY WARNING")
    }
    
    
    
}



