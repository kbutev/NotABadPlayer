//
//  AlertWindows.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 18.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class AlertWindows {
    public static let shared = AlertWindows()
    
    func show(sourceVC: UIViewController,
              withTitle title: String,
              withDescription description: String,
              actionText: String = "Ok",
              action: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: actionText, style: UIAlertAction.Style.default, handler: action))
        
        sourceVC.present(alert, animated: true, completion: nil)
    }
    
    func show(sourceVC: UIViewController,
              withTitle title: String,
              withDescription description: String,
              actionLeftText: String = "No",
              actionLeft: ((UIAlertAction) -> Void)? = nil,
              actionRightText: String = "Yes",
              actionRight: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: actionLeftText, style: UIAlertAction.Style.default, handler: actionLeft))
        alert.addAction(UIAlertAction(title: actionRightText, style: UIAlertAction.Style.default, handler: actionRight))
        
        sourceVC.present(alert, animated: true, completion: nil)
    }
}
