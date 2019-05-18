//
//  PermissionsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 6.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit
import MediaPlayer

class PermissionsViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Media authorization
        demandMediaAuthorization()
    }
    
    private func demandMediaAuthorization() {
        if MPMediaLibrary.authorizationStatus() != .authorized
        {
            // Request permission to read the media library
            MPMediaLibrary.requestAuthorization({(status:MPMediaLibraryAuthorizationStatus) -> Void in
                self.handleMediaAuthorization(status)
            })
        }
        else
        {
            handleMediaAuthorizationAllowed()
        }
    }
    
    private func handleMediaAuthorization(_ status: MPMediaLibraryAuthorizationStatus) {
        if status != .authorized
        {
            handleMediaAuthorizationDenied()
            return
        }
        
        handleMediaAuthorizationAllowed()
    }
    
    private func handleMediaAuthorizationAllowed() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "start", sender: self)
        }
    }
    
    private func handleMediaAuthorizationDenied() {
        DispatchQueue.main.async {
            let appName = Bundle.main.infoDictionary!["CFBundleName"] ?? "Not A Bad Player"
            let alert = UIAlertController(title: "Error", message: "Media library access is required. Go to Settings -> \(appName) -> ALLOW Media & Apple Music.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                exit(0)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
